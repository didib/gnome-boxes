// This file is part of GNOME Boxes. License: LGPLv2+

using GVirConfig;

private class Boxes.InstalledMedia : Boxes.InstallerMedia {
    public const string[] supported_extensions = { ".qcow2", ".qcow2.gz",
                                                   ".qcow", ".qcow.gz",
                                                   ".img", ".img.gz",
                                                   ".cow", ".cow.gz",
                                                   ".vdi", ".vdi.gz",
                                                   ".vmdk", ".vmdk.gz",
                                                   ".vpc", ".vpc.gz",
                                                   ".cloop", ".cloop.gz" };
    private static Regex date_regex = /20[0-9]{6,6}/;

    public override bool need_user_input_for_vm_creation { get { return false; } }
    public override bool ready_to_create { get { return true; } }
    public override bool live { get { return false; } }

    protected override string? architecture {
        owned get {
            // Many distributors provide arch name on the image file so lets try to use that if possible
            if (device_file.contains ("amd64") || device_file.contains ("x86_64"))
                return "x86_64";
            else {
                string[] arch_list = { "i686", "i586", "i486", "i386" };
                foreach (var arch in arch_list) {
                    if (device_file.contains (arch))
                        return arch;
                }

                debug ("Failed to guess architecture for media '%s'.", device_file);
                return null;
            }
        }
    }

    public InstalledMedia (string path, bool known_qcow2 = false) throws GLib.Error {
        var supported = false;

        if (known_qcow2 || path.has_prefix ("/dev/"))
            supported = true; // Let's assume it's device file in raw format
        else
            foreach (var extension in supported_extensions) {
                supported = path.has_suffix (extension);
                if (supported)
                    break;
            }

        if (!supported)
            throw new IOError.NOT_SUPPORTED (_("Unsupported disk image format."));

        device_file = path;
        from_image = true;

        label_setup ();
    }

    public async InstalledMedia.guess_os (string path, MediaManager media_manager) throws GLib.Error {
        this (path);

        if (path.contains ("gnome-continuous") || path.contains ("gnome-ostree")) {
            try {
                os = yield media_manager.os_db.get_os_by_id ("http://gnome.org/continuous/3.10");
            } catch (OSDatabaseError.UNKNOWN_OS_ID error) {
                debug ("gnome-continuous definition not found in libosinfo db");
            } catch (OSDatabaseError error) {
                throw error;
            }
        }

        os = yield guess_os_from_filename (media_manager.os_db);
        resources = (os != null)? media_manager.os_db.get_resources_for_os (os, architecture) :
                                  OSDatabase.get_default_resources ();

        label_setup ();
    }

    // Also converts to native format (QCOW2)
    public async void copy (string destination_path) throws GLib.Error {
        var decompressed = yield decompress ();

        string[] argv = { "qemu-img", "convert", "-O", "qcow2", device_file, destination_path };

        var converting = !device_file.has_suffix (".qcow2");

        debug ("Copying '%s' to '%s'%s.",
               device_file,
               destination_path,
               converting? " while converting it to 'qcow2' format" : "");
        yield exec (argv, null);
        debug ("Finished copying '%s' to '%s'", device_file, destination_path);

        if (decompressed) {
            // We decompressed into a temporary location
            var file = File.new_for_path (device_file);
            delete_file (file);
        }
    }

    public override void setup_domain_config (Domain domain) {
        add_cd_config (domain, from_image? DomainDiskType.FILE : DomainDiskType.BLOCK, null, "hdc", false);
    }

    public override GLib.List<Pair<string,string>> get_vm_properties () {
        var properties = new GLib.List<Pair<string,string>> ();

        properties.append (new Pair<string,string> (_("System"), label));

        return properties;
    }


    public override VMCreator get_vm_creator () {
        return new VMImporter (this);
    }

    private async Osinfo.Os? guess_os_from_filename (OSDatabase os_db) throws OSDatabaseError {
        if (!device_file.contains ("gnome-continuous") && !device_file.contains ("gnome-ostree"))
            return null;

        var date = get_date_from_filename ();
        if (date == null) {
            try {
                // No date on filename means older gnome-continuous images and
                // hence more close to 3.10 than anything newer.
                return yield os_db.get_os_by_id ("http://gnome.org/continuous/3.10");
            } catch (OSDatabaseError.UNKNOWN_OS_ID error) {
                debug ("gnome-continuous definition not found in libosinfo db");

                return null;
            }
        }

        var os_list = yield os_db.list_os_by_distro ("gnome", date);
        if (os_list.length () > 0)
            return os_list.data;
        else
            return null;
    }

    private GLib.Date? get_date_from_filename () {
        GLib.MatchInfo match_info;

        date_regex.match (device_file, 0, out match_info);
        if (!match_info.matches ())
            return null;

        var date_str = match_info.fetch (0);
        var date = GLib.Date ();
        date.set_year ((GLib.DateYear) int.parse (date_str[0:4]));
        date.set_month ((GLib.DateMonth) int.parse (date_str[4:6]));
        date.set_day ((GLib.DateDay) int.parse (date_str[6:8]));

        return date;
    }

    private async bool decompress () throws GLib.Error {
        if (!device_file.has_suffix (".gz"))
            return false;

        var compressed = File.new_for_path (device_file);
        var input_stream = yield compressed.read_async ();

        var decompressed_path = Path.get_basename (device_file).replace (".gz", "");
        decompressed_path = get_user_pkgcache (decompressed_path);
        var decompressed = File.new_for_path (decompressed_path);
        GLib.OutputStream output_stream = yield decompressed.replace_async (null,
                                                                            false,
                                                                            FileCreateFlags.REPLACE_DESTINATION);
        var decompressor = new ZlibDecompressor (ZlibCompressorFormat.GZIP);
        output_stream = new ConverterOutputStream (output_stream, decompressor);

        debug ("Decompressing '%s'..", device_file);
        var buffer = new uint8[1048576];
        while (true) {
            var length = yield input_stream.read_async (buffer);
            if (length <= 0)
                break;

            ssize_t written = 0, i = 0;
            do {
                written = output_stream.write (buffer[i:length]);
                i += written;
            } while (i < length);
        }
        debug ("Decompressed '%s'.", device_file);

        device_file = decompressed_path;

        return true;
    }
}

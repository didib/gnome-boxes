NULL =
BUILT_SOURCES =
EXTRA_DIST =
MAINTAINERCLEANFILES = *.stamp

cachedir=/var/cache/
AM_CPPFLAGS =						\
	-include config.h				\
	-DGNOMELOCALEDIR=\""$(datadir)/locale"\"	\
	-DDATADIR=\""$(datadir)"\"			\
	-DCACHEDIR=\""$(cachedir)"\"			\
	$(DISABLE_DEPRECATED)				\
	-DG_LOG_DOMAIN=\""Boxes"\"			\
	-I$(top_srcdir)/libgd                           \
	$(NULL)

gresource_file = $(top_srcdir)/data/gnome-boxes.gresource.xml

AM_VALAFLAGS =						\
	--enable-experimental				\
	--target-glib=@GLIB_MIN_VERSION@		\
	--vapidir=$(srcdir)/				\
	--vapidir=$(top_srcdir)/libgd                   \
	--vapidir=$(top_srcdir)/vapi                    \
	--vapidir=$(top_srcdir)/vapi/upstream           \
	--pkg config					\
	--pkg common					\
	--pkg gd-1.0					\
	--pkg gdk-pixbuf-2.0				\
	--pkg gio-2.0-workaround			\
	--pkg glib-2.0					\
	--pkg gtk-vnc-2.0				\
	--pkg gudev-1.0					\
	--pkg libarchive				\
	--pkg libsoup-2.4				\
	--pkg libosinfo-1.0				\
	--pkg libvirt-gconfig-1.0			\
	--pkg libvirt-gobject-1.0			\
	--pkg libxml-2.0				\
	--pkg posix					\
	--pkg linux					\
	--pkg libusb-1.0				\
	--pkg spice-client-gtk-3.0			\
	--pkg tracker-sparql-$(TRACKER_VERSION)		\
	--pkg gmodule-2.0				\
	--gresources $(gresource_file)			\
	$(VALA_DEBUG_FLAGS)			        \
	$(NULL)

noinst_LIBRARIES = libcommon.a
libcommon_a_VALASOURCES =			\
	async-launcher.vala			\
	box-config.vala                         \
	collection-source.vala			\
	util.vala				\
	$(NULL)

libcommon_a_DEPENDENCIES =			\
	common.vapi				\
	libcommon.h				\
	libcommon_vala.stamp			\
	$(NULL)

libcommon_a_SOURCES =				\
	$(libcommon_a_VALASOURCES:.vala=.c)	\
	$(NULL)

libcommon_a_CFLAGS = $(BOXES_COMMON_CFLAGS)

libcommon_vala.stamp: $(libcommon_a_VALASOURCES)
	$(AM_V_VALAC)$(VALAC) $(VALAFLAGS) $(VALA_DEBUG_FLAGS)	\
	--enable-experimental					\
	--target-glib=@GLIB_MIN_VERSION@			\
	--vapidir=$(srcdir)/					\
	--pkg config						\
	--pkg glib-2.0						\
	--pkg gio-2.0						\
	--pkg libarchive					\
	-C -H libcommon.h --library common $^
	@touch $(libcommon_a_DEPENDENCIES)

common.vapi libcommon.h: libcommon_vala.stamp
$(libcommon_a_SOURCES): libcommon_vala.stamp

resource_files = $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies --sourcedir=$(top_srcdir)/data $(gresource_file))
resources.c: $(gresource_file) $(resource_files)
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --sourcedir=$(top_srcdir)/data --generate-source $<

MAINTAINERCLEANFILES += $(libcommon_a_SOURCES) $(libcommon_a_DEPENDENCIES)
BUILT_SOURCES += resources.c
EXTRA_DIST += $(libcommon_a_DEPENDENCIES) \
	      $(libcommon_a_VALASOURCES)  \
	      $(gresource_file)

bin_PROGRAMS = gnome-boxes

gnome_boxes_SOURCES =				\
	$(BUILT_SOURCES)			\
	app.vala				\
	app-window.vala				\
	actions-popover.vala			\
	archive-reader.vala			\
	archive-writer.vala			\
	auth-notification.vala			\
	collection.vala				\
	collection-filter-switcher.vala		\
	collection-toolbar.vala			\
	display-page.vala			\
	display-toolbar.vala			\
	display.vala				\
	editable-entry.vala			\
	i-properties-provider.vala		\
	i-collection-view.vala			\
	icon-view.vala				\
	installer-media.vala 			\
	installed-media.vala 			\
	keys-input-popover.vala			\
	libvirt-cloned-media.vala 		\
	libvirt-media.vala 			\
	iso-extractor.vala			\
	libvirt-broker.vala			\
	libvirt-machine.vala			\
	libvirt-machine-properties.vala		\
	list-view.vala				\
	list-view-row.vala			\
	machine.vala				\
	machine-thumbnailer.vala		\
	main.vala				\
	media-manager.vala 			\
	resource-graph.vala			\
	notification.vala			\
	notificationbar.vala			\
	os-database.vala 			\
	properties.vala				\
	properties-window.vala			\
	properties-page-widget.vala		\
	properties-toolbar.vala			\
	remote-machine.vala			\
	searchbar.vala				\
	selectionbar.vala			\
	selection-toolbar.vala			\
	spice-display.vala			\
	topbar.vala				\
	ui.vala					\
	unattended-installer.vala 		\
	unattended-file.vala 			\
	unattended-setup-box.vala 		\
	util-app.vala				\
	vm-configurator.vala 			\
	vm-creator.vala 			\
	vm-importer.vala 			\
	libvirt-system-importer.vala 		\
	libvirt-vm-cloner.vala 			\
	libvirt-vm-importer.vala 		\
	vnc-display.vala			\
	wizard-window.vala			\
	wizard-source.vala			\
	wizard-toolbar.vala			\
	wizard.vala				\
	downloader.vala				\
	empty-boxes.vala			\
	tracker-iso-query.vala			\
	troubleshoot-log.vala			\
	snapshot-list-row.vala 			\
	snapshots-property.vala 		\
	$(NULL)

gnome_boxes_LDADD =				\
	$(BOXES_LIBS)				\
	$(TRACKER_LIBS)				\
	$(top_builddir)/libgd/libgd.la		\
	libcommon.a				\
	$(NULL)

gnome_boxes_CFLAGS = $(BOXES_CFLAGS) $(TRACKER_CFLAGS)
$(srcdir)/gnome_boxes_vala.stamp: $(libcommon_a_DEPENDENCIES)

AM_VALAFLAGS += --pkg govirt-1.0 --pkg rest-0.7
if HAVE_OVIRT
gnome_boxes_SOURCES += ovirt-broker.vala ovirt-machine.vala
gnome_boxes_LDADD += $(OVIRT_LIBS)
gnome_boxes_CFLAGS += $(OVIRT_CFLAGS)
endif

MAINTAINERCLEANFILES += $(gnome_boxes_SOURCES:.vala=.c)

libexec_PROGRAMS = gnome-boxes-search-provider

gnome_boxes_search_provider_SOURCES =		\
	gnome-boxes-search-provider.vala	\
	$(NULL)

gnome_boxes_search_provider_LDADD = libcommon.a $(BOXES_COMMON_LIBS)
gnome_boxes_search_provider_CFLAGS = $(BOXES_COMMON_CFLAGS)
$(srcdir)/gnome_boxes_search_provider_vala.stamp: $(libcommon_a_DEPENDENCIES)

MAINTAINERCLEANFILES += $(gnome_boxes_search_provider_SOURCES:.vala=.c)

EXTRA_DIST += config.vapi

-include $(top_srcdir)/git.mk

AC_PREREQ([2.63])

AC_INIT([gnome-boxes],
        [m4_esyscmd(build-aux/git-version-gen .tarball-version)],
        [https://bugzilla.gnome.org/enter_bug.cgi?product=gnome-boxes],
        [gnome-boxes],
        [https://wiki.gnome.org/Apps/Boxes])
        # Each time the above URL changes, you gotta modify
        # vm-configurator:update_existing_domain() to keep handling old URLs

AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_AUX_DIR([build-aux])

AM_INIT_AUTOMAKE([1.11 dist-xz no-dist-gzip tar-ustar foreign -Wall -Werror subdir-objects -Wno-portability])
AM_MAINTAINER_MODE([enable])

AM_SILENT_RULES([yes])

# Check for programs
AC_PROG_CC
AM_PROG_CC_C_O
AC_PROG_CXX
AM_PROG_AR
AC_CHECK_TOOL([DESKTOP_FILE_VALIDATE], [desktop-file-validate], [/bin/true])

# Initialize libtool
LT_PREREQ([2.2])
LT_INIT([disable-static])

# Pkg-config
PKG_PROG_PKG_CONFIG([0.22])

# i18 support
IT_PROG_INTLTOOL(0.40.0)

GETTEXT_PACKAGE=AC_PACKAGE_NAME
AC_SUBST(GETTEXT_PACKAGE)
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE,"$GETTEXT_PACKAGE",[The name of the gettext domain])

# GObject-introspection support
GOBJECT_INTROSPECTION_REQUIRE([0.9.6])

# Mallard help
YELP_HELP_INIT

# GResource
AC_PATH_PROG(GLIB_COMPILE_RESOURCES, glib-compile-resources)

# GSettings support
GLIB_GSETTINGS

GLIB_MIN_VERSION=2.38.0
AC_SUBST(GLIB_MIN_VERSION)
GOBJECT_INTROSPECTION_MIN_VERSION=0.9.6
GOVIRT_MIN_VERSION=0.2.0
GTK_MIN_VERSION=3.19.8
GTK_VNC_MIN_VERSION=0.4.4
LIBVIRT_GLIB_MIN_VERSION=0.2.3
LIBVIRT_GCONFIG_MIN_VERSION=0.2.0
LIBXML2_MIN_VERSION=2.7.8
LIBUSB_MIN_VERSION=1.0.9
SPICE_GTK_MIN_VERSION=0.27
GUDEV_MIN_VERSION=165
OSINFO_MIN_VERSION=0.2.12
TRACKER_SPARQL=0.13.1
UUID_REQUIRED=1.41.3
LIBSOUP_REQUIRED=2.38
LIBARCHIVE_MIN_VERSION=3.0.0

PKG_CHECK_MODULES(BOXES, [
  glib-2.0 >= $GLIB_MIN_VERSION
  gobject-introspection-1.0 >= $GOBJECT_INTROSPECTION_MIN_VERSION
  gtk+-3.0 >= $GTK_MIN_VERSION
  gtk-vnc-2.0 >= $GTK_VNC_MIN_VERSION
  libvirt-gobject-1.0 >= $LIBVIRT_GLIB_MIN_VERSION
  libvirt-gconfig-1.0 >= $LIBVIRT_GCONFIG_MIN_VERSION
  libxml-2.0 >= $LIBXML2_MIN_VERSION
  libusb-1.0 >= $LIBUSB_MIN_VERSION
  spice-client-gtk-3.0 >= $SPICE_GTK_MIN_VERSION
  gudev-1.0 >= $GUDEV_MIN_VERSION
  libosinfo-1.0 >= $OSINFO_MIN_VERSION
  uuid >= $UUID_REQUIRED
  libsoup-2.4 >= $LIBSOUP_REQUIRED
  libarchive >= $LIBARCHIVE_MIN_VERSION
])


PKG_CHECK_MODULES(TRACKER, [tracker-sparql-1.0 >= $TRACKER_SPARQL], [TRACKER_VERSION=1.0] ,
   [PKG_CHECK_MODULES(TRACKER, [tracker-sparql-0.18 >= $TRACKER_SPARQL], [TRACKER_VERSION=0.18] ,
      [PKG_CHECK_MODULES(TRACKER, [tracker-sparql-0.16 >= $TRACKER_SPARQL], [TRACKER_VERSION=0.16] ,
         [PKG_CHECK_MODULES(TRACKER, [tracker-sparql-0.14 >= $TRACKER_SPARQL], [TRACKER_VERSION=0.14])])])]
)
AC_SUBST(TRACKER_VERSION)


VALA_ADD_CHECKFILE([src/gnome_boxes_vala.stamp])

PKG_CHECK_MODULES(BOXES_COMMON, [
  glib-2.0 >= $GLIB_MIN_VERSION
  gio-2.0 >= $GLIB_MIN_VERSION
  libarchive >= $LIBARCHIVE_MIN_VERSION
])

VALA_ADD_CHECKFILE([src/libcommon_vala.stamp])
VALA_ADD_CHECKFILE([src/gnome_boxes_search_provider_vala.stamp])

VALA_ADD_CHECKFILE([libgd/gd-1.0.vapi])

AC_ARG_ENABLE(ovirt,
              AS_HELP_STRING([--enable-ovirt=yes|no|auto], [Enable support for OVirt]),
              [enable_ovirt=$enableval],
              [enable_ovirt=auto])
case "x$enable_ovirt" in
  xyes)
    PKG_CHECK_MODULES(OVIRT, [govirt-1.0 >= $GOVIRT_MIN_VERSION])
    have_govirt="yes"
    ;;
  xauto)
    PKG_CHECK_MODULES(OVIRT, [govirt-1.0 >= $GOVIRT_MIN_VERSION],
                      [have_govirt=yes], [have_govirt=no])
    ;;
  xno)
    have_govirt="xno"
    ;;
  x*)
    AC_MSG_ERROR([Unknown --enable-ovirt argument: $enable_ovirt])
    ;;
esac
if test "x$have_govirt" = "xyes"; then
  AC_DEFINE([HAVE_OVIRT], [1], [Build with oVirt support?])
else
  AC_DEFINE([HAVE_OVIRT], [0], [Build with oVirt support?])
fi
AM_CONDITIONAL([HAVE_OVIRT], [test "x$have_govirt" = "xyes"])

VALA_CHECK([0.28.0.16], [
  gdk-pixbuf-2.0
  glib-2.0
  gtk+-3.0
  gtk-vnc-2.0
  gudev-1.0
  libarchive
  libosinfo-1.0
  libsoup-2.4
  libvirt-gconfig-1.0
  libvirt-gobject-1.0
  libxml-2.0
  posix
  rest-0.7
  libusb-1.0
  spice-client-gtk-3.0
])

dnl libgd
LIBGD_INIT([
  gtk-hacks
  main-view
  main-icon-view
  notification
  static
  vapi
])

dnl Strict compiler
AC_ARG_ENABLE([strict-cc],
  AS_HELP_STRING([--enable-strict-cc],[Enable strict C compiler]))

AS_IF([test "x$enable_strict_cc" = "xyes"], [CFLAGS="$CFLAGS -Wall -Werror"],
      [CFLAGS="$CFLAGS -w"])

dnl Debugging
AC_ARG_ENABLE(debug,
	AS_HELP_STRING([--enable-debug],[enable debugging]),,
        enable_debug=no)
if test "x$enable_debug" = "xyes"; then
        CFLAGS="$CFLAGS -O0 -ggdb3"
        VALA_DEBUG_FLAGS="-g"
fi

AC_SUBST(VALA_DEBUG_FLAGS)

dnl Installed tests
BEHAVE_INSTALLED_TESTS

AC_CONFIG_FILES([
  Makefile
  data/Makefile
  data/org.gnome.Boxes.desktop.in
  data/icons/Makefile
  data/osinfo/Makefile
  help/Makefile
  libgd/Makefile
  po/Makefile.in
  src/Makefile
  vapi/Makefile
  vapi/upstream/Makefile
])

AC_OUTPUT

dnl ==========================================================================
AC_MSG_NOTICE([

        GNOME Boxes $VERSION
        =================

        prefix:                   ${prefix}
        c compiler:               ${CC} ${CFLAGS}
        build from vala sources:  $enable_vala
        oVirt support:            $have_govirt
        Installed tests:          $enable_installed_tests
])

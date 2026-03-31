SUMMARY = "AGL GSoC 2026 Quiz App"
DESCRIPTION = "A Flutter application for AGL that displays AGL version, \
developer name, and provides buttons to show a picture and play a sound."
AUTHOR = "Anandu"
HOMEPAGE = "https://github.com/anandu-pn/meta-agl-anandu-"
SECTION = "graphics"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d41d8cd98f00b204e9800998ecf8427e"

SRC_URI = "git://github.com/anandu-pn/agl-quiz-app.git;protocol=https;branch=main"
SRCREV = "${AUTOREV}"

S = "${WORKDIR}/git"

# Inherit the flutter-app class from meta-flutter
inherit flutter-app

# Path to the flutter project within the source
FLUTTER_APPLICATION_PATH = "${S}"

# Build configuration
FLUTTER_BUILD_ARGS = "bundle"

# Runtime dependencies
RDEPENDS:${PN} += " \
    flutter-auto \
"

# Install additional assets
do_install:append() {
    # Ensure assets directory exists in target
    install -d ${D}${datadir}/${PN}/assets/
}

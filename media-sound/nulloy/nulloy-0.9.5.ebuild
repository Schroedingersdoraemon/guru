# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit xdg

DESCRIPTION="Music player with a waveform progress bar (sound visualization like in audio editors)"
HOMEPAGE="https://nulloy.com"

NAME="nulloy-theme-night-v1.0"
SRC_URI="https://github.com/nulloy/nulloy/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
	skins? ( https://gitlab.com/vitaly-zdanevich/nulloy-theme-night/-/archive/v1.0/${NAME}.tar.gz )"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+skins"

BDEPEND="
	dev-qt/linguist-tools
	app-arch/zip
"

DEPEND="
	dev-qt/qtcore
	dev-qt/designer
	dev-qt/qtsvg
	dev-qt/linguist
	dev-qt/qtscript
	dev-qt/qtx11extras
	media-libs/gstreamer
	media-libs/gst-plugins-base
	media-libs/taglib
	media-plugins/gst-plugins-meta
"
RDEPEND="${DEPEND}"

src_prepare() {
	if use skins ; then
		eapply "${FILESDIR}"/add-dark-theme.patch

		cp -r $WORKDIR/$NAME src/skins/night
	fi

	default
}

src_configure() {
	# Upstream ./configure script does not support specifying an option's
	# value after an equal sign like in '--prefix="${EPREFIX}/usr"', so we
	# have to set up all the options ourselves and call the script directly
	local myconfargs=(
		$(use skins || echo --no-skins)
		--no-update-check
		--gstreamer-tagreader
		--prefix "${EPREFIX}/usr"
		--libdir "$(get_libdir)"
	)

	QMAKE=/usr/bin/qmake5 LRELEASE=/usr/lib64/qt5/bin/lrelease ./configure "${myconfargs[@]}" || die

	# Because stripping should not be done by the build tools,
	# because Portage does it when the install phase is run to be able
	# to support the `splitdebug` and `installsources` FEATURES.
	# See related issue https://bugs.gentoo.org/856292
	echo "CONFIG += nostrip" >> $WORKDIR/$P/.qmake.cache
}

src_install() {
	emake INSTALL_ROOT="${D}" install
	einstalldocs
}

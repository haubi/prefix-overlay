# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/ffmpeg/ffmpeg-0.5_p20373.ebuild,v 1.8 2010/01/09 15:32:38 fauli Exp $

EAPI=2
SCM=""
if [ "${PV#9999}" != "${PV}" ] ; then
	SCM=subversion
	ESVN_REPO_URI="svn://svn.ffmpeg.org/ffmpeg/trunk"
fi

inherit eutils flag-o-matic multilib toolchain-funcs ${SCM}

DESCRIPTION="Complete solution to record, convert and stream audio and video. Includes libavcodec."
HOMEPAGE="http://ffmpeg.org/"
if [ "${PV#9999}" != "${PV}" ] ; then
	SRC_URI=""
elif [ "${PV%_p*}" != "${PV}" ] ; then # Snapshot
	SRC_URI="mirror://gentoo/${P}.tar.bz2"
else # Release
	SRC_URI="http://ffmpeg.org/releases/${P}.tar.bz2"
fi
FFMPEG_REVISION="${PV#*_p}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="+3dnow +3dnowext alsa altivec cpudetection custom-cflags debug dirac
	  doc ieee1394 +encode faac faad gsm ipv6 jack +mmx +mmxext vorbis test
	  theora threads x264 xvid network zlib sdl X mp3 opencore-amr
	  oss pic schroedinger +hardcoded-tables bindist v4l v4l2
	  speex +ssse3 jpeg2k vdpau"

VIDEO_CARDS="nvidia"

for x in ${VIDEO_CARDS}; do
	IUSE="${IUSE} video_cards_${x}"
done

RDEPEND="sdl? ( >=media-libs/libsdl-1.2.10 )
	alsa? ( media-libs/alsa-lib )
	encode? (
		faac? ( media-libs/faac )
		mp3? ( media-sound/lame )
		vorbis? ( media-libs/libvorbis media-libs/libogg )
		theora? ( media-libs/libtheora[encode] media-libs/libogg )
		x264? ( >=media-libs/x264-0.0.20091021 )
		xvid? ( >=media-libs/xvid-1.1.0 ) )
	faad? ( >=media-libs/faad2-2.6.1 )
	zlib? ( sys-libs/zlib )
	ieee1394? ( media-libs/libdc1394
				sys-libs/libraw1394 )
	dirac? ( media-video/dirac )
	gsm? ( >=media-sound/gsm-1.0.12-r1 )
	jpeg2k? ( >=media-libs/openjpeg-1.3-r2 )
	opencore-amr? ( media-libs/opencore-amr )
	schroedinger? ( media-libs/schroedinger )
	speex? ( >=media-libs/speex-1.2_beta3 )
	jack? ( media-sound/jack-audio-connection-kit )
	X? ( x11-libs/libX11 x11-libs/libXext )
	video_cards_nvidia? (
		vdpau? ( >=x11-drivers/nvidia-drivers-180.29 )
	)"

DEPEND="${RDEPEND}
	>=sys-devel/make-3.81
	mmx? ( dev-lang/yasm )
	doc? ( app-text/texi2html )
	test? ( net-misc/wget )
	v4l? ( sys-kernel/linux-headers )
	v4l2? ( sys-kernel/linux-headers )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-0.4.9_p20090201-solaris.patch
	epatch "${FILESDIR}"/${PN}-0.4.9_p20090201-apple.patch
	[[ ${CHOST} == *-freebsd7* ]] && \
		epatch "${FILESDIR}"/${PN}-0.4.9_p20090201-freebsd7.patch
	# /bin/sh on at least Solaris can't cope very will with these scripts
	sed -i -e '1c\#!/usr/bin/env sh' configure version.sh || die
}

src_prepare() {
	if [[ ${PV} = *9999* ]]; then
		# Set SVN version manually
		subversion_wc_info
		sed -i s/UNKNOWN/SVN-r${ESVN_WC_REVISION}/ "${S}/version.sh"
	elif [ "${PV%_p*}" != "${PV}" ] ; then # Snapshot
		sed -i s/UNKNOWN/SVN-r${FFMPEG_REVISION}/ "${S}/version.sh"
	fi
}

src_configure() {
	local myconf="${EXTRA_FFMPEG_CONF}"

	# enabled by default
	use debug || myconf="${myconf} --disable-debug"
	use zlib || myconf="${myconf} --disable-zlib"
	use sdl || myconf="${myconf} --disable-ffplay"

	if use network; then
		use ipv6 || myconf="${myconf} --disable-ipv6"
	else
		myconf="${myconf} --disable-network"
	fi

	use custom-cflags && myconf="${myconf} --disable-optimizations"
	use cpudetection && myconf="${myconf} --enable-runtime-cpudetect"

	# enabled by default
	if use encode
	then
		use mp3 && myconf="${myconf} --enable-libmp3lame"
		use vorbis && myconf="${myconf} --enable-libvorbis"
		use theora && myconf="${myconf} --enable-libtheora"
		use x264 && myconf="${myconf} --enable-libx264"
		use xvid && myconf="${myconf} --enable-libxvid"
	else
		myconf="${myconf} --disable-encoders"
	fi

	# libavdevice options
	use ieee1394 && myconf="${myconf} --enable-libdc1394"
	# Indevs
	for i in v4l v4l2 alsa oss jack ; do
		use $i || myconf="${myconf} --disable-indev=$i"
	done
	# Outdevs
	for i in alsa oss ; do
		use $i || myconf="${myconf} --disable-outdev=$i"
	done
	use X && myconf="${myconf} --enable-x11grab"

	# Threads; we only support pthread for now but ffmpeg supports more
	use threads && myconf="${myconf} --enable-pthreads"

	# Decoders
	use opencore-amr && myconf="${myconf} --enable-libopencore-amrwb
		--enable-libopencore-amrnb"
	for i in faad dirac schroedinger speex; do
		use $i && myconf="${myconf} --enable-lib$i"
	done
	use jpeg2k && myconf="${myconf} --enable-libopenjpeg"
	if use gsm; then
		myconf="${myconf} --enable-libgsm"
		# Crappy detection or our installation is weird, pick one (FIXME)
		append-flags -I"${EPREFIX}"/usr/include/gsm
	fi
	if use bindist
	then
		use faac && ewarn "faac is nonfree and cannot be distributed; disabling
		faac support."
	else
		use faac && myconf="${myconf} --enable-libfaac"
		{ use faac ; } && myconf="${myconf} --enable-nonfree"
	fi

	#for i in h264_vdpau mpeg1_vdpau mpeg_vdpau vc1_vdpau wmv3_vdpau; do
	#	use video_cards_nvidia || myconf="${myconf} --disable-decoder=$i"
	#	use vdpau || myconf="${myconf} --disable-decoder=$i"
	#done
	use video_cards_nvidia || myconf="${myconf} --disable-vdpau"
	use vdpau || myconf="${myconf} --disable-vdpau"

	# CPU features
	for i in mmx ssse3 altivec ; do
		use $i ||  myconf="${myconf} --disable-$i"
	done
	use mmxext || myconf="${myconf} --disable-mmx2"
	use 3dnow || myconf="${myconf} --disable-amd3dnow"
	use 3dnowext || myconf="${myconf} --disable-amd3dnowext"
	# disable mmx accelerated code if PIC is required
	# as the provided asm decidedly is not PIC.
	if gcc-specs-pie ; then
		myconf="${myconf} --disable-mmx --disable-mmx2"
	fi

	# Option to force building pic
	use pic && myconf="${myconf} --enable-pic"

	# Try to get cpu type based on CFLAGS.
	# Bug #172723
	# We need to do this so that features of that CPU will be better used
	# If they contain an unknown CPU it will not hurt since ffmpeg's configure
	# will just ignore it.
	for i in $(get-flag march) $(get-flag mcpu) $(get-flag mtune) ; do
		[ "${i}" = "native" ] && i="host" # bug #273421
		myconf="${myconf} --cpu=$i"
		break
	done

	# Mandatory configuration
	myconf="${myconf} --enable-gpl --enable-version3 --enable-postproc \
			--enable-avfilter --enable-avfilter-lavf \
			--disable-stripping"

	# cross compile support
	if tc-is-cross-compiler ; then
		myconf="${myconf} --enable-cross-compile --arch=$(tc-arch-kernel) --cross-prefix=${CHOST}-"
		case ${CHOST} in
			*freebsd*)
				myconf="${myconf} --target-os=freebsd"
				;;
			mingw32*)
				myconf="${myconf} --target-os=mingw32"
				;;
			*linux*)
				myconf="${myconf} --target-os=linux"
				;;
		esac
	fi

	# Misc stuff
	use hardcoded-tables && myconf="${myconf} --enable-hardcoded-tables"

	# Specific workarounds for too-few-registers arch...
	if [[ $(tc-arch) == "x86" || $(tc-arch) == x86-* ]]; then
		filter-flags -fforce-addr -momit-leaf-frame-pointer
		append-flags -fomit-frame-pointer
		is-flag -O? || append-flags -O2
		if (use debug); then
			# no need to warn about debug if not using debug flag
			ewarn ""
			ewarn "Debug information will be almost useless as the frame pointer is omitted."
			ewarn "This makes debugging harder, so crashes that has no fixed behavior are"
			ewarn "difficult to fix. Please have that in mind."
			ewarn ""
		fi
	fi

	local arch=${CHOST%%-*}
	# Gentoo Linux ppc64 has powerpc64-* CHOST, but configure doesn't get that
	[[ ${arch} == powerpc64 ]] && arch=ppc64

	# http://lists.mplayerhq.hu/pipermail/mplayer-dev-eng/2009-July/061865.html
	[[ ${CHOST} == *-solaris* ]] &&
		append-flags -Wa,--divide

	cd "${S}"
	./configure \
		--prefix="${EPREFIX}"/usr \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--shlibdir="${EPREFIX}"/usr/$(get_libdir) \
		--mandir="${EPREFIX}"/usr/share/man \
		--enable-static --enable-shared \
		--arch=${CHOST%%-*} \
		--cc="$(tc-getCC)" \
		${myconf} || die "configure failed"
}

src_compile() {
	emake version.h || die #252269
	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Install Failed"

	dodoc Changelog README INSTALL
	dodoc doc/*
}

src_test() {
	if use encode ; then
		for t in codectest lavftest seektest ; do
			LD_LIBRARY_PATH="${S}/libpostproc:${S}/libswscale:${S}/libavcodec:${S}/libavdevice:${S}/libavfilter:${S}/libavformat:${S}/libavutil" \
				emake ${t} || die "Some tests in ${t} failed"
		done
	else
		ewarn "Tests fail without USE=encode, skipping"
	fi
}

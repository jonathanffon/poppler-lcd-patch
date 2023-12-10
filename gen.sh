#!/bin/bash
pkgver=23.12.0
root=$PWD/poppler-${pkgver}
outd=~/.config/poppler-lcd
entryd=/usr/share/applications

# download poppler package
if [ ! -f poppler-${pkgver}.tar.xz -a -z "$1" ]; then
	echo "download poppler package ..."
	curl -O https://poppler.freedesktop.org/poppler-${pkgver}.tar.xz
fi

# apply subpixel rendering patches
if [ ! -d $root -a -z "$1" ]; then
	echo "extract source package and apply patches ..."
	tar xf poppler-${pkgver}.tar.xz
	cd $root
	for patch in $(ls ../*.patch); do
		patch -p1 <$patch
	done
fi

# build libraries. (Please install some prerequisites first)
if [ ! -f $root/build/libpoppler.so -a -z "$1" ]; then
	mkdir -p $root/build && cd $_
	cmake ../ -DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX:PATH=/usr \
		-DCMAKE_INSTALL_LIBDIR=/usr/lib \
		-DENABLE_UNSTABLE_API_ABI_HEADERS=ON \
		-DENABLE_GTK_DOC=ON
	make
	echo "output patched libraries to user directory"
	mkdir -p $outd
	cp $root/build/libpoppler.so $outd
	cp $root/build/glib/libpoppler-glib.so $outd
	cp $root/build/qt5/src/libpoppler-qt5.so $outd
	cp $root/build/qt6/src/libpoppler-qt6.so $outd
	gcc -xc++ -shared -fPIC -fno-inline \
		$root/../backend-patch.cpp -o $outd/backend-patch.so
fi

T=$outd/backend-patch.so
P=$outd/libpoppler.so
G=$outd/libpoppler-glib.so
Q5=$outd/libpoppler-qt5.so
Q6=$outd/libpoppler-qt6.so

# modify desktop entries. usage: `bash gen.sh [inject|unload]`
#   inject: add preload libraries; unload: use original libraries
apps=("texstudio tex $T:$Q6" "org.gnome.Evince evi $G"
	"org.kde.okular oku $Q5" "org.pwmt.zathura zat $G")
if [ "$1" == "inject" ]; then
	for app in "${apps[@]}"; do
		et=($app) && nm=${et[@]:0:1} && tag=${et[@]:1:1} && lib=${et[@]:2:1}
		if [ -f $entryd/$nm.desktop ]; then
			echo "add preload libraries to $nm.desktop ..."
			sudo sed -i "s#^Exec=$tag#Exec=LD_PRELOAD=$lib:$P $tag#" $entryd/$nm.desktop
		fi
	done
elif [ "$1" == "unload" ]; then
	for app in "${apps[@]}"; do
		et=($app) && nm=${et[@]:0:1} && tag=${et[@]:1:1} && lib=${et[@]:2:1}
		if [ -f $entryd/$nm.desktop ]; then
			echo "recover original $nm.desktop ..."
			sudo sed -i "s#^Exec=.*$tag#Exec=$tag#" $entryd/$nm.desktop
		fi
	done
fi

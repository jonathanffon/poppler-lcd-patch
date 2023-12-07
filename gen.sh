#!/bin/bash
pkgver=23.12.0
root=$PWD/poppler-${pkgver}
outd=~/.config/poppler-lcd
entryd=/usr/share/applications

# download poppler package
if [ ! -f poppler-${pkgver}.tar.xz ]; then
	curl -O https://poppler.freedesktop.org/poppler-${pkgver}.tar.xz
fi

# apply subpixel rendering patches
if [ ! -d $root ]; then
	tar xf poppler-${pkgver}.tar.xz
	cd $root
	for patch in $(ls ../*.patch); do
		patch -p1 <$patch
	done
fi

# build libraries. (Please install some prerequisites first)
if [ ! -f $root/build/libpoppler.so ]; then
	mkdir -p $root/build && cd $_
	cmake ../ -DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_INSTALL_PREFIX:PATH=/usr \
		-DCMAKE_INSTALL_LIBDIR=/usr/lib \
		-DENABLE_UNSTABLE_API_ABI_HEADERS=ON \
		-DENABLE_GTK_DOC=ON
	make
fi

# output patched libraries to user directory
mkdir -p $outd
cp $root/build/libpoppler.so $outd
cp $root/build/glib/libpoppler-glib.so $outd
cp $root/build/qt5/src/libpoppler-qt5.so $outd
cp $root/build/qt6/src/libpoppler-qt6.so $outd
gcc -xc++ -shared -fPIC -fno-inline \
	backend-patch.cpp -o $outd/backend-patch.so

# patch desktop entries
if [ "$1" == "install" ]; then
	T=$outd/backend-patch.so
	P=$outd/libpoppler.so
	G=$outd/libpoppler-glib.so
	Q5=$outd/libpoppler-qt5.so
	Q6=$outd/libpoppler-qt6.so
	if [ -f $entryd/texstudio.desktop ]; then
		sudo sed -i "s#^Exec=tex#Exec=LD_PRELOAD=$T:$Q6:$P tex#" $entryd/texstudio.desktop
	fi
	if [ -f $entryd/org.gnome.Evince.desktop ]; then
		sudo sed -i "s#^Exec=evi#Exec=LD_PRELOAD=$G:$P evi#" $entryd/org.gnome.Evince.desktop
	fi
	if [ -f $entryd/org.kde.okular.desktop ]; then
		sudo sed -i "s#^Exec=oku#Exec=LD_PRELOAD=$Q5:$P oku#" $entryd/org.kde.okular.desktop
	fi
fi

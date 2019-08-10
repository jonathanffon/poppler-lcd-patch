# poppler-lcd-patch

PDF rendering library with subpixel engine.

The goal is to increase the apparent resolution of PDF content on LCD laptop.

## Features
- Embed subpixel rendering into Cairo font engine of `poppler` and `poppler-glib`. Add Cairo backend to `poppler-qt5`.
- Grant subpixel smoothing ability to poppler-based PDF viewers, such as Evince, Okular and TeXstudio, without contaminating their source code.

## Install from Arch Linux

Suppose you have `yay` as Pacman wrapper and *AUR* helper.

``` bash
yay -S poppler-lcd poppler-glib-lcd poppler-qt5-lcd
```
If you have a different version of `poppler` installed, you may encounter dependency issues. Try `yay -Sd ${pkgname}` to ignore them.

## Supported Frontends
- [x] Document Viewer (Evince)

- [x] Okular

- [x] TeXstudio

  ...

  > TeXstudio sets splash as its default rendering backend. In order to use Cairo subpixel backend without patching TeXstudio, we can nullify its backend setting by fabricating and injecting a preload library as follows:
  >
  > ``` bash
  > D="#define _ setRenderBackend(RenderBackend)\n"
  > N="namespace Poppler{struct Document{enum RenderBackend{};void _;};void Document::_{}}"
  > F="$HOME/.config/texstudio/injct.so"
  > echo $D$N|gcc -xc++ -shared -fPIC -fno-inline -o $F -
  > sudo sed -i "s#Exec=tex#Exec=LD_PRELOAD=$F tex#" /usr/share/applications/texstudio.desktop
  > ```
  > TeXstudio started by the modified ".desktop" file will be subpixel enabled.
  > 

## Build from source
- Download desired poppler version (e.g. pkgver=0.79.0) from [freedesktop website](https://poppler.freedesktop.org/) .
- Pull poppler source patches from this repo.
``` bash
wget https://poppler.freedesktop.org/poppler-${pkgver}.tar.xz
git clone https://github.com/jonathanffon/poppler-lcd-patch.git
tar -xJf poppler-${pkgver}.tar.xz
mkdir -p build
cd poppler-${pkgver}
for patch in `ls ../poppler-lcd-patch/*.patch`; do
  patch -p1<$patch
done
cd ../build
cmake ../poppler-${pkgver} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=/usr \
  -DCMAKE_INSTALL_LIBDIR=/usr/lib \
  -DENABLE_UNSTABLE_API_ABI_HEADERS=ON \
  -DENABLE_GTK_DOC=ON
make
```

## Screenshot
![before and after subpixel rendering](https://github.com/jonathanffon/poppler-lcd-patch/blob/master/img/compare.png)

## History

PDF viewers on Linux laptop won't render fonts smoothly due to the lack of subpixel hinting.

The issue was submitted 13 years ago by Ernst Sjöstrand ([Issue 61](https://gitlab.freedesktop.org/poppler/poppler/issues/61)). Anders Kaseorg provided a 10-line patch that forced subpixel rendering on Cairo and some image comparison showed great improvements. Then Paul Gideon Dann created a patch for Poppler-0.14 and Vladimir's for Poppler-0.22.

About 9 years ago, Paul requested a Cairo backend for Poppler's Qt4 wrapper, to which the maintainer Albert Astals Cid said no lest someone may complain about a new subpixel functionality ([Issue 435](https://gitlab.freedesktop.org/poppler/poppler/issues/435)).

Two years ago, Yichao Zhou proposed a patch of subpixel rendering support for Poppler-0.43 ([Issue 23](https://gitlab.freedesktop.org/poppler/poppler/issues/23)). It was reviewed by Adrian Johnson but he didn't seem to be willing to accept it.

Nowadays, [Zhou's patch](https://github.com/zhou13/poppler-subpixel) won't work for Poppler>0.43 and [Paul's patch](https://github.com/giddie/poppler-cairo-backend) is still under maintainance for the latest poppler version. Paul's patch has the following disadvantages:

1. subpixel rendering wrapper for glib is so incomplete that any poppler-glib based frontend (e.g. evince) has to be patched to enable subpixel rendering.
2. Cairo compositing operator used for Type 3 fonts is controlled inexplicitly by switching off subpixel antialias.

Recently, based on the work of Paul and Zhou, I have rewritten the subpixel patch to provide subpixel functionality to PDF viewers without patching their own source code.

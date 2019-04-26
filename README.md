# poppler-lcd-patch
PDF rendering library with sub-pixel engine.
The goal is to increase the apparent resolution of PDF content on LCD laptop.

## Features
- Embed sub-pixel rendering into Cairo font engine of `poppler` and `poppler-glib`. Add Cairo backend to `poppler-qt5`.
- Grant sub-pixel smoothing ability to poppler-based PDF viewers, such as Evince, Okular and TeXstudio, without contaminating their source code.

## Install from Arch Linux

Suppose you have `yay` as Pacman wrapper and *AUR* helper.

``` bash
yay -S poppler-lcd poppler-glib-lcd poppler-qt5-lcd
```
If you have a different version of `poppler` installed, you may encounter dependency issues. Try `yay -Sd ${pkgname}` to ignore them.

## Supported Frontend
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
- Download desired poppler version (e.g. pkgver=0.76.0) from [freedesktop website](https://poppler.freedesktop.org/) .
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

## Screenshots
![before and after subpixel rendering](https://github.com/jonathanffon/poppler-lcd-patch/blob/master/img/compare.png)

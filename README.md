# poppler-lcd-patch
PDF rendering library with sub-pixel engine.
The goal is to increase the apparent resolution of PDF content on LCD display.

## Features
- Embed sub-pixel rendering into Cairo font engine.
- Enable sub-pixel in `poppler-glib` and `poppler-qt5`. Those PDF viewers that depend on them, such as evince, okular and texstudio, will have hinting effects without being contaminated.

## Build from source
- Download desired poppler version (e.g. pkgver=0.76.0) from [freedesktop website](https://poppler.freedesktop.org/) .
- Pull poppler source patches in this repo.
```
mkdir -p build
cd poppler-${pkgver}
for patch in `ls ../*.patch`; do
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
## Effects
![before and after subpixel rendering](https://github.com/jonathanffon/poppler-lcd-patch/blob/master/img/compare.png)

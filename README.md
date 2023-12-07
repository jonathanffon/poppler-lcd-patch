# poppler-lcd-patch

PDF rendering library with subpixel engine.

The goal is to increase the apparent resolution of PDF content on LCD laptop.

## Features

- Embed subpixel rendering into Cairo font engine of `poppler` and `poppler-glib`.
- Add Cairo backend to `poppler-qt5` and `poppler-qt6`.
- Grant subpixel smoothing to poppler-based PDF viewers (Evince, Okular, TeXstudio...)

## Build & Install

### Prerequisites

Suppose you are using Arch Linux. Those packages are needed to compile poppler:
'libjpeg' 'gcc-libs' 'cairo' 'fontconfig' 'openjpeg2' 'gtk3' 'pkgconfig' 'lcms2'
'gobject-introspection' 'icu' 'qt5-base' 'qt6-base' 'git' 'nss' 'gpgme' 'gtk-doc'
'curl' 'cmake' 'python' 'boost'

```bash
pacman -S libjpeg-turbo gcc-libs cairo fontconfig openjpeg2 gtk3 pkgconf lcms2 gobject-introspection icu qt5-base qt6-base git nss gpgme gtk-doc curl cmake python boost
```

### Build from source

A script was provided to build necessary shared libraries. They will be copied to `~/.config/poppler-lcd` folder.

```bash
bash gen.sh
```

### Install

Sudoer's password is required. Desktop entries (\*.desktop) will be modified to preload patched libraries.

```bash
bash gen.sh install
```

If you don't want to modify system desktop entries directly, copy them to `~/.local/share/application` and modify them as you wish.

> Take okular for example. Find the line `Exec=okular %U` and replace it with:
> `Exec=LD_PRELOAD=${pathto}/libpoppler-qt5.so:${pathto}/libpoppler.so okular %U`
> Use your customized desktop entry instead.

## Supported Frontends

- [x] Document Viewer (Evince)

- [x] Okular

- [x] TeXstudio

  ...

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

Based on the work of Paul and Zhou, I have rewritten the subpixel patch to provide subpixel functionality to PDF viewers without patching their own source code.

At one time, I tried to maintain a package in Arch User Repository(AUR) that provided a subpixel-hinting version of poppler. However, it might lead to broken package dependencies.

Finally, DLL injection was choosed to introduce subpixel rendering for PDF viewers. The trick can be used on various Linux Distros and won't affect system files except for the `*.desktop` launcher.

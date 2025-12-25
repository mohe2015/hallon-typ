# hallon

A collection of utility functions for Typst.

## Named references example

See [example/example-nameref.typ](example/example-nameref.typ).

![Named references example](example/example-nameref.png)

## Subfigures example

See [example/example-subfig.typ](example/example-subfig.typ).

![Subfigures example](example/example-subfig.png)

## Heading-dependent numbering of figures

See [example/example-figs.typ](example/example-figs.typ).

![Heading-dependent numbering of figures](example/example-figs.png)

See [example/example-appendix.typ](example/example-appendix.typ).

![Heading-dependent numbering of figures with appendices](example/example-appendix.png)

## Custom figure and subfigure caption style

See [example/example-custom-caption.typ](example/example-custom-caption.typ).

![Custom figure and subfigure caption style](example/example-custom-caption.png)

## Etymology

Hallon (`ˈhàlɔn`) means raspberry in Swedish, a befitting name for a package that contains *"lite smått och gott"*.

## Development

Use https://github.com/typst-community/tytanic for testing.

Create a symlink to more easily develop your package changes:

```
DEV_TEMPLATE=hallon
DEV_VERSION=0.1.3

mkdir -p ~/.cache/typst/packages/preview/$DEV_TEMPLATE
rm -R ~/.cache/typst/packages/preview/$DEV_TEMPLATE/$DEV_VERSION
ln -s $PWD ~/.cache/typst/packages/preview/$DEV_TEMPLATE/$DEV_VERSION
```
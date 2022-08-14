# _why's Estate

Static site generator for [_why's Estate](https://viewsourcecode.org/why).

## Usage

```sh
$ ruby estate.rb why why_out
```

This will generate the entire static site into the `why_out/` directory.

`why/index.rb` and any files ending in `*.src.html` in the `why/` directory will be converted to `.html` files (mainly by just sticking the `header.html` on top and the `footer.html` on bottom). Everything else in `why/` will be passed through to the output directory.

## Contributing

If you'd like to help improve the Estate in any way, feel free to open a PR or create an issue! (Especially if you see a dead link, or if you know of something created by \_why that hasn't been listed.)


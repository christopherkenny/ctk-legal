# ctk-legal Format

The `ctk-legal` Quarto template is a template for expert reports and other academic court filing, designed to aesthetically align with the [`ctk-article` template](https://github.com/christopherkenny/ctk-article).

<!-- pdftools::pdf_convert('template.pdf', pages = 1) -->
![[template.qmd](template.qmd)](template_1.png)

## Installing

```bash
quarto use template christopherkenny/ctk-legal
```

This will install the format extension and create an example qmd file that you can use as a starting place for your document.

## Using `ctk-legal`

This template is relatively simple.
It will create a title page, separate table of contents with simplifies section headers, and number each paragraph to allow for easy reference.
Some relevant options you can set:

- `title`: Your report's title
- `subtitle`: Your report's subtitle
- `author`: Author and affiliation information, following [Quarto's schema](https://quarto.org/docs/journals/authors.html). *Only name is used, in typical expert report fashion.*
- `draft`: Adds a big "DRAFT" watermark to the document. Default is `false`.
- `margins`: These default to a sensible 1in all-around margin
- `mainfont`: See the fonts discussion below
- `fontsize`: Set the default font size. Default is 11pt.
- `linestretch`: line spacing. I recommend the default of `1.25`.
- `linkcolor`: Add a splash of colors to your link.
- `biblio-title`: Title for the reference section. Default: "References"

### Fonts

By default, the `ctk-legal` format uses the Spectral font. This can be installed from [Google Fonts](https://fonts.google.com/specimen/Spectral).

To check that it is installed, run:

```
quarto typst fonts
```

If no font by the name "Spectral" is found, the template falls back to Linux Libertine.

## License

This template is licensed under the MIT License. See the [LICENSE](LICENSE) file for details

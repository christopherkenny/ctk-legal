# ctk-legal Format

The `ctk-legal` Quarto template is a template for expert reports and other academic court filing, designed to aesthetically align with the [`ctk-article` template](https://github.com/christopherkenny/ctk-article).

<!-- pdftools::pdf_convert('template.pdf', pages = 1)
![[template.qmd](template.qmd)](template_1.png) -->

## Installing

```bash
quarto use template christopherkenny/ctk-legal
```

This will install the format extension and create an example qmd file that you can use as a starting place for your document.

## Using `ctk-legal`

This template is relatively simple.
Some options you can set:

### Fonts

By default, the `ctk-legal` format uses the Spectral font. This can be installed from [Google Fonts](https://fonts.google.com/specimen/Spectral).

To check that it is installed, run:

```
quarto typst fonts
```

If no font by the name "Spectral" is found, it falls back to Crimson Text. This can be installed from [Google Fonts](https://fonts.google.com/specimen/Crimson+Text).

If no font by the names "Spectral", "Crimson Text", or "Crimson" is found, the template falls back to Linux Libertine.

## License

This template is licensed under the MIT License. See the [LICENSE](LICENSE) file for details

#let to-string(content) = {
  if content == none {
    ""
  } else if content.has("text") {
    content.text
  } else if content.has("children") {
    content.children.map(to-string).join("")
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  }
}

#let article(
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  abstract-title: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: "libertinus serif",
  fontsize: 11pt,
  mathfont: none,
  codefont: none,
  linestretch: 1,
  title-size: 1.5em,
  subtitle-size: 1.25em,
  heading-family: "libertinus serif",
  heading-weight: "bold",
  heading-style: "normal",
  heading-color: black,
  heading-line-height: 0.65em,
  sectionnumbering: none,
  linkcolor: none,
  citecolor: none,
  filecolor: none,
  pagenumbering: "1",
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  draft: false,
  doc,
) = {

  set document(title: title)

  set page(
    paper: paper,
    margin: margin,
    numbering: pagenumbering,
  )
  set page(
    background: rotate(45deg,
      text(128pt, fill: rgb("80000033"))[*DRAFT*]
      )
  ) if draft
  set par(
    justify: true,
    leading: linestretch * 0.65em,
  )
  set text(
    lang: lang,
    region: region,
    font: font,
    size: fontsize,
  )

  show math.equation: set text(font: mathfont) if mathfont != none
  show raw: set text(font: codefont) if codefont != none

  set heading(numbering: sectionnumbering)
  show heading: it => {
    if it.numbering != none {
      pad(left: 1em * (it.level - 1), counter(heading).display("I.A.").split(".").rev().at(1) + ". " + to-string(it.body))
    } else {
      it
    }
  }

  show link: set text(
    fill: rgb(to-string(linkcolor)),
  ) if linkcolor != none
  show ref: set text(
    fill: rgb(to-string(citecolor)),
  ) if citecolor != none
  show link: this => {
    if filecolor != none and type(this.dest) == label {
      text(this, fill: rgb(to-string(filecolor)))
    } else {
      this
    }
  }

  let cnt_para = counter("para")
  let step = cnt_para.step()
  let n_para = context cnt_para.display()
  show par: it => {
    if it.body.at("children", default: ()).at(0, default: none) == step {
      return it
    }

    par(step + [#n_para. ] + it.body)
  }

  show figure: f => {
    show box: it => {
      it.body
    }
    f
  }


  if title != none {
    align(center)[#block(inset: 1em)[
        #set par(leading: heading-line-height)
        #if (
          heading-family != none or heading-weight != "bold" or heading-style != "normal" or heading-color != black or heading-decoration == "underline" or heading-background-color != none
        ) {
          set text(
            font: heading-family,
            weight: heading-weight,
            style: heading-style,
            fill: heading-color,
          )
          text(size: title-size)[#title]
          if subtitle != none {
            parbreak()
            text(size: subtitle-size)[#subtitle]
          }
        } else {
          text(weight: "bold", size: title-size)[#title]
          if subtitle != none {
            parbreak()
            text(weight: "bold", size: subtitle-size)[#subtitle]
          }
        }
      ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author => align(center)[
        #author.name
      ])
    )
  }

  if date != none {
    align(center)[#block[
        #date
      ]]
  }

  if abstract != none {
    block(inset: 2em)[
      #text(weight: "semibold")[#abstract-title] #h(1em) #abstract
    ]
  }

  if title != none or date != none or authors != none or abstract != none {
    pagebreak()
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    show outline.entry.where(
      level: 1
    ): set block(above: 1.3em)
    show outline.entry: it => {
      let pref = if it.prefix() == none {
        ""
      } else {
        to-string(it.prefix()).split(".").rev().at(1) + "."
      }
      link(
        it.element.location(),
        it.indented(pref, it.inner()),
      )
    }

    block(above: 0em, below: 2em)[
      #outline(
        title: toc_title,
        depth: toc_depth,
        indent: toc_indent,
      );
    ]
    pagebreak()
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none,
)

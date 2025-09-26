// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = line(start: (25%,0%), end: (75%,0%))

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): set block(
    fill: luma(230),
    width: 100%,
    inset: 8pt,
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.abs
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == str {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == content {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

// Subfloats
// This is a technique that we adapted from https://github.com/tingerrr/subpar/
#let quartosubfloatcounter = counter("quartosubfloatcounter")

#let quarto_super(
  kind: str,
  caption: none,
  label: none,
  supplement: str,
  position: none,
  subrefnumbering: "1a",
  subcapnumbering: "(a)",
  body,
) = {
  context {
    let figcounter = counter(figure.where(kind: kind))
    let n-super = figcounter.get().first() + 1
    set figure.caption(position: position)
    [#figure(
      kind: kind,
      supplement: supplement,
      caption: caption,
      {
        show figure.where(kind: kind): set figure(numbering: _ => numbering(subrefnumbering, n-super, quartosubfloatcounter.get().first() + 1))
        show figure.where(kind: kind): set figure.caption(position: position)

        show figure: it => {
          let num = numbering(subcapnumbering, n-super, quartosubfloatcounter.get().first() + 1)
          show figure.caption: it => {
            //show par: p => {
            //  p
            //}
            num.slice(2) // I don't understand why the numbering contains output that it really shouldn't, but this fixes it shrug?
            [ ]
            it.body
          }

          quartosubfloatcounter.step()
          it
          counter(figure.where(kind: it.kind)).update(n => n - 1)
        }

        quartosubfloatcounter.update(0)
        body
      }
    )#label]
  }
}

// callout rendering
// this is a figure show rule because callouts are crossreferenceable
#show figure: it => {
  if type(it.kind) != str {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block,
    block_with_new_content(
      old_title_block.body,
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    block(below: 0pt, new_title_block) +
    old_callout.body.children.at(1))
}

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black, body_background_color: white) = {
  block(
    breakable: false,
    fill: background_color,
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"),
    width: 100%,
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%,
      below: 0pt,
      block(
        fill: background_color,
        width: 100%,
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      if(body != []){
        block(
          inset: 1pt,
          width: 100%,
          block(fill: body_background_color, width: 100%, inset: 8pt, body))
      }
    )
}
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

  //show figure.caption: it => {
  //  show par: p => {
  //    return p
  //  }
  //  it.body
  //}


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

#set page(
  paper: "us-letter",
  margin: (x: 1.25in, y: 1.25in),
  numbering: "1",
)


#show: doc => article(
  title: [Expert Report],
  authors: (
    ( name: [An Author],
      affiliation: [],
      email: [] ),
    ),
  date: [September 26, 2025],
  font: ("Spectral",),
  codefont: ("Fira Code",),
  linestretch: 1.25,
  heading-family: ("Spectral",),
  sectionnumbering: "I.A.",
  pagenumbering: "1",
  linkcolor: [\#800000],
  toc: true,
  toc_title: [Table of Contents],
  toc_depth: 3,
  draft: true,
  cols: 1,
  doc,
)

= Introduction
<introduction>
Short intro

Brief description of what you've been instructed to do

We can cite like normal @king1994designing@ho2007matching. And we can cross reference #ref(<sec-findings>, supplement: [Section]).

= Summary of Findings
<sec-findings>
Here is an abstract of the main points.

= Qualifications and Compensation
<qualifications-and-compensation>
Who am I?

= The Analysis
<the-analysis>
Here is the main body of the report.

== Subsection on something interesting
<subsection-on-something-interesting>
Perhaps there's a subsection here.

References automatically follow the last thing if a `bibliography: file.bib` is specified in the header.

= Including Tables
<including-tables>
#figure([
#table(
  columns: 2,
  align: (auto,auto,),
  table.header([month], [count],),
  table.hline(),
  [2024-01-01], [11159],
  [2024-02-01], [6460],
  [2024-03-01], [8850],
  [2024-04-01], [8471],
  [2024-05-01], [8681],
  [2024-06-01], [7710],
)
], caption: figure.caption(
position: top, 
[
Some monthly numbers
]), 
kind: "quarto-float-tbl", 
supplement: "Table", 
)
<tbl-simple>


== Figures and subfigures
<figures-and-subfigures>
Figures can be placed using code, Typst blocks, or using #link("https://quarto.org/docs/authoring/figures.html")[Quarto's figure syntax];. To make a standard figure:

#figure([
#box(image("template_files\\mediabag\\svg-xml-base64,PHN2Z.svg"))

], caption: figure.caption(
position: bottom, 
[
Caption for the figure.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-fig1>


To make a figure with subfigures, try:

#quarto_super(
kind: 
"quarto-float-fig"
, 
caption: 
[
Caption for the subfigures 1.
]
, 
label: 
<fig-subfig1>
, 
position: 
bottom
, 
supplement: 
"Figure"
, 
subrefnumbering: 
"1a"
, 
subcapnumbering: 
"(a)"
, 
[
#grid(columns: 2, gutter: 2em,
  [
#block[
#figure([
#box(image("template_files\\mediabag\\svg-xml-base64,PHN2Z.svg"))
], caption: figure.caption(
position: bottom, 
[
fig a
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-sub1-a>


]
],
  [
#block[
#figure([
#box(image("template_files\\mediabag\\svg-xml-base64,PHN2Z.svg"))
], caption: figure.caption(
position: bottom, 
[
fig b
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
)
<fig-sub1-b>


]
],
)
]
)



#set bibliography(style: "chicago-author-date")

#bibliography("bibliography.bib", title: "References")


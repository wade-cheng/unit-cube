#import "@preview/chic-hdr:0.5.0": *

#let title = [HeadingTitle]

#set document(title: title)
#set page(
  paper: "us-letter",
  margin: 1in,
)
#set text(font: "EB Garamond", number-width: "proportional")
#show math.equation: set text(font: "Libertinus Math")
#set list(marker: [--])

#show heading: it => {
  pagebreak(weak: true)
  v(0.1in)
  block(text(it, style: "italic", weight: "regular"))
  v(4pt)
}

#show: chic.with(
  chic-header(
    left-side: title,
    right-side: [Page #chic-page-number() of #context counter(page).final().at(0)]
  ),
  chic-separator(1pt),
  chic-offset(7pt),
  chic-height(2.5cm)
)

// #import "@preview/booktabs:0.0.4": *
// #show: booktabs-default-table-style

// #figure(
// //  caption: [Time with `-O0`],
//   table(
//     columns: 2,
//     toprule(),
//     [measured], [avg time (ms)],
//     midrule(),
//     $T\*$, $5094.2$,
//     $T_1$, $8957.6$,
//     $T_5$, $2040.6$,
//     $T_10$, $1418.4$,
//     $T_20$, $1235.8$,
//     bottomrule()
//   )
// )

#import "@preview/etykett:0.1.1"

#let data = csv("data.csv").slice(1)

#let make-tag((name, organization)) = [
  #set align(center + horizon)
  #set text(14pt, fill: orange)
  #let badge = grid(
    rows: (1fr, 1fr),
    [
      #text("Open Transport Community Conference", size: 24pt, weight: "bold")
      #image("logo.png")
      #text("Bern, October 6th – 9th, 2026", size: 12pt, fill: blue)
    ],
    [
      #set text(size: 16pt)
      #table(
        columns: (1fr, 18fr, 1fr),
        stroke: none,
        [],
        [
          #set text(weight: "bold")
          #table(
            align: center,
            columns: 1fr,
            // rows: 5 * 1fr,  // For n rows of equal heigth
            stroke: (x: none, top: none, bottom: (paint: maroon, thickness: 0.5pt, dash: "dotted")),
            [#name],
            [#organization],
            [#str.from-unicode(0x20)], // Add space to ensure correct height
            [#str.from-unicode(0x20)],
            [#str.from-unicode(0x20)],
          )],
        [
        ],

        table.cell(colspan: 3, text(fill: black, size: 9pt, "Hosted by SBB")),
        table.cell(colspan: 3, text(fill: black, size: 9pt, "Organized by FOSSGIS")),
      )
    ],
  )
  #grid(
    columns: 2,
    stroke: none,
    [#badge], [#badge],
  )
]

#etykett.labels(
  sheet: etykett.sheet(
    paper: "a4",
    margins: .5cm,
    rows: 2,
    columns: 1,
  ),
  // border: true,  // Enable for debugging
  ..data.map(make-tag),
)

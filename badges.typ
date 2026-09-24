#let data = csv("data.csv").slice(1)

#let make-tag((name, organization)) = [
  #set align(center + horizon)
  #set text(14pt, fill: orange)
  #grid(
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
]

#let data-to-fold(data, rows, columns) = {
  let repeat-each(chunk) = {
    chunk.map(entry => (entry, entry))
  }
  let data-size = data.at(0).len()
  let items-per-page = int((rows * columns) / 2)
  data.chunks(items-per-page).map(repeat-each).flatten().chunks(data-size)
}

#let data-to-duplex(data, rows, columns) = {
  let items-per-page = rows * columns
  let data-size = data.at(0).len()
  let align(chunk) = {
    let entries-missing = items-per-page - chunk.len()
    if entries-missing == 0 {
      chunk
    } else {
      (chunk + ((entries-missing * data-size) * ("", ))).flatten().chunks(data-size)
    }
  }
  let mirror(chunk) = {
    chunk.chunks(columns).map(row => row.rev())
  }
  data.chunks(items-per-page).map(align).map(chunk => (chunk, mirror(chunk))).flatten().chunks(data-size)
}

#let make-badges(data, rows, columns, formatter: data-to-duplex) = {
  let items-per-page = rows * columns
  let make-page(chunk) = {
    grid(
      columns: columns * (1fr, ),
      rows: rows * (1fr, ),
      // stroke: .5pt + gray,
      inset: 1mm,
      ..chunk.map(make-tag)
    )
  }
  set page(
    paper: "a4",
    margin: .5cm,
  )
  formatter(data, rows, columns).chunks(items-per-page).map(make-page).join()
}

#make-badges(data, 2, 2)
// #make-badges(data, 2, 2, formatter: data-to-fold)

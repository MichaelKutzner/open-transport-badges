#let make-tag((name, organization)) = [
  #set align(center + horizon)
  #set text(14pt, fill: orange)
  #let huge(content) = text(size: 24pt, weight: "bold", content)
  #let small(content) = text(fill: black, size: 9pt, content)
  #let insets = (
    top: 0pt,
    right: 2mm,
    bottom: 0pt,
    left: 2mm,
  )
  #let make-sponsors = {
    grid(
      columns: 2 * (1fr,),
      rows: 2 * (1fr,),
      small("Hosted by SBB"), small("Organized by FOSSGIS"),
      image("logos/supporters/sbb-logo.svg"), image("logos/supporters/FOSSGIS.svg"),
    )
  }
  #let make-supporters(logo_filenames) = {
    let logos = logo_filenames.map(filename => (
      "logos/supporters/" + filename
    ))
    grid(
      columns: logos.len() * (1fr,),
      inset: insets,
      ..logos.map(image)
    )
  }
  #let supporters = (
    "DB_InfraGo_logo_red_black_100px_rgb.svg",
    "entur-logo.png",
    "opentransportdata-swiss-logo.png",
    "skanetrafiken-logo.png",
  )
  #let supporters-count = int((supporters.len() + 1) / 2)
  #let make-logos = {
    grid(
      rows: (2fr, 1fr, 6fr, .5fr, 1fr, .5fr),
      columns: (1fr,),
      text("Open Transport Community Conference", weight: "bold"),
      make-sponsors,
      image("logos/logo.png"),
      make-supporters(supporters.slice(0, supporters-count)),
      text("Bern, October 6th – 9th, 2026", size: 12pt, fill: blue),
      make-supporters(supporters.slice(supporters-count, none)),
    )
  }
  #let make-name = {
    [
      #set text(size: 16pt)
      #table(
        columns: (1fr, 18fr, 1fr),
        rows: (1fr, 18fr, 1fr),
        stroke: none,
        table.cell(colspan: 3, ""),
        [],
        [
          #let first-name = name.split(" ").at(0).trim()
          #let last-name = if first-name.len() < name.len() { name.slice(first-name.len() + 1, none).trim() } else { "" }
          #let fields = (
            (
              huge(first-name),
              last-name,
              organization.split("/").map(org => text(fill: blue, org.trim())),
              5 * ("",),
            )
              .filter(row => row != "")  // Remove empty rows
              .flatten()
              .slice(0, 5)
          )
          #table(
            align: center,
            columns: 1fr,
            rows: 5 * 1fr, // For n rows of equal heigth
            stroke: (x: none, top: none, bottom: (paint: maroon, thickness: 0.5pt, dash: "dotted")),
            ..fields
          )],
        [
        ],
        table.cell(colspan: 3, ""),
      )
    ]
  }
  #grid(
    rows: (1fr, 1fr),
    make-logos,
    make-name,
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
      (chunk + ((entries-missing * data-size) * ("",))).flatten().chunks(data-size)
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
      columns: columns * (1fr,),
      rows: rows * (1fr,),
      // stroke: .5pt + gray,  // Helper lines
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

// Setup fake data for development
#let data = (
  ("Max Mustermann", "Muster AG"),
  ("Maxi", ""),
  ("Someperson Withalongname", "Wholesome Community"),
  ("John Doe", ""),
  ("NameX", "Project A/Project B"),
)
// Use real data when printin
// Notice that 'slice(1)' will remove the first row. Remove if not needed.
// #let data = csv("data.csv").slice(1)


#make-badges(data, 2, 2)
// #make-badges(data, 2, 2, formatter: data-to-fold)

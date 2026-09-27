// Colors and fonts, matched to the reference badge variants.
#let light-blue = rgb("#c0d9e5")
#let orange = rgb("#e27e42")

// The reference variants are set in a Helvetica like sans serif.
#let sans = (
  "Helvetica Neue",
  "Helvetica",
  "Nimbus Sans",
  "Arial",
  "Liberation Sans",
  "DejaVu Sans",
)

// The badge is a card of the size of the reference variants (A6), but it is
// always rendered into the cell it is given. The bands are therefore given as
// a fraction of the badge, so that the badge keeps its proportions on any page
// size, while the type keeps the size it has on the reference variants.
//
// Measured on the reference variants, from top to bottom:
//   light blue header, white name band, white organization band, and two thin
//   light blue rules that leave room for a personal note.
// The top edge of the name band is white on white and not visible, its height
// is chosen so that both name lines sit where the reference puts them.
#let band-inset = 8.4%   // left and right edge of the white bands
#let text-inset = 10.8%  // left edge of every text line
#let rule-height = 1.5pt
#let rule-inset = 13.1%  // right edge of the rules, the reference is asymmetric
#let name-band-height = 17.15%
#let organization-band-height = 16.1%
// The two rules at the bottom frame the space for a personal note. Nothing is
// printed there, it is left empty on purpose.
#let note-band-height = 10.2%

// Text sizes of the reference variants.
#let title-size = 14pt
#let first-name-size = 24pt
#let last-name-size = 19pt
#let organization-size = 18pt

// Baseline distances and band padding of the reference variants.
#let title-leading = 19.9pt
#let name-leading = 29.2pt
#let organization-leading = 22pt
#let name-inset = (top: 0pt, right: 0pt, bottom: 13.6pt, left: 0pt)
#let organization-inset = (top: 8.6pt, right: 0pt, bottom: 0pt, left: 0pt)

// The organization band fits three lines of the size above. A longer list is
// scaled down until its last line still fits above the note, but never below
// the minimum, so that the text stays readable.
#let organization-fit = 46pt
#let organization-minimum = 0.45

// The organizations behind the conference. Every description sits above the
// logo it belongs to, so that host, organizer and supporters stay apart.
#let sponsors = (
  (
    description: "Hosted by",
    logo: "logos/supporters/sbb-logo.svg",
  ),
  (
    description: "Organized by",
    logo: "logos/supporters/FOSSGIS.svg",
  ),
)
#let supporters = (
  "logos/supporters/DB_InfraGo_logo_red_black_100px_rgb.svg",
  "logos/supporters/entur-logo.png",
  "logos/supporters/opentransportdata-swiss-logo.png",
  "logos/supporters/skanetrafiken-logo.png",
)
#let supporters-description = "Supported by"

// The light blue header carries the conference logo, the title and the
// organizations behind the conference. Its height is a fraction of the badge,
// so the logo is a fraction of the header.
#let header-logo-height = 34.4%   // conference logo
#let header-top = 2.6%            // margin above the logo
#let header-gap = 2.1%            // between logo, title and organizations
#let description-size = 6.5pt     // "Hosted by SBB" and friends
#let sponsor-logo-height = 16pt
#let supporter-logo-height = 14pt

#let as-text(value) = if type(value) == str { value } else { "" }

// A name is split at the first blank, everything after it is the last name.
// A single word is an alias and is printed as the first name only.
#let split-name(name) = {
  let words = as-text(name).trim().split(regex(" +")).filter(w => w != "")
  if words.len() < 2 { (words.at(0, default: ""), none) } else {
    (words.first(), words.slice(1).join(" "))
  }
}

// Organizations are separated by slashes, with optional whitespace around them.
#let split-organization(organization) = {
  as-text(organization)
    .split("/")
    .map(org => org.trim())
    .filter(org => org != "")
}

// A badge for one person. `person` is a tuple of name and optional
// organization, e.g. `("Someperson Withalongname", "Wholesome Community")`.
//
// The badge is laid out in the cell it is given, so that names which are too
// long for one line can be measured and scaled down before they are typeset.
#let make-tag(person) = layout(size => {
  let name = person.at(0, default: "")
  let organization = person.at(1, default: "")
  let (first-name, last-name) = split-name(name)
  let organizations = split-organization(organization)

  // The text starts at `text-inset` on either side of the badge.
  let text-width = size.width * (100% - 2 * text-inset)

  // Width of a piece of the name, in the font and weight it is printed in.
  let measure-name = (content, font-size) => measure(
    text(font: sans, size: font-size, weight: "bold", content)
  ).width

  // A name is printed on a single line as long as its first and its last name
  // fit on a line each. Longer names are scaled down, down to half the size of
  // the reference variants, before they are broken up.
  let name-fits = scale => {
    let last = last-name == none or measure-name(
      last-name,
      last-name-size * scale,
    ) <= text-width
    measure-name(first-name, first-name-size * scale) <= text-width and last
  }
  let name-scale = 1.0
  for step in range(11) {
    name-scale = 1.0 - 0.05 * step
    if step == 10 or name-fits(name-scale) { break }
  }

  // A long organization list is scaled down, but only as far as the space
  // between the first and the last line of the band allows.
  let organization-scale = calc.min(1.0, calc.max(
    organization-minimum,
    organization-fit / (
      organization-leading * calc.max(1, organizations.len() - 1)
    ),
  ))

  let make-title = content => text(
    font: sans,
    size: title-size,
    weight: "bold",
    fill: white,
    content,
  )
  let make-date = content => text(
    font: sans,
    size: title-size,
    weight: "bold",
    style: "italic",
    fill: white,
    content,
  )
  let make-first-name = content => text(
    font: sans,
    size: first-name-size * name-scale,
    weight: "bold",
    fill: orange,
    content,
  )
  let make-last-name = content => text(
    font: sans,
    size: last-name-size * name-scale,
    weight: "bold",
    fill: orange,
    content,
  )
  let make-organization = content => text(
    font: sans,
    size: organization-size * organization-scale,
    weight: "bold",
    style: "italic",
    fill: orange,
    content,
  )

  // The first name is set larger than the last name, both on the same line.
  let make-name-run = [
    #make-first-name(first-name) #h(0.3em) #make-last-name(last-name)
  ]

  // A name that is too wide for the text column is broken up, so that the first
  // and the last name get a line each.
  let name-on-one-line = last-name == none or measure(
    make-name-run
  ).width <= text-width

  // A small caption, as it sits on the light blue panel.
  let make-description = body => text(
    font: sans,
    size: description-size,
    weight: "bold",
    fill: white,
    body,
  )

  // A logo of the given height. A logo that is too wide for its column is
  // scaled down instead of pushing the other logos out of the line.
  let make-logo = (file, logo-height) => image(
    file,
    width: 100%,
    height: logo-height,
    fit: "contain",
  )

  // A block of the header, in the same column as the text of the badge, so that
  // its left edge lines up with the title and the name.
  let make-header-row = body => grid(
    columns: (text-inset, 100% - 2 * text-inset, text-inset),
    rows: (auto,),
    gutter: 0pt,
    grid.cell[],
    grid.cell(body),
    grid.cell[],
  )

  // Host and organizer, each described above its own logo.
  let make-sponsors = make-header-row(grid(
    columns: sponsors.len() * (1fr,),
    rows: (auto, auto),
    gutter: 1mm,
    align: center + horizon,
    ..sponsors.map(entry => make-description(entry.description)),
    ..sponsors.map(entry => make-logo(entry.logo, sponsor-logo-height)),
  ))

  // The supporters, described once above the row of their logos.
  let make-supporters = make-header-row(grid(
    columns: supporters.len() * (1fr,),
    rows: (auto, auto),
    gutter: 1mm,
    align: center + horizon,
    grid.cell(colspan: supporters.len())[
      #make-description(supporters-description)
    ],
    ..supporters.map(file => make-logo(file, supporter-logo-height)),
  ))

  // Logo of the conference, title and date, and the organizations behind the
  // conference, all on the light blue panel. The title lines sit in rows of a
  // fixed height, so their baseline distance does not depend on the metrics of
  // the font that is used.
  let make-header = block(width: 100%, height: 100%, fill: light-blue)[
    #set align(center)
    #grid(
      rows: (
        header-top,          // margin above the logo
        auto,                // conference logo
        header-gap,          // gap between logo and title
        auto,                // title and date
        header-gap,          // gap between title and organizations
        auto,                // host and organizer
        auto,                // supporters
        1fr,                 // remaining space, the bottom margin
      ),
      gutter: 0pt,
      block[],
      box(width: 100%, height: header-logo-height)[
        #image("logos/logo.png", fit: "contain")
      ],
      block[],
      grid(
        columns: (text-inset, 100% - 2 * text-inset, text-inset),
        rows: (auto,),
        gutter: 0pt,
        align: left + bottom,
        grid.cell[],
        grid.cell[
          #grid(
            rows: 3 * (title-leading,),
            gutter: 0pt,
            align: left + bottom,
            make-title[Open Transport],
            make-title[Community Conference],
            make-date[Bern, October 6th – 9th, 2026],
          )
        ],
        grid.cell[],
      ),
      block[],
      make-sponsors,
      make-supporters,
      block[],
    )
  ]

  // Name and organization on a white band. The band stops at `band-inset`, its
  // text starts at `text-inset`, as on the reference variants. Both insets are
  // fractions of the badge, so they are applied as columns of one grid.
  let make-band = (alignment, padding, content) => grid(
    columns: (band-inset, text-inset - band-inset, 1fr, band-inset),
    rows: (1fr,),
    gutter: 0pt,
    grid.cell[],
    grid.cell(fill: white)[],
    grid.cell(fill: white, align: alignment, inset: padding, content),
    grid.cell[],
  )

  // The name keeps the baseline distance of the reference variants, whether it
  // is printed on one line or on a line per name part.
  let make-name = grid(
    rows: if name-on-one-line { (name-leading,) } else { 2 * (name-leading,) },
    gutter: 0pt,
    align: left + bottom,
    ..if name-on-one-line {
      (make-name-run,)
    } else {
      (make-first-name(first-name), make-last-name(last-name))
    },
  )

  // Every organization is printed on a line of its own. The baseline distance
  // is scaled with the text, so that even long lists stay inside the band.
  let make-organizations = if organizations.len() == 0 {
    none
  } else {
    grid(
      rows: organizations.len() * (organization-leading * organization-scale,),
      gutter: 0pt,
      align: left + top,
      ..organizations.map(make-organization),
    )
  }

  // One of the two thin light blue rules that frame the space for a note.
  let make-rule = grid(
    columns: (text-inset, 100% - text-inset - rule-inset, rule-inset),
    rows: (rule-height,),
    gutter: 0pt,
    grid.cell[],
    grid.cell(fill: light-blue)[],
    grid.cell[],
  )

  grid(
    columns: (1fr,),
    rows: (
      45.7%,   // light blue header
      3.35%,   // gap
      name-band-height,
      organization-band-height,
      note-band-height,
      7.4%,    // bottom margin
    ),
    make-header,
    block(width: 100%, height: 100%),
    make-band(bottom + left, name-inset, make-name),
    make-band(top + left, organization-inset, make-organizations),
    // The note area stays empty on purpose, the two rules are all there is.
    grid(
      columns: (1fr,),
      rows: (rule-height, 1fr, rule-height),
      make-rule,
      block[],
      make-rule,
    ),
    block(width: 100%, height: 100%),
  )
})

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

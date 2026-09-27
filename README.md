## Open Transport Badges

Example of a badge design, that could be used for the [Open Transport Community Conference](https://open-transport.org/).

The project is implemented with [Typst](https://github.com/typst/typst), which allows for an easy way to manage badge versions.

## Usage

The project can be compiled to a PDF file by running `typst compile badges.typ`

Before creating the conference badges, make sure to add a CSV file, e.g. `data.csv`, that contains the actual attendees data.
Then change the code to use that file instead (`#let data = csv("data.csv").slice(1)`).

The CSV file needs to have the following layout:

```
Name,Organization
<Name 1>,<Organization 1>
<Name 2>,<Organization 2>
…
```

If no header row is available, remove `.slice(1)` from the code.

### Page layout

The project assumes, that conference badges need to be A6, cut from an A4 paper.

If a different paper size is used, e.g. A3, you need to change the layout accordingly.
Don't forget to also update `rows` and `columns`, as A3 landscape should provide 2 rows of 4 A6 badges each.

### Duplex print

Using Typst allows for an easy option to modify the data before the badges are created.
Therefore all data will be duplicated and rearranged, to create duplex printable pages by default.
If duplex printing is not an option, but badges should be folded instead, use `formatter: data-to-fold` instead.
As this will duplicate all data, badges can be folded instead.

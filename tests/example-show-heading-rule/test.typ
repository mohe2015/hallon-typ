#set page(width: 12cm, height: auto)

#import "@preview/hallon:0.1.3" as hallon

// needs to come before the style-figures show rule.
#show heading.where(
  level: 1,
): it => {
  block[
    #it.body
  ]
}
#show: hallon.style-figures.with(heading-levels: 1)

// === [ Main matter ] =========================================================

#set heading(numbering: "1.1")

#let example-fig = rect(fill: aqua)

= Section one

See @fig1, @fig2

#figure(
	example-fig,
	caption: lorem(5),
) <fig1>

= Section two

See @fig1, @fig2

#figure(
	example-fig,
	caption: lorem(5),
) <fig2>

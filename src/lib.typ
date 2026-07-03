#let figure-numbering-function = state("figure-numbering-function", "1")
#let subfigure-numbering-function = state("subfigure-numbering-function", "1a")

// Reasoning: We have to override the numbering function to do our custom magic, so we can't really use the value of that numbering function for users to customize our numbering

// === [ Named references ] ====================================================

// nameref displays a reference using section name (instead of numbering).
#let nameref(label) = {
	show ref: it => {
		if it.element == none {
			it
		} else if it.element.func() != heading {
			it
		} else {
			let l = it.target  // label
			let h = it.element // heading
			link(l, h.body)
		}
	}
	ref(label)
}

// === [ Image notes ] =========================================================

// TODO: remove font parameter when custom types are implemented in Typst. Then
// use a `#show image-notes: set text(font: font-sans, weight: "bold ")` rule
// from the user instead.
//
// See https://github.com/typst/typst/issues/147

// image-notes places notes above the given image, positioned as specified by
// alignment.
#let image-notes(img, ..args, alignment: top + right, font: "Nimbus Sans") = {
	let notes = args.pos()
	let dx = 0em
	let dy = 0em
	let ystep = 1em
	if alignment.x == left {
		dx = 0.3em
	} else if alignment.x == center {
		dx = 0em
	} else if alignment.x == right {
		dx = -0.3em
	} else {
		panic("horizontal alignment missing from '" + repr(alignment) + "'")
	}
	if alignment.y == top {
		dy = 0.3em
	} else if alignment.y == horizon {
		dy = 0em - 1em*notes.len()/2
	} else if alignment.y == bottom {
		dy = 0.3em - 1em*notes.len()
	} else {
		panic("vertical alignment missing from '" + repr(alignment) + "'")
	}
	set text(font: font, weight: "bold")
	block(
		{
			img
			for note in notes {
				place(
					alignment,
					dx: dx,
					dy: dy,
				)[#note]
				dy = dy + ystep
			}
		}
	)
}

// === [ Numbering patterns ] ==================================================

// A Typst re-implementation of `NumberingPattern::from_str`
// (crates/typst-library/src/model/numbering.rs, line 295 in typst/typst
// at commit 7c76edc) — written *in* the Typst language itself.
//
// The Rust original walks the pattern string char by char, and whenever it
// hits a recognized "counting symbol" it closes off a (prefix, symbol)
// piece, using everything since the last symbol as the prefix. Whatever is
// left after the final symbol becomes the suffix.

// The counting symbols listed in `numbering()`'s docs — just the set of
// characters that select a numeral system (standing in for
// `NamedNumeralSystem::from_shorthand`'s recognized shorthands).
#let counting-symbols = (
  "1", "a", "A", "i", "I", "α", "Α",
  "一", "壹", "あ", "い", "ア", "イ",
  "א", "가", "ㄱ", "*",
  "١", "۱", "१", "১", "ক",
  "①", "⓵",
)

/// Parses a numbering pattern (e.g. `"1.a.i)"`) into `(pieces, suffix)`,
/// where `pieces` is an array of `(prefix, symbol)` tuples, mirroring
/// `NumberingPattern { pieces, suffix, .. }` in the Rust source.
///
/// Panics with "invalid numbering pattern" if the pattern contains no
/// counting symbol at all, matching the `Err("invalid numbering pattern")`
/// branch of `from_str`.
#let numbering-pattern-from-str(pattern) = {
  let pieces = ()
  let prefix = "" // everything seen since the last counting symbol

  for c in pattern {
    if c in counting-symbols {
      pieces.push((prefix, c))
      prefix = ""
    } else {
      prefix += c
    }
  }

  // Whatever's left after the last symbol is the suffix.
  let suffix = prefix

  if pieces.len() == 0 {
    panic("invalid numbering pattern")
  }

  (pieces: pieces, suffix: suffix)
}

// === [ Subfigures ] ==========================================================

// figure-caption displays the caption of figures.
#let figure-caption(it) = context {
	// Left align caption if occupying more than one line. Otherwise,
	// center align.
	align(
		center,
		block({
			set align(left)
			strong[#it.supplement~#it.counter.display(it.numbering)#it.separator]
			[ ]
			it.body
		})
	)
}

// subfigure-caption displays the caption of subfigures.
#let subfigure-caption(it, parent: none) = context {
	// Left align caption if occupying more than one line. Otherwise,
	// center align.
	align(
		center,
		block({
			set align(left)
			strong(it.counter.display("(a)"))
			[ ]
			it.body
		})
	)
}

// style-figures handles (optional heading-dependent) numbering of figures and
// subfigures.
#let style-figures(
	heading-levels: 0,
	heading-numbering: none,
	figure-caption: figure-caption,
	subfigure-caption: subfigure-caption,
) = (
	rule: body => {
		// Numbering patterns for figures and subfigures.
		let fig-numbering = "1."*heading-levels + "1"     // e.g. "1.1"

		show heading: outer => {
			if outer.level <= heading-levels {
				// reset figure counter.
				counter(figure.where(kind: image)).update(0)
				counter(figure.where(kind: table)).update(0)
				counter(figure.where(kind: raw)).update(0)
			}
			outer
		}

		set figure(numbering: (..nums) => {
			let heading-counters = counter(heading).get().slice(0, heading-levels)
			numbering(figure-numbering-function.get(), ..heading-counters, ..nums)
		})

		show figure.where(kind: image).or(figure.where(kind: table)).or(figure.where(kind: raw)): outer => {
			// reset subfigure counter
			counter(figure.where(kind: "subfigure")).update(0)

			// use bold figure caption.
			show figure.caption: figure-caption

			// use nesting level of figure to infer numbering of subfigures.
			set figure(numbering: (..nums) => {
				let heading-counters = counter(heading).get().slice(0, heading-levels)
				let outer-nums = counter(figure.where(kind: outer.kind)).get()
				numbering(subfigure-numbering-function.get(), ..heading-counters, ..outer-nums, ..nums)
			})

			// Set default supplement for subfigures.
			set figure(supplement: outer.supplement)

			show figure.where(kind: "subfigure"): inner => {
				// use bold "(a)" subfigure caption.
				show figure.caption: subfigure-caption.with(parent: outer)
				inner
			}
			outer
		}

		body
	},
)

// style-equations handles (optional heading-dependent) numbering of equations
#let style-equations(
	heading-levels: 0,
	heading-numbering: none,
) = (
	rule: body => {
		show heading: outer => {
			if outer.level <= heading-levels {
				// reset equation counter.
				counter(math.equation).update(0)
			}
			outer
		}

		set math.equation(numbering: (n) => {

		})

		body
	},
)

// subfigure creates a new subfigure with the given arguments and an optional
// label.
#let subfigure(body, outlined: false, ..args, label: none) = {
	let fig = figure(body, kind: "subfigure", outlined: outlined, ..args)
	if label == none {
		return fig
	}
	[ #fig #label ]
}
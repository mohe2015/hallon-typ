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

// https://github.com/typst/typst/blob/7c76edca62ee16ca4c6dd4f5498fe57793f28517/crates/typst-library/src/model/numbering.rs#L295
#let parse-numbering-pattern(pattern) = {
  let counting-symbols = ("1", "a", "A", "i", "I", "α", "Α", "一", "壹", "あ", "い", "ア", "イ", "א", "가", "ㄱ", "*", "١", "۱", "१", "১", "ক", "①", "⓵")
  
  let pieces = ()
  let handled = 0
  let current-idx = 0
  
  for c in pattern.codepoints() {
    let c-len = c.len()
    
    if c in counting-symbols {
      let prefix = pattern.slice(handled, current-idx)
      pieces.push((prefix: prefix, kind: c))
      
      handled = current-idx + c-len
    }
    
    current-idx += c-len
  }
  
  if pieces.len() == 0 {
    panic("invalid numbering pattern")
  }
  
  let suffix = pattern.slice(handled)
  
  return (pieces: pieces, suffix: suffix)
}

// get-heading-numbering returns the active heading numbering, padded or
// truncated to the specified number of heading levels.
#let get-heading-numbering(loc, heading-levels, heading-numbering: none) = {
	let heading-numbering-str = heading-numbering
	if heading-numbering == none {
		// infer heading numbering from previous heading.
		// default: none workaround for https://github.com/typst/typst/issues/7625
		let prev-heading = query(selector(heading).before(loc)).last(default: none)
		if prev-heading == none {
			return none
		}
		if type(prev-heading.numbering) != str {
			return none
		}
		heading-numbering-str = prev-heading.numbering
	}
	let parsed = parse-numbering-pattern(heading-numbering-str)
	let parts = parsed.pieces
	if parts.len() > heading-levels {
		parts = parts.slice(0, heading-levels)
	} else if parts.len() < heading-levels {
		for i in range(parts.len(), heading-levels) {
			parts.push((prefix: ".", kind: "1"))
		}
	}
	return parts.map(a => a.prefix + a.kind).join("") + parsed.suffix
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

#let universal-figure-numbering(
  heading-levels, 
  heading-numbering, 
  location, 
  kind: none,
  is-sub-fig: false,
  ..nums
) = {
  // 1. Determine the base numbering pattern based on whether it's a subfigure
  let numbering-suffix = if is-sub-fig { "1a" } else { "1" }
  let base-pattern = "1." * heading-levels + numbering-suffix
  let final-pattern = base-pattern

  // 2. Fetch and normalize heading numbers (Truncate / Zero-pad)
  let heading-nums = counter(heading).at(location)
  if heading-nums.len() > heading-levels {
    heading-nums = heading-nums.slice(0, heading-levels)
  } else {
    while heading-nums.len() < heading-levels {
      heading-nums.push(0)
    }
  }

  // 3. Handle custom heading numbering prefix (e.g., "A.1")
  if heading-levels > 0 {
    let heading-numbering-str = get-heading-numbering(
      location, 
      heading-levels, 
      heading-numbering: heading-numbering
    )
    if heading-numbering-str != none {
      final-pattern = heading-numbering-str + "." + numbering-suffix
    }
  }

  // 4. Gather the arguments for std.numbering
  let numbering-args = heading-nums
  
  if is-sub-fig and kind != none {
    let outer-nums = counter(figure.where(kind: kind)).at(location)
    numbering-args += outer-nums
  }
  
  numbering-args += nums.pos()

  // 5. Output the standard Typst numbering
  std.numbering(final-pattern, ..numbering-args)
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

		set figure(numbering: (..nums) => universal-figure-numbering(heading-levels, heading-numbering, here(), ..nums))

		show figure.where(kind: image).or(figure.where(kind: table)).or(figure.where(kind: raw)): outer => {
			// reset subfigure counter
			counter(figure.where(kind: "subfigure")).update(0)

			// use bold figure caption.
			show figure.caption: figure-caption

			// use nesting level of figure to infer numbering of subfigures.
			set figure(numbering: (..nums) => {
				universal-figure-numbering(heading-levels, heading-numbering, outer.kind, outer.location(), is-sub-fig: true, ..nums)
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
	numbering-function: ref => {
		if ref.element.kind == "subfigure" {
			let kind = query(selector(figure.where(kind: image).or(figure.where(kind: table)).or(figure.where(kind: raw))).before(ref.element.location())).last().kind
			universal-figure-numbering.with(heading-levels, heading-numbering, kind, ref.element.location(), is-sub-fig: true)
		} else {
			universal-figure-numbering.with(heading-levels, heading-numbering, ref.element.location())
		}
	}
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

		set math.equation(numbering: (..nums) => universal-figure-numbering(heading-levels, heading-numbering, here(), ..nums))

		body
	},
	numbering-function: ref => universal-figure-numbering.with(heading-levels, heading-numbering, ref.element.location())
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
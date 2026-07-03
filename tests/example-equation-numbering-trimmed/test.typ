#import "@preview/hallon:0.1.3" as hallon: subfigure, parse-numbering, get-counting-body

#set math.equation(numbering: "(1)")

= Chapter 1

$ 1 + 1 = 2 $ <eq1>

See @eq1, @eq2, @eq3, @eq4

#set math.equation(
  numbering: numbering.with("(1)")
)

= Chapter 2

$ 1 + 1 = 2 $ <eq2>

See @eq1, @eq2, @eq3, @eq4

#set math.equation(
  numbering: numbering.with("(1)"),
  supplement: "Test"
)

= Chapter 3

$ 1 + 1 = 2 $ <eq3>

See @eq1, @eq2, @eq3, @eq4

#set math.equation(
  numbering: numbering.with("(1)"),
  supplement: none
)

#show ref: it => {
  let eq = math.equation
  let el = it.element
  
  // Skip all other references.
  if el == none or el.func() != eq { return it }
  
  // Fetch the number for the equation
  let eq_num = if type(el.numbering) == str {
    numbering(get-counting-body(el.numbering), ..counter(eq).at(el.location()))
  } else {
    numbering(el.numbering, ..counter(eq).at(el.location()))
  }
  
  // Format the display: only prefix with supplement if it exists
  let content = if el.supplement != [] {
    el.supplement + " " + eq_num
  } else {
    eq_num
  }
  
  // TODO if el.numbering is a string pattern, we need to strip
  // trimmed numbering by default https://github.com/typst/typst/blob/7c76edca62ee16ca4c6dd4f5498fe57793f28517/crates/typst-library/src/model/reference.rs#L339
  // https://github.com/typst/typst/blob/7c76edca62ee16ca4c6dd4f5498fe57793f28517/crates/typst-library/src/model/numbering.rs#L301
  // https://github.com/typst/codex/blob/0d70dbf5012a7b6765924534aeee4f5b64659ee9/src/numeral_systems.rs#L81
  link(el.location(), content)
}

= Chapter 4

$ 1 + 1 = 2 $ <eq4>

See @eq1, @eq2, @eq3, @eq4

#show: hallon.style-equations(heading-levels: 1).rule

#set math.equation(numbering: "(1.1)")

= Chapter 5

$ 1 + 1 = 2 $ <eq5>

See @eq1, @eq2, @eq3, @eq4

#set math.equation(
  numbering: numbering.with("(1)")
)

= Chapter 6

$ 1 + 1 = 2 $ <eq6>

See @eq1, @eq2, @eq3, @eq4

#set math.equation(
  numbering: numbering.with("(1)"),
  supplement: "Test"
)

= Chapter 7

$ 1 + 1 = 2 $ <eq7>

See @eq1, @eq2, @eq3, @eq4

#set math.equation(
  numbering: numbering.with("(1)"),
  supplement: none
)

#show ref: it => {
  let eq = math.equation
  let el = it.element
  
  // Skip all other references.
  if el == none or el.func() != eq { return it }
  
  // Fetch the number for the equation
  let eq_num = if type(el.numbering) == str {
    numbering(get-counting-body(el.numbering), ..counter(eq).at(el.location()))
  } else {
    numbering(el.numbering, ..counter(eq).at(el.location()))
  }
  
  // Format the display: only prefix with supplement if it exists
  let content = if el.supplement != [] {
    el.supplement + " " + eq_num
  } else {
    eq_num
  }
  
  // TODO if el.numbering is a string pattern, we need to strip
  // trimmed numbering by default https://github.com/typst/typst/blob/7c76edca62ee16ca4c6dd4f5498fe57793f28517/crates/typst-library/src/model/reference.rs#L339
  // https://github.com/typst/typst/blob/7c76edca62ee16ca4c6dd4f5498fe57793f28517/crates/typst-library/src/model/numbering.rs#L301
  // https://github.com/typst/codex/blob/0d70dbf5012a7b6765924534aeee4f5b64659ee9/src/numeral_systems.rs#L81
  link(el.location(), content)
}

= Chapter 8

$ 1 + 1 = 2 $ <eq8>

See @eq1, @eq2, @eq3, @eq4
#set page(width: 12cm, height: auto)

#set figure(numbering: "(a)")

= Section 1

#figure("Figure 1", caption: "Figure 1") <figure-1>

@figure-1

= Section 2

#figure("Figure 2", caption: "Figure 2") <figure-2>

@figure-2

#import "@preview/hallon:0.1.3" as hallon: parse-numbering-pattern

#show: hallon.style-figures(heading-levels: 1).rule

#set heading(numbering: "[I]")

//#set figure(numbering: "(1.a)")

= Section 3

#figure("Figure 3", caption: "Figure 3") <figure-3>

@figure-3

= Section 4

#figure("Figure 4", caption: "Figure 4") <figure-4>

@figure-4

#parse-numbering-pattern("(1.a)")
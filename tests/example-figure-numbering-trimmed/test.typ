#set page(width: 12cm, height: auto)

= Section 1

#set figure(numbering: "(a)")

#figure("Figure 1", caption: "Figure 1") <figure-1>

@figure-1

#import "@preview/hallon:0.1.3" as hallon

#show: hallon.style-figures(heading-levels: 1).rule

= Section 2

#set figure(numbering: "(a)")

#figure("Figure 2", caption: "Figure 2") <figure-2>

@figure-2

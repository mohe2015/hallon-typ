#set page(width: 12cm, height: auto)

#set heading(numbering: "[I]")
#set figure(numbering: "(a)")

= Section 1

#figure("Figure 1", caption: "Figure 1") <figure-1>

@figure-1, @figure-2, @figure-3, @figure-4, @figure-5, @figure-6

= Section 2

#figure("Figure 2", caption: "Figure 2") <figure-2>

@figure-1, @figure-2, @figure-3, @figure-4, @figure-5, @figure-6

#import "@preview/hallon:0.1.3" as hallon

#show: hallon.style-figures(heading-levels: 1).rule

#set heading(numbering: "[I]")
#set figure(numbering: "(a)")

= Section 3

#figure("Figure 3", caption: "Figure 3") <figure-3>
#figure("Figure 4", caption: "Figure 4") <figure-4>

@figure-1, @figure-2, @figure-3, @figure-4, @figure-5, @figure-6

= Section 4

#figure("Figure 5", caption: "Figure 5") <figure-5>
#figure("Figure 6", caption: "Figure 6") <figure-6>

@figure-1, @figure-2, @figure-3, @figure-4, @figure-5, @figure-6

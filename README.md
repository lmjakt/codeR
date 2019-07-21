# codeR

Functions to provide syntax highlighting for R code in R
graphics. The software consists of two components:

1. A compiled function `colorise_R(SEXP code)` implemented in
   C. This takes a character vector and returns a list of
   elements specifying code fragments, their line numbers and
   the type of code.
2. A set of R functions:
   1. `coloriseR`. Wraps the compiled function and converts
      output to a dataframe and a character list giving the
      names of classes recognised by `colorise_R`.
   2. `classColors`. Provides a list of suggested colors for
      a dark or light background as a vector that can be supplied
      to the drawing function.
   3. `classFonts`. Provides a suggested vector of font faces
      (plain, bold, ...) for the recognised classes.
   4. `draw.code`. Draws the code with the suggested colors and
      faces.

<figure>
	<img src="example_2.png" width="700">
	<figcaption>Part of codeR rendered by codeR
	</figcaption>
</figure>

```R
png("example_2.png", width=1200, height=1400)
par(bg=rgb(0.3, 0.3, 0.3)) 
par(mar=c(1,1,1,1))
plot.new()
plot.window(xlim=c(0,100), c(0,100))
draw.code(code.f, 0, 100, cex=1.5, dark.bg=TRUE, family='hack',
          l.spc=1.8, line.no=TRUE)
dev.off()

```

And the above colored by `codeR`:
<figure>
	<img src="png_example_1.png" width="700">
	<figcaption>Code rendered with line numbering and zebra background
	</figcaption>
</figure>

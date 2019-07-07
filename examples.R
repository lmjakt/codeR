## examples usage of coloriseR and associated functions.
source("colorise_R.R")

code <- readLines("colorise_R.R")

code.f <- coloriseR(code)

x11()

par(bg=rgb(0.3, 0.3, 0.3))

plot.new()
plot.window(xlim=c(0,100), c(0,100))
draw.code(code.f, 10, 90, cex=1, dark.bg=TRUE)

plot.new()
plot.window(xlim=c(0,100), c(0,100))
draw.code(code.f, 10, 90, cex=1, dark.bg=TRUE, family='mono', l.spc=2)

plot.new()
plot.window(xlim=c(0,100), c(0,100))
draw.code(code.f, 10, 90, cex=1, dark.bg=TRUE, family='Mincho', l.spc=2)

## to use the Hack monospaced font
## which looks much nicer than Courier
X11Fonts('hack'=X11Font("-*-Hack-*-*-*-*-*-*-*-*-*-*-*-*"))
X11Fonts('Mono'=X11Font("-*-Monospace-*-*-*-*-*-*-*-*-*-*-*-*"))
X11Fonts('LibMono'=X11Font("-*-Liberation Mono-*-*-*-*-*-*-*-*-*-*-*-*"))

plot.new()
plot.window(xlim=c(0,100), c(0,100))
draw.code(code.f, 10, 90, cex=1, dark.bg=TRUE, family='hack', l.spc=1.8)

plot.new()
plot.window(xlim=c(0,100), c(0,100))
draw.code(code.f, 10, 90, cex=0.8, dark.bg=TRUE, family='Mono', l.spc=1.8)

plot.new()
plot.window(xlim=c(0,100), c(0,100))
draw.code(code.f, 10, 90, cex=0.8, dark.bg=TRUE, family='LibMono', l.spc=1.8)


## Use the extrafont package to make system fonts available
install.packages("extrafont")
library(extrafont)
##font_import()
## font_import is slow, but should only be necessary to run once on
## a given system.

loadfonts()

## And then we can use Hack to output a proper pdf.
pdf("example_code.pdf", width=7, height=14, title='code colored by coloriseR')
par(bg=rgb(0.3, 0.3, 0.3)) 
plot.new()
plot.window(xlim=c(0,100), c(0,100))
draw.code(code.f, 10, 90, cex=0.5, dark.bg=TRUE, family='Hack')
dev.off()


## use the constrained drawing
plot.new()
plot.window(xlim=c(0,100), c(0,100))
rect(10, 10, 90, 90)
draw.code.box(code.f, 10, 90, width=80, height=80, cex=0.5, dark.bg=TRUE, family='Monospace',
              moderation=0.15)

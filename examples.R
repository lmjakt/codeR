## examples usage of coloriseR and associated functions.
source("colorise_R.R")

code <- readLines("colorise_R.R")

code.f <- coloriseR(code)

x11()

par(bg=rgb(0.3, 0.3, 0.3))

plot.new()
plot.window(xlim=c(0,100), c(0,100))
draw.code(code.f, 10, 90, cex=1.5, dark.bg=TRUE)

plot.new()
plot.window(xlim=c(0,100), c(0,100))
draw.code(code.f, 10, 90, cex=1.5, dark.bg=TRUE, family='mono')

plot.new()
plot.window(xlim=c(0,100), c(0,100))
draw.code(code.f, 10, 90, cex=1.5, dark.bg=TRUE, family='Mincho')

## to use the Hack monospaced font
## which looks much nicer than Courier
X11Fonts('hack'=X11Font("-*-Hack-*-*-*-*-*-*-*-*-*-*-*-*"))

plot.new()
plot.window(xlim=c(0,100), c(0,100))
draw.code(code.f, 10, 90, cex=1, dark.bg=TRUE, family='hack')

## To output pdf with the Hack font
## this does not work
pdfFonts(hack=pdfFont("-*-Hack-*-*-*-*-*-*-*-*-*-*-*-*"))

## but the package extrafont may help here
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

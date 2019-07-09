## examples usage of coloriseR and associated functions.
source("colorise_R.R")

code <- readLines("colorise_R.R")

code.f <- coloriseR(code[70:100])

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
draw.code(code.f, 10, 90, cex=0.5, dark.bg=TRUE, family='Monospace')
dev.off()


## use the constrained drawing
par(mfrow=c(1,1))
plot.new()
plot.window(xlim=c(0,100), c(0,100))
rect(10, 10, 90, 90)
ppars <- draw.code.box(code.f, 10, 90, width=80, height=80, cex=0.5,
                       dark.bg=TRUE, family='Mono',
                       moderation=0.5)


pdf("example_code_2.pdf", width=7, height=7, title='code colored by coloriseR')
par(bg=rgb(0.3, 0.3, 0.3)) 
plot.new()
plot.window(xlim=c(0,100), c(0,100))
rect(10, 10, 90, 90, border=NA, col=rgb(0.4, 0.4, 0.4))
ppars <- draw.code.box(code.f, 10, 90, width=80, height=80, cex=0.5,
                       dark.bg=TRUE, family='mono', line.no=TRUE, l.spc=2.5,
                       zebra=c(rgb(0.3, 0.3, 0.3), rgb(0.4, 0.4, 0.4)),
                       moderation=0.5)
dev.off()


plot.new()
plot.window(xlim=c(0,100), c(0,100))
rect(10, 10, 90, 90)
ppars <- draw.code(code.f, 10, 90, cex=1, family='Mono', dark.bg=TRUE, l.spc=2,
                   line.no=TRUE,
                   zebra=c(rgb(0.3, 0.3, 0.3), rgb(0.35, 0.35, 0.35)))


plot.new()
plot.window(xlim=c(0,100), c(0,100))
rect(10, 10, 90, 90)
draw.code(code.f, 10, 90, cex=0.273, family='Mono', dark.bg=TRUE,
          zebra=c(rgb(0.3, 0.3, 0.3), rgb(0.35, 0.35, 0.35)))


## to get an arbitrary function we can do..
code <- c(head(classColors, n=-1), tail(classColors, n=1))
code.c <- coloriseR(code)
par(bg=rgb(0.3, 0.3, 0.3))

plot.new()
plot.window(xlim=c(0,100), ylim=c(0,100))
draw.code(code.c, 10, 90, dark.bg=TRUE, family="Mono", cex=1.2)

plot.new()
plot.window(xlim=c(0,100), c(0,100))
draw.code(code.c, 10, 90, cex=0.8, dark.bg=TRUE, family='Mono', l.spc=1.8)

rect(0,0,100,100)
plot.new()
plot.window(xlim=c(0,100), c(0,100))
draw.code(code.f, 10, 90, cex=0.8, dark.bg=TRUE, family='Mono', l.spc=1.8)

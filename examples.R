## examples usage of coloriseR and associated functions.
source("colorise_R.R")

code <- readLines("colorise_R.R")

code.f <- coloriseR(code[48:100])

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
par("mar"=c(2,2,2,2))
plot.window(xlim=c(0,100), c(0,100))
draw.code(code.f, 0, 100, cex=1, dark.bg=TRUE, family='hack', l.spc=1.8)

png("example_1.png", width=1200, height=1400)
par(bg=rgb(0.3, 0.3, 0.3)) 
par(mar=c(1,1,1,1))
plot.new()
plot.window(xlim=c(0,100), c(0,100))
draw.code(code.f, 0, 100, cex=1.5, dark.bg=TRUE, family='hack',
          l.spc=1.8, line.no=FALSE)
dev.off()

png("example_2.png", width=1200, height=1400)
par(bg=rgb(0.3, 0.3, 0.3)) 
par(mar=c(1,1,1,1))
plot.new()
plot.window(xlim=c(0,100), c(0,100))
draw.code(code.f, 0, 100, cex=1.5, dark.bg=TRUE, family='hack',
          l.spc=1.8, line.no=TRUE)
dev.off()

png("example_3.png", width=1200, height=1400)
par(bg=rgb(0.3, 0.3, 0.3)) 
par(mar=c(1,1,1,1))
plot.new()
plot.window(xlim=c(0,100), c(0,100))
draw.code(code.f, 0, 100, cex=1.5, dark.bg=TRUE, family='hack',
          l.spc=2, line.no=TRUE,
          zebra=c(rgb(0.3, 0.3, 0.3), rgb(0.3, 0.35, 0.35)))
dev.off()

## make a png of the text above:
png.code  <- c(
    'png("example_2.png", width=1200, height=1400)',
    'par(bg=rgb(0.3, 0.3, 0.3))',
    'par(mar=c(1,1,1,1))',
    'plot.new()',
    'plot.window(xlim=c(0,100), c(0,100))',
    "draw.code(code.f, 0, 100, cex=1.5, dark.bg=TRUE, family='hack',",
    '          l.spc=1.8, line.no=TRUE)',
    'dev.off()')

png.code.f  <- coloriseR(png.code)

png("png_example_1.png", width=1200, height=600)
par(bg=rgb(0.3, 0.3, 0.3)) 
par(mar=c(1,1,1,1))
plot.new()
plot.window(xlim=c(0,100), c(0,100))
draw.code(png.code.f, 0, 100, cex=1.5, dark.bg=TRUE, family='hack',
          l.spc=2, line.no=TRUE,
          zebra=c(rgb(0.3, 0.3, 0.3), rgb(0.3, 0.35, 0.35)))
dev.off()


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
## this doesn't always work. However the following should work

## to see the names of pdfFonts
names(pdfFonts())

pdf.mono  <- grep("mono", names(pdfFonts()), ignore.case=TRUE, value=TRUE)
## pdf.mono[2] is 'DejaVu Sans Mono' on my laptop. That seems the
## best of this set. Note that pdf.mono[4], 'Liberation Mono' does not
## work.

pdf("example_code.pdf", width=7, height=14, title='code colored by coloriseR')
par(bg=rgb(0.3, 0.3, 0.3)) 
par(mar=c(1,1,1,1))
plot.new()
plot.window(xlim=c(0,100), c(0,100))
draw.code(code.f, 0, 100, cex=0.5, dark.bg=TRUE,
          family=pdf.mono[2], l.spc=2)
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

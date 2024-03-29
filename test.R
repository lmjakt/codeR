## test the function to colorise R code


rlines <- readLines( "../MasterSource.R" )

dyn.load("colorise_R.so")
rlines.1 <- .Call("colorise_R", rlines[1:20])


## x is a list returned by colrise_R
write.code <- function(code, left, top, cex=1, col=1:4, font=1:3, l.spc=1.5){
    line.height <- strheight('A', cex=cex) * 1.5 ## seems not to matter
    x <- left
    for(i in 1:length(code[[1]])){
        y <- top - code[[1]][i] * line.height
        x <- ifelse( (i==1 || code[[1]][i-1] != code[[1]][i]), left,
                    x + strwidth( code[[2]][i-1], cex=cex,
                                  font=font[ 1 + code[[3]][i-1] %% length(font) ]) )
        text(x, y, code[[2]][i],
             col=col[ 1 + code[[3]][i] %% length(col) ],
             font=font[ 1 + code[[3]][i] %% length(font) ], cex=cex, adj=c(0,0) )
    }
}

write.monospace.code <- function(code, left, top, cex=1, col=1:4, font=1:3, l.spc=1.5,
                                 c.space=strwidth('A', cex=cex)){
    line.height <- strheight('A', cex=cex) * 1.5 ## seems not to matter
    code.c <- strsplit(code[[2]], '')
    n <- length(unlist(code.c))
    code.x <- rep(0, n)
    code.y <- rep(0, n)
    code.col <- rep(1,n)
    code.font <- rep(1,n)
    j <- 1
    x <- left
    for(i in 1:length(code.c)){
        y <- top - code[[1]][i] * line.height
        x <- ifelse( (i==1 || code[[1]][i-1] != code[[1]][i]), left, x )
        w.n <- length(code.c[[i]])
        if(!w.n)
            next
        k <- j + w.n - 1
        code.x[j:k] <- x + 1:w.n * c.space
        code.y[j:k] <- y
        code.col[j:k] <- col[ 1 + code[[3]][i] %% length(col) ]
        code.font[j:k] <- font[ 1 + code[[3]][i] %% length(font) ]
        x <- code.x[k]
        j <- k + 1
    }
    text(code.x, code.y, unlist(code.c), col=code.col, font=code.font, cex=cex,
         adj=c(0.5,0))
}

t.font <- c(1, 2, 3, 3, 1, 2)
t.cols <- c('black', 'blue', 'purple', 'dark green', 'red', rgb(0.6, 0, 0.6))


plot.new()
plot.window(xlim=c(0,100), ylim=c(0,100))
write.code(rlines.1, top=90, left=10, col=t.cols, font=t.font)

plot.new()
plot.window(xlim=c(0,100), ylim=c(0,100))
write.monospace.code(rlines.1, top=90, left=10, cex=0.8, c.space=strwidth('3', cex=0.8))


text(80, 60, "hello", font=1, cex=2, family='serif')

source("colorise_R.R")

rlines.2 <- coloriseR(rlines)

plot.window(xlim=c(0,100), ylim=c(0,100))
draw.code(rlines.2$code, top=90, left=10, col=t.cols, font=t.font)

## How does cex relate to spacing

cx <- 3 * 0.75^(1:12)

word <- "test"
sizes <- sapply(cx, function(cex){ c(strwidth(word, cex=cex), strheight(word, cex=cex))} )

par(mfrow=c(2,1))
plot( cx, sizes[1,], col='white' )
lm(sizes[1,] ~ cx )
abline(0, 0.037, col='white')
plot( cx, sizes[2,], col='white' )
lm(sizes[2,] ~ cx )
abline(0, 0.05, col='white')


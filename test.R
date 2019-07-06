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

plot.new()
plot.window(xlim=c(0,100), ylim=c(0,100))

write.code(rlines.1, top=90, left=10)

plot.new()
plot.window(xlim=c(0,100), ylim=c(0,100))
write.monospace.code(rlines.1, top=90, left=10, cex=0.8)
    

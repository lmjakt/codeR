## A small number of functions to facilitate the presentation of R
## code on screen.

dyn.load("colorise_R.so")

coloriseR <- function(lines){
    clines <- .Call("colorise_R", lines)
    df <- data.frame( 'i'=clines[[1]],
                     'string'=clines[[2]],
                     'class'=clines[[3]],
                     'description'=clines[[4]][ clines[[3]] + 1 ])
    list('code'=df, 'classes'=clines[[4]])
}

## tries to find some useful colors for a set of terms
classColors <- function(class.names, dark.bg=FALSE){
    n <- length(class.names)
    cols <- rep('black', n)
    if(dark.bg)
        cols <- rep('white', n)
    names(cols) <- class.names
    ## R simply adds elements to the end of the list if we
    ## try to assign using unknown names. So the following should
    ## be safe
    cols['function'] = ifelse(dark.bg, rgb(0.7, 0.7, 0.3), rgb(0.5, 0.1, 0.3))
    cols['s_quoted'] = ifelse(dark.bg, rgb(0.3, 0.8, 0.8), rgb(0.1, 0.5, 0.5))
    cols['d_quoted'] = ifelse(dark.bg, rgb(0.3, 0.8, 0.8), rgb(0.1, 0.5, 0.5))
    cols['comment'] = ifelse(dark.bg, rgb(0.9, 0.4, 0.4), rgb(0.6, 0.1, 0.1))
    cols['assignment'] = ifelse(dark.bg, rgb(0.8, 0.1, 0.8), rgb(0.7, 0.1, 0.7))
    cols
}

## returns a data frame giving both the numeric codes and
## their meaning
classFonts <- function(class.names){
    font.des <- c('plain', 'bold', 'italic', 'bold italic', 'symbol')
    n <- length(class.names)
    fonts <- rep(1, n)
    names(fonts) <- class.names
    fonts['function'] <- 2
    fonts['comment'] <- 3
    fonts['assignment'] <- 2
    data.frame( 'font'=fonts, 'desc'=font.des[ fonts ], stringsAsFactors=FALSE )
}

## code is a dataframe as returned by coloriseR
draw.code <- function(codes, left, top, cex=1, dark.bg=FALSE,
                      col=NULL, font=NULL, l.spc=1.5){
    if(is.null(col))
        col <- classColors(codes$classes, dark.bg)
    if(is.null(font)){
        font.classes <- classFonts(codes$classes)
        font <- font.classes$font
    }else{
        font.classes <- font
    }
    code <- codes$code
    line.height <- strheight('A', cex=cex) * l.spc ## seems not to matter
    x <- left
    for(i in 1:nrow(code)){
        y <- top - code[i,1] * line.height
        x <- ifelse( (i==1 || code[i-1,1] != code[i,1]), left,
                    x + strwidth( code[i-1, 2], cex=cex,
                                 font=font[ 1 + code[i-1, 3] %% length(font) ]) )
        text(x, y, code[i,2],
             col=col[ 1 + code[i,3] %% length(col) ],
             font=font[ 1 + code[i,3] %% length(font) ],
             cex=cex, adj=c(0,0) )
    }
    invisible(list('cols'=col, 'fonts'=font.classes))
}

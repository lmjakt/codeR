## A small number of functions to facilitate the presentation of R
## code on screen.

dyn.load("colorise_R.so")

coloriseR <- function(lines){
    clines <- .Call("colorise_R", lines)
    df <- data.frame('i'=clines[[1]],
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

## codes is a list as returned by coloriseR
## which contains a datarame called code
draw.code <- function(codes, left, top, cex=1, dark.bg=FALSE,
                      col=NULL, font=NULL, l.spc=1.5,
                      do.draw=TRUE, line.no=FALSE,
                      line.font=3, line.margin=1,
                      line.col=ifelse(dark.bg,
                                      rgb(0.7, 0.7, 0.7),
                                      rgb(0.3, 0.3, 0.3)),
                      zebra=NULL,
                      ...){
    if(is.null(col))
        col <- classColors(codes$classes, dark.bg)
    if(is.null(font)){
        font.classes <- classFonts(codes$classes)
        font <- font.classes$font
    }else{
        font.classes <- font
    }
    code <- codes$code
    ## All characters have the same height
    line.height <- strheight('A', cex=cex, ...) * l.spc 
    pos <- matrix(nrow=nrow(code), ncol=3)
    colnames(pos) <- c('x', 'w', 'y')
    pos[,'y'] <- (top - code[,1] * line.height) - line.height/2   
    for(i in 1:nrow(code)){
        y <- top - code[i,1] * line.height
        pos[i,'w'] <- strwidth(code[i, 2], cex=cex,
                               font=font[ 1 + code[i, 3] %% length(font) ], ...)
        pos[i,'x'] <- ifelse( (i==1 || code[i-1,1] != code[i,1]), left,
                            pos[i-1,'x'] + pos[i-1,'w'] )
    }
    text.w <- max( pos[,'x'] + pos[,'w'] )
    labels <- 0:max(code[,1])
    labels.y <- (top - labels * line.height) - line.height/2
    labels <- labels + 1
    labels.w <- max(strwidth(labels, cex=cex, font=line.font)) +
        line.margin * strwidth("9", cex=cex, font=line.font)
    labels.col <- line.col
    if(line.no){
        pos[,'x'] <- pos[,'x'] + labels.w
        text.w  <- text.w + labels.w
    }
    if(do.draw){
        if(!is.null(zebra)){
            rect(left, labels.y - line.height/2, left + text.w, labels.y + line.height/2,
                 col=zebra, border=NA)
        }
        text(pos[,'x'], pos[,'y'], code[,2],
             col=col[ 1 + code[,3] %% length(col) ],
             font=font[ 1 + code[,3] %% length(font) ],
             cex=cex, adj=c(0,0.5), ... )
        if(line.no)
            text(left, labels.y, labels, col=labels.col, cex=cex,
                 font=line.font, adj=c(0,0.5), ...)
        }
    invisible(list('cols'=col, 'fonts'=font.classes, 'pos'=pos, 'lheight'=line.height))
}

## scales the text to fit the box specified.. 
draw.code.box <- function(codes, left, top, width, height,
                          justify=c(0.5, 0.5),
                          cex=1, dark.bg=FALSE,
                          col=NULL, font=NULL, l.spc=1.5,
                          line.no=FALSE,
                          line.font=3, line.margin=2,
                          line.col=ifelse(dark.bg,
                                          rgb(0.7, 0.7, 0.7),
                                          rgb(0.3, 0.3, 0.3)),
                          maxiter=20, moderation=0.2,
                          ...){
    iter <- 1
    while(iter <- maxiter){
        pos <- draw.code(codes, left, top, cex, dark.bg,
                         col, font, l.spc,
                         do.draw=FALSE, line.no,
                         line.font, line.margin,
                         line.col, ...)
        w <- max( pos$pos[,'x'] + pos$pos[,'w'] - left )
        h <- pos$lheight + max(pos$pos[,'y']) - min(pos$pos[,'y'])
        print(paste("cex:", cex, " w:", w, " h:", h))
        if(w < width && h < height)
            break
        cex <- cex * exp( moderation * min( c(log(width/w), log(height / h) )) )
        ## and try again... 
        iter <- iter + 1
    }
    pos <- draw.code(codes, left, top, cex, dark.bg,
              col, font, l.spc,
              do.draw=TRUE, line.no,
              line.font, line.margin,
              line.col, ...)
    return(c('pos'=pos, 'cex'=cex))
    rect(left, top-h, left+w, top)
}

# $Id: minDirection.R 88 2010-11-13 23:26:02Z Lars $

# Function to calculate the min step for each input or max step for
# each output to the frontier, retninger i MEA. A series of LP problems

minDirection <- function(lps, Z, m, n, ORIENTATION, LP=FALSE)  {
   md <- length(Z)
   if ( ORIENTATION=="in" && md != m )
      stop("Input dimensions wrong in minDirection, internal bug")
   if ( ORIENTATION=="out" && md != n )
      stop("Output dimensions wrong in minDirection, internal bug")

   if (LP) print(lps)
   # Saet taeller for fooerste vare
   mn0 <- switch(ORIENTATION, "in"=0, "out"=m, "in-out"=0)
   zSign <- 1 - 2*(ORIENTATION=="in")
  
   lpcontr <- lp.control(lps)
   eps <- sqrt(lpcontr$epsilon["epsint"])
   if (LP) print(paste("eps =",eps))
   Direct <- rep(NA,md)
   for ( h in 1:md )  {
      if (LP) print(paste(" -->  Vare",h),quote=FALSE)
      if ( h>1) set.rhs(lps, zSign*Z[h-1], mn0+h-1)       
      set.rhs(lps, 0, mn0+h)       
      set.column(lps, 1, c(1,1),c(0,mn0+h))
      if (LP) print(lps)
      solve(lps)
      if (LP) print(get.objective(lps))
      temp_ <- get.objective(lps)
      if ( abs(temp_) < eps )  temp_ <- 0.0
      Direct[h] <- temp_
   }
   Direct <- Z - Direct
   if (LP) { print("Min direction:"); print(Direct) }
   return(Direct)
}



# mea er en wrapper for dea med special vaerdi af DIRECT

mea <-  function(X,Y, RTS="vrs", ORIENTATION="in", XREF=NULL, YREF=NULL,
         FRONT.IDX=NULL,
         TRANSPOSE=FALSE, LP=FALSE, CONTROL=NULL, LPK=NULL)  {

   e <- dea(X,Y, RTS, ORIENTATION, XREF, YREF,
            FRONT.IDX, SLACK=FALSE, DUAL=FALSE, DIRECT="min", 
            TRANSPOSE=FALSE, LP=LP, CONTROL=CONTROL, LPK=LPK)

   return(e)

}



# Tegn linjer for MEA

mea.lines <- function(N, X, Y)  {
for ( n in N )  {
   abline(h=X[n,2],lty="dotted")
   abline(v=X[n,1],lty="dotted")
   vn <- dea(X[n,,drop=FALSE],Y[n,,drop=FALSE],
             XREF=X, YREF=Y,FAST=TRUE,DIRECT=c(X[n,1],0))
   hn <- dea(X[n,,drop=FALSE],Y[n,,drop=FALSE],
             XREF=X, YREF=Y,FAST=TRUE,DIRECT=c(0,X[n,2]))
   abline(h=(1-hn)*X[n,2],lty="dotted")
   abline(v=(1-vn)*X[n,1],lty="dotted")
   # lines(c((1-vn)*X[n,1], X[n,1]), c(h=(1-hn)*X[n,2], X[n,2]),lw=2)
   arrows(X[n,1], X[n,2], (1-vn)*X[n,1], (1-hn)*X[n,2], lwd=2 )

   abline(0, X[n,2]/X[n,1],lty="dashed", col="red")
   abline(X[n,2] - X[n,1]*(X[n,2]-(1-hn)*X[n,2])/(X[n,1]-(1-vn)*X[n,1]), 
          (X[n,2] - (1-hn)*X[n,2])/(X[n,1] - (1-vn)*X[n,1]) , 
          lty="dashed", col="blue")
} 
}


# 
# smea <-  function(X,Y, RTS="vrs", ORIENTATION="in", XREF=NULL, YREF=NULL,
#          FRONT.IDX=NULL,
#          TRANSPOSE=FALSE, LP=FALSE, CONTROL=NULL, LPK=NULL)  {
# 
#    e <- sdea(X,Y, RTS, ORIENTATION, DIRECT="min", 
#              TRANSPOSE=FALSE, LP=LP)
# 
#    return(e)
# 
# }
# 
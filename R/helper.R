#' General helper functions
#'
#' Helper functions for ego centric network analysis
#'
#' @template max_alteri
#' @template directed
#' @param x \code{Numeric}.
#' @param y \code{Numeric}.
#' @name helper
NULL

#' @describeIn helper Returns the count of possible edges in an
#' undirected or directed, ego-centered network, based on the number of alteri.
dyad.poss <- function(max.alteri, directed = F) {
  dp <- (max.alteri^2-max.alteri)
  if (!directed) {
    dp <- dp/2 
  }
  dp
}

#' @describeIn helper Generates a \code{data.frame} marking possible dyads in 
#' a wide alter-alter relation \code{data.frame}. Row names corresponds to the 
#' network size. This is useful for sanitizing alter-alter relations in the wide 
#' format.
#' @export
sanitize.wide.edges <- function(max.alteri) {
  x <- max.alteri
  dp <- dyad.poss(x)
  
  names_ <- create.edge.names.wide(x)
  
  m <- matrix(0, nrow = x, ncol = x)
  m[lower.tri(m)] <- 99
  m1 <- m[, 1:(x-1)]
  for(i in 2:x){
    m1 <- cbind(m1, m[, i:(x-1)])
  }
  m1 <- m1[, 1:dp]
  
  df <- data.frame(m1)
  names(df) <- names_
  df
}

#' @describeIn helper Creates a \code{vector} of names for variables 
#' containing data on alter-alter relations/ dyads in ego-centered networks.
#' @export
create.edge.names.wide <- function(x) {
  leading.zeros.character <- paste("%0",
                                   nchar(as.character(x)),
                                   "d", sep = "")
  
  names_ <- c()
  for(i in 1:(x-1)){
    for(j in (i+1):x){
      i_ <- sprintf(leading.zeros.character, i)
      j_ <- sprintf(leading.zeros.character, j)
      names_ <- c(names_, paste(i_,j_,sep=" to "))
    }
  }
  names_
}

#' @describeIn helper Calculates the possible edges between members of 
#' different groups in an ego-centered network.
#' @export
dyads.possible.between.groups <- function(x, y) x*y

#' @describeIn helper Calculates the optimal distribution of a number of 
#' equally sized objects on a DIN-Norm DIN 476 (i.e. DIN A4) page in landscape 
#' view.
#' @export
din.page.dist <- function(x) {
  for(yps in 2:x) {
    ix <- x / yps
    if(ix/yps <= sqrt(2)) {
      break()  
    }
  }
  c(x = ceiling(ix),y = ceiling(yps))
}
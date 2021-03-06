% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/composition.R
\name{comp.cat.counts}
\alias{comp.cat.counts}
\title{Count category frequencies of an alter attribute for ego-centered-network data.}
\usage{
comp.cat.counts(alteri, var, egoID = "egoID", fun = fun.count)
}
\arguments{
\item{alteri}{A 'long' dataframe with alteri in rows.}

\item{var}{Alter attribute which categories are to be counted.}

\item{egoID}{\code{Character} giving the name of the variable identifying 
egos (default = "egoID") in \code{alteri}.}

\item{fun}{Function to be used for counting. \code{fun.count} for absolute counts \code{fun.prop} propotional counts.}
}
\value{
Returns a \code{dataframe} with counts of all categories as variables.
}
\description{
This function counts the category frequencies (absolute or proportional) of a variable representing alter attributes in ego-centered-network data.
}
\keyword{internal}


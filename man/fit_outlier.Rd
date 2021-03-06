% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/api_fit_outlier.R
\name{fit_outlier}
\alias{fit_outlier}
\title{Outlier detection}
\usage{
fit_outlier(
  A,
  adj,
  z = NULL,
  alpha = 0.05,
  nsim = 10000,
  ncores = 1,
  validate = TRUE
)
}
\arguments{
\item{A}{Character matrix or data.frame. All values must be limited to a single character.}

\item{adj}{Adjacency list or \code{gengraph} object of a decomposable graph.
See package \code{ess} for \code{gengraph} objects.}

\item{z}{Named vector (same names as \code{colnames(A)}) or \code{NULL}. See details.
Values must be limited to a single character.}

\item{alpha}{Significance level}

\item{nsim}{Number of simulations}

\item{ncores}{Number of cores to use in parallelization}

\item{validate}{Logical. If true, it checks if \code{A} only has single character
values and converts it if not.}
}
\value{
A \code{outlier_model} object with either \code{novelty} or \code{outlier}
as child classes. These are used for different purposes. See the details
}
\description{
Detecting outliers within a dataset or test if a new (novel) observation is an outlier.
}
\details{
If the goal is to detect outliers within \code{A} set \code{z} to \code{NULL};
this procedure is most often just referred to as outlier detection. Once \code{fit_outlier}
has been called in this situation, one can exploit the \code{outliers} function to get the
indicies for which observations in \code{A} that are outliers. See the examples.

On the other hand, if the goal is test if the new unseen observation \code{z} is an outlier
in\code{A}, then supply a named vector to \code{z}.

All values must be limited to a single character representation; if not, the function will
internally convert to one such representation. The reason for this, is a speedup in runtime
performance. One can also use the exported function \code{to_chars} on \code{A} in
advance and set \code{validate} to \code{FALSE}. 

The \code{adj} object is most typically found using \code{fit_graph} from the \code{ess}
package. But the user can supply an adjacency list, just a named \code{list}, of their own
choice if needed.
}
\examples{

library(dplyr)
library(ess)  # For the fit_graph function
set.seed(7)   # For reproducibility

# Psoriasis patients
d <- derma \%>\%
  filter(ES == "psoriasis") \%>\%
  select(1:20) \%>\% # only a subset of data is used to exemplify
  as_tibble()

# Fitting the interaction graph
# see package ess for details
g <- fit_graph(d, trace = FALSE) 
plot(g)

# -----------------------------------------------------------
#                        EXAMPLE 1
#    Testing which observations within d are outliers
# -----------------------------------------------------------

# Only 500 simulations is used here to exeplify
# The default number of simulations is 10,000
m1 <- fit_outlier(d, g, nsim = 500)
print(m1)
outs  <- outliers(m1)
douts <- d[which(outs), ]
douts

# Notice that m1 is of class 'outlier'. This means, that the procedure has tested which
# observations _within_ the data are outliers. This method is most often just referred to
# as outlier detection. The following plot is the distribution of the test statistic. Think
# of a simple t-test, where the distribution of the test statistic is a t-distribution.
# In order to conclude on the hypothesis, one finds the critical value and verify if the
# test statistic is greater or less than this.

# Retrieving the test statistic for individual observations
x1 <- douts[1, ] \%>\% unlist()
x2 <- d[1, ] \%>\% unlist()
dev1 <- deviance(m1, x1) # falls within the critical region in the plot (the red area)
dev2 <- deviance(m1, x2) # falls within the acceptable region in the plot

dev1
dev2

# Retrieving the pvalues
pval(m1, dev1)
pval(m1, dev2)

# -----------------------------------------------------------
#                        EXAMPLE 2
#         Testing if a new observation is an outlier
# -----------------------------------------------------------

# An observation from class "chronic dermatitis"
z <- derma \%>\%
  filter(ES == "chronic dermatitis") \%>\%
  select(1:20) \%>\%
  slice(1) \%>\%
  unlist()

# Test if z is an outlier in class "psoriasis"
# Only 500 simulations is used here to exeplify
# The default number of simulations is 10,000
m2 <- fit_outlier(d, g, z, nsim = 500)
print(m2)
plot(m2) # Try using more simulations and the complete derma data

# Notice that m2 is of class 'novelty'. The term novelty detection
# is sometimes used in the litterature when the goal is to verify
# if a new unseen observation is an outlier in a homogen dataset.

# Retrieving the test statistic and pvalue for z
dz <- deviance(m2, z)
pval(m2, dz)

}
\seealso{
\code{\link{fit_mixed_outlier}}, \code{\link{fit_multiple_models}},
\code{\link{outliers}}, \code{\link{pval}}, \code{\link{deviance}}
}

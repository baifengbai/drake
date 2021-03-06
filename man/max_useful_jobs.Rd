% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/deprecate.R
\name{max_useful_jobs}
\alias{max_useful_jobs}
\title{Deprecated function}
\usage{
max_useful_jobs(config = drake::read_drake_config(), imports = c("files",
  "all", "none"), from_scratch = FALSE)
}
\arguments{
\item{config}{internal configuration list of \code{\link{make}(...)},
produced also with \code{\link[=drake_config]{drake_config()}}.}

\item{imports}{Set the \code{imports} argument to change your
assumptions about how fast objects/files are imported.}

\item{from_scratch}{logical, whether to assume
the next \code{\link[=make]{make()}} will run from scratch
so that all targets are attempted.}
}
\value{
A numeric scalar, the maximum number of useful jobs for
\code{\link{make}(..., jobs = ...)}.
}
\description{
Do not use this function. \code{Drake}'s parallel algorithm
has changed since version 5.1.2, so \code{max_useful_jobs()}
will give you the wrong idea of how many jobs to use. Instead,
use the \code{\link[=predict_runtime]{predict_runtime()}} function with a sensible value
for \code{known_times} and \code{default_time}
to cover any targets not built so far.
}
\details{
Deprecated on May 4, 2018.
}
\examples{
# Do not use this function. Use predict_runtime() instead.
# Pay special attention to the force_times and default_time
# arguments.
}
\seealso{
\code{\link[=predict_runtime]{predict_runtime()}}
}
\keyword{internal}

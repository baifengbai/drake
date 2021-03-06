% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/workplan.R
\name{knitr_in}
\alias{knitr_in}
\title{Declare the \code{knitr}/\code{rmarkdown} source files
of a workflow plan command.}
\usage{
knitr_in(...)
}
\arguments{
\item{...}{Character strings. File paths of \code{knitr}/\code{rmarkdown}
source files supplied to a command in your workflow plan data frame.}
}
\value{
A character vector of declared input file paths.
}
\description{
Use this function to help write the commands
in your workflow plan data frame. See the examples
for a full explanation.
}
\examples{
\dontrun{
test_with_dir("Contain side effects", {
# `knitr_in()` is like `file_in()`
# except that it analyzes active code chunks in your `knitr`
# source file and detects non-file dependencies.
# That way, updates to the right dependencies trigger rebuilds
# in your report.
# The mtcars example (`drake_example("mtcars")`)
# already has a demonstration
load_mtcars_example()
config <- make(my_plan)
vis_drake_graph(config)
# Now how did drake magically know that
# `small`, `large`, and `coef_regression2_small` were
# dependencies of the output file `report.md`?
# because the command in the workflow plan had
# `knitr_in("report.Rmd")` in it, so drake knew
# to analyze the active code chunks. There, it spotted
# where `small`, `large`, and `coef_regression2_small`
# were read from the cache using calls to `loadd()` and `readd()`.
})
}
}
\seealso{
\code{\link[=file_in]{file_in()}}, \code{\link[=file_out]{file_out()}}, \code{\link[=ignore]{ignore()}}
}

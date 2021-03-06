% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/correctCRU.R
\name{correctCRU}
\alias{correctCRU}
\title{correctCRU}
\usage{
correctCRU(x, subtype)
}
\arguments{
\item{x}{magpie object provided by the read function}

\item{subtype}{Switch between diffrent input}
}
\value{
List of magpie objects with results on cellular level, weight, unit and description.
}
\description{
Correct CRU content
}
\examples{

\dontrun{
  readSource("CRU", subtype="precipitation", convert="onlycorrect")
}

}
\seealso{
\code{\link{readCRU}},
\code{\link{read.LPJ_input}}
}
\author{
Kristine Karstens
}

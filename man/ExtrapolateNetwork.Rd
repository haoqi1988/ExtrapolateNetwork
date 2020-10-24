\name{ExtrapolateNetwork}
\alias{ExtrapolateNetwork}
\title{Network Extrapolation}
\usage{
ExtrapolateNetwork(df,a,N)
}
\arguments{
\item{df,a,N}{3 inputs}
}
\value{
df is the empirical dataframe, a is the number of attributes, N is the number of desired nodes in the network
}
\description{
This package is designed to generate full networks for ABMs from survey data.
    For example, the survey asked people about their attributes, say, ethnicity, and also asked them
    whom they friend with, what attributes their friends have, and how many such friends they each have.
    say, a paricipant could be white, have 4 white friends, 3 black friends and 1 asian friend in his network.
    Then, this package could be used to generate a full network, based on these ego network data, that represents
    1. the attribute distribuion
    2. the degree distribution,
    3. the attribute by degree distribution,
    4. the attribute by degree by link type (e.g. black-white link, asian-asian link) distribution
    of the dataset.
}
\examples{

}

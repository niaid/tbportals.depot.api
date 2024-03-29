% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/setup.R
\name{store_secret_credentials}
\alias{store_secret_credentials}
\title{Store secret credentials in local Renvironment for reuse}
\usage{
store_secret_credentials()
}
\value{
Stores user credentials in a local .Renviron file
}
\description{
\code{store_secret_credentials} is a function to be executed interactively in Rstudio.
It will prompt the user to input the email associated with the API credentials they have
been provided in the form of a secret as well as the secret itself and save it locally as a
.Renviron file so that they can be reused moving forward without having to reenter the info.
}
\details{
\code{store_secret_credentials} should only be used within Rstudio or else will throw an error. It is best practice to run
this function first to store your user credentials to access the Tidy Depot API and then use the other functions
as part of the package subsequently. For example, \code{get_token} function needs the email address and secret you were provided to access
the Tidy Depot API and this function will automatically retrieve this data if you have correctly run \code{store_secret_credentials}
first.  It is possible to run \code{get_token} and provide your email address and secret key to the "email_address" and "secret"
arguments but it is not best practice and users should be sure to remove any evidence in the .Rhistory files or they may accidentally
share their credentials unintentionally with others.
}
\author{
Gabriel Rosenfeld, \email{gabriel.rosenfeld@nih.gov}
}

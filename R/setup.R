#' Store secret credentials in local Renvironment for reuse
#'
#' @author Gabriel Rosenfeld, \email{gabriel.rosenfeld@@nih.gov}
#'
#' @description
#' `store_secret_credentials` is a function to be executed interactively in Rstudio.
#' It will prompt the user to input the email associated with the API credentials they have
#' been provided in the form of a secret as well as the secret itself and save it locally as a
#' .Renviron file so that they can be resued moving forward without having to reenter the info.
#'
#' @details
#' `store_secret_credentials` should only be used within Rstudio or else will throw an error. It is best practice to run
#' this function first to store your user credentials to access the Tidy Depot API and then use the other functions
#' as part of the package subsequently. For example, `get_token` function needs the email address and secret you were provided to access
#' the Tidy Depot API and this function will automatically retrieve this data if you have correctly run `store_secret_credentials`
#' first.  It is possible to run `get_token` and provide your email address and secret key to the "email_address" and "secret"
#' arguments but it is not best practice and users should be sure to remove any evidence in the .Rhistory files or they may accidentally
#' share their credentials unintentionally with others.
#'
#' @return Stores user credentials in a local .Renviron file
#'
#' @example
#' \dontrun{
#' store_secret_credentials() # Run in Rstudio
#' }
#'
#' @export
store_secret_credentials <- function() {
  .s <- rstudioapi::askForPassword(prompt = "Please copy and paste the secret you received to be stored")
  if(file.exists("~/.Renviron")){
    cat(x = "\n", file = "~/.Renviron", append = T)
    cat(x = glue::glue("DEPOT_API_SECRET = {.s}"), file = "~/.Renviron", append = T)
    cat(x = "\n", file = "~/.Renviron", append = T)
  }else{
    file.create("~/.Renviron")
    cat(x = "\n", file = "~/.Renviron", append = T)
    cat(x = glue::glue("DEPOT_API_SECRET = {.s}"), file = "~/.Renviron")
    cat(x = "\n", file = "~/.Renviron", append = T)
  }

  .e <- rstudioapi::askForPassword(prompt = "Please input your email where you received the secret")
  cat(x = "\n", file = "~/.Renviron", append = T)
  cat(x = glue::glue("DEPOT_API_SECRET_EMAIL = {.e}"), file = "~/.Renviron", append = T)
  cat(x = "\n", file = "~/.Renviron", append = T)

}

#' Get secret in local Renvironment for reuse
#'
#' @author Gabriel Rosenfeld, \email{gabriel.rosenfeld@@nih.gov}
#'
#' @description
#' `get_secret` is a function that retrieves the secret credentials stored in the local .Renviron
#' file from the `store_secret_credentials`.
#'
#' @details
#' `get_secret` should most likely never be run by the user as it is an internal function that will be
#' passed to other functions like `get_token`.  Nevertheless, it may be useful for a user who wants to
#' check the secret that was saved in the local .Renviron file for errors.  If the secret is incorrect,
#' the user may consider rerunning `store_secret_credentials` and copying and pasting the correct secret
#' as part of that prompt.
#'
#' @return string of the secret
#'
#' @example
#' \dontrun{
#' get_secret()
#' }
#'
#' @export
get_secret <- function() {

  if (!file.exists("~/.Renviron")) {
    stop("Please set env var DEPOT_API_SECRET to your secret that you received using store_secret_credentials function",
         call. = FALSE)
  }
  readRenviron("~/.Renviron")
  pat <- Sys.getenv('DEPOT_API_SECRET')
  if (identical(pat, "")) {
    stop("Please set env var DEPOT_API_SECRET to your secret that you received using store_secret_credentials function",
         call. = FALSE)
  }
  return(Sys.getenv("DEPOT_API_SECRET"))
}

#' Get email associated with secret in local Renvironment for reuse
#'
#' @author Gabriel Rosenfeld, \email{gabriel.rosenfeld@@nih.gov}
#'
#' @description
#' `get_secret_email` is a function that retrieves the email address associated with the credentials stored in the local .Renviron
#' file from the `store_secret_credentials`.
#'
#' @details
#' `get_secret_email` should most likely never be run by the user as it is an internal function that will be
#' passed to other functions like `get_token`.  Nevertheless, it may be useful for a user who wants to
#' check the email address that was saved in the local .Renviron file for errors.  If the email address is incorrect,
#' the user may consider rerunning `store_secret_credentials` and inputting the correct email address as
#' part of the prompt.
#'
#' @return string of the email address
#'
#' @example
#' \dontrun{
#' get_secret_email()
#' }
#'
#' @export
get_secret_email <- function() {

  if (!file.exists("~/.Renviron")) {
    stop("Please set env var DEPOT_API_SECRET_EMAIL to the email address where you received your secret using store_secret_credentials function",
         call. = FALSE)
  }
  readRenviron("~/.Renviron")
  pat <- Sys.getenv('DEPOT_API_SECRET_EMAIL')
  if (identical(pat, "")) {
    stop("Please set env var DEPOT_API_SECRET_EMAIL to the email address where you received your secret using store_secret_credentials function",
         call. = FALSE)
  }
  return(Sys.getenv("DEPOT_API_SECRET_EMAIL"))
}

#' Generate a token from the TB DEPOT tidy API
#'
#' @author Gabriel Rosenfeld, \email{gabriel.rosenfeld@@nih.gov}
#'
#' @description
#' `get_token` is a function that retrieves a token string from the API that
#' is required as part of submitting a correct `tidy_depot_api` request in the token parameter.
#'
#' @details
#' `get_token` should work as a function call without having to pass any user parameters provided
#' the user has correctly run `store_secret_credentials` to save these credentials locally in an
#' .Renviron file.  `get_token` will then use that information to request a token string from the API
#' and return this string.  The string can then be used for the `tidy_depot_api` function int he token
#' parameter to request data and validate the user's credentials.
#'
#' @param email_address email address associated with secret
#' @param secret secret used for generating API token
#' @return The token string used for Authentication header in API calls
#'
#' @example
#' \dontrun{
#' get_token() # If user has correctly saved their credentials via store_secret_credentials(), which is best practice
#'
#' get_token(email_address = "USER_EMAIL_ADDRESS", secret = "USER_SECRET") # Bad practice and be sure to clear your history
#' }
#'
#' @export
get_token <- function(email_address = get_secret_email(),
                      secret = get_secret()) {
  return(httr::content(httr::GET(url = httr::modify_url("https://analytic.tbportals.niaid.nih.gov/api/Token",
                                                        query = list(emailAddress = email_address,
                                                                     secret = secret)))))
}

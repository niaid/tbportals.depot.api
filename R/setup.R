#' Store secret credentials in local Renvironment for reuse
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
#' @param email_address email address associated with secret
#' @param secret secret used for generating API token
#' @return The token string used for Authentication header in API calls
#'
#' @export
get_token <- function(email_address = get_secret_email(),
                      secret = get_secret()) {
  return(httr::content(httr::GET(url = httr::modify_url("https://analytic.tbportals.niaid.nih.gov/api/Token",
                                                        query = list(emailAddress = email_address,
                                                                     secret = secret)))))
}

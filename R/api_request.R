#' Generate a DEPOT tidy API request
#'
#' @author Gabriel Rosenfeld, \email{gabriel.rosenfeld@@nih.gov}
#'
#' @description
#' `tidy_depot_api` executes an api request for the path endpoint (e.g. Patient-Case) and
#' returns a tidy_depot_api class object with the API call results unless there is an error
#'
#' @details
#' This function depends upon setting up your user credentials to access the Tidy Depot API locally including your email address
#' and secret key using `store_secret_credentials` in Rstudio.  This will prompt you to store that information in a local .Renviron
#' file.  Afterwards, retrieve a unique token string using the `get_token` function which is passed as the token arguent to the
#' `tidy_depot_api` function along with the path end point of interest.  Any erros will be returned instead of the API call notifying
#' that there may be an issue with either your credentials or the endpoint name.
#'
#'
#' @param path The name of an endpoint of interest (e.g. Biochemistry)
#' @param token The token string returned from get_token() function
#' @param cohortId The int string containing the cohortId of interest from DEPOT
#'
#' @return An object of class tidy_depot_api containing API call results
#'
#' @example
#' \dontrun{
#' store_secret_credentials() # Run in Rstudio
#' t <- get_token()
#' tidy_depot_api(path = "Patient-Case", token = t)
#' tidy_depot_api(path = "Patient-Case", token = t, cohortId = "Paste id number here from DEPOT")
#' }
#'
#' @export
tidy_depot_api <- function(path, token, cohortId = ""){
  url <- httr::modify_url(url = "https://analytic.tbportals.niaid.nih.gov",
                          path = glue::glue("/api/{path}"), query = list(returnCsv = "false",
                                                                         cohortId = cohortId))

  resp <- httr::GET(url = url, httr::add_headers(accept = "application/json",
                                                 Authorization = glue::glue("Bearer {token}")))

  if (httr::http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }



  if (httr::status_code(resp) != 200) {
    stop(
      sprintf(
        "DEPOT Tidy API request failed [%s]\n%s\n<%s>",
        httr::status_code(resp),
        parsed$message,
        parsed$documentation_url
      ),
      call. = FALSE
    )
  }

  parsed <- jsonlite::fromJSON(httr::content(resp, "text"), simplifyVector = TRUE) %>%
    readr::type_convert()

  structure(
    list(
      content = parsed,
      path = path,
      response = resp
    ),
    class = "tidy_depot_api"
  )
}


#' Generate a DEPOT tidy API request
#'
#' @param path The name of an endpoint of interest (e.g. Biochemistry)
#' @param token The token string returned from get_token() function
#'
#' @return An object of class tidy_depot_api containing API call results
#'
#' @export
tidy_depot_api <- function(path, token){
  url <- httr::modify_url(url = "https://analytic.tbportals.niaid.nih.gov",
                    path = glue::glue("/api/{path}"), query = list(returnCsv = "false"))

  resp <- httr::GET(url = url, httr::add_headers(accept = "application/json",
                                     Authorization = glue::glue("Bearer {token}")))

  if (httr::http_type(resp) != "application/json") {
    stop("API did not return json", call. = FALSE)
  }

  parsed <- jsonlite::fromJSON(httr::content(resp, "text"), simplifyVector = TRUE)

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

  structure(
    list(
      content = parsed,
      path = path,
      response = resp
    ),
    class = "tidy_depot_api"
  )
}

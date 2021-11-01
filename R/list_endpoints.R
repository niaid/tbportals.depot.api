#' List data end points for API
#'
#' @author Gabriel Rosenfeld, \email{gabriel.rosenfeld@@nih.gov}
#'
#' @description
#' `list_endpoints` generates a convenient data.frame listing the endpoint name under "endpoint"
#' along with a high-level general description of the endpoint data under "description"
#'
#' @details
#' `list_endpoints` will list the available endpoints that return data from the Tidy Depot API along with
#' a description of the type of data provided.  It is a useful function to ensure that the name provided
#' as part of the "path" argument to `tidy_depo_api` function call.  If the name provided to the path
#' argument is incorrent then an error will be thrown and no API call returned.
#'
#'
#'
#' @return data frame of available endpoints
#'
#' @example
#' list_endpoints()
#'
#' @export
list_endpoints <- function(){
  data.table(
    #endpoint = c("Biochemistry", "CT", "CT-Annotation",
    endpoint = c("XX", "CT", "CT-Annotation",
                 "CXR", "CXR-Manual-Annotation", "CXR-Qure-Annotation",
                 "DST", "Genomics", "Patient-Case", "Specimen",
                 "Treatment-Regimen"),
    description = c("Laboratory and biochemistry records information",
                    "Computed Tomagraphy records information",
                    "Computed Tomagraphy records radiologist annotations",
                    "Chest X ray records information",
                    "Chest X ray records radiologist annotations",
                    "Chest X ray records Qure AI algorithm annotations",
                    "Drug sensitivity testing results records",
                    "Pathogen genomics records information",
                    "Patient case record information",
                    "Specimen record information",
                    "Treatment and regiment record information")
  )
}

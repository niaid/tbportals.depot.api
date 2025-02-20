
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tbportals.depot.api

<!-- badges: start -->

[![R-CMD-check](https://github.com/niaid/tbportals.depot.api/workflows/R-CMD-check/badge.svg)](https://github.com/niaid/tbportals.depot.api/actions)
<!-- badges: end -->

tbportals.depot.api R package aims to provide a convenient wrapper
functionality in R to the TB Portals Analytic API containing the tidy
analytic data from TB Portals DEPOT database. For more information about
TB Portals, check out the [TB Portals
website](https://tbportals.niaid.nih.gov/).

## Installation

``` r
# Install release version from CRAN
install.packages("tbportals.depot.api") # Not available yet

# Install development version from GitHub
devtools::install_github("niaid/tbportals.depot.api")
```

## Usage

Please see Article, “Setting up connection to API”, before following
along with the code example below as it assumes you have saved your
credentials locally which are required for interacting with the API.

This is a basic example which shows you how to solve a common problem of
pulling all the data from an endpoint (for other end points check out
[link](https://analytic.tbportals.niaid.nih.gov/index.html):

``` r
library(tbportals.depot.api)
library(tidyverse)
library(magrittr)
library(arsenal)

# Generate Token using your locally saved credentials (see article for how to set up)
TOKEN <- get_token()

# Pull the patient case data and explore some aspects of the publicly available cases
patient_cases <- tidy_depot_api(path = "Patient-Case", token = TOKEN)
```

Now that patient case data has been pulled, let’s explore structure of
the resulting data. The request is returned as its own class with the
structured data from the API call in the “content”, the endpoint url in
the “path”, and the actually http response in the “response”.

``` r
# Dimensions of the resulting JSON data from the API call
patient_cases$content %>% dim()
#> [1] 16905   207

# End point used for the API call
patient_cases$path
#> [1] "Patient-Case"

# The httr response content containing the specific information about the call
patient_cases$response
#> Response [https://analytic.tbportals.niaid.nih.gov/api/Patient-Case?returnCsv=false&cohortId=]
#>   Date: 2025-02-20 19:24
#>   Status: 200
#>   Content-Type: application/json; charset=utf-8
#>   Size: 137 MB
```

Let’s explore some aspects of the patient cases stratifying by the type
of drug resistance associated with the case to get a sense of the number
of publicly shared data available.

``` r
# Store data.frame of patient case characteristics
patient_cases_df <- patient_cases$content

# Select attributes of interest
patient_cases_df %<>%
  select(condition_id, patient_id, age_of_onset, sex, bmi, case_definition, type_of_resistance)

# Summarise number of conditions by patient_id
patient_cases_df %<>%
  group_by(patient_id) %>%
  mutate(num_conditions = n_distinct(condition_id)) %>%
  select(-condition_id) %>%
  distinct() %>%
  type.convert()
#> Warning in type.convert.default(x[[i]], ...): 'as.is' should be specified by
#> the caller; using TRUE
#> Warning in type.convert.default(x[[i]], ...): 'as.is' should be specified by
#> the caller; using TRUE
#> Warning in type.convert.default(x[[i]], ...): 'as.is' should be specified by
#> the caller; using TRUE
#> Warning in type.convert.default(x[[i]], ...): 'as.is' should be specified by
#> the caller; using TRUE
#> Warning in type.convert.default(x[[i]], ...): 'as.is' should be specified by
#> the caller; using TRUE
#> Warning in type.convert.default(x[[i]], ...): 'as.is' should be specified by
#> the caller; using TRUE
#> Warning in type.convert.default(x[[i]], ...): 'as.is' should be specified by
#> the caller; using TRUE

# Patient counts by type of resistance and other case characteristics
tableby(type_of_resistance ~ age_of_onset + sex + bmi + case_definition, data = patient_cases_df) %>%
  summary()
```

|                      | MDR non XDR (N=7410) | Mono DR (N=1171) | Negative (N=1)  | Not Reported (N=3) | Poly DR (N=383) | Pre-XDR (N=1225) | Sensitive (N=5255) |  XDR (N=1457)   | Total (N=16905) |  p value |
|:---------------------|:--------------------:|:----------------:|:---------------:|:------------------:|:---------------:|:----------------:|:------------------:|:---------------:|:---------------:|---------:|
| **age_of_onset**     |                      |                  |                 |                    |                 |                  |                    |                 |                 | \< 0.001 |
|    Mean (SD)         |   42.476 (13.253)    | 43.691 (14.988)  |   54.000 (NA)   |  34.333 (14.012)   | 43.225 (15.419) | 43.691 (12.716)  |  44.085 (16.007)   | 42.484 (12.887) | 43.166 (14.288) |          |
|    Range             |    1.000 - 94.000    |  4.000 - 88.000  | 54.000 - 54.000 |  23.000 - 50.000   | 1.000 - 93.000  |  7.000 - 90.000  |   1.000 - 95.000   | 3.000 - 84.000  | 1.000 - 95.000  |          |
| **sex**              |                      |                  |                 |                    |                 |                  |                    |                 |                 | \< 0.001 |
|    Female            |     1875 (25.3%)     |   321 (27.4%)    |    0 (0.0%)     |     2 (66.7%)      |   115 (30.0%)   |   268 (21.9%)    |    1501 (28.6%)    |   374 (25.7%)   |  4456 (26.4%)   |          |
|    Male              |     5535 (74.7%)     |   850 (72.6%)    |   1 (100.0%)    |     1 (33.3%)      |   268 (70.0%)   |   957 (78.1%)    |    3754 (71.4%)    |  1083 (74.3%)   |  12449 (73.6%)  |          |
| **bmi**              |                      |                  |                 |                    |                 |                  |                    |                 |                 |          |
|    N-Miss            |         675          |       396        |        1        |         0          |       113       |        43        |        2811        |       79        |      4118       |          |
|    Mean (SD)         |    20.631 (3.492)    |  20.770 (3.991)  |       NA        |   16.667 (2.108)   | 20.543 (3.807)  |  20.646 (4.045)  |   20.779 (4.154)   | 20.538 (3.541)  | 20.656 (3.723)  |          |
|    Range             |   10.400 - 48.600    | 11.000 - 61.100  |       NA        |  15.400 - 19.100   | 13.200 - 40.700 | 10.300 - 47.900  |  10.500 - 93.700   | 11.800 - 38.600 | 10.300 - 93.700 |          |
| **case_definition**  |                      |                  |                 |                    |                 |                  |                    |                 |                 | \< 0.001 |
|    Chronic TB        |      182 (2.5%)      |     8 (0.7%)     |    0 (0.0%)     |      0 (0.0%)      |    1 (0.3%)     |    87 (7.1%)     |     11 (0.2%)      |    93 (6.4%)    |   382 (2.3%)    |          |
|    Failure           |      399 (5.4%)      |    40 (3.4%)     |    0 (0.0%)     |      0 (0.0%)      |    12 (3.1%)    |    27 (2.2%)     |     39 (0.7%)      |   340 (23.3%)   |   857 (5.1%)    |          |
|    Lost to follow up |      355 (4.8%)      |    25 (2.1%)     |    0 (0.0%)     |      0 (0.0%)      |    19 (5.0%)    |    38 (3.1%)     |     85 (1.6%)      |    78 (5.4%)    |   600 (3.5%)    |          |
|    New               |     4557 (61.5%)     |   917 (78.3%)    |   1 (100.0%)    |     1 (33.3%)      |   294 (76.8%)   |   671 (54.8%)    |    4524 (86.1%)    |   447 (30.7%)   |  11412 (67.5%)  |          |
|    Other             |      219 (3.0%)      |    26 (2.2%)     |    0 (0.0%)     |     2 (66.7%)      |    10 (2.6%)    |    33 (2.7%)     |     81 (1.5%)      |    65 (4.5%)    |   436 (2.6%)    |          |
|    Relapse           |     1693 (22.8%)     |   154 (13.2%)    |    0 (0.0%)     |      0 (0.0%)      |   46 (12.0%)    |   368 (30.0%)    |     512 (9.7%)     |   433 (29.7%)   |  3206 (19.0%)   |          |
|    Unknown           |       5 (0.1%)       |     1 (0.1%)     |    0 (0.0%)     |      0 (0.0%)      |    1 (0.3%)     |     1 (0.1%)     |      3 (0.1%)      |    1 (0.1%)     |    12 (0.1%)    |          |

If interested in other available endpoints, you can use the
list_endpoints function for a data.frame of currently available
endpoints.

``` r
# This function lists endpoints as a data.frame along with a brief description. 
# To show it in this markdown file, we add knitr::kable()
knitr::kable(list_endpoints())
```

| endpoint              | description                                         |
|:----------------------|:----------------------------------------------------|
| Biochemistry          | Laboratory and biochemistry records information     |
| CT                    | Computed Tomagraphy records information             |
| CT-Annotation         | Computed Tomagraphy records radiologist annotations |
| CXR                   | Chest X ray records information                     |
| CXR-Manual-Annotation | Chest X ray records radiologist annotations         |
| CXR-Qure-Annotation   | Chest X ray records Qure AI algorithm annotations   |
| DST                   | Drug sensitivity testing results records            |
| Genomics              | Pathogen genomics records information               |
| Patient-Case          | Patient case record information                     |
| Specimen              | Specimen record information                         |
| Treatment-Regimen     | Treatment and regimen record information            |

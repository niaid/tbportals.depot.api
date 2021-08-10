
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
install.packages("tbportals.depot.api")

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
structured data from the API call in the “content”, the endpoint url nin
the “path”, and the actually http response in the “response”.

``` r
#Data.frame dimensions of the resulting JSON data from the API call"
patient_cases$content %>% dim()
#> [1] 5339  204

#End point used for the API call
patient_cases$path
#> [1] "Patient-Case"

#The httr response content containing the specific information about the call
patient_cases$response
#> Response [https://analytic.tbportals.niaid.nih.gov/api/Patient-Case?returnCsv=false&cohortId=]
#>   Date: 2021-08-10 21:19
#>   Status: 200
#>   Content-Type: application/json; charset=utf-8
#>   Size: 41 MB
```

Let’s explore some aspects of the patient cases stratifying by the type
of drug resistance associated with the case to get a sense of the number
of publicly shared data available.

``` r
# Store data.frame of patient case characteristics
patient_cases_df <- patient_cases$content

# Select attributes of interest
patient_cases_df %<>%
  select(condition_id, patient_id, age_of_onset, gender, bmi, case_definition, type_of_resistance)

# Summarise number of conditions by patient_id
patient_cases_df %<>%
  group_by(patient_id) %>%
  mutate(num_conditions = n_distinct(condition_id)) %>%
  select(-condition_id) %>%
  distinct() %>%
  type.convert()

# Patient counts by type of resistance and other case characteristics
tableby(type_of_resistance ~ age_of_onset + gender + bmi + case_definition, data = patient_cases_df) %>%
  summary()
```

|                      | MDR non XDR (N=2346) | Mono DR (N=380) | Poly DR (N=173) | Pre-XDR (N=37)  | Sensitive (N=1540) |   XDR (N=863)   | Total (N=5339)  |  p value |
| :------------------- | :------------------: | :-------------: | :-------------: | :-------------: | :----------------: | :-------------: | :-------------: | -------: |
| **age\_of\_onset**   |                      |                 |                 |                 |                    |                 |                 |    0.004 |
| Mean (SD)            |   41.231 (13.194)    | 41.779 (14.909) | 42.399 (14.913) | 41.838 (13.779) |  43.051 (15.468)   | 41.393 (12.941) | 41.863 (14.048) |          |
| Range                |    3.000 - 85.000    | 8.000 - 87.000  | 18.000 - 93.000 | 21.000 - 90.000 |   2.000 - 88.000   | 15.000 - 84.000 | 2.000 - 93.000  |          |
| **gender**           |                      |                 |                 |                 |                    |                 |                 |    0.546 |
| Female               |     604 (25.7%)      |   105 (27.6%)   |   50 (28.9%)    |    9 (24.3%)    |    438 (28.4%)     |   232 (26.9%)   |  1438 (26.9%)   |          |
| Male                 |     1742 (74.3%)     |   275 (72.4%)   |   123 (71.1%)   |   28 (75.7%)    |    1102 (71.6%)    |   631 (73.1%)   |  3901 (73.1%)   |          |
| **bmi**              |                      |                 |                 |                 |                    |                 |                 |    0.007 |
| N-Miss               |         353          |       163       |       68        |        0        |        649         |       68        |      1301       |          |
| Mean (SD)            |    20.667 (3.442)    | 20.699 (4.355)  | 20.502 (3.996)  | 19.586 (4.291)  |   21.126 (3.751)   | 20.626 (3.675)  | 20.748 (3.640)  |          |
| Range                |   12.800 - 40.300    | 12.900 - 61.100 | 13.400 - 40.700 | 12.100 - 29.000 |  11.700 - 36.500   | 11.800 - 38.600 | 11.700 - 61.100 |          |
| **case\_definition** |                      |                 |                 |                 |                    |                 |                 | \< 0.001 |
| Chronic TB           |      47 (2.0%)       |    0 (0.0%)     |    0 (0.0%)     |    6 (16.2%)    |      1 (0.1%)      |    53 (6.1%)    |   107 (2.0%)    |          |
| Failure              |     268 (11.4%)      |    28 (7.4%)    |    9 (5.2%)     |    2 (5.4%)     |     27 (1.8%)      |   277 (32.1%)   |   611 (11.4%)   |          |
| Lost to follow up    |      191 (8.1%)      |    10 (2.6%)    |    11 (6.4%)    |    3 (8.1%)     |     37 (2.4%)      |    55 (6.4%)    |   307 (5.8%)    |          |
| New                  |     1217 (51.9%)     |   272 (71.6%)   |   124 (71.7%)   |   16 (43.2%)    |    1290 (83.8%)    |   213 (24.7%)   |  3132 (58.7%)   |          |
| Other                |      49 (2.1%)       |    5 (1.3%)     |    6 (3.5%)     |    3 (8.1%)     |     18 (1.2%)      |    40 (4.6%)    |   121 (2.3%)    |          |
| Relapse              |     573 (24.4%)      |   64 (16.8%)    |   22 (12.7%)    |    7 (18.9%)    |    165 (10.7%)     |   225 (26.1%)   |  1056 (19.8%)   |          |
| Unknown              |       1 (0.0%)       |    1 (0.3%)     |    1 (0.6%)     |    0 (0.0%)     |      2 (0.1%)      |    0 (0.0%)     |    5 (0.1%)     |          |

If interested in other available endpoints, you can use the
list\_endpoints function for a data.frame of currently available
endpoints.

``` r
# This function lists endpoints as a data.frame along with a brief description
list_endpoints()
```

``` 
            endpoint                                         description
```

1 Biochemistry Laboratory and biochemistry records information 2 CT
Computed Tomagraphy records information 3 CT-Annotation Computed
Tomagraphy records radiologist annotations 4 CXR Chest X ray records
information 5 CXR-Manual-Annotation Chest X ray records radiologist
annotations 6 CXR-Qure-Annotation Chest X ray records Qure AI algorithm
annotations 7 DST Drug sensitivity testing results records 8 Genomics
Pathogen genomics records information 9 Patient-Case Patient case record
information 10 Specimen Specimen record information 11 Treatment-Regimen
Treatment and regiment record information

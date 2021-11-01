
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
structured data from the API call in the “content”, the endpoint url nin
the “path”, and the actually http response in the “response”.

``` r
# Dimensions of the resulting JSON data from the API call
patient_cases$content %>% dim()
#> [1] 5812  205

# End point used for the API call
patient_cases$path
#> [1] "Patient-Case"

# The httr response content containing the specific information about the call
patient_cases$response
#> Response [https://analytic.tbportals.niaid.nih.gov/api/Patient-Case?returnCsv=false&cohortId=]
#>   Date: 2021-11-01 14:47
#>   Status: 200
#>   Content-Type: application/json; charset=utf-8
#>   Size: 44.9 MB
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

|                      | MDR non XDR (N=2519) | Mono DR (N=426) | Poly DR (N=183) | Pre-XDR (N=75)  | Sensitive (N=1697) |   XDR (N=912)   | Total (N=5812)  |    p value |
|:---------------------|:--------------------:|:---------------:|:---------------:|:---------------:|:------------------:|:---------------:|:---------------:|-----------:|
| **age\_of\_onset**   |                      |                 |                 |                 |                    |                 |                 | &lt; 0.001 |
|    Mean (SD)         |   41.279 (13.302)    | 41.279 (14.957) | 42.082 (14.778) | 41.867 (13.668) |  43.334 (15.474)   | 41.400 (12.879) | 41.931 (14.106) |            |
|    Range             |    3.000 - 86.000    | 7.000 - 87.000  | 18.000 - 93.000 | 17.000 - 90.000 |   2.000 - 89.000   | 15.000 - 84.000 | 2.000 - 93.000  |            |
| **gender**           |                      |                 |                 |                 |                    |                 |                 |      0.463 |
|    Female            |     651 (25.8%)      |   123 (28.9%)   |   54 (29.5%)    |   16 (21.3%)    |    470 (27.7%)     |   244 (26.8%)   |  1558 (26.8%)   |            |
|    Male              |     1868 (74.2%)     |   303 (71.1%)   |   129 (70.5%)   |   59 (78.7%)    |    1227 (72.3%)    |   668 (73.2%)   |  4254 (73.2%)   |            |
| **bmi**              |                      |                 |                 |                 |                    |                 |                 |      0.007 |
|    N-Miss            |         346          |       138       |       73        |        1        |        739         |       69        |      1366       |            |
|    Mean (SD)         |    20.696 (3.434)    | 20.935 (4.406)  | 20.415 (3.925)  | 19.849 (4.444)  |   21.087 (3.725)   | 20.625 (3.630)  | 20.761 (3.640)  |            |
|    Range             |   12.800 - 40.300    | 11.000 - 61.100 | 13.400 - 40.700 | 12.100 - 32.400 |  11.700 - 36.500   | 11.800 - 38.600 | 11.000 - 61.100 |            |
| **case\_definition** |                      |                 |                 |                 |                    |                 |                 | &lt; 0.001 |
|    Chronic TB        |      56 (2.2%)       |    0 (0.0%)     |    0 (0.0%)     |   17 (22.7%)    |      1 (0.1%)      |    53 (5.8%)    |   127 (2.2%)    |            |
|    Failure           |     275 (10.9%)      |    28 (6.6%)    |    9 (4.9%)     |    3 (4.0%)     |     28 (1.6%)      |   282 (30.9%)   |   625 (10.8%)   |            |
|    Lost to follow up |      199 (7.9%)      |    12 (2.8%)    |    11 (6.0%)    |    4 (5.3%)     |     41 (2.4%)      |    56 (6.1%)    |   323 (5.6%)    |            |
|    New               |     1331 (52.8%)     |   313 (73.5%)   |   134 (73.2%)   |   33 (44.0%)    |    1417 (83.5%)    |   233 (25.5%)   |  3461 (59.5%)   |            |
|    Other             |      52 (2.1%)       |    6 (1.4%)     |    6 (3.3%)     |    3 (4.0%)     |     21 (1.2%)      |    41 (4.5%)    |   129 (2.2%)    |            |
|    Relapse           |     605 (24.0%)      |   66 (15.5%)    |   22 (12.0%)    |   15 (20.0%)    |    187 (11.0%)     |   247 (27.1%)   |  1142 (19.6%)   |            |
|    Unknown           |       1 (0.0%)       |    1 (0.2%)     |    1 (0.5%)     |    0 (0.0%)     |      2 (0.1%)      |    0 (0.0%)     |    5 (0.1%)     |            |

If interested in other available endpoints, you can use the
list\_endpoints function for a data.frame of currently available
endpoints.

``` r
# This function lists endpoints as a data.frame along with a brief description
list_endpoints()
```

                endpoint                                         description

1 Biochemistry Laboratory and biochemistry records information 2 CT
Computed Tomagraphy records information 3 CT-Annotation Computed
Tomagraphy records radiologist annotations 4 CXR Chest X ray records
information 5 CXR-Manual-Annotation Chest X ray records radiologist
annotations 6 CXR-Qure-Annotation Chest X ray records Qure AI algorithm
annotations 7 DST Drug sensitivity testing results records 8 Genomics
Pathogen genomics records information 9 Patient-Case Patient case record
information 10 Specimen Specimen record information 11 Treatment-Regimen
Treatment and regiment record information

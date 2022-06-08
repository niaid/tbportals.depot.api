
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
# Install development version from GitHub
devtools::install_github("niaid/tbportals.depot.api")
```

## Usage

Please see Article, [Setting up connection to API](https://niaid.github.io/tbportals.depot.api/articles/setting_up_connection.html), before following
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
#> [1] 6853  205

# End point used for the API call
patient_cases$path
#> [1] "Patient-Case"

# The httr response content containing the specific information about the call
patient_cases$response
#> Response [https://analytic.tbportals.niaid.nih.gov/api/Patient-Case?returnCsv=false&cohortId=]
#>   Date: 2022-03-28 19:21
#>   Status: 200
#>   Content-Type: application/json; charset=utf-8
#>   Size: 53.2 MB
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

|                      | MDR non XDR (N=3030) | Mono DR (N=507) | Poly DR (N=199) | Pre-XDR (N=141) | Sensitive (N=1963) |  XDR (N=1013)   | Total (N=6853)  |    p value |
|:---------------------|:--------------------:|:---------------:|:---------------:|:---------------:|:------------------:|:---------------:|:---------------:|-----------:|
| **age\_of\_onset**   |                      |                 |                 |                 |                    |                 |                 | &lt; 0.001 |
|    Mean (SD)         |   41.267 (13.320)    | 41.690 (15.113) | 42.231 (14.784) | 43.809 (13.441) |  43.364 (15.492)   | 41.609 (12.865) | 42.030 (14.119) |            |
|    Range             |    3.000 - 86.000    | 7.000 - 87.000  | 18.000 - 93.000 | 17.000 - 90.000 |   2.000 - 89.000   | 15.000 - 84.000 | 2.000 - 93.000  |            |
| **gender**           |                      |                 |                 |                 |                    |                 |                 |      0.242 |
|    Female            |     788 (26.0%)      |   147 (29.0%)   |   61 (30.7%)    |   29 (20.6%)    |    534 (27.2%)     |   267 (26.4%)   |  1826 (26.6%)   |            |
|    Male              |     2242 (74.0%)     |   360 (71.0%)   |   138 (69.3%)   |   112 (79.4%)   |    1429 (72.8%)    |   746 (73.6%)   |  5027 (73.4%)   |            |
| **bmi**              |                      |                 |                 |                 |                    |                 |                 |      0.056 |
|    N-Miss            |         414          |       160       |       82        |        3        |        900         |       69        |      1628       |            |
|    Mean (SD)         |    20.653 (3.774)    | 20.807 (4.347)  | 20.375 (3.844)  | 20.325 (4.327)  |   21.003 (3.691)   | 20.573 (3.587)  | 20.705 (3.784)  |            |
|    Range             |   10.400 - 83.900    | 11.000 - 61.100 | 13.400 - 40.700 | 12.100 - 35.400 |  11.700 - 36.500   | 11.800 - 38.600 | 10.400 - 83.900 |            |
| **case\_definition** |                      |                 |                 |                 |                    |                 |                 | &lt; 0.001 |
|    Chronic TB        |      72 (2.4%)       |    1 (0.2%)     |    0 (0.0%)     |   30 (21.3%)    |      2 (0.1%)      |    60 (5.9%)    |   165 (2.4%)    |            |
|    Failure           |     307 (10.1%)      |    30 (5.9%)    |    9 (4.5%)     |    3 (2.1%)     |     30 (1.5%)      |   293 (28.9%)   |   672 (9.8%)    |            |
|    Lost to follow up |      229 (7.6%)      |    15 (3.0%)    |    14 (7.0%)    |    7 (5.0%)     |     45 (2.3%)      |    62 (6.1%)    |   372 (5.4%)    |            |
|    New               |     1635 (54.0%)     |   381 (75.1%)   |   145 (72.9%)   |   67 (47.5%)    |    1640 (83.5%)    |   276 (27.2%)   |  4144 (60.5%)   |            |
|    Other             |      63 (2.1%)       |    7 (1.4%)     |    6 (3.0%)     |    3 (2.1%)     |     25 (1.3%)      |    46 (4.5%)    |   150 (2.2%)    |            |
|    Relapse           |     723 (23.9%)      |   71 (14.0%)    |   24 (12.1%)    |   31 (22.0%)    |    219 (11.2%)     |   275 (27.1%)   |  1343 (19.6%)   |            |
|    Unknown           |       1 (0.0%)       |    2 (0.4%)     |    1 (0.5%)     |    0 (0.0%)     |      2 (0.1%)      |    1 (0.1%)     |    7 (0.1%)     |            |

If interested in other available endpoints, you can use the
list\_endpoints function for a data.frame of currently available
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

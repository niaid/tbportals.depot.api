
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
#> [1] 6434  205

# End point used for the API call
patient_cases$path
#> [1] "Patient-Case"

# The httr response content containing the specific information about the call
patient_cases$response
#> Response [https://analytic.tbportals.niaid.nih.gov/api/Patient-Case?returnCsv=false&cohortId=]
#>   Date: 2022-01-06 23:29
#>   Status: 200
#>   Content-Type: application/json; charset=utf-8
#>   Size: 49.8 MB
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

|                      | MDR non XDR (N=2820) | Mono DR (N=485) | Poly DR (N=195) | Pre-XDR (N=94)  | Sensitive (N=1884) |   XDR (N=956)   | Total (N=6434)  |    p value |
|:---------------------|:--------------------:|:---------------:|:---------------:|:---------------:|:------------------:|:---------------:|:---------------:|-----------:|
| **age\_of\_onset**   |                      |                 |                 |                 |                    |                 |                 | &lt; 0.001 |
|    Mean (SD)         |   41.177 (13.294)    | 41.278 (15.007) | 42.000 (14.719) | 42.723 (13.942) |  43.476 (15.507)   | 41.422 (12.795) | 41.942 (14.123) |            |
|    Range             |    3.000 - 86.000    | 7.000 - 87.000  | 18.000 - 93.000 | 17.000 - 90.000 |   2.000 - 89.000   | 15.000 - 84.000 | 2.000 - 93.000  |            |
| **gender**           |                      |                 |                 |                 |                    |                 |                 |      0.354 |
|    Female            |     727 (25.8%)      |   142 (29.3%)   |   60 (30.8%)    |   22 (23.4%)    |    517 (27.4%)     |   255 (26.7%)   |  1723 (26.8%)   |            |
|    Male              |     2093 (74.2%)     |   343 (70.7%)   |   135 (69.2%)   |   72 (76.6%)    |    1367 (72.6%)    |   701 (73.3%)   |  4711 (73.2%)   |            |
| **bmi**              |                      |                 |                 |                 |                    |                 |                 |      0.016 |
|    N-Miss            |         406          |       159       |       82        |        1        |        859         |       69        |      1576       |            |
|    Mean (SD)         |    20.626 (3.514)    | 20.894 (4.402)  | 20.373 (3.883)  | 20.170 (4.473)  |   21.039 (3.688)   | 20.617 (3.599)  | 20.715 (3.664)  |            |
|    Range             |   10.400 - 41.000    | 11.000 - 61.100 | 13.400 - 40.700 | 12.100 - 32.400 |  11.700 - 36.500   | 11.800 - 38.600 | 10.400 - 61.100 |            |
| **case\_definition** |                      |                 |                 |                 |                    |                 |                 | &lt; 0.001 |
|    Chronic TB        |      63 (2.2%)       |    1 (0.2%)     |    0 (0.0%)     |   18 (19.1%)    |      1 (0.1%)      |    56 (5.9%)    |   139 (2.2%)    |            |
|    Failure           |     297 (10.5%)      |    30 (6.2%)    |    9 (4.6%)     |    3 (3.2%)     |     28 (1.5%)      |   285 (29.8%)   |   652 (10.1%)   |            |
|    Lost to follow up |      224 (7.9%)      |    15 (3.1%)    |    14 (7.2%)    |    5 (5.3%)     |     44 (2.3%)      |    58 (6.1%)    |   360 (5.6%)    |            |
|    New               |     1514 (53.7%)     |   363 (74.8%)   |   142 (72.8%)   |   46 (48.9%)    |    1576 (83.7%)    |   251 (26.3%)   |  3892 (60.5%)   |            |
|    Other             |      58 (2.1%)       |    7 (1.4%)     |    6 (3.1%)     |    3 (3.2%)     |     23 (1.2%)      |    43 (4.5%)    |   140 (2.2%)    |            |
|    Relapse           |     663 (23.5%)      |   68 (14.0%)    |   23 (11.8%)    |   19 (20.2%)    |    210 (11.1%)     |   262 (27.4%)   |  1245 (19.4%)   |            |
|    Unknown           |       1 (0.0%)       |    1 (0.2%)     |    1 (0.5%)     |    0 (0.0%)     |      2 (0.1%)      |    1 (0.1%)     |    6 (0.1%)     |            |

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

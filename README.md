
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
#> [1] 6006  205

# End point used for the API call
patient_cases$path
#> [1] "Patient-Case"

# The httr response content containing the specific information about the call
patient_cases$response
#> Response [https://analytic.tbportals.niaid.nih.gov/api/Patient-Case?returnCsv=false&cohortId=]
#>   Date: 2021-11-30 19:47
#>   Status: 200
#>   Content-Type: application/json; charset=utf-8
#>   Size: 46.5 MB
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

|                      | MDR non XDR (N=2574) | Mono DR (N=452) | Poly DR (N=192) | Pre-XDR (N=78)  | Sensitive (N=1795) |   XDR (N=915)   | Total (N=6006)  |    p value |
|:---------------------|:--------------------:|:---------------:|:---------------:|:---------------:|:------------------:|:---------------:|:---------------:|-----------:|
| **age\_of\_onset**   |                      |                 |                 |                 |                    |                 |                 | &lt; 0.001 |
|    Mean (SD)         |   41.264 (13.337)    | 41.230 (15.015) | 42.125 (14.780) | 41.885 (13.529) |  43.301 (15.399)   | 41.442 (12.898) | 41.933 (14.122) |            |
|    Range             |    3.000 - 86.000    | 7.000 - 87.000  | 18.000 - 93.000 | 17.000 - 90.000 |   2.000 - 89.000   | 15.000 - 84.000 | 2.000 - 93.000  |            |
| **gender**           |                      |                 |                 |                 |                    |                 |                 |      0.321 |
|    Female            |     663 (25.8%)      |   134 (29.6%)   |   57 (29.7%)    |   17 (21.8%)    |    497 (27.7%)     |   243 (26.6%)   |  1611 (26.8%)   |            |
|    Male              |     1911 (74.2%)     |   318 (70.4%)   |   135 (70.3%)   |   61 (78.2%)    |    1298 (72.3%)    |   672 (73.4%)   |  4395 (73.2%)   |            |
| **bmi**              |                      |                 |                 |                 |                    |                 |                 |      0.007 |
|    N-Miss            |         359          |       155       |       80        |        1        |        811         |       68        |      1474       |            |
|    Mean (SD)         |    20.658 (3.441)    | 20.877 (4.416)  | 20.395 (3.894)  | 19.818 (4.464)  |   21.056 (3.709)   | 20.616 (3.625)  | 20.730 (3.640)  |            |
|    Range             |   10.400 - 40.300    | 11.000 - 61.100 | 13.400 - 40.700 | 12.100 - 32.400 |  11.700 - 36.500   | 11.800 - 38.600 | 10.400 - 61.100 |            |
| **case\_definition** |                      |                 |                 |                 |                    |                 |                 | &lt; 0.001 |
|    Chronic TB        |      59 (2.3%)       |    0 (0.0%)     |    0 (0.0%)     |   17 (21.8%)    |      1 (0.1%)      |    55 (6.0%)    |   132 (2.2%)    |            |
|    Failure           |     280 (10.9%)      |    28 (6.2%)    |    9 (4.7%)     |    3 (3.8%)     |     28 (1.6%)      |   282 (30.8%)   |   630 (10.5%)   |            |
|    Lost to follow up |      206 (8.0%)      |    15 (3.3%)    |    13 (6.8%)    |    4 (5.1%)     |     42 (2.3%)      |    56 (6.1%)    |   336 (5.6%)    |            |
|    New               |     1364 (53.0%)     |   335 (74.1%)   |   140 (72.9%)   |   35 (44.9%)    |    1497 (83.4%)    |   233 (25.5%)   |  3604 (60.0%)   |            |
|    Other             |      53 (2.1%)       |    5 (1.1%)     |    6 (3.1%)     |    3 (3.8%)     |     23 (1.3%)      |    41 (4.5%)    |   131 (2.2%)    |            |
|    Relapse           |     611 (23.7%)      |   68 (15.0%)    |   23 (12.0%)    |   16 (20.5%)    |    202 (11.3%)     |   248 (27.1%)   |  1168 (19.4%)   |            |
|    Unknown           |       1 (0.0%)       |    1 (0.2%)     |    1 (0.5%)     |    0 (0.0%)     |      2 (0.1%)      |    0 (0.0%)     |    5 (0.1%)     |            |

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
| Treatment-Regimen     | Treatment and regiment record information           |

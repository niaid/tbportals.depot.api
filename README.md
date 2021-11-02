
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
#> [1] 5867  205

# End point used for the API call
patient_cases$path
#> [1] "Patient-Case"

# The httr response content containing the specific information about the call
patient_cases$response
#> Response [https://analytic.tbportals.niaid.nih.gov/api/Patient-Case?returnCsv=false&cohortId=]
#>   Date: 2021-11-02 14:45
#>   Status: 200
#>   Content-Type: application/json; charset=utf-8
#>   Size: 45.4 MB
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

|                      | MDR non XDR (N=2546) | Mono DR (N=429) | Poly DR (N=186) | Pre-XDR (N=76)  | Sensitive (N=1716) |   XDR (N=914)   | Total (N=5867)  |    p value |
|:---------------------|:--------------------:|:---------------:|:---------------:|:---------------:|:------------------:|:---------------:|:---------------:|-----------:|
| **age\_of\_onset**   |                      |                 |                 |                 |                    |                 |                 | &lt; 0.001 |
|    Mean (SD)         |   41.255 (13.336)    | 41.478 (14.885) | 42.086 (14.822) | 41.711 (13.645) |  43.300 (15.463)   | 41.431 (12.891) | 41.929 (14.114) |            |
|    Range             |    3.000 - 86.000    | 7.000 - 87.000  | 18.000 - 93.000 | 17.000 - 90.000 |   2.000 - 89.000   | 15.000 - 84.000 | 2.000 - 93.000  |            |
| **gender**           |                      |                 |                 |                 |                    |                 |                 |      0.363 |
|    Female            |     657 (25.8%)      |   125 (29.1%)   |   55 (29.6%)    |   16 (21.1%)    |    478 (27.9%)     |   244 (26.7%)   |  1575 (26.8%)   |            |
|    Male              |     1889 (74.2%)     |   304 (70.9%)   |   131 (70.4%)   |   60 (78.9%)    |    1238 (72.1%)    |   670 (73.3%)   |  4292 (73.2%)   |            |
| **bmi**              |                      |                 |                 |                 |                    |                 |                 |      0.009 |
|    N-Miss            |         348          |       140       |       75        |        1        |        745         |       69        |      1378       |            |
|    Mean (SD)         |    20.660 (3.440)    | 20.889 (4.464)  | 20.412 (3.908)  | 19.917 (4.454)  |   21.075 (3.713)   | 20.620 (3.628)  | 20.738 (3.643)  |            |
|    Range             |   10.400 - 40.300    | 11.000 - 61.100 | 13.400 - 40.700 | 12.100 - 32.400 |  11.700 - 36.500   | 11.800 - 38.600 | 10.400 - 61.100 |            |
| **case\_definition** |                      |                 |                 |                 |                    |                 |                 | &lt; 0.001 |
|    Chronic TB        |      56 (2.2%)       |    0 (0.0%)     |    0 (0.0%)     |   17 (22.4%)    |      1 (0.1%)      |    53 (5.8%)    |   127 (2.2%)    |            |
|    Failure           |     279 (11.0%)      |    27 (6.3%)    |    9 (4.8%)     |    3 (3.9%)     |     28 (1.6%)      |   282 (30.9%)   |   628 (10.7%)   |            |
|    Lost to follow up |      202 (7.9%)      |    13 (3.0%)    |    12 (6.5%)    |    4 (5.3%)     |     41 (2.4%)      |    56 (6.1%)    |   328 (5.6%)    |            |
|    New               |     1347 (52.9%)     |   317 (73.9%)   |   135 (72.6%)   |   34 (44.7%)    |    1434 (83.6%)    |   233 (25.5%)   |  3500 (59.7%)   |            |
|    Other             |      52 (2.0%)       |    5 (1.2%)     |    6 (3.2%)     |    3 (3.9%)     |     21 (1.2%)      |    41 (4.5%)    |   128 (2.2%)    |            |
|    Relapse           |     609 (23.9%)      |   66 (15.4%)    |   23 (12.4%)    |   15 (19.7%)    |    189 (11.0%)     |   249 (27.2%)   |  1151 (19.6%)   |            |
|    Unknown           |       1 (0.0%)       |    1 (0.2%)     |    1 (0.5%)     |    0 (0.0%)     |      2 (0.1%)      |    0 (0.0%)     |    5 (0.1%)     |            |

If interested in other available endpoints, you can use the
list\_endpoints function for a data.frame of currently available
endpoints.

``` r
# This function lists endpoints as a data.frame along with a brief description
list_endpoints(format = "html") # format = "html" for printing in markdown/html file
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

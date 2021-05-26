
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tbportals.depot.api

<!-- badges: start -->

<!-- badges: end -->

tbportals.depot.api aims to provide a convenient wrapper functionality
in R to the TB Portals Analytic API containing the tidy data from TB
Portals DEPOT database. For more information about TB Portals, check out
their [TB Portals website](https://tbportals.niaid.nih.gov/).

## Installation

``` r
devtools::install_github("niaid/tbportals.depot.api")
```

## Example

Please see Article, “Setting up connection to API”, prior to following
along with the code below as it assumes you have saved your credentials
locally which are required for interacting with the API.

This is a basic example which shows you how to solve a common problem
(for other end points check out
[link](https://analytic.tbportals.niaid.nih.gov/index.html):

``` r
library(tbportals.depot.api)
library(tidyverse)
library(magrittr)
library(ggplot2)
library(ggpubr)
library(arsenal)

#Generat Token using your locally saved credentials (see article for how to set up)
TOKEN <- get_token()

## Pull the patient case data and explore some aspects of the publicly available cases
patient_cases <- tidy_depot_api(path = "Patient-Case", token = TOKEN)
```

Now that patient case data has been pulled, let’s explore structure of
the resulting data:

``` r
#Data.frame dimensions of the resulting JSON data from the API call"
patient_cases$content %>% dim()
#> [1] 4536  204

#End point used for the API call
patient_cases$path
#> [1] "Patient-Case"

#The httr response content containing the specific information about the call
patient_cases$response
#> Response [https://analytic.tbportals.niaid.nih.gov/api/Patient-Case?returnCsv=false&cohortId=]
#>   Date: 2021-05-20 17:30
#>   Status: 200
#>   Content-Type: application/json; charset=utf-8
#>   Size: 34.5 MB
```

Let’s explore some aspects of the patient cases:

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

|                      | MDR non XDR (N=2168) | Mono DR (N=315) | Poly DR (N=141) | Pre-XDR (N=24)  | Sensitive (N=1069) |   XDR (N=819)   | Total (N=4536)  |  p value |
| :------------------- | :------------------: | :-------------: | :-------------: | :-------------: | :----------------: | :-------------: | :-------------: | -------: |
| **age\_of\_onset**   |                      |                 |                 |                 |                    |                 |                 |    0.294 |
| Mean (SD)            |   41.231 (13.196)    | 41.390 (15.113) | 43.106 (14.742) | 43.458 (14.709) |  42.213 (15.824)   | 41.248 (12.941) | 41.547 (14.010) |          |
| Range                |    3.000 - 85.000    | 8.000 - 87.000  | 19.000 - 93.000 | 24.000 - 90.000 |   2.000 - 87.000   | 15.000 - 84.000 | 2.000 - 93.000  |          |
| **gender**           |                      |                 |                 |                 |                    |                 |                 |    0.328 |
| Female               |     559 (25.8%)      |   86 (27.3%)    |   39 (27.7%)    |    6 (25.0%)    |    318 (29.7%)     |   224 (27.4%)   |  1232 (27.2%)   |          |
| Male                 |     1609 (74.2%)     |   229 (72.7%)   |   102 (72.3%)   |   18 (75.0%)    |    751 (70.3%)     |   595 (72.6%)   |  3304 (72.8%)   |          |
| **bmi**              |                      |                 |                 |                 |                    |                 |                 | \< 0.001 |
| N-Miss               |         330          |       151       |       59        |        0        |        583         |       67        |      1190       |          |
| Mean (SD)            |    20.762 (3.455)    | 20.939 (4.737)  | 20.946 (4.248)  | 19.842 (4.843)  |   21.530 (3.925)   | 20.650 (3.651)  | 20.855 (3.683)  |          |
| Range                |   12.800 - 40.300    | 12.900 - 61.100 | 13.400 - 40.700 | 12.100 - 29.000 |  11.700 - 36.500   | 11.800 - 38.600 | 11.700 - 61.100 |          |
| **case\_definition** |                      |                 |                 |                 |                    |                 |                 | \< 0.001 |
| Chronic TB           |      41 (1.9%)       |    0 (0.0%)     |    0 (0.0%)     |    4 (16.7%)    |      0 (0.0%)      |    43 (5.3%)    |    88 (1.9%)    |          |
| Failure              |     261 (12.0%)      |    25 (7.9%)    |    9 (6.4%)     |    2 (8.3%)     |     19 (1.8%)      |   270 (33.0%)   |   586 (12.9%)   |          |
| Lost to follow up    |      181 (8.3%)      |    10 (3.2%)    |    10 (7.1%)    |    1 (4.2%)     |     36 (3.4%)      |    54 (6.6%)    |   292 (6.4%)    |          |
| New                  |     1105 (51.0%)     |   221 (70.2%)   |   94 (66.7%)    |    9 (37.5%)    |    866 (81.0%)     |   196 (23.9%)   |  2491 (54.9%)   |          |
| Other                |      43 (2.0%)       |    4 (1.3%)     |    6 (4.3%)     |    2 (8.3%)     |     17 (1.6%)      |    38 (4.6%)    |   110 (2.4%)    |          |
| Relapse              |     536 (24.7%)      |   54 (17.1%)    |   21 (14.9%)    |    6 (25.0%)    |    129 (12.1%)     |   218 (26.6%)   |   964 (21.3%)   |          |
| Unknown              |       1 (0.0%)       |    1 (0.3%)     |    1 (0.7%)     |    0 (0.0%)     |      2 (0.2%)      |    0 (0.0%)     |    5 (0.1%)     |          |

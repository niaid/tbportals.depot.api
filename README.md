
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tbportals.depot.api

<!-- badges: start -->

<!-- badges: end -->

The goal of tbportals.depot.api is to provide a convenient wrapper
functionality in R to the TB Portals Analytic API containing the Tidy
data from DEPOT. For more information about TB Portals, check out their
[TB Portals website](https://tbportals.niaid.nih.gov/).

## Installation

You can install the released version of tbportals.depot.api from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("tbportals.depot.api")
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
#> [1] 4041  204

#End point used for the API call
patient_cases$path
#> [1] "Patient-Case"

#The httr response content containing the specific information about the call
patient_cases$response
#> Response [https://analytic.tbportals.niaid.nih.gov/api/Patient-Case?returnCsv=false]
#>   Date: 2021-04-15 12:57
#>   Status: 200
#>   Content-Type: application/json; charset=utf-8
#>   Size: 30.4 MB
```

Let’s explore some aspects of the patient cases:

``` r
# Store data.frame of patient case characteristics
patient_cases_df <- patient_cases$content

# Select attributes of interest
patient_cases_df %<>%
  select(condition_id, patient_id, age_of_onset, gender, country, case_definition, type_of_resistance)

# Summarise number of conditions by patient_id
patient_cases_df %<>%
  group_by(patient_id) %>%
  mutate(num_conditions = n_distinct(condition_id)) %>%
  select(-condition_id) %>%
  distinct() %>%
  type.convert()

# Patient counts by type of resistance and other case characteristics
tableby(type_of_resistance ~ age_of_onset + gender + country + case_definition, data = patient_cases_df) %>%
  summary()
```

|                      | MDR non XDR (N=1845) | Mono DR (N=306) | Poly DR (N=133) | Pre-XDR (N=14)  | Sensitive (N=987) |   XDR (N=755)   | Total (N=4040)  |  p value |
| :------------------- | :------------------: | :-------------: | :-------------: | :-------------: | :---------------: | :-------------: | :-------------: | -------: |
| **age\_of\_onset**   |                      |                 |                 |                 |                   |                 |                 |    0.429 |
| Mean (SD)            |   41.095 (13.377)    | 41.111 (15.132) | 43.286 (14.774) | 40.714 (12.098) |  41.827 (15.953)  | 40.955 (12.909) | 41.320 (14.145) |          |
| Range                |    3.000 - 85.000    | 8.000 - 87.000  | 19.000 - 93.000 | 24.000 - 63.000 |  2.000 - 87.000   | 15.000 - 84.000 | 2.000 - 93.000  |          |
| **gender**           |                      |                 |                 |                 |                   |                 |                 |    0.282 |
| Female               |     482 (26.1%)      |   86 (28.1%)    |   38 (28.6%)    |    3 (21.4%)    |    300 (30.4%)    |   212 (28.1%)   |  1121 (27.7%)   |          |
| Male                 |     1363 (73.9%)     |   220 (71.9%)   |   95 (71.4%)    |   11 (78.6%)    |    687 (69.6%)    |   543 (71.9%)   |  2919 (72.3%)   |          |
| **country**          |                      |                 |                 |                 |                   |                 |                 | \< 0.001 |
| Azerbaijan           |      178 (9.6%)      |    6 (2.0%)     |    3 (2.3%)     |    0 (0.0%)     |     54 (5.5%)     |   97 (12.8%)    |   338 (8.4%)    |          |
| Belarus              |     445 (24.1%)      |    27 (8.8%)    |   15 (11.3%)    |    0 (0.0%)     |    156 (15.8%)    |   289 (38.3%)   |   932 (23.1%)   |          |
| Georgia              |     373 (20.2%)      |   78 (25.5%)    |   69 (51.9%)    |    0 (0.0%)     |    452 (45.8%)    |   90 (11.9%)    |  1062 (26.3%)   |          |
| India                |       3 (0.2%)       |    7 (2.3%)     |    3 (2.3%)     |    0 (0.0%)     |     7 (0.7%)      |    1 (0.1%)     |    21 (0.5%)    |          |
| Kazakhstan           |      114 (6.2%)      |    10 (3.3%)    |    12 (9.0%)    |    7 (50.0%)    |     64 (6.5%)     |    38 (5.0%)    |   245 (6.1%)    |          |
| Moldova              |     377 (20.4%)      |   43 (14.1%)    |   22 (16.5%)    |    0 (0.0%)     |    181 (18.3%)    |   86 (11.4%)    |   709 (17.5%)   |          |
| Nigeria              |      34 (1.8%)       |   83 (27.1%)    |    0 (0.0%)     |    0 (0.0%)     |     0 (0.0%)      |    0 (0.0%)     |   117 (2.9%)    |          |
| Romania              |      167 (9.1%)      |   35 (11.4%)    |    7 (5.3%)     |    0 (0.0%)     |     21 (2.1%)     |    65 (8.6%)    |   295 (7.3%)    |          |
| Ukraine              |      154 (8.3%)      |    17 (5.6%)    |    2 (1.5%)     |    7 (50.0%)    |     52 (5.3%)     |   89 (11.8%)    |   321 (7.9%)    |          |
| **case\_definition** |                      |                 |                 |                 |                   |                 |                 | \< 0.001 |
| Chronic TB           |      34 (1.8%)       |    0 (0.0%)     |    0 (0.0%)     |    3 (21.4%)    |     0 (0.0%)      |    29 (3.8%)    |    66 (1.6%)    |          |
| Failure              |     221 (12.0%)      |    25 (8.2%)    |    9 (6.8%)     |    2 (14.3%)    |     15 (1.5%)     |   260 (34.4%)   |   532 (13.2%)   |          |
| Lost to follow up    |      177 (9.6%)      |    10 (3.3%)    |    10 (7.5%)    |    1 (7.1%)     |     33 (3.3%)     |    52 (6.9%)    |   283 (7.0%)    |          |
| New                  |     924 (50.1%)      |   214 (69.9%)   |   86 (64.7%)    |    4 (28.6%)    |    802 (81.3%)    |   182 (24.1%)   |  2212 (54.8%)   |          |
| Other                |      39 (2.1%)       |    4 (1.3%)     |    6 (4.5%)     |    1 (7.1%)     |     15 (1.5%)     |    35 (4.6%)    |   100 (2.5%)    |          |
| Relapse              |     449 (24.3%)      |   52 (17.0%)    |   21 (15.8%)    |    3 (21.4%)    |    120 (12.2%)    |   197 (26.1%)   |   842 (20.8%)   |          |
| Unknown              |       1 (0.1%)       |    1 (0.3%)     |    1 (0.8%)     |    0 (0.0%)     |     2 (0.2%)      |    0 (0.0%)     |    5 (0.1%)     |          |

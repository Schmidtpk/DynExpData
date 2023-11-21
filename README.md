
<!-- README.md is generated from README.Rmd. Please edit that file -->

# DynExpData

<!-- badges: start -->
<!-- badges: end -->

The goal of DynExpData is to provide easy data access to the
experimental data from the paper “Identifying dynamic shifts to careless
and insufficient effort behavior in questionnaire responses; A novel
approach and experimental validation”.

## Installation

You can install the development version of DynExpData like so:

``` r
# install.packages("devtools")
devtools::install_github("Schmidtpk/DynExpData")
```

## Instructions

The raw data can be found in this github. The different data parts are
in this package under data. The simplest way to work with the data is by
using the `pull_data` function:

``` r
library(DynExpData)
#> Loading required package: dplyr
#> Warning: package 'dplyr' was built under R version 4.1.3
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
#> Loading required package: tidyr
#> Warning: package 'tidyr' was built under R version 4.1.3
#> Loading required package: tibble
#> Warning: package 'tibble' was built under R version 4.1.3

# load data into list
data.list <- pull_data()
#> Standardize mean and sd by person

ls(data.list)
#>  [1] "cd"               "cond"             "instr"            "iord"            
#>  [5] "n_item"           "n_person"         "raw_ord"          "time"            
#>  [9] "tord"             "treatment.timing" "ymat"
```

If you prefer to work with data.frames, the `gen_df` function creates
those:

``` r
# generate data.frame (tidyformat)
df <- gen_df(data.list)
#> Joining, by = c("id", "j", "iname")
#> Joining, by = c("id", "iname")
#> Joining, by = "id"
#> Joining, by = "id"
#> Joining, by = "id"

head(df)
#> # A tibble: 6 x 12
#>   id        j iname  time timer~1  value     i     t treat~2 instr  cond value~3
#>   <chr> <int> <chr> <dbl>   <dbl>  <dbl> <int> <int>   <dbl> <chr> <dbl>   <dbl>
#> 1 R_1C~     1 anx1   1.82  0.205   0.611     1    16      64 Don'~     4   0.611
#> 2 R_1C~     1 anx2   1.16  0.0361 -0.710     2    84      64 Don'~     4  -0.710
#> 3 R_1C~     1 anx3   3.33  0.647   0.591     3    41      64 Don'~     4   0.591
#> 4 R_1C~     1 anx4   1.87  0.177   0.306     4    66      64 Don'~     4   0.306
#> 5 R_1C~     1 anx5   2.39  0.293  -0.395     5    13      64 Don'~     4  -0.395
#> 6 R_1C~     1 anx6   1.26  0.0562  1.11      6    77      64 Don'~     4   5.89 
#> # ... with abbreviated variable names 1: timerank, 2: treatment.timing,
#> #   3: value.org
```

If you want to sample specific data points, the pull_data functions has
arguments for that. You can look at `?pull_data` for details.

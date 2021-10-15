
<!-- README.md is generated from README.Rmd. Please edit that file -->

# PhyloDecR

<!-- badges: start -->
<!-- badges: end -->

The goal of PhyloDecR is to check sets of taxon sets for phylogenetic
decisiveness in R.

## Installation

You can install the released version of PhyloDecR from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("PhyloDecR")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("pottNeJa/PhyloDecR")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(PhyloDecR)

## basic example code
data(exampleData)
head(exampleData)
#>        V1
#> 1 1_2_3_5
#> 2 1_2_3_6
#> 3 1_2_4_5
#> 4 1_2_4_6
#> 5 1_3_4_6
#> 6 1_3_5_6
```

Okay, we have an example data set with 10 quadruples and n=6 taxa.

First, we want to check if this input data is okay for the algorithm.
There are three conditions (proof see master thesis):

1.  Input Quadruple size has to be large enough (>
    $$ {N\\choose 4}$$
    )
2.  All triples must to be in the input data
3.  All tuples must be sufficiently available

``` r
test1<-createInput(fn="_archive/quadruple_check2.txt",sepSym = "_")
#> [1] "CHECK 1 OK - input is not too small ..."
#> [1] "CHECK 2 OK - all triples are at least one time there"
#> [1] "CHECK 3 OK - all tuples are often enough available"

test1$input
#>  [1] "1_2_3_5" "1_2_3_6" "1_2_4_5" "1_2_4_6" "1_3_4_6" "1_3_5_6" "1_4_5_6"
#>  [8] "2_3_4_5" "2_3_4_6" "2_3_5_6"
test1$taxa
#> [1] 1 2 3 4 5 6
test1$comments
#> [1] "CHECK 1 OK - input is not too small ..."             
#> [2] "CHECK 2 OK - all triples are at least one time there"
#> [3] "CHECK 3 OK - all tuples are often enough available"

knitr::kable(test1$data,caption = "All possible quadruples with the given n and their status (given as input or to be resolved)")
```

| quadruple | taxa1 | taxa2 | taxa3 | taxa4 | triple1 | triple2 | triple3 | triple4 | status     |
|:----------|------:|------:|------:|------:|:--------|:--------|:--------|:--------|:-----------|
| 1_2\_3_4  |     1 |     2 |     3 |     4 | 1_2\_3  | 1_2\_4  | 1_3\_4  | 2_3\_4  | unresolved |
| 1_2\_3_5  |     1 |     2 |     3 |     5 | 1_2\_3  | 1_2\_5  | 1_3\_5  | 2_3\_5  | input      |
| 1_2\_3_6  |     1 |     2 |     3 |     6 | 1_2\_3  | 1_2\_6  | 1_3\_6  | 2_3\_6  | input      |
| 1_2\_4_5  |     1 |     2 |     4 |     5 | 1_2\_4  | 1_2\_5  | 1_4\_5  | 2_4\_5  | input      |
| 1_2\_4_6  |     1 |     2 |     4 |     6 | 1_2\_4  | 1_2\_6  | 1_4\_6  | 2_4\_6  | input      |
| 1_2\_5_6  |     1 |     2 |     5 |     6 | 1_2\_5  | 1_2\_6  | 1_5\_6  | 2_5\_6  | unresolved |
| 1_3\_4_5  |     1 |     3 |     4 |     5 | 1_3\_4  | 1_3\_5  | 1_4\_5  | 3_4\_5  | unresolved |
| 1_3\_4_6  |     1 |     3 |     4 |     6 | 1_3\_4  | 1_3\_6  | 1_4\_6  | 3_4\_6  | input      |
| 1_3\_5_6  |     1 |     3 |     5 |     6 | 1_3\_5  | 1_3\_6  | 1_5\_6  | 3_5\_6  | input      |
| 1_4\_5_6  |     1 |     4 |     5 |     6 | 1_4\_5  | 1_4\_6  | 1_5\_6  | 4_5\_6  | input      |
| 2_3\_4_5  |     2 |     3 |     4 |     5 | 2_3\_4  | 2_3\_5  | 2_4\_5  | 3_4\_5  | input      |
| 2_3\_4_6  |     2 |     3 |     4 |     6 | 2_3\_4  | 2_3\_6  | 2_4\_6  | 3_4\_6  | input      |
| 2_3\_5_6  |     2 |     3 |     5 |     6 | 2_3\_5  | 2_3\_6  | 2_5\_6  | 3_5\_6  | input      |
| 2_4\_5_6  |     2 |     4 |     5 |     6 | 2_4\_5  | 2_4\_6  | 2_5\_6  | 4_5\_6  | unresolved |
| 3_4\_5_6  |     3 |     4 |     5 |     6 | 3_4\_5  | 3_4\_6  | 3_5\_6  | 4_5\_6  | unresolved |

All possible quadruples with the given n and their status (given as
input or to be resolved)

Okay, my example data passes all initial tests. This means, that I can
run the algorithm created by Mareike Fischer.

``` r
test2<-runAlgorithm(data = test1$data)
```

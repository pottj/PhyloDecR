
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

## To do

-   Check MA for the three conditions (number of quadruples, triples &
    tuples) & add the corresponding lemma or theorem
-   Test all used taxa sets of the MA
-   Optimize algorithm output
-   Full description of all the functions
-   Test with taxa sets from Mareike
-   Compare algorithm with Mareikes Mathematica Code

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

### Step 1: Create Input

``` r
test1 = createInput(fn="../../2103_FischerPaper/Beispiele/example_Fischer_1.txt",sepSym = ",")
#> Input contains 3 trees with 9 different taxa. The biggest tree has 6 taxa.
test2 = createInput(fn="../../2103_FischerPaper/Beispiele/example_Fischer_2.txt",sepSym = ",")
#> Input contains 11 trees with 6 different taxa. The biggest tree has 4 taxa.
test3 = createInput(fn="../../2103_FischerPaper/Beispiele/example_8_12_Decisive.txt", sepSym = "_")
#> Input contains 28 trees with 8 different taxa. The biggest tree has 4 taxa.

test1$input_raw
#>    V1 V2 V3 V4 V5 V6
#> 1:  a  b  d  c  e  g
#> 2:  a  b  f  h      
#> 3:  d  e  f  x
test1$input_quadruples
#>     taxa1 taxa2 taxa3 taxa4
#>  1:     a     b     c     d
#>  2:     a     b     c     e
#>  3:     a     b     c     g
#>  4:     a     b     d     e
#>  5:     a     b     d     g
#>  6:     a     b     e     g
#>  7:     a     c     d     e
#>  8:     a     c     d     g
#>  9:     a     c     e     g
#> 10:     a     d     e     g
#> 11:     b     c     d     e
#> 12:     b     c     d     g
#> 13:     b     c     e     g
#> 14:     b     d     e     g
#> 15:     c     d     e     g
#> 16:     a     b     f     h
#> 17:     d     e     f     x
test1$input_ordered
#>     taxa1 taxa2 taxa3 taxa4 quadruple
#>  1:     1     2     3     4   1_2_3_4
#>  2:     1     2     3     5   1_2_3_5
#>  3:     1     2     3     7   1_2_3_7
#>  4:     1     2     4     5   1_2_4_5
#>  5:     1     2     4     7   1_2_4_7
#>  6:     1     2     5     7   1_2_5_7
#>  7:     1     3     4     5   1_3_4_5
#>  8:     1     3     4     7   1_3_4_7
#>  9:     1     3     5     7   1_3_5_7
#> 10:     1     4     5     7   1_4_5_7
#> 11:     2     3     4     5   2_3_4_5
#> 12:     2     3     4     7   2_3_4_7
#> 13:     2     3     5     7   2_3_5_7
#> 14:     2     4     5     7   2_4_5_7
#> 15:     3     4     5     7   3_4_5_7
#> 16:     1     2     6     8   1_2_6_8
#> 17:     4     5     6     9   4_5_6_9
test1$taxa
#>    taxaID NR
#> 1:      a  1
#> 2:      b  2
#> 3:      c  3
#> 4:      d  4
#> 5:      e  5
#> 6:      f  6
#> 7:      g  7
#> 8:      h  8
#> 9:      x  9

head(test1$data)
#>    taxa1 taxa2 taxa3 taxa4 quadruple triple1 triple2 triple3 triple4     status
#> 1:     1     2     3     4   1_2_3_4   1_2_3   1_2_4   1_3_4   2_3_4      input
#> 2:     1     2     3     5   1_2_3_5   1_2_3   1_2_5   1_3_5   2_3_5      input
#> 3:     1     2     3     6   1_2_3_6   1_2_3   1_2_6   1_3_6   2_3_6 unresolved
#> 4:     1     2     3     7   1_2_3_7   1_2_3   1_2_7   1_3_7   2_3_7      input
#> 5:     1     2     3     8   1_2_3_8   1_2_3   1_2_8   1_3_8   2_3_8 unresolved
#> 6:     1     2     3     9   1_2_3_9   1_2_3   1_2_9   1_3_9   2_3_9 unresolved
# knitr::kable(test1$data,caption = "All possible quadruples with the given taxa and their status (given as input or to be resolved)")
```

### Step 2: Do some initial tests

The second input, *test2*, contains data for 11 taxa lists of 6
different taxa.

First, we want to check if this input data is okay for the algorithm.
There are three conditions (proof see master thesis):

1.  Input Quadruple size has to be large enough ($n-1 \\choose 4$) –> to
    check! could also be ($n-1 \\choose 3$), maybe just a typo! See
    Theorem 5 / Conjecture of my Master Thesis
2.  All triples must to be in the input data! See Lemma 1 of my Master
    Thesis.
3.  All tuples must be sufficiently available! –> See Theorem 6 of my
    Master Thesis.

``` r
test1_checks = initialCheck(data = test1$data)
#> [1] "CHECK 1 NOT OK - NOT RESOLVABLE VIA THIS ALGORITHM"
#> [1] "CHECK 2 OK - all triples are at least one time there"
#> [1] "CHECK 3 NOT OK - NOT PHYLOGENETICALLY DECISIVE"
test2_checks = initialCheck(data = test2$data)
#> [1] "CHECK 1 OK - input is not too small ..."
#> [1] "CHECK 2 OK - all triples are at least one time there"
#> [1] "CHECK 3 OK - all tuples are often enough available"
test3_checks = initialCheck(data = test3$data)
#> [1] "CHECK 1 NOT OK - NOT RESOLVABLE VIA THIS ALGORITHM"
#> [1] "CHECK 2 OK - all triples are at least one time there"
#> [1] "CHECK 3 OK - all tuples are often enough available"
```

Okay, my example data passes all initial tests. This means, that I can
run the algorithm created by Mareike Fischer.

``` r
test1_alg<-runAlgorithm(data = test1$data)
#> [1] 1
#> [1] 93
#> [1] 2
#> [1] 43
#> [1] 3
#> [1] 5
#> [1] 4
#> [1] 3
#> [1] 5
#> [1] 3
#> [1] 6
#> [1] 3
#> [1] 7
#> [1] 3
#> [1] 8
#> [1] 3
#> [1] 9
#> [1] 3
#> [1] 10
#> [1] 3
#> [1] 11
#> [1] 3
#> [1] 12
#> [1] 3
#> [1] 13
#> [1] 3
#> [1] 14
#> [1] 3
#> [1] 15
#> [1] 3
#> [1] 16
#> [1] 3
#> [1] 17
#> [1] 3
#> [1] 18
#> [1] 3
#> [1] 19
#> [1] 3
#> [1] 20
#> [1] 3
#> [1] 21
#> [1] 3
#> [1] 22
#> [1] 3
#> [1] 23
#> [1] 3
#> [1] 24
#> [1] 3
#> [1] 25
#> [1] 3
#> [1] 26
#> [1] 3
#> [1] 27
#> [1] 3
#> [1] 28
#> [1] 3
#> [1] 29
#> [1] 3
#> [1] 30
#> [1] 3
#> [1] 31
#> [1] 3
#> [1] 32
#> [1] 3
#> [1] 33
#> [1] 3
#> [1] 34
#> [1] 3
#> [1] 35
#> [1] 3
#> [1] 36
#> [1] 3
#> [1] 37
#> [1] 3
#> [1] 38
#> [1] 3
#> [1] 39
#> [1] 3
#> [1] 40
#> [1] 3
#> [1] 41
#> [1] 3
#> [1] 42
#> [1] 3
#> [1] 43
#> [1] 3
#> [1] 44
#> [1] 3
#> [1] 45
#> [1] 3
#> [1] 46
#> [1] 3
#> [1] 47
#> [1] 3
#> [1] 48
#> [1] 3
#> [1] 49
#> [1] 3
#> [1] 50
#> [1] 3
#> [1] 51
#> [1] 3
#> [1] 52
#> [1] 3
#> [1] 53
#> [1] 3
#> [1] 54
#> [1] 3
#> [1] 55
#> [1] 3
#> [1] 56
#> [1] 3
#> [1] 57
#> [1] 3
#> [1] 58
#> [1] 3
#> [1] 59
#> [1] 3
#> [1] 60
#> [1] 3
#> [1] 61
#> [1] 3
#> [1] 62
#> [1] 3
#> [1] 63
#> [1] 3
#> [1] 64
#> [1] 3
#> [1] 65
#> [1] 3
#> [1] 66
#> [1] 3
#> [1] 67
#> [1] 3
#> [1] 68
#> [1] 3
#> [1] 69
#> [1] 3
#> [1] 70
#> [1] 3
#> [1] 71
#> [1] 3
#> [1] 72
#> [1] 3
#> [1] 73
#> [1] 3
#> [1] 74
#> [1] 3
#> [1] 75
#> [1] 3
#> [1] 76
#> [1] 3
#> [1] 77
#> [1] 3
#> [1] 78
#> [1] 3
#> [1] 79
#> [1] 3
#> [1] 80
#> [1] 3
#> [1] 81
#> [1] 3
#> [1] 82
#> [1] 3
#> [1] 83
#> [1] 3
#> [1] 84
#> [1] 3
#> [1] 85
#> [1] 3
#> [1] 86
#> [1] 3
#> [1] 87
#> [1] 3
#> [1] 88
#> [1] 3
#> [1] 89
#> [1] 3
#> [1] 90
#> [1] 3
#> [1] 91
#> [1] 3
#> [1] 92
#> [1] 3
#> [1] 93
#> [1] 3
#> [1] 94
#> [1] 3
#> [1] 95
#> [1] 3
#> [1] 96
#> [1] 3
#> [1] 97
#> [1] 3
#> [1] 98
#> [1] 3
#> [1] 99
#> [1] 3
#> [1] 100
#> [1] 3
#> [1] 101
#> [1] 3
#> [1] 102
#> [1] 3
#> [1] 103
#> [1] 3
#> [1] 104
#> [1] 3
#> [1] 105
#> [1] 3
#> [1] 106
#> [1] 3
#> [1] 107
#> [1] 3
#> [1] 108
#> [1] 3
#> [1] 109
#> [1] 3
#> [1] "NOT RESOLVABLE VIA THIS ALGORITHM, MAYBE A SECOND FIXING TAXON IS NEEDED"
test2_alg<-runAlgorithm(data = test2$data)
#> [1] 1
#> [1] 0
#> [1] "PHYLOGENETICALLY DECISIVE"
test3_alg<-runAlgorithm(data = test3$data)
#> [1] 1
#> [1] 0
#> [1] "PHYLOGENETICALLY DECISIVE"
```

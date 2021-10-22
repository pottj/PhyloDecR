
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

-   Discuss with Mareike: is my version of her algorithm correct?
-   Check master thesis for further conditions

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(PhyloDecR)

## basic example data sets
fn1 = system.file("extdata", 
                  "example_1_notDecisive.txt", 
                  package = "PhyloDecR")
fn2 = system.file("extdata", 
                  "example_2_Decisive.txt", 
                  package = "PhyloDecR")
fn3 = system.file("extdata", 
                  "example_3_Decisive.txt", 
                  package = "PhyloDecR")
```

### Step 1: Create Input

``` r
test1 = createInput(fn=fn1,sepSym = ",")
#> Input contains 3 trees with 9 different taxa. The biggest tree has 6 taxa.
test2 = createInput(fn=fn2,sepSym = ",")
#> Input contains 11 trees with 6 different taxa. The biggest tree has 4 taxa.
test3 = createInput(fn=fn3, sepSym = "_")
#> Input contains 28 trees with 8 different taxa. The biggest tree has 4 taxa.

knitr::kable(test1$input_raw,caption = "Input from text file. Does not need to be numeric, does not need to be quadruples")
```

| V1  | V2  | V3  | V4  | V5  | V6  |
|:----|:----|:----|:----|:----|:----|
| a   | b   | d   | c   | e   | g   |
| a   | b   | f   | h   |     |     |
| d   | e   | f   | x   |     |     |

Input from text file. Does not need to be numeric, does not need to be
quadruples

``` r
knitr::kable(test1$input_quadruples,caption = "Input quadruples. If in input was a tree with more than four taxa, all quadruples in that tree are added here")
```

| taxa1 | taxa2 | taxa3 | taxa4 |
|:------|:------|:------|:------|
| a     | b     | c     | d     |
| a     | b     | c     | e     |
| a     | b     | c     | g     |
| a     | b     | d     | e     |
| a     | b     | d     | g     |
| a     | b     | e     | g     |
| a     | c     | d     | e     |
| a     | c     | d     | g     |
| a     | c     | e     | g     |
| a     | d     | e     | g     |
| b     | c     | d     | e     |
| b     | c     | d     | g     |
| b     | c     | e     | g     |
| b     | d     | e     | g     |
| c     | d     | e     | g     |
| a     | b     | f     | h     |
| d     | e     | f     | x     |

Input quadruples. If in input was a tree with more than four taxa, all
quadruples in that tree are added here

``` r
knitr::kable(test1$input_ordered,caption = "Input quadruples, all numeric from 1 to n (different taxa in input).")
```

| taxa1 | taxa2 | taxa3 | taxa4 | quadruple |
|:------|:------|:------|:------|:----------|
| 1     | 2     | 3     | 4     | 1_2\_3_4  |
| 1     | 2     | 3     | 5     | 1_2\_3_5  |
| 1     | 2     | 3     | 7     | 1_2\_3_7  |
| 1     | 2     | 4     | 5     | 1_2\_4_5  |
| 1     | 2     | 4     | 7     | 1_2\_4_7  |
| 1     | 2     | 5     | 7     | 1_2\_5_7  |
| 1     | 3     | 4     | 5     | 1_3\_4_5  |
| 1     | 3     | 4     | 7     | 1_3\_4_7  |
| 1     | 3     | 5     | 7     | 1_3\_5_7  |
| 1     | 4     | 5     | 7     | 1_4\_5_7  |
| 2     | 3     | 4     | 5     | 2_3\_4_5  |
| 2     | 3     | 4     | 7     | 2_3\_4_7  |
| 2     | 3     | 5     | 7     | 2_3\_5_7  |
| 2     | 4     | 5     | 7     | 2_4\_5_7  |
| 3     | 4     | 5     | 7     | 3_4\_5_7  |
| 1     | 2     | 6     | 8     | 1_2\_6_8  |
| 4     | 5     | 6     | 9     | 4_5\_6_9  |

Input quadruples, all numeric from 1 to n (different taxa in input).

``` r
knitr::kable(test1$taxa, caption = "Transfomation matrix")
```

| taxaID |  NR |
|:-------|----:|
| a      |   1 |
| b      |   2 |
| c      |   3 |
| d      |   4 |
| e      |   5 |
| f      |   6 |
| g      |   7 |
| h      |   8 |
| x      |   9 |

Transfomation matrix

``` r
head(test1$data)
#>    taxa1 taxa2 taxa3 taxa4 quadruple triple1 triple2 triple3 triple4     status
#> 1:     1     2     3     4   1_2_3_4   1_2_3   1_2_4   1_3_4   2_3_4      input
#> 2:     1     2     3     5   1_2_3_5   1_2_3   1_2_5   1_3_5   2_3_5      input
#> 3:     1     2     3     6   1_2_3_6   1_2_3   1_2_6   1_3_6   2_3_6 unresolved
#> 4:     1     2     3     7   1_2_3_7   1_2_3   1_2_7   1_3_7   2_3_7      input
#> 5:     1     2     3     8   1_2_3_8   1_2_3   1_2_8   1_3_8   2_3_8 unresolved
#> 6:     1     2     3     9   1_2_3_9   1_2_3   1_2_9   1_3_9   2_3_9 unresolved
```

### Step 2: Do some initial tests

The second input, *test2*, contains data for 11 taxa lists of 6
different taxa.

First, we want to check if this input data is okay for the algorithm.
There are three conditions (proof see master thesis):

1.  Input Quadruple size has to be large enough ($n-1 \\choose 3$)to
    make this algorithm work. See Theorem 5 / Conjecture of master
    thesis
2.  All triples must to be in the input data! See Lemma 1 of master
    thesis.
3.  All tuples must be sufficiently available! –> See Theorem 6 of
    master thesis.

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

Not all data pass the test.

-   Data 1: low quadruple number & not all tuples sufficiently available
    –> Algorithm will not be able to give a positive result
-   Data 2: all initial checks passed –> algorithm should be able to
    give true positive or true negative result
-   Data 3: low quadruple number –> algorithm will not be able to give a
    positive result

``` r
test1_alg<-runAlgorithm(data = test1$data,verbose = T)
#> Using 17 of 126 quadruples as input for algorithm (9 unique taxa). 
#>  This leaves 109 quadruples unsolved.
#> In round #1, 0 quadruples could be resolved ...
#> [1] "NOT RESOLVABLE VIA THIS ALGORITHM, MAYBE A SECOND FIXING TAXON IS NEEDED"
test2_alg<-runAlgorithm(data = test2$data,verbose = T)
#> Using 11 of 15 quadruples as input for algorithm (6 unique taxa). 
#>  This leaves 4 quadruples unsolved.
#> In round #1, 2 quadruples could be resolved ...
#> In round #2, 2 quadruples could be resolved ...
#> [1] "PHYLOGENETICALLY DECISIVE"
test3_alg<-runAlgorithm(data = test3$data,verbose = T)
#> Using 28 of 70 quadruples as input for algorithm (8 unique taxa). 
#>  This leaves 42 quadruples unsolved.
#> In round #1, 0 quadruples could be resolved ...
#> [1] "NOT RESOLVABLE VIA THIS ALGORITHM, MAYBE A SECOND FIXING TAXON IS NEEDED"
```

The algorithm cannot give false positives! If there are fixing taxa to
resolve all quadruples, the set is phylogenetic decisive (proof of
proposition 7 of Fischer Preprint).

The algorithm can give false negatives! For example, the third example
set is phylogenetic decisive, but has not enough quadruples in the set
to enable the algorithm to find fixing taxa (see master thesis, theorem
2).

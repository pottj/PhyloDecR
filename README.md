
<!-- README.md is generated from README.Rmd. Please edit that file -->

# PhyloDecR

<!-- badges: start -->
<!-- badges: end -->

The goal of PhyloDecR is to check sets of taxon sets for phylogenetic
decisiveness in R.

## Installation

Once published, you can install the released version of PhyloDecR from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("PhyloDecR")
```

Currently, only the development version from
[GitHub](https://github.com/) is available with:

``` r
# install.packages("devtools")
devtools::install_github("pottj/PhyloDecR")
```

## To do

-   Discuss with Mareike: is my version of her algorithm correct?
-   Check master thesis for further conditions

## Minimal example

Here are three basic examples for the algorithms in this package:

1.  FixingTaxonTraceability (original algorithm of Mareike Fischer,
    focusing on *green* quadruples)
2.  myAlgorithm (does the same as FixingTaxonTraceability, but focuses
    on *red* quadruples –&gt; bit faster)
3.  findNRC (find no-rainbow 4-coloring, exact algorithm, taken adapted
    from Ghazaleh Parvinis work)

### Loading example data

Here, I use three data sets with *n* = 6 taxa, but different input
quadruple numbers.

-   The first set contains 8 of 15 possible quadruples –&gt; not
    decisive
-   the second set contains 9 quadruples –&gt; decisive, but fixing
    taxon traceable
-   the third set contains 11 quadruples –&gt; decisive and fixing taxon
    traceable

``` r
library(PhyloDecR)

## basic example data sets
fn1 = system.file("extdata", 
                  "example_5_notDecisive.txt", 
                  package = "PhyloDecR")
fn2 = system.file("extdata", 
                  "example_4_Decisive_notFTT.txt", 
                  package = "PhyloDecR")
fn3 = system.file("extdata", 
                  "example_2_Decisive.txt", 
                  package = "PhyloDecR")

# load input 
test1 = createInput(fn=fn1,sepSym = "_")
#> Input contains 8 trees with 6 different taxa. The biggest tree has 4 taxa.
test2 = createInput(fn=fn2,sepSym = "_")
#> Input contains 9 trees with 6 different taxa. The biggest tree has 4 taxa.
test3 = createInput(fn=fn3, sepSym = ",")
#> Input contains 11 trees with 6 different taxa. The biggest tree has 4 taxa.

# check input 
knitr::kable(test1$input_raw,caption = "Input from text file. Does not need to be numeric, does not need to be quadruples")
```

|  V1 |  V2 |  V3 |  V4 |
|----:|----:|----:|----:|
|   1 |   2 |   3 |   5 |
|   1 |   2 |   4 |   5 |
|   1 |   2 |   4 |   6 |
|   1 |   3 |   4 |   6 |
|   1 |   3 |   5 |   6 |
|   1 |   4 |   5 |   6 |
|   2 |   3 |   4 |   5 |
|   2 |   3 |   4 |   6 |

Input from text file. Does not need to be numeric, does not need to be
quadruples

``` r
knitr::kable(test1$input_quadruples,caption = "Input quadruples. If in input was a tree with more than four taxa, all quadruples in that tree are added here")
```

| taxa1 | taxa2 | taxa3 | taxa4 |
|------:|------:|------:|------:|
|     1 |     2 |     3 |     5 |
|     1 |     2 |     4 |     5 |
|     1 |     2 |     4 |     6 |
|     1 |     3 |     4 |     6 |
|     1 |     3 |     5 |     6 |
|     1 |     4 |     5 |     6 |
|     2 |     3 |     4 |     5 |
|     2 |     3 |     4 |     6 |

Input quadruples. If in input was a tree with more than four taxa, all
quadruples in that tree are added here

``` r
knitr::kable(test1$input_ordered,caption = "Input quadruples, all numeric from 1 to n (different taxa in input).")
```

| taxa1 | taxa2 | taxa3 | taxa4 | quadruple  |
|------:|------:|------:|------:|:-----------|
|     1 |     2 |     3 |     5 | 1\_2\_3\_5 |
|     1 |     2 |     4 |     5 | 1\_2\_4\_5 |
|     1 |     2 |     4 |     6 | 1\_2\_4\_6 |
|     1 |     3 |     4 |     6 | 1\_3\_4\_6 |
|     1 |     3 |     5 |     6 | 1\_3\_5\_6 |
|     1 |     4 |     5 |     6 | 1\_4\_5\_6 |
|     2 |     3 |     4 |     5 | 2\_3\_4\_5 |
|     2 |     3 |     4 |     6 | 2\_3\_4\_6 |

Input quadruples, all numeric from 1 to n (different taxa in input).

``` r
knitr::kable(test1$taxa, caption = "Transfomation matrix")
```

| taxaID |  NR |
|-------:|----:|
|      1 |   1 |
|      2 |   2 |
|      3 |   3 |
|      4 |   4 |
|      5 |   5 |
|      6 |   6 |

Transfomation matrix

``` r
head(test1$data)
#>    taxa1 taxa2 taxa3 taxa4 quadruple triple1 triple2 triple3 triple4     status
#> 1:     1     2     3     4   1_2_3_4   1_2_3   1_2_4   1_3_4   2_3_4 unresolved
#> 2:     1     2     3     5   1_2_3_5   1_2_3   1_2_5   1_3_5   2_3_5      input
#> 3:     1     2     3     6   1_2_3_6   1_2_3   1_2_6   1_3_6   2_3_6 unresolved
#> 4:     1     2     4     5   1_2_4_5   1_2_4   1_2_5   1_4_5   2_4_5      input
#> 5:     1     2     4     6   1_2_4_6   1_2_4   1_2_6   1_4_6   2_4_6      input
#> 6:     1     2     5     6   1_2_5_6   1_2_5   1_2_6   1_5_6   2_5_6 unresolved
```

The input data are lists containing five elements each:

-   raw input: data as given in the txt file
-   input quadruples: input data transformed into quadruples only (in
    case a bigger tree was given as input)
-   input ordered: data transformed to quadruples, and taxa ID forced to
    numeric and ordered hierarchically
-   data: all possible quadruples given the taxon set with status
    information (quadruple as input available, quadruple not in input =
    unresolved). In addition, all four triples possible by each
    quadruple are listed
-   taxa: data table used for transformation, taxaID denotes the
    original input taxaID (as in input\_raw & input\_quadruples), NR is
    the ordered number of this taxon (as in input\_ordered & data)

### Some initial tests

In my master thesis, and hopefully in our paper, we show some lower
bound for fixing taxon tracability.

1.  Input Quadruple size has to be large enough ($n-1 \\choose 3$)to
    make this algorithm work. See Theorem 5 / Conjecture of master
    thesis
2.  All triples must to be in the input data! See Lemma 1 of master
    thesis.
3.  All tuples must be sufficiently available! –&gt; See Theorem 6 of
    master thesis.

``` r
initialCheck(data = test1$data)
#> [1] "CHECK 1 NOT OK - NOT RESOLVABLE VIA THIS ALGORITHM"  
#> [2] "CHECK 2 OK - all triples are at least one time there"
#> [3] "CHECK 3 NOT OK - NOT PHYLOGENETICALLY DECISIVE"
initialCheck(data = test2$data)
#> [1] "CHECK 1 NOT OK - NOT RESOLVABLE VIA THIS ALGORITHM"  
#> [2] "CHECK 2 OK - all triples are at least one time there"
#> [3] "CHECK 3 OK - all tuples are often enough available"
initialCheck(data = test3$data)
#> [1] "CHECK 1 OK - input is not too small ..."             
#> [2] "CHECK 2 OK - all triples are at least one time there"
#> [3] "CHECK 3 OK - all tuples are often enough available"
```

Not all data pass the test.

-   Data set 1: low quadruple number & not all tuples sufficiently
    available –&gt; Algorithm will not be able to give a positive result
-   Data set 2: low quadruple number –&gt; algorithm will not be able to
    give a positive result
-   Data set 3: all initial checks passed –&gt; algorithm should be able
    to give true positive or true negative result

### Testing the sets

``` r
# 1) Using Mareike Fischers version of the FTT Algorithm
time1 = Sys.time()
test1_1 = FixingTaxonTraceability(data = test1$data,verbose=T)
#> Using 8 of 15 quadruples as input for algorithm (6 unique taxa). 
#>  This leaves 7 quadruples unsolved.
#> It took 16 steps to come to a conclusion ...
#> Not all quadruples can be resolved via fixing taxa - please increase input data! 
#>      You can check the input partly resolved data for next steps
test2_1 = FixingTaxonTraceability(data = test2$data,verbose=T)
#> Using 9 of 15 quadruples as input for algorithm (6 unique taxa). 
#>  This leaves 6 quadruples unsolved.
#> It took 18 steps to come to a conclusion ...
#> Not all quadruples can be resolved via fixing taxa - please increase input data! 
#>      You can check the input partly resolved data for next steps
test3_1 = FixingTaxonTraceability(data = test3$data,verbose=T)
#> Using 11 of 15 quadruples as input for algorithm (6 unique taxa). 
#>  This leaves 4 quadruples unsolved.
#> It took 12 steps to come to a conclusion ...
#> Fixing taxon traceable! 
#>      Hence also phylogenetic decisive!
message("Time for FTT (Fischer) : " ,round(difftime(Sys.time(),time1,units = "sec"),3)," seconds")
#> Time for FTT (Fischer) : 1.702 seconds

# 2) Using my version of the FTT Algorithm
time1 = Sys.time()
test1_2 = runAlgorithm(data = test1$data,verbose = T)
#> Using 8 of 15 quadruples as input for algorithm (6 unique taxa). 
#>  This leaves 7 quadruples unsolved.
#> In round #1, 0 quadruples could be resolved ...
#> [1] "NOT RESOLVABLE VIA THIS ALGORITHM, MAYBE A SECOND FIXING TAXON IS NEEDED"
test2_2 = runAlgorithm(data = test2$data,verbose = T)
#> Using 9 of 15 quadruples as input for algorithm (6 unique taxa). 
#>  This leaves 6 quadruples unsolved.
#> In round #1, 0 quadruples could be resolved ...
#> [1] "NOT RESOLVABLE VIA THIS ALGORITHM, MAYBE A SECOND FIXING TAXON IS NEEDED"
test3_2 = runAlgorithm(data = test3$data,verbose = T)
#> Using 11 of 15 quadruples as input for algorithm (6 unique taxa). 
#>  This leaves 4 quadruples unsolved.
#> In round #1, 2 quadruples could be resolved ...
#> In round #2, 2 quadruples could be resolved ...
#> [1] "PHYLOGENETICALLY DECISIVE"
message("Time for FTT (Pott) : " ,round(difftime(Sys.time(),time1,units = "sec"),3)," seconds")
#> Time for FTT (Pott) : 0.409 seconds

# 3) using the exact algorithm findNRC
time1 = Sys.time()
test1_3 = findNRC(data = test1,verbose = T)
#> Testing i=1, k=1, j=1, and l=1 ...
#>         this coloring resulted in: fail
#>         counter at 1
#> Testing i=1, k=1, j=1, and l=2 ...
#>         this coloring resulted in: fail
#>         counter at 1
#> Testing i=1, k=1, j=1, and l=3 ...
#>         this coloring resulted in: fail
#>         counter at 1
#> Testing i=1, k=1, j=1, and l=4 ...
#>         this coloring resulted in: fail
#>         counter at 1
#> Testing i=1, k=1, j=1, and l=5 ...
#>         this coloring resulted in: fail
#>         counter at 1
#> Testing i=1, k=2, j=1, and l=1 ...
#>         this coloring resulted in: fail
#>         counter at 1
#> Testing i=1, k=2, j=1, and l=2 ...
#>         this coloring resulted in: fail
#>         counter at 1
#> Testing i=1, k=2, j=1, and l=3 ...
#>         this coloring resulted in: fail
#>         counter at 1
#> Testing i=1, k=2, j=1, and l=4 ...
#>         this coloring resulted in: NRC
#>         counter at 1
test2_3 = findNRC(data = test2,verbose = F)
test3_3 = findNRC(data = test3,verbose = F)
message("Time for NRC (Parvini) : " ,round(difftime(Sys.time(),time1,units = "sec"),3)," seconds")
#> Time for NRC (Parvini) : 19.912 seconds
```

### Checking the output

``` r
# 1) Using Mareike Fischers version of the FTT Algorithm
knitr::kable(test1_1[11:15,])
```

| taxa1 | taxa2 | taxa3 | taxa4 | quadruple  | triple1 | triple2 | triple3 | triple4 | status     | round | counter | fixingTaxa |
|------:|------:|------:|------:|:-----------|:--------|:--------|:--------|:--------|:-----------|------:|--------:|-----------:|
|     1 |     2 |     5 |     6 | 1\_2\_5\_6 | 1\_2\_5 | 1\_2\_6 | 1\_5\_6 | 2\_5\_6 | unresolved |     0 |       0 |          0 |
|     1 |     3 |     4 |     5 | 1\_3\_4\_5 | 1\_3\_4 | 1\_3\_5 | 1\_4\_5 | 3\_4\_5 | unresolved |     0 |       0 |          0 |
|     2 |     3 |     5 |     6 | 2\_3\_5\_6 | 2\_3\_5 | 2\_3\_6 | 2\_5\_6 | 3\_5\_6 | unresolved |     0 |       0 |          0 |
|     2 |     4 |     5 |     6 | 2\_4\_5\_6 | 2\_4\_5 | 2\_4\_6 | 2\_5\_6 | 4\_5\_6 | unresolved |     0 |       0 |          0 |
|     3 |     4 |     5 |     6 | 3\_4\_5\_6 | 3\_4\_5 | 3\_4\_6 | 3\_5\_6 | 4\_5\_6 | unresolved |    16 |       0 |          0 |

``` r
knitr::kable(test3_1[11:15,])
```

| taxa1 | taxa2 | taxa3 | taxa4 | quadruple  | triple1 | triple2 | triple3 | triple4 | status   | round | counter | fixingTaxa |
|------:|------:|------:|------:|:-----------|:--------|:--------|:--------|:--------|:---------|------:|--------:|-----------:|
|     2 |     3 |     5 |     6 | 2\_3\_5\_6 | 2\_3\_5 | 2\_3\_6 | 2\_5\_6 | 3\_5\_6 | input    |     0 |       0 |          0 |
|     1 |     2 |     3 |     4 | 1\_2\_3\_4 | 1\_2\_3 | 1\_2\_4 | 1\_3\_4 | 2\_3\_4 | resolved |     3 |       1 |          6 |
|     1 |     3 |     4 |     5 | 1\_3\_4\_5 | 1\_3\_4 | 1\_3\_5 | 1\_4\_5 | 3\_4\_5 | resolved |     5 |       1 |          2 |
|     2 |     4 |     5 |     6 | 2\_4\_5\_6 | 2\_4\_5 | 2\_4\_6 | 2\_5\_6 | 4\_5\_6 | resolved |     6 |       1 |          1 |
|     3 |     4 |     5 |     6 | 3\_4\_5\_6 | 3\_4\_5 | 3\_4\_6 | 3\_5\_6 | 4\_5\_6 | resolved |    12 |       1 |          1 |

``` r
# 2) Using my version of the FTT Algorithm
knitr::kable(test1_2[11:15,])
```

| taxa1 | taxa2 | taxa3 | taxa4 | quadruple  | triple1 | triple2 | triple3 | triple4 | status     | round | fixingTaxa |
|------:|------:|------:|------:|:-----------|:--------|:--------|:--------|:--------|:-----------|------:|-----------:|
|     1 |     2 |     5 |     6 | 1\_2\_5\_6 | 1\_2\_5 | 1\_2\_6 | 1\_5\_6 | 2\_5\_6 | unresolved |     0 |          0 |
|     1 |     3 |     4 |     5 | 1\_3\_4\_5 | 1\_3\_4 | 1\_3\_5 | 1\_4\_5 | 3\_4\_5 | unresolved |     0 |          0 |
|     2 |     3 |     5 |     6 | 2\_3\_5\_6 | 2\_3\_5 | 2\_3\_6 | 2\_5\_6 | 3\_5\_6 | unresolved |     0 |          0 |
|     2 |     4 |     5 |     6 | 2\_4\_5\_6 | 2\_4\_5 | 2\_4\_6 | 2\_5\_6 | 4\_5\_6 | unresolved |     0 |          0 |
|     3 |     4 |     5 |     6 | 3\_4\_5\_6 | 3\_4\_5 | 3\_4\_6 | 3\_5\_6 | 4\_5\_6 | unresolved |     0 |          0 |

``` r
knitr::kable(test3_2[11:15,])
```

| taxa1 | taxa2 | taxa3 | taxa4 | quadruple  | triple1 | triple2 | triple3 | triple4 | status   | round | fixingTaxa |
|------:|------:|------:|------:|:-----------|:--------|:--------|:--------|:--------|:---------|------:|-----------:|
|     2 |     3 |     5 |     6 | 2\_3\_5\_6 | 2\_3\_5 | 2\_3\_6 | 2\_5\_6 | 3\_5\_6 | input    |     0 |          0 |
|     1 |     2 |     3 |     4 | 1\_2\_3\_4 | 1\_2\_3 | 1\_2\_4 | 1\_3\_4 | 2\_3\_4 | resolved |     1 |          6 |
|     2 |     4 |     5 |     6 | 2\_4\_5\_6 | 2\_4\_5 | 2\_4\_6 | 2\_5\_6 | 4\_5\_6 | resolved |     1 |          1 |
|     1 |     3 |     4 |     5 | 1\_3\_4\_5 | 1\_3\_4 | 1\_3\_5 | 1\_4\_5 | 3\_4\_5 | resolved |     2 |          2 |
|     3 |     4 |     5 |     6 | 3\_4\_5\_6 | 3\_4\_5 | 3\_4\_6 | 3\_5\_6 | 4\_5\_6 | resolved |     2 |          2 |

``` r
# 3) using the exact algorithm findNRC
test1_3
#> $coloring
#>    taxaID NR  color
#> 1:      1  1   blue
#> 2:      2  2  green
#> 3:      3  3   blue
#> 4:      4  4   blue
#> 5:      5  5    red
#> 6:      6  6 yellow
#> 
#> $quadruples_colored
#>    taxa1 taxa2 taxa3 taxa4 quadruple taxa1_col taxa2_col taxa3_col taxa4_col
#> 1:     1     2     3     5   1_2_3_5      blue     green      blue       red
#> 2:     1     2     4     5   1_2_4_5      blue     green      blue       red
#> 3:     1     2     4     6   1_2_4_6      blue     green      blue    yellow
#> 4:     1     3     4     6   1_3_4_6      blue      blue      blue    yellow
#> 5:     1     3     5     6   1_3_5_6      blue      blue       red    yellow
#> 6:     1     4     5     6   1_4_5_6      blue      blue       red    yellow
#> 7:     2     3     4     5   2_3_4_5     green      blue      blue       red
#> 8:     2     3     4     6   2_3_4_6     green      blue      blue    yellow
#>    sumUniqueColors sumColored
#> 1:               3          4
#> 2:               3          4
#> 3:               3          4
#> 4:               2          4
#> 5:               3          4
#> 6:               3          4
#> 7:               3          4
#> 8:               3          4
#> 
#> $result
#> [1] "NRC"
test3_3
#> $coloring
#>    taxaID NR color
#> 1:      1  1  blue
#> 2:      2  2  blue
#> 3:      3  3  blue
#> 4:      4  4  blue
#> 5:      5  5   red
#> 6:      6  6 green
#> 
#> $quadruples_colored
#>     taxa1 taxa2 taxa3 taxa4 quadruple taxa1_col taxa2_col taxa3_col taxa4_col
#>  1:     1     2     3     5   1_2_3_5      blue      blue      blue       red
#>  2:     1     2     3     6   1_2_3_6      blue      blue      blue     green
#>  3:     1     2     4     5   1_2_4_5      blue      blue      blue       red
#>  4:     1     2     4     6   1_2_4_6      blue      blue      blue     green
#>  5:     1     2     5     6   1_2_5_6      blue      blue       red     green
#>  6:     1     3     4     6   1_3_4_6      blue      blue      blue     green
#>  7:     1     3     5     6   1_3_5_6      blue      blue       red     green
#>  8:     1     4     5     6   1_4_5_6      blue      blue       red     green
#>  9:     2     3     4     5   2_3_4_5      blue      blue      blue       red
#> 10:     2     3     4     6   2_3_4_6      blue      blue      blue     green
#> 11:     2     3     5     6   2_3_5_6      blue      blue       red     green
#>     sumUniqueColors sumColored
#>  1:               2          4
#>  2:               2          4
#>  3:               2          4
#>  4:               2          4
#>  5:               3          4
#>  6:               2          4
#>  7:               3          4
#>  8:               3          4
#>  9:               2          4
#> 10:               2          4
#> 11:               3          4
#> 
#> $result
#> [1] "fail"
```

**Interpretation**

In both FTT algorithms, the output is a data table containing all
possible quadruples with a status entry (input, solved, unresolved) and
the used fixing taxon. The round number is slightly different: in my
algorithm, the round indicates the number of times a started the foreach
loop, in Mareikes algorithm its the combination of the for loop and the
tested taxa (all taxa are tested in a certain order).

The output of the findNRC algorithm is a list of the last round. In case
of a break its the first NRC coloring found, otherwise its the last RC
coloring. The first element is the coloring by taxa, the second element
the colored quadruples and the last the result (*fail*: no NRC, *NRC*:
NRC found).

The FTT algorithm cannot give false positives! If there are fixing taxa
to resolve all quadruples, the set is phylogenetic decisive (proof of
proposition 7 of Fischer Preprint).

The FTT algorithm can give false negatives! For example, the second
example set is phylogenetic decisive, but has not enough quadruples in
the set to enable the algorithm to find fixing taxa (see master thesis,
theorem 2).

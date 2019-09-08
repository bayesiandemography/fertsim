---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->


# fertsim

This repository contains the R code for the modelling and graphs of Section 4.1 of the paper

> Zhang JL, Bryant J. Forthcoming. Fully Bayesian benchmarking of small area estimation models. *Journal of Official Statistics*

In Section 4.1, we use simulated data on births disaggregated by age, area, and time to study the effect of benchmarking on model performance. 

The model and graphs in the paper can be reproduced by using the application `make` to run the file "Makefile". The outputs are created in the "out" folder. For more on makefiles, see, for instance, [Reproducibility starts at home](http://www.jonzelner.net/statistics/make/docker/reproducibility/2016/05/31/reproducibility-pt-1/).

For the code to run, you will need to have the packages **coda**, **docopt**, and **latticeExtra** installed on your computer. These can all be installed from CRAN.

You will also need to have the packages **dembase** and **demest**. These can be installed from GitHub using
``` r
devtools::install_github("statisticsnz/dembase")
devtools::install_github("statisticsnz/demest")
```

Finally, you'll need the simulated data on births. This is contained in the R package **simbirths** which can be installed from GitHub using
``` r
devtools::install_github("bayesiandemography/simbirths")
```





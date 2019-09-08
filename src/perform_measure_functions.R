
## Functions to measure performance

statsForD <- function(rates.est, exposure, rates.reg.time) {
    rates.est.ag <- collapseDimension(rates.est,
                                      dimension = "age",
                                      weights = exposure)
    mean.rates.est.ag <- collapseIterations(rates.est.ag,
                                            FUN = mean)
    ans <- abs(mean.rates.est.ag - rates.reg.time) / rates.reg.time
    as.numeric(ans)
}

statsForMSEMean <- function(rates.est, rates.true) {
    mean.rates.est <- collapseIterations(rates.est,
                                         FUN = mean)
    ans <- (mean.rates.est - rates.true)^2
    as.numeric(ans)
}


statsForMSEMedian <- function(rates.est, rates.true) {
    median.rates.est <- collapseIterations(rates.est,
                                           FUN = median)
    ans <- (median.rates.est - rates.true)^2
    as.numeric(ans)
}

statsForMAPEMean <- function(rates.est, rates.true) {
    mean.rates.est <- collapseIterations(rates.est,
                                         FUN = mean)
    ans <- 100 * abs(mean.rates.est - rates.true) / rates.true
    as.numeric(ans)
}

statsForMAPEMedian <- function(rates.est, rates.true) {
    median.rates.est <- collapseIterations(rates.est,
                                           FUN = median)
    ans <- 100 * abs(median.rates.est - rates.true) / rates.true
    as.numeric(ans)
}

statsForW <- function(rates.est) {
    kProbQuantiles <- c(0.025, 0.975)
    quantiles.rates.est <- collapseIterations(rates.est, prob = kProbQuantiles)
    lower <- slab(quantiles.rates.est,
                  dimension = "quantile",
                  elements = 1L)
    upper <- slab(quantiles.rates.est,
                  dimension = "quantile",
                  elements = 2L)
    ans <- upper - lower
    as.numeric(ans)
}

statsForC <- function(rates.est, rates.true) {
    kProbQuantiles <- c(0.025, 0.975)
    quantiles.rates.est <- collapseIterations(rates.est,
                                              prob = kProbQuantiles)
    lower <- slab(quantiles.rates.est,
                  dimension = "quantile",
                  elements = 1L)
    upper <- slab(quantiles.rates.est,
                  dimension = "quantile",
                  elements = 2L)
    inside.interval <- (lower <= rates.true) & (rates.true <= upper)
    as.logical(inside.interval)
}


save(statsForD,
     statsForMSEMean, statsForMSEMedian,
     statsForMAPEMean, statsForMAPEMedian,
     statsForW, statsForC,
     file = "out/perform_measure_functions.rda")

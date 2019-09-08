
## PRELIMINARIES ##############################################################

library(methods)
library(demest)
library(docopt)
library(simbirths)

## Control values

'Usage:
   fertility_estimation.R [options]

Options:
  --variant (base | level | distn) [default: base]
  --bench (none | inexact | exact) [default: none]
  --scale [default: 0.25]
  -b --nBurnin [default: 100]
  -s --nSim [default: 100]
  -c --nChain [default: 4]
  -t --nThin [default: 2]
  -r --nReplicate [default: 5]
' -> doc

opts <- docopt(doc)
variant <- opts$variant
bench <- opts$bench
scale <- as.numeric(opts$scale)
nBurnin <- as.integer(opts$nBurnin)
nSim <- as.integer(opts$nSim)
nChain <- as.integer(opts$nChain)
nThin <- as.integer(opts$nThin)
nReplicate <- as.integer(opts$nReplicate)


## Functions to measure performance

load("out/perform_measure_functions.rda")


## Objects from sim.births

name.counts <- sprintf("sim.birth.counts.%s", variant)
name.rates.true <- sprintf("sim.birth.rates.%s", variant)
y.all <- get(name.counts)
rates.true.all <- get(name.rates.true)
exposure <- sim.fem.popn
y.all <- Counts(y.all,
                dimscales = c(time = "Intervals"))
rates.true.all <- Counts(rates.true.all,
                         dimscales = c(time = "Intervals"))
exposure <- Counts(exposure,
                   dimscales = c(time = "Intervals"))
y.reg.time.all <- collapseDimension(y.all,
                                    dimension = "age")
rates.reg.time.all <- y.reg.time.all / exposure
standard.bench <- apply(sim.birth.standard,
                        MARGIN = c("region", "time"),
                        all)
standard.bench <- as.logical(standard.bench)
standard.cell <- as.logical(sim.birth.standard)
id.bench <- seq_along(standard.bench)
id.cell <- seq_along(standard.cell)


## Objects to hold results

perform_bench <- vector(mode = "list",
                        length = nReplicate)
perform_cells <- vector(mode = "list",
                        length = nReplicate)

if (bench == "none")
    unbenchmarked.mean.rates <- vector(mode = "list",
                                       length = nReplicate)


## SIMULATION #################################################################

set.seed(0)

for (i in seq_len(nReplicate)) {

    cat("starting replicate", variant, bench, i, "\n")

    ## Make benchmarks and models
    
    rates.reg.time <- subarray(rates.reg.time.all,
                               subarray = iteration == i)
    
    if (bench == "none") {
        model <- Model(y ~ Poisson(mean ~ age + region + time),
                       age ~ DLM(trend = NULL, damp = NULL),
                       time ~ Exch(error = Error(scale = HalfT(scale = 0.25))),
                       region ~ Exch(error = Error(scale = HalfT(scale = 0.25))),
                       priorSD = HalfT(scale = scale),
                       jump = 0.25)
    } else if (bench %in% c("inexact", "exact")) {
        if (bench == "inexact")
            aggregate <- AgPoisson(value = rates.reg.time,
                                   jump = 0.1)
        else
            aggregate <- AgCertain(value = rates.reg.time)
        model <- Model(y ~ Poisson(mean ~ age + region + time),
                       age ~ DLM(trend = NULL, damp = NULL),
                       time ~ Exch(error = Error(scale = HalfT(scale = 0.25))),
                       region ~ Exch(error = Error(scale = HalfT(scale = 0.25))),
                       priorSD = HalfT(scale = scale),
                       aggregate = aggregate,
                       jump = 0.25)
    } else {
        stop(gettextf("invalid value for bench : \"%s\"", bench))
    }

    mcmc_multiplier <- if (bench == "none") 5 else 1 # non-benchmarked takes longer to converge
    
    ## Estimate

    y <- subarray(y.all,
                  subarray = iteration == i)
    filename <- tempfile()
    estimateModel(model,
                  y = y,
                  exposure = exposure,
                  filename = filename,
                  nBurnin = nBurnin * mcmc_multiplier,
                  nSim = nSim * mcmc_multiplier,
                  nChain = nChain,
                  nThin = nThin * mcmc_multiplier)
    s <- fetchSummary(filename)
    print(s)


    ## Extract results and calculate performance measures

    rates.est <- fetch(filename,
                       where = c("model", "likelihood", "rate"))
    rates.true <- subarray(rates.true.all,
                           subarray = iteration == i)
    D <- statsForD(rates.est = rates.est,
                   exposure = exposure,
                   rates.reg.time = rates.reg.time)
    MSE.mean <- statsForMSEMean(rates.est = rates.est,
                                rates.true = rates.true)
    MSE.median <- statsForMSEMedian(rates.est = rates.est,
                                    rates.true = rates.true)
    MAPE.mean <- statsForMAPEMean(rates.est = rates.est,
                                  rates.true = rates.true)
    MAPE.median <- statsForMAPEMedian(rates.est = rates.est,
                                      rates.true = rates.true)
    W <- statsForW(rates.est = rates.est)
    C <- statsForC(rates.est = rates.est,
                   rates.true = rates.true)

    perform_bench.i <- data.frame(variant = variant,
                                  bench = bench,
                                  iteration = i,
                                  id = id.bench,
                                  standard = standard.bench,
                                  D = D,
                                  row.names = NULL)
    perform_cells.i <- data.frame(variant = variant,
                                  bench = bench,
                                  iteration = i,
                                  id = id.cell,
                                  standard = standard.cell,
                                  MSE.mean = MSE.mean,
                                  MSE.median = MSE.median,
                                  MAPE.mean = MAPE.mean,
                                  MAPE.median = MAPE.median,
                                  W = W,
                                  C = C,
                                  row.names = NULL)
    perform_bench[[i]] <- perform_bench.i
    perform_cells[[i]] <- perform_cells.i

    if (bench == "none")
        unbenchmarked.mean.rates[[i]] <- collapseIterations(rates.est, FUN = mean)
    
}


## COLLECT AND SAVE RESULTS ###################################################

perform_bench <- do.call(rbind,
                         args = perform_bench)
perform_cells <- do.call(rbind,
                         args = perform_cells)
file <- sprintf("out/perform_%s_%s.rda",
                variant, bench)

if (bench == "none") {
    save(perform_bench, perform_cells, unbenchmarked.mean.rates,
         file = file)
} else {
    save(perform_bench, perform_cells,
         file = file)
}
    





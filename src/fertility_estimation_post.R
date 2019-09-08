
## PRELIMINARIES ##############################################################

library(methods)
library(demest)
library(docopt)
library(simbirths)


## Control values

'Usage:
   fertility_estimation_post.R [options]

Options:
  --variant (base | level | distn) [default: base]
  --bench (raked | datta) [default: raked]
  -r --nReplicate [default: 5]
' -> doc

opts <- docopt(doc)
variant <- opts$variant
bench <- opts$bench
nReplicate <- as.integer(opts$nReplicate)


## Functions to measure performance

load("out/perform_measure_functions.rda")


## Unbenchmarked mean rates

file <- sprintf("out/perform_%s_none.rda",
                variant)
load(file)
rm(perform_bench)
rm(perform_cells)
## (leaves 'unbenchmarked.mean.rates')


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


## Benchmark weights matrix B

n.age <- dim(exposure)[1L]
n.reg.time <- length(exposure) / n.age
wt <- prop.table(exposure, margin = c("region", "time"))
wt <- matrix(wt, nrow = n.age)
B <- matrix(0, nrow = n.age * n.reg.time, ncol = n.reg.time)
for (i in seq_len(ncol(wt)))
    B[seq(to = i * n.age, length = n.age), i] <- wt[, i]


## Objects to hold results

perform_bench <- vector(mode = "list",
                        length = nReplicate)
perform_cells <- vector(mode = "list",
                        length = nReplicate)


## Calculations #################################################################

for (i in seq_len(nReplicate)) {

    ## Death counts

    y <- subarray(y.all,
                  subarray = iteration == i)
    
    ## Benchmarks
    
    rates.reg.time <- subarray(rates.reg.time.all,
                               subarray = iteration == i)
    benchmarks <- as.numeric(rates.reg.time)

    ## Unbenchmarked means

    unbench.mean <- unbenchmarked.mean.rates[[i]]
    unbench.mean <- as.numeric(unbench.mean)
    ag.unbench.mean <- crossprod(B, unbench.mean)
    ag.unbench.mean <- as.numeric(ag.unbench.mean)

    ## Construct estimate

    if (bench == "raked") {
        raked.numerator <- rep(benchmarks, each = n.age)
        raked.denominator <- rep(ag.unbench.mean, each = n.age)
        rates.est <- unbench.mean * raked.numerator / raked.denominator
    } else if (bench == "datta") {
        Omega.inv <- y / exposure^2
        Omega.inv <- as.numeric(Omega.inv)
        Omega.inv <- diag(Omega.inv)
        A <- Omega.inv %*% B %*% solve(crossprod(B, Omega.inv) %*% B)
        rates.est <- unbench.mean + A %*% (benchmarks - ag.unbench.mean)
    } else
        stop(gettextf("invalid value for bench : \"%s\"", bench))
    rates.est <- array(rates.est,
                       dim = dim(y),
                       dimnames = dimnames(y))
    rates.est <- Values(rates.est,
                        dimscales = c(time = "Intervals"))        
        
    
    ## Calculate performance measures

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
    W <- rep(NA, times = length(rates.est))
    C <- rep(NA, times = length(rates.est))

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
    
}


## COLLECT AND SAVE RESULTS ###################################################

perform_bench <- do.call(rbind,
                         args = perform_bench)
perform_cells <- do.call(rbind,
                         args = perform_cells)
file = sprintf("out/perform_%s_%s.rda",
               variant, bench)
save(perform_bench, perform_cells,
     file = file)





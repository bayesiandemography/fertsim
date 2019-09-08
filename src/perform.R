
perform_bench_all <- data.frame(variant = character(),
                                bench = character(),
                                iteration = integer(),
                                id = integer(),
                                standard = logical(),
                                D = numeric())
perform_cells_all <- data.frame(variant = character(),
                                bench = character(),
                                iteration = integer(),
                                id = integer(),
                                standard = logical(),
                                MSE.mean = numeric(),
                                MSE.median = numeric(),
                                MAPE.mean = numeric(),
                                MAPE.median = numeric(),
                                W = numeric(),
                                C = numeric())
for (variant in c("base", "level", "distn")) {
    for (bench in c("none", "inexact", "exact", "raked", "datta")) {
        file = sprintf("out/perform_%s_%s.rda",
                       variant, bench)
        load(file)
        perform_bench_all <- rbind(perform_bench_all,
                                   perform_bench)
        perform_cells_all <- rbind(perform_cells_all,
                                   perform_cells)
    }
}
perform_bench_all <- aggregate(perform_bench_all["D"],
                               perform_bench_all[c("variant", "bench", "id", "standard")],
                               mean)
perform_cells_all <- aggregate(perform_cells_all[c("MSE.mean", "MSE.median", "MAPE.mean", "MAPE.median", "W", "C")],
                               perform_cells_all[c("variant", "bench", "id", "standard")],
                               mean)
perform_bench_all$D <- 100 * perform_bench_all$D
perform_cells_all$MSE.mean <- 1000 * sqrt(perform_cells_all$MSE.mean)
perform_cells_all$MSE.median <- 1000 * sqrt(perform_cells_all$MSE.median)
perform_cells_all$W <- 1000 * perform_cells_all$W
perform_cells_all$C <- 100 * perform_cells_all$C
perform_bench_all$measure <- "D"
names(perform_bench_all)[match("D", names(perform_bench_all))] <- "value"
perform_cells_all <- reshape(perform_cells_all,
                             varying = list(c("MSE.mean", "MSE.median", "MAPE.mean", "MAPE.median", "W", "C")),
                             v.names = "value",
                             idvar = c("variant", "bench", "id", "standard"),
                             timevar = "measure",
                             times = c("MSE.mean", "MSE.median", "MAPE.mean", "MAPE.median", "W", "C"),
                             direction = "long")
perform <- rbind(perform_bench_all,
                 perform_cells_all)
perform$variant <- factor(perform$variant,
                          levels = c("base", "level", "distn"),
                          labels = c("No change", "Change in level", "Change in distn"))
perform$bench <- factor(perform$bench,
                        levels = c("datta", "raked", "exact", "inexact", "none"),
                        labels = c("DGSM", "Raked", "Exact", "Inexact", "None"))
perform$measure <- factor(perform$measure,
                          levels = c("D", "MSE.mean", "MSE.median", "MAPE.mean", "MAPE.median", "W", "C"))
perform$standard <- factor(perform$standard,
                           levels = c("TRUE", "FALSE"),
                           labels = c("Standard", "Non-standard"))
saveRDS(perform,
        file = "out/perform.rds")
        

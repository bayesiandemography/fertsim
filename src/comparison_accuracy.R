
library(latticeExtra)

perform <- readRDS("out/perform.rds")
perform <- subset(perform,
                  subset = (measure %in% c("MSE.mean", "MSE.median", "MAPE.mean", "MAPE.median")))
perform$measure <- droplevels(perform$measure)
perform$bench <- factor(perform$bench, levels = rev(levels(perform$bench)))
comparison_accuracy <- round(tapply(perform$value, perform[c("bench", "measure", "variant")], median), 1)
saveRDS(comparison_accuracy,
        file = "out/comparison_accuracy.rds")




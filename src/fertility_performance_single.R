
library(methods)
library(docopt)
library(latticeExtra)

'Usage:
   fertility_performance_single.R [options]

Options:
  --variant (level | distn) [default: level]
' -> doc

opts <- docopt(doc)
variant <- opts$variant

perform <- readRDS("out/perform.rds")
perform <- subset(perform,
                  subset = !(measure %in% c("MSE.median", "MAPE.mean", "MAPE.median")))
perform$measure <- droplevels(perform$measure)               

label <- sprintf("Change in %s", variant)
data <- perform[perform$variant == label, ]

panel.special <- function(x, y, ...) {
    panel.bwplot(x, y, ...)
    medians <- tapply(x, y, median)
    labels <- sprintf("%3.1f", round(medians, 1))
    x <- as.numeric(medians)
    y <- match(names(medians), levels(y))
    panel.text(labels = labels, x = x, y = y + 0.4, cex = 0.8)
}
strip.special <- strip.custom(factor.levels =
                                  c(expression(Discrepancy~~italic(D[rt]%*%1000)),
                                    expression(sqrt(MSE[italic(art)])%*%1000),
                                    expression(Width~~italic(W[art]^0.95)%*%1000),
                                    expression(Coverage~~italic(C[art]^0.95))))
xlim <- list(c(0, 7), c(0, 35), c(0, 65), c(-1, 101))
p <- bwplot(bench ~ value | measure + standard,
            data = data,
            box.ratio = 0.9,
            par.settings = list(box.rectangle = list(col = "black"),
                                box.umbrella = list(col = "black"),
                                plot.symbol = list(col = "black", pch = "|"),
                                fontsize = list(text = 8, points = 6),
                                strip.background = list(col = "grey90")),
            scales = list(tck = 0.4, x = list(relation = "free")),
            pch = "|",
            xlab = "",
            xlim = xlim,
            as.table = TRUE,
            panel = panel.special)
p <- useOuterStrips(p,
                    strip = strip.special,
                    strip.lines = 1.4)
file.pdf <- sprintf("out/fertility_performance_%s.pdf", variant)
pdf(file = file.pdf,
    width = 6,
    height = 3.6)
plot(p)
dev.off()



library(methods)
library(xtable)            

## Rates used to generate synthetic data in package 'simbirths'.
## The code to generate the birth rates is in simbirths/data-raw/sim.birth.rates.R

labels.age.groups <- paste(seq(15, 40, 5), seq(19, 44, 5), sep = "-")

asfr.total <- c(0.02884,
                0.07135,
                0.10827,
                0.12100,
                0.06533,
                0.01266)
names(asfr.total) <- labels.age.groups

asfr.maori <- c(0.07096 * 1.5,
                0.15006 * 1.25,
                0.14334,
                0.11120,
                0.06033,
                0.01503)
names(asfr.maori) <- labels.age.groups

age.effect.standard <- asfr.total
age.effect.nonstandard <- prop.table(asfr.maori) * sum(asfr.total)

age.effect.table <- data.frame(Standard = age.effect.standard,
                               Nonstandard = age.effect.nonstandard)
age.effect.table <- rbind(age.effect.table, Total = colSums(age.effect.table))
age.effect.table <- xtable(age.effect.table,
                           caption = "Age effects (exponentiated)",
                           align = c("r", "c", "c"),
                           label = "tab:fertility_age_effects",
                           digits = c(0, 4, 4))
nr <- nrow(age.effect.table)
age.effect.table <- print(age.effect.table,
                          caption.placement = "top",
                          hline.after = c(-1, 0, nr-1, nr),
                          sanitize.colnames.function = function(x) x)

cat(age.effect.table,
    file = "out/fertility_age_effects.tex")


scale = 0.25
b = 2000 # nBurnin
s = 2000 # nSim
c = 4     # nChain
t = 8    # nThin
r = 200    # nReplicate



.PHONY: all
all: out/fertility_age_effects.tex \
     out/fertility_performance_all.pdf \
     out/fertility_performance_distn.pdf \
     out/fertility_performance_level.pdf


out/comparison_accuracy.rds : src/comparison_accuracy.R \
                              out/perform.rds
	Rscript $<

out/fertility_performance_level.pdf : src/fertility_performance_single.R \
                                      out/perform.rds
	Rscript $< --variant level

out/fertility_performance_distn.pdf : src/fertility_performance_single.R \
                                      out/perform.rds
	Rscript $< --variant distn

out/fertility_performance_all.pdf : src/fertility_performance_all.R \
                                    out/perform.rds
	Rscript $<

out/perform.rds : src/perform.R \
                  out/perform_base_none.rda \
                  out/perform_base_inexact.rda \
                  out/perform_base_exact.rda \
                  out/perform_base_raked.rda \
                  out/perform_base_datta.rda \
                  out/perform_level_none.rda \
                  out/perform_level_inexact.rda \
                  out/perform_level_exact.rda \
                  out/perform_level_raked.rda \
                  out/perform_level_datta.rda \
                  out/perform_distn_none.rda \
                  out/perform_distn_inexact.rda \
                  out/perform_distn_exact.rda \
                  out/perform_distn_raked.rda \
                  out/perform_distn_datta.rda
	Rscript $<

out/perform_base_none.rda : src/fertility_estimation.R \
                            out/perform_measure_functions.rda
	Rscript $< --variant base --bench none --scale $(scale) -b $(b) -s $(s) -c $(c) -t $(t) -r $(r)

out/perform_base_inexact.rda : src/fertility_estimation.R \
                           out/perform_measure_functions.rda
	Rscript $< --variant base --bench inexact --scale $(scale) -b $(b) -s $(s) -c $(c) -t $(t) -r $(r)

out/perform_base_exact.rda : src/fertility_estimation.R \
                         out/perform_measure_functions.rda
	Rscript $< --variant base --bench exact --scale $(scale) -b $(b) -s $(s) -c $(c) -t $(t) -r $(r)

out/perform_base_raked.rda : src/fertility_estimation_post.R \
                             out/perform_measure_functions.rda
	Rscript $< --variant base --bench raked -r $(r)

out/perform_base_datta.rda : src/fertility_estimation_post.R \
                             out/perform_measure_functions.rda
	Rscript $< --variant base --bench datta -r $(r)

out/perform_level_none.rda : src/fertility_estimation.R \
                         out/perform_measure_functions.rda
	Rscript $< --variant level --bench none --scale $(scale) -b $(b) -s $(s) -c $(c) -t $(t) -r $(r)

out/perform_level_inexact.rda : src/fertility_estimation.R \
                            out/perform_measure_functions.rda
	Rscript $< --variant level --bench inexact --scale $(scale) -b $(b) -s $(s) -c $(c) -t $(t) -r $(r)

out/perform_level_exact.rda : src/fertility_estimation.R \
                          out/perform_measure_functions.rda
	Rscript $< --variant level --bench exact --scale $(scale) -b $(b) -s $(s) -c $(c) -t $(t) -r $(r)

out/perform_level_raked.rda : src/fertility_estimation_post.R \
                          out/perform_measure_functions.rda
	Rscript $< --variant level --bench raked -r $(r)

out/perform_level_datta.rda : src/fertility_estimation_post.R \
                          out/perform_measure_functions.rda
	Rscript $< --variant level --bench datta -r $(r)

out/perform_distn_none.rda : src/fertility_estimation.R \
                         out/perform_measure_functions.rda
	Rscript $< --variant distn --bench none --scale $(scale) -b $(b) -s $(s) -c $(c) -t $(t) -r $(r)

out/perform_distn_inexact.rda : src/fertility_estimation.R \
                            out/perform_measure_functions.rda
	Rscript $< --variant distn --bench inexact --scale $(scale) -b $(b) -s $(s) -c $(c) -t $(t) -r $(r)

out/perform_distn_exact.rda : src/fertility_estimation.R \
                              out/perform_measure_functions.rda
	Rscript $< --variant distn --bench exact --scale $(scale) -b $(b) -s $(s) -c $(c) -t $(t) -r $(r)

out/perform_distn_raked.rda : src/fertility_estimation_post.R \
                              out/perform_measure_functions.rda \
                              out/perform_distn_none.rda
	Rscript $< --variant distn --bench raked -r $(r)

out/perform_distn_datta.rda : src/fertility_estimation_post.R \
                              out/perform_measure_functions.rda \
                              out/perform_distn_none.rda
	Rscript $< --variant distn --bench datta -r $(r)

out/fertility_age_effects.tex : src/fertility_age_effects.R
	Rscript $<

out/perform_measure_functions.rda : src/perform_measure_functions.R
	Rscript $<



.PHONY: clean
clean:
	rm -rf out
	mkdir -p out



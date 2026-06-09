# Precompiled vignettes that require specialist packages or extenisve downloads via APIs
# Must manually move image files from oceandatr/ to oceandatr/vignettes/ after knit

knitr::knit("vignettes/usage_prioritization.Rmd.orig", "vignettes/usage_prioritization.Rmd")
knitr::knit("vignettes/getboundary.Rmd.orig", "vignettes/getboundary.Rmd")

fs::dir_copy("figure", "vignettes/figure", overwrite = TRUE)
fs::dir_delete("figure")
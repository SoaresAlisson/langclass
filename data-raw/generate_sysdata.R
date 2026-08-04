# Regenerate the pre-trained classifier shipped as `sysdata.rda`.
#
# Run from the package root:
#   Rscript dev/generate_sysdata.R
#
# This builds a Naive Bayes model over the stopword lists for every
# language reported by available_languages("stopwords-iso") and stores it
# as R/sysdata.rda (internal, non-exported). The classifier is then used by
# classify_text() when no model is supplied.

suppressPackageStartupMessages({
  library(stopwords)
  library(quanteda)
  library(quanteda.textmodels)
})

# Load the package functions without installing
for (f in list.files("R", pattern = "\\.R$", full.names = TRUE)) {
  source(f)
}

langclass_classifier <- build_classifier(source = "stopwords-iso")

dir.create("R", showWarnings = FALSE)
save(langclass_classifier, file = "R/sysdata.rda", compress = "xz")

cat("Saved R/sysdata.rda (",
    format(file.info("R/sysdata.rda")$size, big.mark = ","),
    " bytes)\n", sep = "")

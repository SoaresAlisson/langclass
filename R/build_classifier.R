#' Build a Naive Bayes language classifier
#'
#' Trains a Naive Bayes model over the stopword lists for every language
#' reported by [available_languages()] using
#' [quanteda.textmodels::textmodel_nb()]. Each language contributes one
#' "document" containing its stopwords, and the class label is the language
#' code. The resulting model can classify any new text into one of those
#' languages.
#'
#' @param source Character; passed to [available_languages()]. Defaults to
#'   `"stopwords-iso"`.
#' @param prior Character; the prior distribution used by
#'   [quanteda.textmodels::textmodel_nb()]. One of `"uniform"`,
#'   `"docfreq"` or `"termfreq"`. Defaults to `"uniform"`.
#' @param ... Additional arguments passed to
#'   [quanteda.textmodels::textmodel_nb()].
#'
#' @return A trained `textmodel_nb` object, suitable for passing to
#'   [classify_text()].
#'
#' @seealso [available_languages()], [classify_text()]
#' @export
#' @examples
#' \dontrun{
#' m <- build_classifier()
#' classify_text("Hallo Leute, mein Name ist Johannes", model = m)
#' }
build_classifier <- function(source = "stopwords-iso",
                             prior = c("uniform", "docfreq", "termfreq"),
                             ...) {
  langs <- available_languages(source)
  stopword_lists <- stats::setNames(
    lapply(langs, function(l) stopwords::stopwords(l, source = source)),
    langs
  )
  # Normalize to NFC so the model's features match what quanteda::tokens()
  # emits when classifying new text. stopwords() returns some entries in NFD
  # (e.g. certain Arabic ones), which would otherwise make the newdata
  # feature set non-conformant during prediction.
  stopword_lists <- lapply(stopword_lists, stringi::stri_trans_nfc)

  dfm_ <- quanteda::dfm(
    quanteda::tokens(stopword_lists),
    tolower = TRUE
  )

  quanteda.textmodels::textmodel_nb(
    dfm_,
    y = langs,
    prior = match.arg(prior),
    ...
  )
}

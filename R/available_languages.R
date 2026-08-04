#' Languages available for classification
#'
#' Returns the set of language codes for which the package can classify
#' texts. The default classifier is trained over every language listed by
#' [stopwords::stopwords_getsources()] that `stopwords` supports for the
#' chosen source.
#'
#' @param source Character; the `stopwords` source to draw language codes
#'   from. Defaults to `"stopwords-iso"`, which offers the widest coverage.
#'   Other options include `"snowball"`, `"smart"`, `"marimo"`, `"nltk"`,
#'   `"misc"`, `"ancient"` and `"perseus"` (see
#'   [stopwords::stopwords_getsources()]).
#'
#' @return A character vector of language codes (e.g. `"en"`, `"pt"`,
#'   `"de"`), sorted alphabetically.
#'
#' @export
#' @examples
#' available_languages()
#' available_languages(source = "snowball")
available_languages <- function(source = "stopwords-iso") {
  sort(stopwords::stopwords_getlanguages(source))
}

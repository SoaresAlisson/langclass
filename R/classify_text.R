#' Classify the language of a text
#'
#' Predicts the language of one or more texts using a Naive Bayes
#' classifier trained on stopword lists (see [build_classifier()]). By
#' default the package ships a pre-trained classifier covering all
#' languages from the `stopwords` package, so you can classify texts
#' without building a model first.
#'
#' @param text Character vector. One or more texts to classify.
#' @param model A trained `textmodel_nb` object (from
#'   [build_classifier()]) or the default classifier. If `NULL`
#'   (default), the classifier shipped with the package is used.
#' @param threshold Numeric scalar in `[0, 1]`. If the probability of the
#'   best-scoring language is below this value, the text is considered
#'   unidentifiable and the prediction is returned as `NA`.
#' @param details Logical. If `TRUE`, returns a data frame with a row per
#'   text and a column per language holding the posterior probabilities, plus
#'   a `label` column (the best-scoring language, or `NA` when its
#'   probability is below `threshold`) and a `probability` column (the raw
#'   probability of that best-scoring language). If `FALSE` (default),
#'   returns a named character vector with the best language per text (or
#'   `NA` when below `threshold`).
#' @param ... Additional arguments passed to
#'   [quanteda.textmodels::predict.textmodel_nb()].
#'
#' @return Either a named character vector of predicted language codes, or
#'   (when `details = TRUE`) a data frame with the full probability table.
#'
#' @seealso [build_classifier()], [available_languages()]
#' @export
#' @examples
#' classify_text("Olá pessoal, meu nome é João")
#' classify_text(c("Hello everyone, my name is John",
#'                 "Ciao a tutti, il mio nome è Marco"))
#' classify_text("Hola a todos, mi nombre es João", details = TRUE)
classify_text <- function(text,
                          model = NULL,
                          threshold = 0,
                          details = FALSE,
                          ...) {
  if (is.null(model)) {
    model <- langclass_classifier
  }

  if (!inherits(model, "textmodel_nb")) {
    stop("`model` must be a textmodel_nb object (see ?build_classifier).",
         call. = FALSE)
  }

  if (!is.numeric(threshold) || length(threshold) != 1L || is.na(threshold) ||
      threshold < 0 || threshold > 1) {
    stop("`threshold` must be a single number between 0 and 1.", call. = FALSE)
  }

  text <- as.character(text)
  if (length(text) == 0L) {
    return(if (details) {
      data.frame()
    } else {
      character(0)
    })
  }
  if (anyNA(text) || any(!nzchar(text))) {
    stop("`text` must be a character vector with no missing or empty values.",
         call. = FALSE)
  }

  feats <- quanteda::featnames(model$x)
  dfm_new <- quanteda::dfm(quanteda::tokens(tolower(text)))
  dfm_new <- quanteda::dfm_match(dfm_new, features = feats)

  predict_nb <- utils::getS3method("predict", "textmodel_nb", optional = TRUE)
  if (is.null(predict_nb)) {
    loadNamespace("quanteda.textmodels")
    predict_nb <- utils::getS3method("predict", "textmodel_nb", optional = TRUE)
  }
  if (is.null(predict_nb)) {
    stop("Could not find the predict method for textmodel_nb. Make sure ",
         "quanteda.textmodels is installed.", call. = FALSE)
  }
  prob <- predict_nb(model, newdata = dfm_new, type = "probability", ...)

  best_idx <- max.col(prob, ties.method = "first")
  labels <- colnames(prob)[best_idx]
  probs <- prob[cbind(seq_len(nrow(prob)), best_idx)]
  labels[probs < threshold] <- NA_character_

  if (details) {
    out <- as.data.frame(prob)
    out$label <- labels
    out$probability <- probs
    return(out)
  }

  names(labels) <- if (!is.null(dimnames(prob)[[1L]])) {
    dimnames(prob)[[1L]]
  } else {
    seq_along(labels)
  }
  labels
}

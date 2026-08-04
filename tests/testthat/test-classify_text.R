test_that("classify_text identifies the correct language", {
  expect_identical(unname(classify_text("Hello everyone, my name is John")), "en")
  expect_identical(unname(classify_text("Olá pessoal, meu nome é João")), "pt")
  expect_identical(unname(classify_text("Hallo Leute, mein Name ist Johannes")), "de")
  expect_identical(unname(classify_text("Hola a todos, mi nombre es João")), "es")
  expect_identical(unname(classify_text("Bonjour tout le monde, mon nom est João")), "fr")
  expect_identical(unname(classify_text("Ciao a tutti, il mio nome è João")), "it")
})

test_that("classify_text handles a vector of texts", {
  txts <- c("Hello everyone, my name is John",
            "Olá pessoal, meu nome é João",
            "Hallo Leute, mein Name ist Johannes")
  out <- classify_text(txts)
  expect_type(out, "character")
  expect_named(out)
  expect_identical(unname(out), c("en", "pt", "de"))
})

test_that("classify_text returns probabilities with details = TRUE", {
  d <- classify_text("Hola a todos, mi nombre es João", details = TRUE)
  expect_s3_class(d, "data.frame")
  expect_true(all(c("label", "probability") %in% colnames(d)))
  expect_identical(d$label[[1]], "es")
  expect_identical(nrow(d), 1L)
  # probability column matches the label column's probability
  expect_equal(d$probability[[1]], d[[d$label[[1]]]][[1]])
})

test_that("classify_text threshold flags low-confidence predictions", {
  # "123" carries no stopword signal and scores near the uniform prior (~1/57)
  expect_true(is.na(classify_text("123", threshold = 0.05)))
  # real English text clears the threshold
  expect_false(is.na(classify_text("Hello everyone, my name is John",
                                   threshold = 0.05)))
})

test_that("classify_text uses a supplied model", {
  m <- build_classifier(source = "snowball")
  out <- classify_text("Hallo Leute, mein Name ist Johannes", model = m)
  expect_identical(unname(out), "de")
})

test_that("classify_text validates inputs", {
  expect_error(classify_text(character(0)), NA)
  expect_error(classify_text(""))
  expect_error(classify_text(NA_character_))
  expect_error(classify_text("hello", model = "not a model"))
  expect_error(classify_text("hello", threshold = -0.1))
  expect_error(classify_text("hello", threshold = 1.5))
  expect_error(classify_text("hello", threshold = c(0, 0.5)))
})

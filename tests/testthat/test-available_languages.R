test_that("available_languages returns a non-empty sorted character vector", {
  langs <- available_languages()
  expect_type(langs, "character")
  expect_gt(length(langs), 20)
  expect_equal(anyDuplicated(langs), 0L)
  expect_identical(langs, sort(langs))

  # common languages are covered
  expect_true(all(c("en", "pt", "es", "de", "fr", "it") %in% langs))

  # a different source returns its own set
  snowball <- available_languages("snowball")
  expect_true("de" %in% snowball)
  expect_false("af" %in% snowball)  # not in snowball
})

test_that("available_languages rejects unknown sources", {
  expect_error(available_languages("not-a-source"), class = "condition")
})

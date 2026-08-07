# langClass package


# langclass

## A Language classifier using Naive Bayes

Identify the language of a text using the ultra speed of a Naive Bayes
classifier.

This package uses
[Quanteda::stopwords](https://github.com/quanteda/stopwords) (see the
[documentation](https://stopwords.quanteda.io/reference/index.html)) to
train a Naive Bayes classifier over stopword lists for all languages
available in the `stopwords` package, then classifies new texts into one
of those languages.

## Installation

``` r
# install.packages("remotes")
remotes::install_github("SoaresAlisson/langclass")
```

## Usage

``` r
library(langclass)

available_languages()
```

     [1] "af" "ar" "bg" "bn" "br" "ca" "cs" "da" "de" "el" "en" "eo" "es" "et" "eu"
    [16] "fa" "fi" "fr" "ga" "gl" "ha" "he" "hi" "hr" "hu" "hy" "id" "it" "ja" "ko"
    [31] "ku" "la" "lt" "lv" "mr" "ms" "nl" "no" "pl" "pt" "ro" "ru" "sk" "sl" "so"
    [46] "st" "sv" "sw" "th" "tl" "tr" "uk" "ur" "vi" "yo" "zh" "zu"

``` r
# Classify texts right away with the shipped pre-trained classifier
classify_text("Olá pessoal, meu nome é João")
```

    text1 
     "pt" 

``` r
classify_text(c("Hello everyone, my name is John",
                "Ciao a tutti, il mio nome è Marco"))
```

    text1 text2 
     "en"  "it" 

Or build your own classifier and use it

``` r
model <- build_classifier()
classify_text("Bonjour tout le monde, mon nom est Anne", model = model)
```

## Functions

- `available_languages()`: list all languages covered by the package.
- `build_classifier()`: (re)build a Naive Bayes classifier from the
  stopword lists.
- `classify_text()`: classify one or more texts into a language,
  returning the best match (and optionally the full probability table).

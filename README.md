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

## Limitations

`langclass` is a fast, lightweight heuristic, not a production-grade
language detector. The classifier only sees **stopwords**: each language
contributes a single “document” containing its stopword list, and
content words are dropped when classifying new text. That design keeps
the model small and instant, but it comes with real limits.

### It only sees stopwords

Texts with few or no stopwords carry almost no signal, and the
prediction is essentially arbitrary — ties break toward the
alphabetically first language (here, Afrikaans):

``` r
classify_text(c("Python programming", "John Smith"))
```

    text1 text2 
     "af"  "af" 

### Short texts are unreliable

The shorter the text, the fewer stopwords it contains and the closer
every language scores to the uniform prior (1/57 ≈ 0.018). Single-word
greetings are effectively random guesses:

``` r
classify_text(c("Olá!", "¡Hola!", "Tchüss!"))
```

    text1 text2 text3 
     "ko"  "ko"  "ko" 

### Closely related languages are confused

Languages that share many stopwords — Portuguese/Spanish,
Danish/Norwegian/ Swedish, Czech/Slovak — compete for the same text. The
winner is often right, but with low confidence, and its closest
competitors are usually sibling languages:

``` r
d <- classify_text("Mi casa es grande y bonita, me gusta mucho vivir aqui",
                   details = TRUE)
d[, c("label", "probability", "es", "it", "pt")]
```

          label probability        es         it         pt
    text1    es   0.3105861 0.3105861 0.08039824 0.04220078

### Unknown languages are forced into a known one

The classifier always picks the best of the languages it knows. A text
in an uncovered language — Icelandic and Amharic are absent from
`stopwords-iso` — is assigned an arbitrary label at near-uniform
probability:

``` r
classify_text(c("Ég heiti Jón og ég bý í Reykjavík",  # Icelandic, not covered
                "ሰላም እንዴት ነህ ስሜ አሊሰን ነው"))       # Amharic, not covered
```

    text1 text2 
     "yo"  "af" 

### Mixed-language texts get a single label

A code-switched or multilingual text is classified as one language —
usually the one contributing the most stopwords — with low confidence.
One workaround to this problem is to tokenize the text into sentences and then classify it.

### Script and spelling matter

Stopwords are matched in their native script, so a language written in
another script (Russian transliterated to Latin letters, Arabic in “chat
alphabet”) will not match its stopwords. Text is lowercased but
[diacritics are not
folded](https://quanteda.io/reference/char_tolower.html): `café` and
`cafe` are different tokens.

### Probabilities are not calibrated

Naive Bayes assumes features are independent (stopwords are not) and
each language is a single tiny document, so posterior probabilities do
not measure real-world accuracy — they only rank the candidates. Treat
`threshold` as a coarse safety valve and tune it on your own data:

``` r
classify_text(c("123", "Hello everyone, my name is John"), threshold = 0.05)
```

    text1 text2 
       NA  "en" 

### The quality ceiling is the `stopwords` lists

The model is only as good as the stopword lists it is trained on.
Coverage varies widely — from a few dozen to more than a thousand words
per language in `stopwords-iso` — and some languages are missing
entirely. For robust, production-grade detection, consider dedicated
tools such as [fastText](https://fasttext.cc/),
[CLD3](https://github.com/google/cld3) or
[langdetect](https://pypi.org/project/langdetect/).

## Functions

- `available_languages()`: list all languages covered by the package.
- `build_classifier()`: (re)build a Naive Bayes classifier from the
  stopword lists.
- `classify_text()`: classify one or more texts into a language,
  returning the best match (and optionally the full probability table).

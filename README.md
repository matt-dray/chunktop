
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {chunktop}

<!-- badges: start -->

[![Project Status: Concept – Minimal or no implementation has been done
yet, or the repository is only intended to be a limited example, demo,
or
proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
<!-- badges: end -->

Scenario: you’ve written a report in an R Markdown file, but your
collaborator is not an R user. You want to transfer the content of an R
Markdown chunk option to them for editing; perhaps something text heavy,
like the ‘fig.cap’ option. They’ll return to you the edited text and you
want to insert their changes back into the relevant chunk. This is
[John’s
reality](https://fosstodon.org/@johnmackintosh/111047625054222865).

The goal of {chunktop} is to extract the values of selected chunk
options, prepare them for external editing, receive the results and
reinsert them into the original R Markdown file. It uses [the {parsermd}
package](https://cran.r-project.org/package=parsermd) for all the heavy
lifting.

Install from GitHub:

``` r
if (!require("chunktop")) {
  install.packages("remotes")
  remotes::install_github("matt-dray/chunktop")
}
# Loading required package: chunktop
```

Currently the package will read an Rmd file and extract specific chunk
options to a list; convert this data to a data.frame to be saved to CSV;
reads in that CSV to a data.frame; and converts it back to a list.

Here’s a demo R Markdown file and an Abstract Syntax Tree (AST) of its
structure as extracted by {parsermd}.

``` r
path <- system.file("extdata/demo1.Rmd", package = "chunktop")
parsermd::parse_rmd(path)
# ├── YAML [1 lines]
# └── Heading [h1] - A header
#     ├── Chunk [r, 1 opt, 1 lines] - chunk1
#     └── Heading [h2] - A subheader
#         ├── Chunk [r, 2 opts, 1 lines] - chunk2
#         ├── Markdown [2 lines]
#         ├── Chunk [r, 1 lines] - chunk3
#         └── Chunk [r, 2 opts, 1 lines] - chunk4
```

Let’s use the {chunktop} functions to extract the options of interest.

``` r
(chunktop_list <- get_chunktop(path, c("fig.cap", "eval")))
# $chunk1
# $chunk1$eval
# [1] "FALSE"
# 
# 
# $chunk2
# $chunk2$fig.cap
# [1] "\"I am a fig caption.\""
# 
# 
# $chunk4
# $chunk4$fig.cap
# [1] "\"I am another fig caption.\""
# 
# $chunk4$eval
# [1] "TRUE"

(chunktop_df <- chunktop_to_df(chunktop_list))
#   chunk_name option_name                option_value
# 1     chunk1        eval                       FALSE
# 2     chunk2     fig.cap       "I am a fig caption."
# 3     chunk4     fig.cap "I am another fig caption."
# 4     chunk4        eval                        TRUE
  
csv_file <- tempfile(fileext = ".csv")

write.csv(chunktop_df, csv_file, row.names = FALSE)

(chunktop_df2 <- read.csv(csv_file))
#   chunk_name option_name                option_value
# 1     chunk1        eval                       FALSE
# 2     chunk2     fig.cap       "I am a fig caption."
# 3     chunk4     fig.cap "I am another fig caption."
# 4     chunk4        eval                        TRUE

(chunktop_list2 <- df_to_chunktop(chunktop_df2))
# $chunk1
# $chunk1$eval
# [1] "FALSE"
# 
# 
# $chunk2
# $chunk2$fig.cap
# [1] "\"I am a fig caption.\""
# 
# 
# $chunk4
# $chunk4$fig.cap
# [1] "\"I am another fig caption.\""
# 
# $chunk4$eval
# [1] "TRUE"

(chunktop_df3 <- chunktop_to_df(chunktop_list2))
#   chunk_name option_name                option_value
# 1     chunk1        eval                       FALSE
# 2     chunk2     fig.cap       "I am a fig caption."
# 3     chunk4     fig.cap "I am another fig caption."
# 4     chunk4        eval                        TRUE
```

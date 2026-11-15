
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {chunktop}

<!-- badges: start -->

[![Project Status: Abandoned – Initial development has started, but there has not yet been a stable, usable release; the project has been abandoned and the author(s) do not intend on continuing development.](https://www.repostatus.org/badges/latest/abandoned.svg)](https://www.repostatus.org/#abandoned)
[![Blog
posts](https://img.shields.io/badge/rostrum.blog-black?style=flat&labelColor=00ff00&logo=data%3Aimage%2Fgif%3Bbase64%2CR0lGODdhoACgAJEAAAAAAP%2F%2F%2FwAAAAAAACH5BAlkAAIALAAAAACgAKAAAAL%2FlI%2BpywgPY5u02hQzuLz7r0nfSBohVKbqdT7rS7UbTMNyjR93zoNtX9sBh7EfcSU8Kh3GJSnpVEKjnCkVaL0WT1pps2vJgr1cp3gMPufU6Cs7%2BG233zS6nByK2u%2FEPTLO1%2BWnMhi4BjhUaAhXtqS4aIOIJQmJpvhYqXVJmbm42dgZ%2BpkXWjqqUWrKOYGZioc60urat9ogOzsJ2nGLy3Oa0VtVy3AmUzy8wMuCrHBsTErMjCH9pytszfQMG40dRk34bcKpDZ0cLqDs3V3hTI5ie57OHj%2FuLsJdvnv%2BRL%2BObv8O3zYP8rbku3YwG0BW%2FRLmcjjPH8CA5vwxtIjj172K%2FwvhYRQITE67gc0mzgC5seRHS%2FUkmrwI8d%2FKMSNDotQGk%2BS0mWlaxjR5kqNOhUMN1Uy5s%2BNNFx5j3jlKUaVSoTapIvXks6i4iTmrStXKByrTpca6XtWxz0xWr0ntmY3ali1Wl3SnfpWLlqeghkDdxkrriG9fcvz0ahI8%2BFlhpyIRJ9YIdy5jso%2FBvh2bCXLlyVYjG3W82XJT0XNAhz4bkTNN06cx6zPshnXrxaQzv1TLNZg6u7Ry6zboN7Dv36Pd6blNvDhh3LyTEzXOPLjzu8uFN58u83oPoNg7K44Ovfvz6q%2FCi0%2FRuuz5w%2Blhr6%2FWvvZ7RvHxzn9Y3%2FP97fnt7%2F8%2F1J9%2B%2F2UUoIAD1lGgawf6kmBQ54mlHmVrkUedgQTWJV2F30mIoX8A%2FoScdxGKCOFxHVIYF4rj4aSchfSBxV2LG5I4oYsInsgihyAOp6GDve2oXXYZppijiCYCOeSKM%2FZYInioCWkekzUuSaSCiUw5opQ4Uqmkj3tt6WVeQTbZCZk0gnlZmIGYqSWS%2FhX0IYxYslmlmmFhmSadXaqCpoxZ1pkmn24%2BGSNZgYqCp596iilfT33qKOejtknaZqSD2hgMhIsuaKSiiXKamqVJMuohqFtdyiWpT5p6qqhRAsrqoZC%2BCdh6mn4aa6ezElrrg3PimiusuwoIJ6I81nmre4L%2Fjtrqq10WW9qxz%2F6qrLFjhlhpqb8Veiaqf3bHbba8SotduMhSq1ov5k4LJrQskdusiqoW6Su8UMobL73qAnsupcJO6m2e%2FO5pravjXuuvZAYTi%2B2%2FPS5La7sDz2vlZwlT%2FC3GsgK8cMX5pvqxne5GcnHIm96LqaMBe1oyyh7f2fK6GvsJ8cEdZxzyxpWcLHPONBccsbc89%2FrjzQLHTPSVSNt78lMTm%2Fy0y3Y6vTTCK5cZdc9S6wzJ0ExHTfXV3Rr9c7TpEjzsy5pNfeHZM6ctsmlHNor22EHT%2FXZ5q5Ztt83a6qp3ynWLy7B7IzuM0M1N833E2keL%2FZrb6MnNMuSJPv9NsuRbV062D9V6rnmyli%2FzOceYIx7s5IYnnbrjqWeOt8%2Bvwxf75rODs3rpt7t%2Bu%2Bqhsx4s773TdvrgkBQAADs%3D)](https://www.rostrum.blog/posts/2023-09-16-chunktop/)

<!-- badges: end -->

>[!NOTE]
>This didn't quite work out as I'd planned, so it's archived. Read more [in the blogpost](https://www.rostrum.blog/posts/2023-09-16-chunktop/).

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

#' Extract Chunk Options
#'
#' Parse an R Markdown file and read selected chunk options of interest to a
#' list, where each list element is named after the chunk.
#'
#' @param rmd_file Character. Path to an R Markdown (.Rmd) file to be read.
#' @param opts Character. A vector of named options to read from R Markdown
#'     chunks.
#'
#' @return A list. One element per chunk, with sub-lists named for each chunk
#'     option named in 'opts', if present.
#'
#' @details Each chunk in the target R Markdown file must have a unique chunk
#'     name.
#'
#' @examples
#' # Read example R Markdown file
#' path <- system.file("extdata/demo1.Rmd", package = "chunktop")
#'
#' # Extract 'fig.cap' chunk from each chunk into a list
#' get_chunktop(path, "fig.cap")
#'
#' @export
get_chunktop <- function(rmd_file, opts) {

  if (tools::file_ext(rmd_file) != "Rmd") {
    stop("'rmd_file' must be an R Markdown file (.Rmd).", call. = FALSE)
  }

  if (!dir.exists(dirname(rmd_file))) {
    stop("The directory in 'rmd_file' does not exist.", call. = FALSE)
  }

  if (!inherits(opts, "character")) {
    stop("The chunk options in 'opts' must be class character.", call. = FALSE)
  }

  # Isolate chunks with options of interest
  rmd <- parsermd::parse_rmd(rmd_file)
  chunks_with_opts <- parsermd::rmd_select(rmd, parsermd::has_option(opts))

  if (length(chunks_with_opts) == 0) {
    stop("There are no chunks with options provided by 'opts'.", call. = FALSE)
  }

  # Extract names for chunks contianing options of interest
  chunk_names <- parsermd::rmd_node_label(chunks_with_opts)

  if (max(table(chunk_names)) > 1) {
    stop("Chunk names should be unique", call. = FALSE)
  }

  if (any(is.na(chunk_names))) {
    stop("All chunks must have a unique names.", call. = FALSE)
  }

  # Extract all options from selected chunks, apply chunk names to list
  chunk_opts <- parsermd::rmd_node_options(chunks_with_opts)
  names(chunk_opts) <- chunk_names

  # Simplify to the options that match the options of interest
  for (i in seq_along(chunk_opts)) {
    names_in_opts <- names(chunk_opts[[i]]) %in% opts
    opts_to_keep <- chunk_opts[[i]][names_in_opts]
    chunk_opts[[i]] <- opts_to_keep
  }

  chunk_opts

}

#' Convert a List of R Markdown Chunk Options to a Data Frame
#'
#' Having extracted specific chunk options from an R Markdown file with
#' [get_chunktop], convert the list output to a data.frame.
#'
#' @param chunktop_list Nested list. One element per chunk. One sub-element per
#'     option.
#'
#' @return A data.frame with three columns: 'chunk_name' (character) of the name
#' of the chunk containing the option of interest, 'opt_name' (character) for
#' the name of the option of interest and 'opt_value' (character, numeric or
#' logical) for the value stored by the option represented by that row.
#'
#' @examples
#' # Read example R Markdown file
#' path <- system.file("extdata/demo1.Rmd", package = "chunktop")
#'
#' # Extract 'fig.cap' chunk from each chunk into a list, convert to data.frame
#' get_chunktop(path, "fig.cap") |> chunktop_to_df()
#'
#' @export
chunktop_to_df <- function(chunktop_list) {

  opts_df <- stack(chunktop_list)

  opts_list <- vector("list", length(chunktop_list))

  for (i in seq_along(chunktop_list)) {
    opts_list[[i]] <- names(chunktop_list[[i]])
  }

  opts_df$opts <- unlist(opts_list)

  opts_df <- opts_df[, c("ind", "opts", "values")]
  names(opts_df) <- c("chunk_name", "option_name", "option_value")

  opts_df

}

#' Convert a Data Frame of R markdown Chunk Options to a List
#'
#' @param chunktop_df Data.frame. Contains chunk information for R Markdown
#'     chunks to be replaced. Columns are 'chunk_name' (character) of the name
#'     of the chunk containing the option of interest, 'opt_name' (character)
#'     for the name of the option of interest and 'opt_value' (character,
#'     numeric or logical) for the value stored by the option represented by
#'     that row.
#'
#' @return A list. One element per chunk, with sub-lists named for each chunk
#'     option.
#'
#' @examples
#' # Read example R Markdown file
#' path <- system.file("extdata/demo1.Rmd", package = "chunktop")
#'
#' # Create temporary CSV file to hold output
#' csv_file <- tempfile(fileext = ".csv")
#'
#' # Extract 'fig.cap' chunk option into a list, convert to data.frame, write to CSV
#' get_chunktop(path, "fig.cap") |>
#'  chunktop_to_df() |>
#'  write.csv(csv.file, row.names = FALSE)
#'
#' # Read CSV back in and re-convert into list
#' read.csv(csv_file) |> df_to_chunktop(chunktop_df)
#'
#' @export
df_to_chunktop <- function(chunktop_df) {

  chunk_names <- unique(chunktop_df$chunk_name)
  chunk_list <- vector("list", length(chunk_names))
  names(chunk_list) <- chunk_names

  for (i in seq_along(chunktop_df$chunk_name)) {

    chunk <- chunktop_df$chunk_name[i]
    opt <- chunktop_df$option_name[i]
    val <- chunktop_df$option_value[i]

    opt_val <- setNames(list(val), opt)

    chunk_list[[chunk]] <- append(chunk_list[[chunk]], opt_val)

  }

  chunk_list

}

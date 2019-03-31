#' Source a R code using Nectar computing cluster
#' @param file The R file to run.
#' @param remote_dir The remote directory to copy the file to.
#' @param remote_name The remote hostname.
#' @param execute T or F; whether to launch a terminal and run the code.
source_nectar <- function(file, remote_dir, remote_name, execute = T) {
  dname <- dirname(file)
  cmd <- glue::glue(
    "scp {file} {remote_name}:~/{remote_dir} && \
    ssh {remote_name} 'cd {remote_dir} && Rscript {file}' && \
    scp {remote_name}:~/{remote_dir}.RData {dname}/.RData"
  )
  if (execute) {
    term_id <- rstudioapi::terminalExecute(cmd, workingDir = getwd())
    cat("Code launched at terminal '", term_id, "'.\n", sep = "")
    return(term_id)
  }
  invisible(NULL)
}


#' Load an image file
#' @param term_id The terminal id.
#' @param file The image file.
#' @param verbose Should item names be printed during loading?
#' @param clean_file Should the image file be removed after it is loaded?
#' @param clean_terminal Should the exited terminal be removed?
load_now <- function(term_id, file = ".RData", verbose = T, 
                     clean_file = F, clean_terminal = T) {
  if (is.null(rstudioapi::terminalExitCode(term_id))) {
    cat("Result is not ready.\n")
    return(invisible(NULL))
  } 
  if (!file.exists(file)) {
    cat("Process ended but file does not exist.\n")
    return(invisible(NULL))
  } 
  
  load(file, verbose = verbose, envir = globalenv())
  if (clean_file) invisible(file.remove(file = file))
  if (clean_terminal) rstudioapi::terminalKill(term_id)
}


# # Usage
# id <- source_nectar("test.R", "Documents/test_folder/", "myNectar")
# load_now(id, clean_file = T)

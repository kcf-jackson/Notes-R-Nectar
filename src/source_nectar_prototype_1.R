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
    return(term_id)
  }
  invisible(cmd)
}


#' Load an image file
#' @param file The image file.
#' @param verbose Should item names be printed during loading?
#' @param clean_up Should the image file be removed after it is loaded.
#' @note By default, `clean_up` is set to be FALSE to avoid accidentally 
#' removing file from the system. But generally, as the function uses
#' the file existence to tell whether the code at the terminal has finished
#' running, one should set `clean_up = T` in practice.
load_now <- function(file = ".RData", verbose = T, clean_up = F) {
  if (!file.exists(file)) {
    cat("Result is not ready.\n")
    return(invisible(NULL))
  }
  load(file, verbose = verbose, envir = globalenv())
  if (clean_up) {
    invisible(file.remove(file = file))
  }
}


#' Kill exited terminal
#' @description This function is needed to clean the terminal space as each
#' `source_nectar` call starts a new terminal. 
clean_exited_terminal <- function() {
  exit_codes <- Map(
    rstudioapi::terminalExitCode, 
    rstudioapi::terminalList()
  )
  is_exited <- purrr::map_lgl(exit_codes, ~!is.null(.x))
  exited_ids <- names(exit_codes)[is_exited]
  purrr::map(exited_ids, rstudioapi::terminalKill)
  cat("OK\n")
}


# # Usage
# source_nectar("test.R", "Documents/test_folder/", "myNectar")
# load_now(clean_up = T)
# clean_exited_terminal()

#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes
#' @importFrom rvest html_text
#' @importFrom utils download.file
#' @title Downloads and installs the latest version of R for Mac OS X.
#' @description Update your version of R from inside R itself (Mac OS X only).
#' @param admin_password \code{character}. The system-wide password of the user. The parameter will be only employed to execute commands gaining administrator privileges on the computer and will not be stored anywhere.
#' @author Andrea Cirillo, Robert Myles McDonnell
#' @examples
#' updateR(admin_password = "****")
#' @export
updateR <- function(admin_password = NULL){

  # first test for on OS
  stopifnot(.Platform$OS.type == "unix")
  # test for password
  if(is.null(admin_password)){
    stop("User system password is missing")
  }

  page_source = "https://cran.rstudio.com/bin/macosx/"

  file <- xml2::read_html(page_source) %>%
    rvest::html_nodes("h1+ p a+ a , table:nth-child(8) tr:nth-child(1) td > a") %>%
    rvest::html_text() %>% strsplit("\n", fixed = TRUE) %>%
    .[[2]]

  stopifnot(grepl(".pkg", file) == TRUE)
  url <- paste0(page_source, file)

  # download package, set folder for download
  download.file(url, file)

  #install .pkg file
  pkg <- gsub("\\.pkg" , "", file)
  message(paste0("Installing ", pkg, "...please wait"))
  command <- paste0("echo ", admin_password, " | sudo -S installer -pkg ",
                "'", file, "'", " -target /")
  system(command, ignore.stdout = TRUE, ignore.stderr = TRUE)

  arg <- paste0("--check-signature ", file)
  system2("pkgutil", arg)

  x <- system2("R", args = "--version", stdout = TRUE)
  x <- x[1]

  message(paste0("Everything went smoothly, R was updated to ", x))

}


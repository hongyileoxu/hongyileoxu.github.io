# Check the accessibility of URLs in Canvas 
# June 24, 2024. 

library(httr)
check_url <- function(url) {
  response <- try(GET(url), silent = TRUE)

  if (inherits(response, "try-error")) {
    return(list(url = url, status = "Error", code = NA))
  }

  status_code <- status_code(response)

  if (status_code == 200) {
    status <- "Accessible"
  } else {
    status <- "Inaccessible"
  }

  return(list(url = url, status = status, code = status_code))
}

check_URLs <- function(urls) {
  # urls <- c("http://example.com", "http://nonexistentwebsite.com", "http://google.com")
  results <- lapply(urls, check_url)

  # Convert the results to a data frame for easier viewing
  results_df <- do.call(rbind, lapply(results, as.data.frame))
  # check whether it links within Canvas
  results_df$canvas <- grepl(pattern = "canvas_", x = results_df$url, fixed = T)
  results_df$accessible <- (results_df$canvas == TRUE | results_df$status == "Accessible" )
  
  return(results_df)
} 

html_URLs <- function(html) {
  # Given an html doc location, return the checking results for all URLs in there. 
  data <- read_html(html)
  
  # content name 
  name <- html_elements(data, xpath = "head") %>% html_text() 
  ## all elements with an external link 
  data_a <- html_elements(data, "a") 
  ## extract text and url 
  data_name_url <- sapply(X = data_a, FUN = function(x) {
    return <- data.frame(
      text = html_text2(x = x), 
      url = html_attr(x, name = "href")
    )
  }) %>% t() %>% as.data.frame()
  
  # check URLs 
  data_url_check <- check_URLs(urls = data_name_url$url)
  data_url_check$text <- data_name_url$text
  data_url_check$file <- name 
  
  return(data_url_check)
}

## use `check_URLs` to directly get the outputs 

## now, I import the dataset. 
setwd("~/Web_URL_Checking")

## get all HTML files in the subfolders. 
all_html_loc <- list.files(pattern = ".html$", recursive = TRUE) %>% 
  grep(pattern = "wiki", x = ., fixed = T, invert = T, value = T) 

library(tidyverse)
library(xml2)
library(rvest)
# library(XML)

html_URLs(html = doc) %>% View() 

## Final Output: 
Canvas_Check_URLs <- do.call(rbind, lapply(X = all_html_loc, FUN = html_URLs))

as_tibble(Canvas_Check_URLs) %>% filter(code %in% c(403, 404, 429)) %>% View("inaccessiable")

# ========================================================================================================
# ========================================================================================================
# ========================================================================================================
# 
# read_html(doc)
# course_toc <- read_xml(x = paste("~/Web_URL_Checking", "course_settings", "module_meta.xml", sep = "/")) 
# course_toc_childrens <- xml_children(x = course_toc) # get the chilrens 
# xml_structure(course_toc) 
# 
# # xml_attr(xml_children(course_toc)[[1]], )
# 
# lapply(X = 1:xml_length(course_toc), FUN = function (x) {
#   data <- course_toc_childrens[[x]] # get a specific children 
#   identifier <- xml_attrs(data)
#   name <- xml_text(data)
#   
#   return(identifier)
# })
# 
# course_toc_tbl <- as_tibble(as_list(course_toc)) %>% unnest_longer()
# 
# course_toc_tbl %>% 
#   filter(modules_id == "title") %>%
#   unnest_wider(modules)
# 
# xml_(course_toc)
# 
# xml_structure(course_toc[[1]])
# xml_find_all(course_toc, xpath = "record")
# 


# library(pingr)
# 
# ping("amazon.com")
# ping("https://www2.deloitte.com/content/campaigns/us/audit/survey/diversity-%20venture-capital-human-capital-survey-dashboard.html")
# ping("https://hbsp.harvard.edu/tu/495e42ee")
# 
# url.show("https://hbsp.harvard.edu/tu/495e42ee")
# 
# library(httr)
# check_url <- function(url) {
#   response <- try(GET(url), silent = TRUE)
#   
#   if (inherits(response, "try-error")) {
#     return(list(url = url, status = "Error", code = NA))
#   }
#   
#   status_code <- status_code(response)
#   
#   if (status_code == 200) {
#     status <- "Accessible"
#   } else {
#     status <- "Inaccessible"
#   }
#   
#   return(list(url = url, status = status, code = status_code))
# } 
# 
# check_url("https://hbsp.harvard.edu/tu/495e42ee")
# check_url("https://www2.deloitte.com/content/campaigns/us/audit/survey/diversity-%20venture-capital-human-capital-survey-dashboard.html")
# 
# 
# urls <- c("http://example.com", "http://nonexistentwebsite.com", "http://google.com")
# 
# results <- lapply(urls, check_url)
# 
# # Convert the results to a data frame for easier viewing
# results_df <- do.call(rbind, lapply(results, as.data.frame))
# 
# print(results_df)






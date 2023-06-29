# =================================================================

# 0. import libraries ---- 
library(rvest)
library(tidyverse)
library(htm2txt) # convert html to txt. 
library(reshape2)
library(gt)

# =================================================================

# a. filing.header(): extract the header info from the filing ----
filing.header <- function(x, # the file 
                          regex_header = 'ACCESSION NUMBER:|</SEC-HEADER>' # the regex of the start to end of the header section in the filing
) { # parse filing header info 
  header <- grep(pattern = regex_header, x = filing, perl = T)
  header_cleaned <- str_squish(x[header[1]:(header[2]-1)]) 
  header_info <- str_split_fixed(header_cleaned[header_cleaned != ""], 
                                 pattern = ":\\s", 2)
  return(header_info)
}

# b. filing.toc(): extract the table of content(s) -----
filing.toc <- function(x, # filing 
                       regex_toc = '<text>|</text>' # locate ToC
){ # find the table of content(s)
  toc <- grep(pattern = regex_toc, x = x, ignore.case = T)[1:2] # the part containing the ToC
  filing_toc <- read_html(paste0(x[toc[1]:toc[2]], collapse = "")) # extract the toc
  return(filing_toc)
} 

# c. loc.item(): locate the item of interest ---- 
## particularly item 2 in 10-Q and item 5 in 10-K
loc.item <- function(x, # filing 
                     filing_type, # filing type from the previous input
                     regex_item = c("Unregistered Sales of Equity Securities and Use of Proceeds", 
                                    "Market for Registrant’s Common Equity, Related Stockholder Matters and Issuer Purchases of Equity Securities") 
) { 
  # locate the section of the item of interest 
  ## > item 2 in 10-Q: "Unregistered Sales of Equity Securities and Use of Proceeds" ;
  ## > item 5 in 10-K: "Market for Registrant’s Common Equity, Related Stockholder Matters and Issuer Purchases of Equity Securities" ;
  toc <- filing.toc(x = filing)
  
  regex <- regex_item[filing_type == c("10-Q", "10-K")] # identify the regex 
  print(regex)
  
  toc_txt <- html_nodes(html_nodes(toc, "table"), "a") 
  
  item_id <- gsub(x = unique(html_attr(toc_txt[which(grepl(pattern = regex,
                                        x = html_text(toc_txt), 
                                        ignore.case = T)) + 0:6],"href"))[1:2],
                  pattern = '#', replacement = '')
  loc_item <- vapply(X = item_id,
                     FUN = function(p) {
                        loc_item0 <- grep(pattern = p, x = x, fixed = T)
                        return(ifelse(length(loc_item0) != 1, loc_item0[2], loc_item0[1]))
                      },
                     FUN.VALUE = numeric(1))

   return(list(loc_item = loc_item, item_id = item_id))
}

# d. filing.item_txt(): header/footnote / unit ----
## extract the txt header and/or footnote and unit from the item

# e. filing.item(): extract text (header and/or footnote), unit and cleaned table ----
filing.item <- function(x, # filing
                        loc_item, # the location of the item of interest
                        item_id, # the identifier from 'href' for the section 
                        filing_qrt, # the quarter the filing was made 
                        table = TRUE, # whether to scrap the table numbers 
                        parts = c("footnote") # the parts of information that you want 
) { 
  # extract info from the section/item 
  if (loc_item[1] == loc_item[2]) {
    item_parse <- str_split_fixed(string = x[loc_item[1]:loc_item[2]],
                                  pattern = item_id[1], n = Inf) %>% .[1, ncol(.)]
    item_txt <- str_extract(string = item_parse, 
                            pattern = paste0("^(.*?)", item_id[2], collapse = ""))
  } else {
    # the full item 
    item_txt <- x[loc_item[1]:loc_item[2]] 
  }
  # find the table(s) 
  item_html <- read_html(paste0(item_txt, collapse = ""))
  item_tbls <- html_nodes(item_html, "table")
  item_tbl_id <- grep(pattern = "Total", x = item_tbls, fixed = T)[1]  # identify the correct table
  
  ## extract the table 
  if (!is.na(item_tbl_id)) {
    ## 
    item_htm2txt <- html_text(item_html, trim = T) # pure text document 
    filing_item2_txt <- strsplit(x = item_htm2txt, split = (html_text(item_tbls[[item_tbl_id]], trim = F)), fixed = T)[[1]][match(parts, c("header", "footnote"))]
    
    ### extract the unit information 
    item_table_unit <- c(na.omit((str_extract(string = item_htm2txt,
                                              pattern = str_extract(html_text(item_html), pattern = "\\(([^()]+)\\)")))))
    
    ### <Tables starts here!>
    ### clean the table 
    item_table <- unique.matrix(as.matrix(html_table(item_tbls[[item_tbl_id]])))[-1,]
    tbl_periods_id <- grep(pattern = '(\\w+\\d{1,2},\\s+\\d{4}|Total|total)', item_table[,1]) # id_row for the periods
    tbl_periods <- rep(item_table[tbl_periods_id,1],
                       time = c(diff(tbl_periods_id), 1) 
    ) # return the periods 
    tbl_periods[tbl_periods == "Total"] <- filing_qrt # entering the filing quarter
    
    tbl_title <- c("item", item_table[1,][-1])
    tbl_numbers <- item_table[-(1:(tbl_periods_id[1]-1)),] %>% # remove the first line
      cbind(., "period" =`length<-`(tbl_periods, nrow(.))) %>%  # add 'period' column 
      .[-(tbl_periods_id[which(c(diff(tbl_periods_id), 1) != 1)] - (tbl_periods_id[1]-1)), # clean duplicated rows 
        c(TRUE, duplicated(tbl_title[-1], incomparables = c(NA, "")), TRUE)] # clean duplicated columns
    
    tbl_numbers <- matrix(str_replace(tbl_numbers,
                                      pattern = "\\$|(\\s*?)\\(\\d\\)",
                                      replacement = ""),
                          ncol = ncol(tbl_numbers), 
                          dimnames = list(NULL,
                                          c("item",
                                            tbl_title[duplicated(tbl_title[-1], incomparables = c(NA, ""))],
                                            "period")))
    ### return the cleaned table
    tbl_numbers_cleaned <- melt(as.tibble(tbl_numbers), id.vars = c("item", "period")) 
    
    return(list(table = as.matrix(tbl_numbers_cleaned), 
                parts = filing_item2_txt,
                table_unit = item_table_unit
    ) )
    
  } else { # if no table in the item 
    return(list(table = NULL,
                parts = NULL,  
                table_unit = NULL
    ))
  }
}

# Appendix. list of built-in functions----
lsf.str()

# =====================================================

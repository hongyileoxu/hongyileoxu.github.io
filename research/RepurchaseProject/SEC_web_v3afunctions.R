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
                          regex_header = 'ACCESSION NUMBER:|</SEC-(HEADER|Header)>' # the regex of the start to end of the header section in the filing
) { # parse filing header info 
  header <- grep(pattern = regex_header, x = x, perl = T)
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
loc.item  <- function(x, # filing 
                      filing_type, # filing type from the previous input
                      regex_item = c("Unregistered Sales of Equity Securities and Use of Proceeds", 
                                     "Market for Registrant") # item header
) { 
  # locate the section of the item of interest 
  ## > item 2 in 10-Q: "Unregistered Sales of Equity Securities and Use of Proceeds" ;
  ## > item 5 in 10-K: "Market for Registrant&rsquo;s Common Equity, Related Stockholder Matters and Issuer Purchases of Equity Securities" ;
  toc <- filing.toc(x = x)
  
  regex <- regex_item[filing_type == c("10-Q", "10-K")] # identify the regex 
  regex2 <- c("[>][itemITEM]{4}\\s*2\\.", "[>][itemITEM]{4}\\s*5\\.")[filing_type == c("10-Q", "10-K")] # identify the regex for item
  
  toc_txt <- html_nodes(html_nodes(toc, "table"), "a") 
  
  item_id <- gsub(x = unique(html_attr(toc_txt[which(grepl(pattern = regex,
                                                           x = html_text(toc_txt), 
                                                           ignore.case = T)) + 0:6],"href"))[1:2],
                  pattern = '#', replacement = '')
  
  if (!all(is.na(item_id))) { # locate the item if item_id(url) is found
    loc_item <- vapply(X = item_id,
                       FUN = function(p) {
                         loc_item0 <- grep(pattern = paste("[<].+=(\"|\')", p, "(\"|\')", sep = "")[1], x = x) # the regex is modified to match the exact pattern in html
                         return(ifelse(length(loc_item0) != 1, loc_item0[2], loc_item0[1]))
                       },
                       FUN.VALUE = numeric(1))
  } else { # if no url or link/identifier is found
    ## look for all the items   
    item_all <- grep(pattern = "[>]item\\s*\\d{1}[.]", x = x, ignore.case = T) # the location of each item
    loc_item1 <- item_all[tail(grep(pattern = regex2, x = htm2txt(x[item_all]), ignore.case = T), 1)]  # find the match
    ## check whether the 1st location is found
    if (length(loc_item1) > 0) { # if the first is identified
      loc_item2 <- grep(pattern = "[>]item\\s*\\d{1}[.]", x = x[(loc_item1+1):length(x)], ignore.case = T, value = F)[1] + loc_item1
      ifelse(is.na(loc_item2), loc_item <- rep(loc_item1, 2), loc_item <- c(loc_item1, loc_item2)) 
    } else { # if the first is not identified
      loc_item <- rep(NA, 2)
    }
  }
  ## return the location, id, and item number (i.e. item 2 or 5)
  return(list(loc_item = loc_item, item_id = item_id, item = regex2))
}

# d. tbl.rowkeep(): sub-function for `filing.item` for table row cleaning  ----
tbl.rowkeep <- function(regex_row = '(\\w+(\\s+?)\\d{1,2},\\s+\\d{4}|Total|total|to|[-]|\\d+\\/\\d+\\/\\d+)', # the regex for the kept row(s)
                        row_name, # the name of each row
                        filing_qrt # the filing quarter 
) {
  # identify the rows that match the regex_row
  tbl_periods_id <- grep(pattern = regex_row, row_name) # id_row for the periods
  if (length(tbl_periods_id) > 0) { # check if the table is valid
    tbl_periods_times <- c(diff(tbl_periods_id), 1) # time of repeat for each row 
    # identify the kept rows
    tbl_rowkeep <- setdiff(x = head(tbl_periods_id, 1):tail(tbl_periods_id, 1), 
                           y = subset(tbl_periods_id, tbl_periods_times != 1))
    # create the `period` column 
    tbl_periods <- rep(row_name[tbl_periods_id], time = tbl_periods_times )
    tbl_periods[tbl_periods == "Total"] <- filing_qrt # entering the filing quarter
    # return values
    return(list(rowkeep = tbl_rowkeep, 
                period = tbl_periods))
  } else { # table is not actual there !!!
    return(NA) # indicating no table in there!
  }
}

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# e. filing.item(): extract text (header and/or footnote), unit and cleaned table ----
## ================================================================================================================
## ================================================================================================================
filing.item <- function(x, # filing
                        loc_item, # the location of the item of interest
                        item_id, # the identifier from 'href' for the section 
                        item, # the number of the item 
                        filing_qrt, # the quarter the filing was made 
                        table = TRUE, # whether to scrap the table numbers 
                        parts = c("footnote") # the parts of information that you want 
) { 
  # extract info from the section/item 
  if (loc_item[1] == loc_item[2]) {
    print("same loc_item")
    if (any(is.na(item_id)) == TRUE) {
      # print("no item_id")
      item_parse <- sub(pattern = paste(".*", item, sep = "")[1], "", x[loc_item[1]])
      item_txt <- sub(pattern = "[>][itemITEM]{4}\\s*\\d{1}\\..*", "", item_parse)
    } else {
      print("Yes! item_id")
      item_parse <- sub(pattern = paste(".*(\"|\')", item_id[1], "(\"|\')", sep = "")[1], "", x[loc_item[1]])
      item_txt <- sub(pattern = paste("(\"|\')", item_id[2], "(\"|\')", ".*", sep=""), "", item_parse)
    }
  } else {
    # the full item 
    item_txt <- x[loc_item[1]:loc_item[2]] 
  }
  
  # find the table(s) 
  item_html <- read_html(paste(item_txt, collapse = ""))
  # html_text(item_html)
  
  if ((grepl(pattern = "<table>|</table>", item_html, ignore.case = T)) == FALSE) { # if no table found in the item # all(is.na(item_tbls))
    print("No Table!")
    return(list(table = matrix(NA, nrow = 1, ncol = 4),
                parts = html_text(item_html, trim = T),  
                table_unit = NA))
  } else { # if there are tables!
    item_tbls <- html_nodes(item_html, "table")
    item_tbl_id <- grep(pattern = "Total.*Number|purchase|repurchase", x = item_tbls, ignore.case = T)[1] # identify the correct table
    
    ## extract the table 
    if (ifelse(is.na(item_tbl_id), 
               FALSE, # if no table is identified
               grepl(pattern = "total.*number.*of|Average.*Price.*Paid", x = html_text(item_tbls[[item_tbl_id]]), ignore.case = T) # check again the table is correct
               )
      ) {
      ## extract the item text 
      item_htm2txt <- html_text(item_html, trim = T) # pure text document 
      filing_item2_txt <- sub(pattern = gsub(pattern = "([()\\$\\[\\]])", replacement = "\\\\\\1", 
                                             html_text(item_tbls[[item_tbl_id]], trim = T), perl = T),
                              replacement = "<footnote>",
                              x = item_htm2txt)
      
      ### extract the unit information 
      item_table_unit <- str_extract(string = item_htm2txt, pattern = "\\(in[^()]+\\)")
      
      ### <Tables starts here!>
      ### clean the table 
      item_table <- unique.matrix(as.matrix(html_table(item_tbls[[item_tbl_id]])), MARGIN = 1) %>% # 1. store in a matrix
        .[, colSums(. == "$") == 0 & !is.na(colSums(. == "$"))] %>% # colSums(is.na(.))==0
        unique.matrix(MARGIN = 2)
            
      ### identify the rows to keep
      tbl_rowkeep_info <- tbl.rowkeep(row_name = item_table[,1], filing_qrt = filing_qrt)

      if (NA %in% tbl_rowkeep_info) { # IF THE TABLE IS NOT VALID
        # no actual table can be identified 
        return(list(table = matrix(NA, nrow = 1, ncol = 4),
                    parts = html_text(item_html, trim = T),  
                    table_unit = NA ))
      } else { # Continue for a valid table      
        tbl_periods <- tbl_rowkeep_info$period # return the period for each column 
        tbl_rowkeep <- tbl_rowkeep_info$rowkeep # identify the rows to be kept in `item_table`
        
        ### clean rows in the table 
        tbl_numbers <- item_table[-(1:(tbl_rowkeep[1]-1)), , drop = F] %>% # remove the first(several) line(s) and keep only the numbers
          cbind(., `length<-`(tbl_periods, nrow(.))) %>%  # add 'period' column 
          .[tbl_rowkeep+1-tbl_rowkeep[1], , drop = F] # clean duplicated rows 
        
        ####  clean the main titles and store to tbl_title0 -> merge into tbl_title
        ifelse((tbl_rowkeep[1]-1) == 1,
               tbl_title0 <- item_table[1,-1],
               tbl_title0 <- apply(X = item_table[(1:(tbl_rowkeep[1]-1)),-1, drop=F],
                                   MARGIN = 2, 
                                   FUN = function(name) paste0(name, collapse = "")))
        tbl_title <- c("item", tbl_title0, "period")
        
        ### store duplicated and non-duplicated column headers
        tbl_title_duplicated <- which(x = duplicated(tbl_title)) # duplicated
        tbl_title_nonduplicated <- setdiff(1:length(tbl_title), c(tbl_title_duplicated-1, tbl_title_duplicated))
        #### check whether have duplicated columns 
        if (length(tbl_title_duplicated) > 0) { # if there are duplicated columns 
          tbl_numbers <- cbind(tbl_title_duplicated - 1, tbl_title_duplicated) %>% # identify all duplicated ones 
            split(., seq(nrow(.))) %>% # create a list recording the repeated headers in pairs <each element in the list contains a pair>
            sapply(FUN = function(id) str_replace(paste(tbl_numbers[, id[1]],
                                                        tbl_numbers[, id[2]],
                                                        sep = ""), 
                                                  pattern = "\\$|(\\s*?)\\(\\d\\)",
                                                  replacement = "")) %>%
            cbind(tbl_numbers[, tbl_title_nonduplicated]) # cbind with non-duplicated headers. 
        } ## otherwise just use the old tbl_numbers 
        
        colnames(tbl_numbers) <- tbl_title[c(tbl_title_duplicated, tbl_title_nonduplicated)]
        
        ### return the cleaned table
        tbl_numbers_cleaned <- melt(as.data.frame(tbl_numbers), id.vars = c("item", "period")) 
        # tbl_numbers_cleaned %>% View
        return(list(table = as.matrix(tbl_numbers_cleaned), 
                    parts = filing_item2_txt,
                    table_unit = item_table_unit
        ) )
      }
    } else { # if no table in the item 
      return(list(table = matrix(NA, nrow = 1, ncol = 4),
                  parts = html_text(item_html, trim = T),  
                  table_unit = NA ))
    }
  }
}
## ================================================================================================================
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# f. filing.cleaned(): the aggregate function function ----
## this function returns the cleaned header info, table, table_unit and parts (header and footnote in the item)
filing.cleaned <- function(loc_file, # name of the filing
                           zip_file # name of the zipped file 
) { 
  ## import the txt filing 
  filing <- readLines(unz(zip_file, loc_file))
            
  ## store header info 
  info <- t(filing.header(x = filing)[,2])
  ## store item location
  loc_item2 <- loc.item(x = filing, filing_type = substr(info[2], start = 1, stop = 4) )
  if (all(is.na(loc_item2$loc_item))) { 
    ## check whether the item is in the document
    item2_cleaned <- list(table = matrix(NA, nrow = 1, ncol = 4),
                          parts = NA,  
                          table_unit = NA)
  } else {
    ## generate cleaned info 
    item2_cleaned <- filing.item(x = filing,
                                 loc_item = loc_item2$loc_item,
                                 item_id = loc_item2$item_id,
                                 item = loc_item2$item_id,
                                 filing_qrt = str_extract(loc_file, pattern = '(QTR\\d{1})'),
                                 parts = "footnote")
  }
  ## return output 
  return(c(list(info = info), # store header info
              item2_cleaned)) # combine info with cleaned table 
} 

# Appendix. list of built-in functions----
lsf.str()

# =====================================================

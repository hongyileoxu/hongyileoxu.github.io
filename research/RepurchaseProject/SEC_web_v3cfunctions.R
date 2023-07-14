# =================================================================
# 0. import libraries ---- 
library(rvest)
library(xml2) # for modify nodes in htmlß
library(tidyr)
library(reshape2)
library(stringr) # for str_squish 
library(archive) # to connect files in large zip files (>= 4GB)
# library(htm2txt) # convert html to txt. # not very useful
# library(gt) # just for beautiful tables
# =================================================================

# parameters: 
text_break_node = read_xml("<table><tr><td> &lt;footnote&gt; </td></tr></table>\n")
text_break_table = read_xml("<table><tr><td> &lt;table&gt; </td></tr></table>\n")

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
                      regex_item = c("(Unregistered|UNREGISTERED|UNRE\\w+)\\s+(Sale|sale|SALE)(s|S|)\\s*(of|Of|OF)", 
                                     "(Market|MARKET)\\s+(for|For|FOR)\\s*(The|THE|the)?\\s*(Registrant|REGISTRANT|registrant|Re|re|RE)") # item header
) { 
  # locate the section of the item of interest 
  ## > item 2 in 10-Q: "Unregistered Sales of Equity Securities and Use of Proceeds" ;
  ## > item 5 in 10-K: "Market for Registrant&rsquo;s Common Equity, Related Stockholder Matters and Issuer Purchases of Equity Securities" ;

  regex1 <- regex_item[filing_type == c("10-Q", "10-K")] # identify the regex 
  regex2 <- c("[>](Item|ITEM)[^0-9]+2\\.", "[>](Item|ITEM)[^0-9]+5\\.")[filing_type == c("10-Q", "10-K")] # identify the regex for item
  
  ## <Find item_id in the ToC>
  toc_tbl <- html_nodes(filing.toc(x = x), "table") %>% # tables including the toc 
    .[grep("href", x = ., ignore.case = T)] 
  if (any(grepl(pattern = ">Part.+I", x = toc_tbl, ignore.case = T))) {
    toc_tbl_id <- which(grepl(pattern = ">Part.+[I]{2}", x = toc_tbl, ignore.case = T) )[1] # locate the table for TOC: will return NA if there are no tables in toc_tbl
  } else {
    toc_tbl_id <- which(grepl(pattern = "SIGNATURE|EXHIBIT", x = toc_tbl, ignore.case = T))[1] # locate the table for TOC: will return NA if there are no tables in toc_tbl
  }
  
  if (isTRUE(grepl(pattern = "href", x = toc_tbl[[toc_tbl_id]], ignore.case = T))) { 
    # if such table exists & contains url 
    ## find the row of item in the TOC
    toc_row <- html_nodes(toc_tbl[[toc_tbl_id]], "tr") %>% # separate each row
      .[grep("^(Item)?\\s*\\d{1}", x = html_text(., trim = T), ignore.case = T)]
    toc_row_id <- grep(pattern = regex1, x = html_text(toc_row), ignore.case = T)[1] # separate and identify the row
    
    ## find the id for the item 
    if (!is.na(toc_row_id)) { # if this item exists in the toc 
      item_id1 <- grep("#.+", html_attr(html_nodes(toc_row[toc_row_id], "a"), "href"), value = T)[1]
      if (!grepl('#', item_id1)) {
        item_id <- rep(NA, 2)
      } else {
        item_id2 <- grep("#.+", html_attr(html_nodes(toc_row[toc_row_id+1], "a"), "href"), value = T)[1]
        if (!grepl('#', item_id2)) { # check whether it is a valid href -> if no then replace with the next valid one 
          item_id2 <- grep('#.+', html_attr(html_nodes(toc_row[-(1:toc_row_id)], "a"), "href"), value = T, fixed = T)[1]
        }
        
        if (item_id1 == item_id2) { # for some wired errors for instance: <https://www.sec.gov/Archives/edgar/data/858655/000155837017000308/hayn-20161231x10q.htm#Toc>
          item_id1 <- grep("#.+", html_attr(html_nodes(toc_row[toc_row_id], "a"), "href"), value = T)[2]
        }
        
        item_id <-  sub(pattern = '#', replacement = '', x = c(item_id1, item_id2))
      }
    } else {
      item_id <- rep(NA, 2)
    }
    
  } else {
    item_id <- rep(NA, 2)
  }

  ## <What if no url is found.>  
  if (!any(is.na(item_id))) { # locate the item if item_id(url) is found

    if (any(nchar(item_id) >= 3)) {
      ## if the id is in the acceptable length
      loc_item <- vapply(X = item_id,
                         FUN = function(p) {
                           loc_item0 <- grep(pattern = paste("[<].+=(\"|\')", p, "(\"|\')", sep = "")[1], x = x)
                           return(ifelse(length(loc_item0) != 1, loc_item0[2], loc_item0[1]))
                         },
                         FUN.VALUE = numeric(1))
    } else {
      ## if only the num of characters is too few in the id 
      x_text_id <- grep(pattern = '<text>|</text>', x = x, ignore.case = T)[1:2] # identify the main body 
      ## extract all attributes in each part of the text  
      x_text_attr <- lapply(x_text_id[1]:x_text_id[2], FUN = function(id) {
        res_attr <- try(html_attrs(html_nodes(read_html(x[id]), "a")), silent = T)
        ifelse(inherits(res_attr, "try-error"), output <- NA,
               ifelse(is.null(unlist(res_attr)[1]), output <- NA, output <- unlist(res_attr)) )
        return(output)
      } )
      ## find the paragraph containing matched id(s) 
      loc_item <- sapply(item_id, FUN = function(id) which(sapply(x_text_attr, FUN = function(x) any(grepl(pattern = paste("^", id, "$", sep = "")[1], x))))) + x_text_id[1] - 1
    }

    ## if they are wrongly directed to the same element in `filing / x`. > searching with brutal force: 
    if (diff(loc_item) <= 0 & nchar(x[loc_item[1]]) < 5000) {
      ## this part is exactly the same as the following part > brutal force
      ## look for all the items 
      loc_item1 <- tail(grep(pattern = regex1, # paste("(", regex1, "|", regex2, ")", sep = "")[1],
                             x = x, ignore.case = F), 1)  # find the match
      # loc_item1_check <- tail(grep(pattern = ">Part.+\\bII\\b", x = x, ignore.case = T), 1) # record the Part II section in the filing
      ## check whether the 1st location is found
      if (length(loc_item1) > 0 ) { # if the first is identified # & length(loc_item1_check) > 0
        # if (loc_item1 >= loc_item1_check) { # if the place is correct 
        loc_item2 <- grep(pattern = "(>)?(Item|ITEM)[^0-9]+\\d{1}[.]",
                          x = x[(loc_item1+1):grep(pattern = '<text>|</text>', x = x, ignore.case = T)[2]],
                          ignore.case = T)[1] + loc_item1 # absorb the case without '>'. 
        
        if (is.na(loc_item2)) { # if it returns NA
          loc_item2 <- grep(pattern = "(>)?(Item|ITEM)",
                            x = x[(loc_item1+1):grep(pattern = '<text>|</text>', x = x, ignore.case = T)[2]],
                            ignore.case = T)[1] + loc_item1 # absorb the case without '>'. 
        } ## have a second try if `loc_item2` is NA. 
        ifelse(is.na(loc_item2), loc_item <- rep(loc_item1, 2), loc_item <- c(loc_item1, loc_item2))
        
        # } else {
        #   loc_item <- rep(NA, 2)
        # }
      } else { # if the first is not identified
        loc_item <- rep(NA, 2)
      }
    }
                                                                  
    
  } else { # if no url or link/identifier is found
    ## look for all the items 
    loc_item1 <- tail(grep(pattern = regex1, # paste("(", regex1, "|", regex2, ")", sep = "")[1],
                           x = x, ignore.case = F), 1)  # find the match
    # loc_item1_check <- tail(grep(pattern = ">Part.+\\bII\\b", x = x, ignore.case = T), 1) # record the Part II section in the filing
    ## check whether the 1st location is found
    if (length(loc_item1) > 0 ) { # if the first is identified # & length(loc_item1_check) > 0
        # if (loc_item1 >= loc_item1_check) { # if the place is correct 
        loc_item2 <- grep(pattern = "(>)?(Item|ITEM)[^0-9]+\\d{1}[.]",
                          x = x[(loc_item1+1):grep(pattern = '<text>|</text>', x = x, ignore.case = T)[2]],
                          ignore.case = T)[1] + loc_item1 # absorb the case without '>'. 
        
        if (is.na(loc_item2)) { # if it returns NA
          loc_item2 <- grep(pattern = "(>)?(Item|ITEM)",
                            x = x[(loc_item1+1):grep(pattern = '<text>|</text>', x = x, ignore.case = T)[2]],
                            ignore.case = T)[1] + loc_item1 # absorb the case without '>'. 
        } ## have a second try if `loc_item2` is NA. 
        ifelse(is.na(loc_item2), loc_item <- rep(loc_item1, 2), loc_item <- c(loc_item1, loc_item2))
        
        # } else {
        #   loc_item <- rep(NA, 2)
        # }
      } else { # if the first is not identified
        loc_item <- rep(NA, 2)
      }
  }
  
  ## return the location, id, and item number (i.e. item 2 or 5)
  return(list(loc_item = loc_item, item_id = item_id, item = c(regex1, regex2)))
}

# d. tbl.rowkeep(): sub-function for `filing.item` for table row cleaning  ----
tbl.rowkeep <- function(regex_row = '(\\w+(\\s+?)\\d{1,2},\\s+\\d{4}|Total|to|[-]|\\d+\\/\\d+\\/\\d+)|(Jan(uary)?|Feb(ruary)?|Mar(ch)?|Apr(il)?|May|Jun(e)?|Jul(y)?|Aug(ust)?|Sep(tember)?|Oct(ober)?|Nov(ember)?|Dec(ember)?)', # the regex for the kept row(s)
                        row_name, # the name of each row
                        filing_qrt # the filing quarter 
) {
  # identify the rows that match the regex_row
  tbl_periods_id <- grep(pattern = regex_row, row_name, ignore.case = T) # id_row for the periods
  tbl_periods_last <- max(which(row_name != ""))
  if (length(tbl_periods_id) > 0) {
    
    if (tbl_periods_last %in% tbl_periods_id) {
      # the last row is included in tbl_periods_id
      tbl_periods_times <- c(diff(tbl_periods_id), 1) # time of repeat for each row 
      # identify the kept rows
      tbl_rowkeep <- setdiff(x = head(tbl_periods_id, 1):tail(tbl_periods_id, 1), 
                             y = subset(tbl_periods_id, tbl_periods_times != 1))
      # create the `period` column 
      tbl_periods <- rep(row_name[tbl_periods_id], time = tbl_periods_times)
      if (grepl(pattern = '[Total]{5}', x = tail(tbl_periods, 1), ignore.case = T)) {
        tbl_periods[length(tbl_periods)] <- filing_qrt # entering the filing quarter
      }

    } else {
      # the last row is not included in tbl_periods_id (e.g. no row 'total')
      tbl_periods_times <- diff(c(tbl_periods_id, tbl_periods_last+1)) # time of repeat for each row 
      # identify the kept rows
      tbl_rowkeep <- setdiff(x = tbl_periods_id[1]:tbl_periods_last, 
                             y = subset(tbl_periods_id, tbl_periods_times != 1))
      # create the `period` column 
      tbl_periods <- rep(row_name[tbl_periods_id], time = tbl_periods_times)
    }
    
    # return values
    return(list(rowkeep = tbl_rowkeep, 
                period = tbl_periods))
  } else {
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
                        item, # the regex for the item (item number./ item name)
                        filing_qrt, # the quarter the filing was made 
                        text_break_node, # the xml to replace the identified table
                        table = TRUE, # whether to scrap the table numbers 
                        parts = c("footnote") # the parts of information that you want 
) { 
  # extract info from the section/item 
  if (loc_item[1] == loc_item[2]) {
    # print("same loc_item")
    if (any(is.na(item_id)) == TRUE) {
      # print("no item_id")
      item_parse <- sub(pattern = paste(".*", item[1], sep = "")[1], "", x[loc_item[1]], ignore.case = F)
      item_txt <- sub(pattern = "(>|)(Item|ITEM).*", "", item_parse) 
    } else {
      
      if (any(nchar(item_id) >= 3)) { # the id is long enough
        # print("Yes! item_id")
        item_parse <- sub(pattern = paste(".*(\"|\'|[^#])", item_id[1], "(\"|\'|)", sep = "")[1], "", x[loc_item[1]])
        
        ## check if the item_parse contains the correct item info 
        if (grepl(paste(item[1], "|(Item|ITEM).+[36]{1}\\.", sep = ""), html_text(read_html(substr(item_parse, 1, 1500))), ignore.case = F)) { ## July 14, 2023 ----
          item_txt <- sub(pattern = paste("(\"|\'|[^#])", item_id[2], "(\"|\'|)", ".*", sep=""), "", item_parse)
        } else { # if not, then use brutal force to search for ">Item 2." or ">Item 5."
          item_parse <- sub(pattern = paste(".*", item[2], sep = "")[1], "", x[loc_item[1]], ignore.case = F)
          item_txt <- sub(pattern = "(>|)(Item|ITEM).*", "", item_parse) 
        }
        
      } else { # if the id is NOT long enough 
        # print("Yes! item_id")
        item_parse <- sub(pattern = paste(".*", item[2], sep = "")[1], "", x[loc_item[1]], ignore.case = F)
        item_txt <- sub(pattern = "(>|)(Item|ITEM).*", "", item_parse)
        
      }
      
    }
  } else {
    # the full item 
    item_txt <- x[loc_item[1]:loc_item[2]] 
  }
  
  # find the table(s) 
  res <- try(item_html <- read_html(paste("<text>", paste(str_squish(item_txt), collapse = ""), "</text>", collapse = "")), silent = T)
  if (inherits(res, "try-error")) {
    if (nchar(x[loc_item[1]]) > 300) {
      item_parse <- sub(pattern = paste(".*", item[2], sep = "")[1], "", paste(item_txt, collapse = " "), ignore.case = T) ## July 14, 2023 ----
      item_txt <- sub(pattern = "(>)?(Item|ITEM)[^0-9]+\\d{1}.*", "", item_parse)
      res <- try(item_html <- read_html(paste(item_txt, collapse = "")), silent = T)
    }
    res2 <- try(item_html <- read_html(paste('<p>', item_txt, '</p>', collapse = "")), silent = T)
  } 
  
  item_tbls <- html_nodes(item_html, "table")
  if (length(item_tbls) == 0) { # if no table found in the item 
    print("No Table!")
    return(list(table = matrix(NA, nrow = 1, ncol = 4),
                parts = html_text(item_html, trim = T),  
                table_unit = NA))
  } else { # if there are tables!
    item_tbl_id <- which(str_count(string = as.character(item_tbls), pattern = "/tr") > 1 & # number of rows > 1
                           str_count(string = as.character(item_tbls), pattern = "/td") > 6 & # number of columns > 6
                           grepl(pattern = "Total.*Number|purchase|repurchase", x = item_tbls, ignore.case = T))[1] # identify the correct table
    
    ## extract the table 
    if (ifelse(is.na(item_tbl_id), 
               FALSE, # if no table is identified
               grepl(pattern = "total.*number.*of|Average.*Price.*Paid",
                     x = html_text(item_tbls[[item_tbl_id]]),
                     ignore.case = T) # check again the table is correct
               )
      ) { 
      ### <Tables starts here!>
      ### clean the table 
      item_table <- unique.matrix(as.matrix(html_table(item_tbls[[item_tbl_id]])), MARGIN = 1) %>% # 1. store in a matrix 
        .[which(rowSums(is.na(.)) == min(rowSums(is.na(.)))), , drop=F] %>% # exclude the mostly empty line. 
        .[, colSums(. == "$") == 0 & !is.na(colSums(. == "$")), drop=F] %>% 
        unique.matrix(MARGIN = 2) 
            
      ### identify the rows to keep
      tbl_rowkeep_info <- tbl.rowkeep(row_name = item_table[,1], filing_qrt = filing_qrt)

      if (NA %in% tbl_rowkeep_info) { # IF THE TABLE IS NOT VALID
        ## no actual table can be identified 
        return(list(table = matrix(NA, nrow = 1, ncol = 4),
                    parts = html_text(item_html, trim = T),  
                    table_unit = NA ))
      } else { 
        ## Continue for a valid table      
        tbl_periods <- tbl_rowkeep_info$period # return the period for each column 
        tbl_rowkeep <- tbl_rowkeep_info$rowkeep # identify the rows to be kept in `item_table`

        ### clean rows in the table 
        if (tbl_rowkeep[1]-1 == 0) {
          tbl_numbers <- item_table %>% # remove the first(several) line(s) and keep only the numbers
            cbind(., `length<-`(tbl_periods, nrow(.))) %>%  # add 'period' column 
            .[tbl_rowkeep+1-tbl_rowkeep[1],, drop = F] # clean duplicated rows 
        } else {
          tbl_numbers <- item_table[-(1:(tbl_rowkeep[1]-1)),, drop = F] %>% # remove the first(several) line(s) and keep only the numbers
            cbind(., `length<-`(tbl_periods, nrow(.))) %>%  # add 'period' column 
            .[tbl_rowkeep+1-tbl_rowkeep[1],, drop = F] # clean duplicated rows 
        }
        
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
          tbl_numbers_nondup <- tbl_numbers[, tbl_title_nonduplicated,drop=F] # non-duplicated columns 
          tbl_numbers_dup <- cbind(tbl_title_duplicated - 1, tbl_title_duplicated) %>% # identify all duplicated ones 
            split(., seq(nrow(.))) %>% # create a list recording the repeated headers in pairs <each element in the list contains a pair>
            sapply(FUN = function(id) str_replace(paste(tbl_numbers[, id[1]],
                                                        tbl_numbers[, id[2]], # merge cells in the same row
                                                        sep = ""), 
                                                  pattern = "\\$|(\\s*?)\\(\\d\\)",
                                                  replacement = ""))
           if (is.matrix(tbl_numbers_dup)) {
              tbl_numbers <- cbind(tbl_numbers_dup, tbl_numbers_nondup)
            } else {
              tbl_numbers <- cbind(matrix(tbl_numbers_dup, nrow = 1), tbl_numbers_nondup)
            }  # cbind with non-duplicated headers. 
        } ## otherwise just use the old tbl_numbers 
                   
        #### append back the column headers
        colnames(tbl_numbers) <- tbl_title[c(tbl_title_duplicated, tbl_title_nonduplicated)] 
        
        ### return the cleaned table - from wide to long
        tbl_numbers_cleaned <- melt(as.data.frame(tbl_numbers), id.vars = c("item", "period")) 

        ## <table unit information>
        ## extract the unit information 
        item_table_unit <- str_extract(string = html_text(item_html, trim = T), pattern = "\\(in\\s*[^()0-9]+\\)")
        
        ## <text info excl. table>
        ## extract item text and exclude the table. 
        xml_replace(.x = item_tbls[[item_tbl_id]], .value = text_break_node) # replace the identified table
        filing_item2_txt <- html_text(item_html, trim = T) # store the txt excl. table
                   
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
                           zip_file, # name of the zipped file 
                           text_break_node # xml text to replace the identified table 
) { 
  ## import the txt filing 
  if (!is.null(zip_file)) {
    filing <- readLines(archive_read(zip_file, loc_file))
  } else {
    filing <- readLines(loc_file)
  }
        
  ## store header info 
  info <- filing.header(x = filing) 
  selected_headers <- c('ACCESSION NUMBER','CONFORMED SUBMISSION TYPE','PUBLIC DOCUMENT COUNT','CONFORMED PERIOD OF REPORT','FILED AS OF DATE','DATE AS OF CHANGE','FILER:','COMPANY DATA:','COMPANY CONFORMED NAME','CENTRAL INDEX KEY','STANDARD INDUSTRIAL CLASSIFICATION','IRS NUMBER','STATE OF INCORPORATION','FISCAL YEAR END','FILING VALUES:','FORM TYPE','SEC ACT','SEC FILE NUMBER','FILM NUMBER','BUSINESS ADDRESS:','STREET 1','STREET 2','CITY','STATE','ZIP','BUSINESS PHONE')
  info_cleaned <- info[match(selected_headers, table = info[1:(grep("mail", info[,1], ignore.case = T)[1]-1),1]), 2] # all info before section "MAIL ADDRESS:"

  ## clean the document to improve parsing accuracy. 
  x_close_tagid <- grep(pattern = "</\\w+>$", filing) # identify the ending tag 
  ### only do this if the element in the vector is not too small. 
  if (length(x_close_tagid) > 10) {
    x_para_id <- c(
      grep(x = filing, pattern = "</SEC")[1], # the start of the doc 
      x_close_tagid[which(diff(x_close_tagid) != 1)] # guess the location of a potential paragraph/term 
    )
    x_para_id <- cbind(head(x_para_id+1, -1), x_para_id[-1])
    filing <- apply(X = x_para_id, MARGIN = 1, FUN = function(x) paste(filing[x[1]:x[2]], collapse = " "))
  }
  
  ## store item location
  loc_item2 <- loc.item(x = filing, filing_type = substr(info[2,2], start = 1, stop = 4) )
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
                                 item = loc_item2$item,
                                 text_break_node = text_break_node, 
                                 filing_qrt = str_extract(loc_file, pattern = '(QTR\\d{1})'),
                                 parts = "footnote")
  }
  ## return output 
  return(c(list(info = info_cleaned), # store header info
              item2_cleaned)) # combine info with cleaned table 
} 


# g. filing.cleaned_parallel(): the filing.cleaned() function for parallel ---- 
## this is based on funtion `filing.cleaned` and gives to output in parallel computing  
filing.cleaned_parallel <- function(loc_file, zip_file, text_break_node, errors = 1) {
  ## set the error return format
  error <- list(NA, matrix("ERROR", nrow = 1, ncol = 4))[[errors]]
  
  ## use `filing.cleaned` first to generate outputs 
  res_filing.cleaned <- try(
    filing_cleaned <- filing.cleaned(loc_file,
                                     zip_file, 
                                     text_break_node), 
    silent = T
  )
  
  ## whether error in the `filing.cleaned` function 
  if (inherits(res_filing.cleaned, "try-error")) { # if error 
    return(list(info = c(loc_file, zip_file) )) # store the file info in `info`.  
  } else {
    # store values
    if (ncol(filing_cleaned$table) != 4) {
      return(list(info = c(loc_file, zip_file) )) # store the file info in `info`.  
    } else {
      ## store table data 
      return(list(
        filing_info = c(filing_cleaned$info[1:26], filing_cleaned$table_unit, filing_cleaned$parts), 
        repurchase_tbl = filing_cleaned$table
      ))
    }
  }
}

                   
                   
# Appendix. list of built-in functions----
lsf.str()

# =====================================================

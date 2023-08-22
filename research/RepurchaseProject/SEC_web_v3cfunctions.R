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
  
  res_toc <- try(if (is.na(toc[2])) {
    filing_toc <- read_html(x[toc[1]]) # extract the toc
  } else {
    filing_toc <- read_html(paste(x[toc[1]:toc[2]], collapse = " ")) # extract the toc
  }, silent = T)
  
  if (inherits(res_toc, "try-error")) {
    if (is.na(toc[2])) {
      filing_toc <- read_html(x[toc[1]], options = c("HUGE", "NSCLEAN")) # extract the toc
    } else {
      filing_toc <- read_html(paste(x[toc[1]:toc[2]], collapse = " "), options = c("HUGE", "NSCLEAN")) # extract the toc
    }
  } 
  
  return(filing_toc)
} 

# c. loc.item(): locate the item of interest ---- 
## particularly item 2 in 10-Q and item 5 in 10-K
loc.item  <- function(x, # filing 
                      filing_type, # filing type from the previous input
                      regex_item = c("(Unregistered|UNREGISTERED|UNRE\\w+)\\s+(Sale|sale|SALE)(s|S|)\\s*(of|Of|OF)", 
                                     "(Market|MARKET)\\s+(for|For|FOR)\\s*(The|THE|the)?\\s*(Registrant|REGISTRANT|registrant|Re|re|RE|CO)") # item header ## July 14, 2023 ----
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
    toc_tbl_id <- which(grepl(pattern = ">Part.+[I]{2}|SIGNATURE", x = toc_tbl, ignore.case = T) )[1] # locate the table for TOC: will return NA if there are no tables in toc_tbl
  } else {
    toc_tbl_id <- which(grepl(pattern = "SIGNATURE|EXHIBIT", x = toc_tbl, ignore.case = T))[1] # locate the table for TOC: will return NA if there are no tables in toc_tbl
  }
  
  if (isTRUE(grepl(pattern = "href", x = toc_tbl[[toc_tbl_id]], ignore.case = T))) { 
    # if such table exists & contains url 
    ## find the row of item in the TOC
    toc_row <- html_nodes(toc_tbl[[toc_tbl_id]], "tr") %>% # separate each row
      .[grep(pattern = "^(Item|ITEM|\\d)", x = html_text(., trim = T), ignore.case = T)]
    toc_row_id <- grep(pattern = regex1, x = html_text(toc_row), ignore.case = T)[1] # separate and identify the row
    
    ## find the id for the item  ## updated July 16, 2023
    if (!is.na(toc_row_id)) { # if this item exists in the toc 
      item_id1 <- grep("#.+", html_attr(html_nodes(toc_row[toc_row_id], "a"), "href"), value = T)[1]
      if (!grepl('#', item_id1)) {
        item_id <- rep(NA, 2)
      } else {
        ### check whether the ToC has multiple components ## updated July 16, 2023 
        if (toc_row_id == length(toc_row)) {
          #### find the tables for the ToC
          toc_tbl_ids <- which(grepl(pattern = ">Part.+I|SIGNATURE", x = toc_tbl, ignore.case = T) )
          #### record all id(s) in the ToC ## updated July 16, 2023 
          toc_row_all <- html_nodes(toc_tbl[toc_tbl_ids], "tr") %>% # separate each row
            .[grep(pattern = "^(Item|ITEM|\\d)|(Exhibit|SIGNATURE)", x = html_text(., trim = T), ignore.case = T)]
          item_id_all <- unique(grep("#", html_attr(html_nodes(toc_row_all, "a"), "href"), value = T)) 
          #### 
          item_id2 <- item_id_all[match(item_id1, item_id_all)+1] 
        } else {
          item_id2 <- grep("#.+", html_attr(html_nodes(toc_row[toc_row_id+1], "a"), "href"), value = T)[1]
          if (!grepl('#', item_id2)) { # check whether it is a valid href -> if no then replace with the next valid one 
            item_id2 <- grep('#.+', html_attr(html_nodes(toc_row[-(1:toc_row_id)], "a"), "href"), value = T)[1] ## updated July 16, 2023 
          }
          
        } ## updated July 16, 2023  
        
        if (item_id1 == item_id2 & !is.na(item_id2)) { # for some wired errors for instance: <https://www.sec.gov/Archives/edgar/data/858655/000155837017000308/hayn-20161231x10q.htm#Toc>
          item_id1 <- grep("#.+", html_attr(html_nodes(toc_row[toc_row_id], "a"), "href"), value = T)[2]
        }
        
        item_id <-  sub(pattern = '#', replacement = '', x = c(item_id1, item_id2))

        ## add a backup id ## updated August 8, 2023 
        item_id_backup <- grep('#.+', html_attr(html_nodes(toc_row[-(1:(toc_row_id))], "a"), "href"), value = T)[2:3] %>% ## updated August 8, 2023 
          sub(pattern = '#', replacement = '', x = .) 
      }
    } else {
      item_id <- rep(NA, 2)
    }
    
  } else {
    item_id <- rep(NA, 2)
  }
  
  ## <What if no url is found.>  
  if ( ifelse(any(is.na(item_id)), FALSE, item_id[1] != item_id[2]) ) { # locate the item if item_id(url) is found ## updated July 15, 2023 ----
    
    if (any(nchar(item_id) >= 3)) {
      ## if the id is in the acceptable length
      loc_item <- vapply(X = item_id,
                         FUN = function(p) {
                           loc_item0 <- grep(pattern = paste("[<].+=(\"|\')", gsub("\\W", "\\\\\\W", p), "(\"|\')", sep = "")[1], x = x)
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
      loc_item <- sapply(item_id, FUN = function(id) which(sapply(x_text_attr, FUN = function(x) any(grepl(pattern = paste("^", id, "$", sep = "")[1], x))))[1]) + x_text_id[1] - 1
    }
    
    ## if they are wrongly directed to the same element in `filing / x`. > searching with brutal force: 
    if ( ifelse(any(is.na(loc_item)), TRUE, diff(loc_item) <= 0 & nchar(x[loc_item[1]]) < 5000) ) { ## updated July 15, 2023 ----
    
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
    if (length(loc_item1) > 0 ) { # if the first is identified # & length(loc_item1_check) > 0 ## updated July 16, 2023
      if (loc_item1 == length(x)) {
        loc_item <- rep(loc_item1, 2)
      } else {
        # if (loc_item1 >= loc_item1_check) { # if the place is correct 
        loc_item2 <- grep(pattern = "(>)?(Item|ITEM)[^0-9]+\\d{1}[.]",
                          x = x[(loc_item1+1):grep(pattern = '<text>|</text>', x = x, ignore.case = T)[2]],
                          ignore.case = T)[1] + loc_item1 # absorb the case without '>'. 
        
        if (is.na(loc_item2)) { # if it returns NA
          loc_item2 <- grep(pattern = "(>)?(Item|ITEM)",
                            x = x[(loc_item1+1):grep(pattern = '<text>|</text>', x = x, ignore.case = T)[2]],
                            ignore.case = T)[1] + loc_item1 # absorb the case without '>'. 
          }
        
        ## have a second try if `loc_item2` is NA. 
        ifelse(is.na(loc_item2), loc_item <- rep(loc_item1, 2), loc_item <- c(loc_item1, loc_item2))
      } 
      
    } else { # if the first is not identified
      loc_item <- rep(NA, 2)
    }
  }
  
  ## return the location, id, and item number (i.e. item 2 or 5)
  return(list(loc_item = loc_item, item_id = item_id, item = c(regex1, regex2)))
}

# d. (INACTIVE) tbl.rowkeep(): sub-function for `filing.item` for table row cleaning ---- 
tbl.rowkeep <- function(regex_row = '(\\w+(\\s+?)\\d{1,2},\\s+\\d{4}|Total|to|[-]|\\d+\\/\\d+\\/\\d+)|(Jan(uary)?|Feb(ruary)?|Mar(ch)?|Apr(il)?|May|Jun(e)?|Jul(y)?|Aug(ust)?|Sep(tember)?|Oct(ober)?|Nov(ember)?|Dec(ember)?)', # the regex for the kept row(s)
                        row_name, # the name of each row
                        reporting_qrt # the filing quarter 
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
        tbl_periods[length(tbl_periods)] <- reporting_qrt # entering the filing quarter
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

# d2. updated tbl.rowkeep2() function 
tbl.rowkeep2 <- function(regex_row = '(\\w+(\\s+?)\\d{1,2},\\s+\\d{4}|Total|[^a-zA-Z]to|[-]|\\d+\\/\\d+\\/\\d+)|((Jan(uary)?|Feb(ruary)?|Mar(ch)?|Apr(il)?|May|Jun(e)?|Jul(y)?|Aug(ust)?|Sep(tember)?|Oct(ober)?|Nov(ember)?|Dec(ember)?)\\b)|quarter', # the regex for the kept row(s)
                         row_name, # the name of each row
                         reporting_qrt # the reporting quarter 
) {
  # identify the rows that match the regex_row
  tbl_periods_id <- grep(pattern = regex_row, row_name, ignore.case = T) # id_row for the periods
  
  if (length(tbl_periods_id) > 0) {
    # 
    tbl_col_id <- rep(F, length(row_name)); tbl_col_id[tbl_periods_id] <- T # record the loc of each item and item matching regex_row
    tbl_periods <- row_name[tbl_periods_id][cumsum(tbl_col_id)] # convert to the `period` variable 
    tbl_rowkeep <- which(cumsum(tbl_col_id) != 0) # record the item location of `period` variable 
    
    # return values
    return(list(rowkeep = tbl_rowkeep, 
                period = tbl_periods))
  } else {
    return(NA) # indicating no table in there!
  }
  
}

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# e. (INACTIVE) filing.item0(): extract text (header and/or footnote), unit and cleaned table 
## ================================================================================================================
#### e2. updated filing.item() function 
filing.item <- function(x, # filing
                        loc_item, # the location of the item of interest
                        item_id, # the identifier from 'href' for the section 
                        item, # the regex for the item (item number./ item name)
                        item_id_backup, # a backup id ## *August 8, 2023 
                        reporting_qrt, # the quarter the filing was made 
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
      item_txt <- sub(pattern = "(>|)(Item|ITEM|Signature|SIGNATURE).*", "", item_parse) ## *updated August 18, 2023 
    } else {
      
      if (any(nchar(item_id) >= 3)) { # the id is long enough
        # print("Yes! item_id")
        item_parse <- sub(pattern = paste(".*(\"|\'|[^#])", item_id[1], "(\"|\'|)", sep = "")[1], "", x[loc_item[1]])
        
        ## check if the item_parse contains the correct item info 
        if (grepl(paste(item[1], "|(Item|ITEM).+[36]{1}(.)?.+[A-Z]\\w+\\s+[A-Z]", sep = ""), substr(html_text(read_html(item_parse)), 1, 1500), ignore.case = F)) { ## July 15, 2023
          if (grepl(pattern = paste("(\"|\'|[^#])", item_id[2], "(\"|\'|)", sep=""), x = item_parse) ) {
            item_txt <- sub(pattern = paste("(\"|\'|[^#])", item_id[2], "(\"|\'|)", ".*", sep=""), "", item_parse)
          } else { ## *August 8, 2023 
            item_txt <- ifelse(
              (grepl(pattern = paste("(\"|\'|[^#])", item_id_backup[1], "(\"|\'|)", sep=""), x = item_parse) ), 
              sub(pattern = paste("(\"|\'|[^#])", item_id_backup[1], "(\"|\'|)", ".*", sep=""), "", item_parse),
              sub(pattern = paste("(\"|\'|[^#])", item_id_backup[2], "(\"|\'|)", ".*", sep=""), "", item_parse)
            )
          }
          
        } else { # if not, then use brutal force to search for ">Item 2." or ">Item 5."
          item_parse <- sub(pattern = paste(".*", item[1], sep = "")[1], "", x[loc_item[1]], ignore.case = F) # updated July 15, 2023
          item_txt <- sub(pattern = "(>|)(Item|ITEM)[^_].*", "", item_parse) 
        }
        
      } else { # if the id is NOT long enough 
        # print("Yes! item_id")
        item_parse <- sub(pattern = paste(".*", item[2], sep = "")[1], "", x[loc_item[1]], ignore.case = F)
        item_txt <- sub(pattern = "(>|)(Item|ITEM).*", "", item_parse) ## July 14, 2023 
      }
      
    }
  } else {
    # the full item ## *updated August 18, 2023 
    if (any(is.na(item_id))) { 
      item_txt <- paste(str_squish(x[loc_item[1]:loc_item[2]]), collapse = "") %>% 
        sub(pattern = paste(".*", item[2], sep = "")[1], "", ., ignore.case = F) %>% 
        sub(pattern = "(>)?(Item|ITEM)(.){0,30}[6-9]\\b.*", "", .) ## *updated August 18, 2023 
      
    } else {
      item_txt <- paste(str_squish(x[loc_item[1]:loc_item[2]]), collapse = "")
      
    }
    
    # item_txt <-  paste(str_squish(x[loc_item[1]:loc_item[2]]), collapse = " ") %>% 
    #   sub(pattern = paste(".*", item[2], sep = "")[1], "", ., ignore.case = F) %>%
    #   sub(pattern = "(>|)(Item|ITEM).*", "", .) ## August 7, 2023 
  }
  
  # find the table(s) ## *updated August 9, 2023 
  # res <- try(item_html <- read_html(paste(item_txt, collapse = "")), silent = T)
  res <- try(item_html <- read_html(paste("<text>", item_txt, "</text>", collapse = "")), silent = T)
  # res <- try(item_html <- read_html(paste("<text>", item_txt, "</text>", collapse = "")), silent = T)
  if (inherits(res, "try-error")) {
    if (nchar(x[loc_item[1]]) > 300) {
      item_parse <- sub(pattern = paste(".*", item[2], sep = "")[1], "", paste(item_txt, collapse = " "), ignore.case = T) ## July 14, 2023 
      item_txt <- sub(pattern = "(>)?(Item|ITEM)[^0-9]+\\d{1}.*", "", item_parse)
      res <- try(item_html <- read_html(paste(item_txt, collapse = "")), silent = T)
    }
    res2 <- try(item_html <- read_html(paste('<p>', item_txt, '</p>', collapse = "")), silent = T)
  } 
  
  item_tbls <- html_nodes(item_html, "table")
  if (length(item_tbls) == 0) { # if no table found in the item 
    # print("No Table!")
    return(list(table = matrix(NA, nrow = 1, ncol = 4),
                parts = "No Table!" , # html_text(item_html, trim = T),  
                table_unit = NA))
  } else { # if there are tables! ## updated August 8, 2023 
    item_tbl_id <- which(str_count(string = as.character(item_tbls), pattern = "/tr") > 1 & # number of rows > 1
                           str_count(string = as.character(item_tbls), pattern = "/td") / str_count(string = as.character(item_tbls), pattern = "/tr") >= 6 & # number of columns >= 6
                           grepl(pattern = "Total.*Number|purchase|repurchase", x = item_tbls, ignore.case = T) & 
                           grepl(pattern = "program|price|plan", x = item_tbls, ignore.case = T) & 
                           grepl(pattern = "share", x = item_tbls, ignore.case = T) & 
                           !grepl(pattern = "issuance|revenue|income|conversion|(purchase price of common)", x = item_tbls, ignore.case = T) )[1] # identify the correct table
          ## id: "0001403475-21-000015"
    
    ## extract the table 
    if (ifelse(is.na(item_tbl_id), 
               FALSE, # if no table is identified
               grepl(pattern = "total.*number.*of|Average.*Price.*Paid",
                     x = html_text(item_tbls[[item_tbl_id]]),
                     ignore.case = T) # check again the table is correct
    )
    ) { 
      ### <Tables starts here!>
      ### clean the table ## *updated August 22, 2023 
      item_table0 <- unique.matrix(as.matrix(html_table(item_tbls[[item_tbl_id]], header = F)), MARGIN = 2) %>% 
        .[,colSums(is.na(.)) != nrow(.),drop=F]
      item_table0 <- apply(item_table0, MARGIN = 2, FUN = function(x) str_replace(string = x, pattern = "\\([a-zA-Z0-9]{1}\\)", replacement = "") %>% trimws)
      if (nrow(item_table0) > 6) {
        item_table0_footnotes <- sapply(apply(item_table0, MARGIN = 1, FUN = function(x) {
          table(x, exclude = "") # exclude "" elements > collect the frequency of appearance in each row  
        }), FUN = function(x) {
          if (length(x) == 1) {
            output <- as.logical(x > ncol(item_table0)/2)
          } else { # id "0000732717-14-000110.txt" ## *updated August 22, 2023 
            if (length(x) == 2) {
              output <- as.logical(x[which.max(x)] > ncol(item_table0)/2)
            } else {
              output <- FALSE
            }
          }
          return(output)
        }) 
        item_table0_footnotesid <- which((item_table0_footnotes +
                                            dplyr::lead(item_table0_footnotes, default = 1) + 
                                            dplyr::lead(item_table0_footnotes, 2, default = 1)) == 3)[1]
        item_table0_head <- which(apply(item_table0, MARGIN = 1,
                    FUN = function(x) sum({grepl(pattern = "total|number|average|price", x, ignore.case = T)}, na.rm = T) ) > 0)[1]
        if (!is.na(item_table0_footnotesid) & (item_table0_footnotesid > item_table0_head) ) { # if the footnote is identified 
          item_table0 <- item_table0[1:max(1,item_table0_footnotesid-1),,drop=F]
        }
      }
      
      ### remove rows with all same elements 
      if ( sum(grepl(pattern = "total.*number.*of|Average.*Price.*Paid", x = item_table0[,1], ignore.case = T)) > 1 ) { 
        # for the case: "0001144204-17-014104" ## sum(item_table0[1,] %in% month.name) > 0
        item_table0 <- item_table0 %>%
          .[, colSums(. == "$") == 0 & !is.na(colSums(. == "$")), drop=F] # remove columns having only $ or NA 
        item_table0 <- t(item_table0)
      }  
      ## (abandoned*) grepl(pattern = "border-bottom", html_nodes(item_tbls[[item_tbl_id]], "tr")) # try to identify the header row
      ### check empty rows and remove them 
      if ( length(which(apply(item_table0, MARGIN = 1, FUN = function(x) sum(nchar(na.omit(x)), na.rm = T)) == 0)) > 0 ) {
        item_table2 <- item_table0[-which(apply(item_table0, MARGIN = 1, FUN = function(x) sum(nchar(x), na.rm = T)) == 0),,drop=F] # remove empty rows
        
      } else {
        item_table2 <- item_table0
      } ## *updated August 19, 2023 
      
      
      ## whether has `$`: ## *updated August 18, 2023 
      item_table_dollar <- rep("", ncol(item_table2))
      item_table_dollar[which(colSums(item_table2 == "$", na.rm = T) > 0) + 1] <- "D$-" # record the column that is in dollar ($)
      # item_table2[1,] <- paste(item_table_dollar, item_table2[1,,drop=F], sep = "") # replace the old column headers by the new ones with ($)
      
      item_table3 <- item_table2 %>% 
        rbind(item_table_dollar, ., deparse.level = 0) %>% # add the symbol ($) info in the first row 
        .[, colSums(. == "$", na.rm = T) == 0 & colSums(is.na(item_table2)) != nrow(item_table2), drop=F] %>% # remove columns having only $ or NA (past code: <!is.na(colSums(. == "$"))> )
        unique.matrix(x = ., MARGIN = 2)  # remove repeated columns 
      # if (any(is.na(item_table3))) { # if there still exists NA elements -> replace it by dash 
      #   item_table3[is.na(item_table3)] <- "NA"
      # }
      item_table <- item_table3 %>% 
        .[apply(., MARGIN = 1, FUN = function(x) length((unique(x)))) != 1,,drop=F] %>% # remove merged rows 
        .[,apply(., MARGIN = 2, FUN = function(x) sum(nchar(x, type = "width"))) != 0,drop=F] # remove zero width columns 
        
      ### identify the rows to keep ## *updated August 22, 2023 
      # item_table_headerid <- 0; item_table_headerid0 <- 100
      # while ((item_table_headerid0 != item_table_headerid) & !any(grepl(pattern = "///", x = item_table, fixed = T))) {
      
      #### the header row ## *updated August 22, 2023 
      item_table_headercount <- apply(item_table, 1, FUN = function(x) sum(grepl(pattern = "plan|program|purchased", x = x, ignore.case = T)))
      if (max(item_table_headercount) == 0 ) { # id "0001217234-21-000046"
        item_table_headercount <- apply(item_table, 1, FUN = function(x) sum(grepl(pattern = "price|number|total", x = x, ignore.case = T)))
      } 
      ## *updated August 22, 2023 
      potential_header_idcheck <- sapply(X = which(item_table_headercount > 0), FUN = function(x) {
        # get the full header up to a row: from row 2 to row `x`
        headername <- apply(item_table[2:x,,drop=F], MARGIN = 2, FUN = function(y) paste(y, collapse = "") ) # get the full header up to a row
        ## count the unique (non empty) headers there  
        uniq_headername <- grep(pattern = "[a-zA-Z]", x = unique(headername), value = T) %>% length() 
        # get the row text and count the unique items in each row (for the case that footnotes cannot be fully removed)
        headername_row <- grep(pattern = "[a-zA-Z]", x = unique(item_table[x,,drop=T]), value = T) %>% length() 
        uniq_headername[(headername_row == 1)] <- 0
        return(uniq_headername) # return the number 
      })
      
      #### following code explanation: `item_table_headerid` ## *updated August 22, 2023 
      #### (1) [.] > identify the rows with the most number of unique items 
      #### (2) max(.) > find the row number of the qualified rows and choose the last row among them 
      item_table_headerid <- max(which(item_table_headercount>0)[which(potential_header_idcheck == max(potential_header_idcheck))]) ## record the number of cells with letters in each row 
        item_table_headerid0 <- max(which(item_table_headercount == max(item_table_headercount))) 
      if (item_table_headerid0 != item_table_headerid) {
        new_row <- item_table[item_table_headerid0,]
        if (item_table_headerid0 < item_table_headerid) {
          new_row[nchar(new_row, type = "width") != 0] <- gsub(pattern = "$", "///", new_row[nchar(new_row, type = "width") != 0] )
          # sub("///.*", "", new_row) # to extract the info afterwards 
          item_table[item_table_headerid0,] <- new_row
        } else {
          item_table[item_table_headerid0,] <- ""
        }
      }
        # if (item_table_headerid0 == item_table_headerid) {break} 
      # }
      
      ### record the column ids for rownames (row-headers) ## *updated August 19, 2023 
      item_table_colheaders <- which(cumsum(grepl(pattern = "total|number|purchase", ignore.case = T, 
                                     x = apply(item_table[min(2, item_table_headerid):item_table_headerid,,drop=F], # pick the header rows 
                                     MARGIN = 2, FUN = function(x) paste(x, collapse = " ")) ) )  == 0 )
      if (length(item_table_colheaders) == 0) { # e.g. "0001564590-21-004296" 
        item_table_colheaders <- which(cumsum((!duplicated(apply(item_table[min(2, item_table_headerid):item_table_headerid,,drop=F], # pick the header rows
                                                                 MARGIN = 2, FUN = function(x) paste(x, collapse = " ")) ) ) ) == 1 )
      }
      
      #### replace the NA in the matrix entry
      item_table <- apply(item_table, MARGIN = 2, FUN = function(x) replace_na(x, "N/A"))
      
      #### the number rows to keep (after removing the header row(s) )
      if (nrow(item_table[-(1:item_table_headerid), -item_table_colheaders, drop = F]) > 4) {
        item_table_numbersid <- item_table_headerid + 
          which(apply(item_table[-(1:item_table_headerid), -item_table_colheaders, drop = F], 1, FUN = function(x) sum(grepl("\\W|\\w", x))) != 0)
      } else {
        item_table_numbersid <- (item_table_headerid+1):nrow(item_table)  
      }
      
      #### the first column with row info ## *updated August 19, 2023 
      if (length(item_table_colheaders) > 1) { # if multiple first columns
        item_table <- cbind(
          as.matrix(apply(item_table[,item_table_colheaders,drop=F], 1, FUN = function(x) paste(unique(x[nchar(x, type = "width") != 0]), collapse = " - "))), 
          item_table[,-item_table_colheaders, drop=F] 
        )
      } 
      
      #### the new `period` variable and rows to be kept 
      tbl_rowkeep_info <- tbl.rowkeep2(row_name = item_table[,1], reporting_qrt = reporting_qrt)
      
      if (NA %in% tbl_rowkeep_info) { # IF THE TABLE IS NOT VALID
        ## no actual table can be identified 
        return(list(table = matrix(NA, nrow = 1, ncol = 4),
                    parts = html_text(item_html, trim = T),  
                    table_unit = NA, 
                    table_html_code = NA ))
      } else { 
        ## Continue for a valid table      
        tbl_periods <- tbl_rowkeep_info$period # return the period for each column 
        tbl_rowkeep <- tbl_rowkeep_info$rowkeep # identify the rows to be kept in `item_table`
        
        ### clean rows in the table 
        tbl_numbers <- item_table %>% .[tbl_rowkeep, ,drop=F] %>% # keep the rows after the headers
          cbind(., `length<-`(tbl_periods, nrow(.))) %>%  # add 'period' column 
          .[match(item_table_numbersid[item_table_numbersid >= (tbl_rowkeep)[1]], tbl_rowkeep), ,drop=F] # keep the rows with values 
        
        ### create the tbl_titles
        if (item_table_headerid == 1) {
          tbl_title0 <- item_table[item_table_headerid,-1,drop=T] %>%
            gsub(pattern = "\\([a-zA-Z0-9]{1}\\)", replacement = "", x = .) %>% 
            trimws %>% as.vector
        } else {
          tbl_title0 <- apply(item_table[1:item_table_headerid,-1,drop=F], MARGIN = 2,
                              FUN = function(name) paste(name, collapse = " ") ) %>%
            gsub(pattern = "\\([a-zA-Z0-9]{1}\\)", replacement = "", x = .) %>%
            trimws %>% as.vector
        }
        ### to impute missing headers
        tbl_title0[which(nchar(tbl_title0, type = "width") == 0)] <- tbl_title0[which(nchar(tbl_title0, type = "width") == 0)-1]
        tbl_title <- c("item", (tbl_title0), "period") ## final headers 
        
        ### store duplicated and non-duplicated column headers
        tbl_title_dupid <- cumsum(!duplicated(gsub("D\\$-|\\s", "", tbl_title)))
        
        if (max(tbl_title_dupid) < length(tbl_title)) { # if there are duplicated headers
          tbl_numbers <- sapply(X = 1:max(tbl_title_dupid), FUN = function(x) {
            apply(tbl_numbers[, which(tbl_title_dupid == x),drop=F], MARGIN = 1, FUN = function(x) paste(unique(x), collapse = " ")) %>% 
              str_replace_all(pattern = "\\$|(\\s*?)\\([12ab]\\)", replacement = "")
          })
          
          if (is.null(dim(tbl_numbers))) {
            tbl_numbers <- matrix(tbl_numbers, nrow = 1)
          }
          ## clean the wired values (id "0001039684-11-000029")
          if (sum(str_count(tbl_numbers[,1], pattern = "[a-zA-Z]") == str_count(tbl_numbers[,2], pattern = "[a-zA-Z]")) > nrow(tbl_numbers)/2 ) {
            tbl_numbers[,c(-1, -ncol(tbl_numbers))] <- apply(tbl_numbers[,c(-1, -ncol(tbl_numbers)), drop=F], MARGIN = 2,
                  FUN = function(x) str_replace_all(string = x, pattern = paste(tbl_numbers[,1], collapse = "|"), replacement = ""))
          }
          
        } ## otherwise just use the old tbl_numbers 
        
        #### append back the column headers
        colnames(tbl_numbers) <- tbl_title[!duplicated(tbl_title_dupid)] 
        
        ### return the cleaned table - from wide to long
        tbl_numbers_cleaned <- melt(as.data.frame(tbl_numbers), id.vars = c("item", "period")) 
        
        ## <table unit information>
        ## extract the unit information from the table ## updated July 16, 2023
        item_table_unit <- str_extract(string = html_text(item_tbls[[item_tbl_id]], trim = T), pattern = "\\((I|i)(N|n)\\s*[^()0-9c][^()0-9]+\\)")
        if (is.na(item_table_unit)) { # check directly in the table if the `item_table_unit` returns NA 
          item_table_unit <- grep(pattern = "in\\s*(hundred|thousand|million|billion)", x = item_table0, ignore.case = T, value = T)[1]
        } 
        
        ## <text info excl. table> ## *updated August 22, 2023 (issues)
        ## extract item text and exclude the table. ## *updated August 22, 2023 ----- 
        table_html_code <- as.character(item_tbls[[item_tbl_id]]) # store the raw html code for the table 
        xml_replace(.x = item_tbls[[item_tbl_id]], .value = text_break_node) # replace the identified table
        filing_item2_txt <- html_text(item_html, trim = T) # store the txt excl. table
        if (is.na(item_table_unit)) { # if no unit info inside the table
          ## search in the text before the table 
          item_table_unit <- str_extract(string = sub(pattern = "<footnote>.*", replacement = "", x = filing_item2_txt),
                                         pattern = "\\((I|i)(N|n)\\s*[^()0-9c][^()0-9]+\\)")
        }
        
        # tbl_numbers_cleaned %>% View
        return(list(table = as.matrix(tbl_numbers_cleaned), 
                    parts = filing_item2_txt,
                    table_unit = item_table_unit, 
                    table_html_code = table_html_code
        ) )
      }
    } else { # if no table in the item ## *updated August 22, 2023 
      return(list(table = matrix(NA, nrow = 1, ncol = 4),
                  parts = substr(html_text(item_html, trim = T), 1, 5000), # keep only the first 5000 char
                  table_unit = NA,
                  table_html_code = NA ))
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
  info_cleaned <- info[match(selected_headers, 
                             table = info[1:max(grep("mail", info[,1], ignore.case = T)[1]-1, nrow(info), na.rm = T),1]), 2] # all info before section "MAIL ADDRESS:"
  
  ## clean the document to improve parsing accuracy. 
  ## updated July 16, 2023 
  x_text_id <- grep(pattern = '<text>|</text>', x = filing, ignore.case = T)[1:2] # identify the main body
  if (any(is.na(x_text_id))) { ## if containing NA 
    filing <- filing[x_text_id[1]]
    
  } else {
    filing <- filing[x_text_id[1]:x_text_id[2]] ## keep only the text component
    x_close_tagid <- grep(pattern = "</\\w+>$|<text>", filing, ignore.case = T) # identify the ending tag 
    
    ### only do this if the element in the vector is not too small. 
    if (length(x_close_tagid)/length(filing) < 0.7 & length(filing) > 800) { ## updated July 15, 2023
      x_para_id <- c(
        x_close_tagid[which(diff(x_close_tagid) >= 1)], # guess the location of a potential paragraph/term 
        length(filing)
      )
      x_para_id <- rbind(rep(1, 2), cbind(head(x_para_id+1, -1), x_para_id[-1])) 
      filing <- apply(X = x_para_id, MARGIN = 1, FUN = function(x) paste(filing[x[1]:x[2]], collapse = " "))
    }
    
  }  ## July 16, 2023 
  
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
                                 item_id_backup = loc_item2$item_id_backup, ## updated August 8, 2023 
                                 text_break_node = text_break_node, 
                                 reporting_qrt = info_cleaned[4],
                                 parts = "footnote")

    ## re-search the whole document 
    if (0 == 1) { # I hide this component
      if (all(is.na(item2_cleaned$table))) { ## updated July 16, 2023 
        x_text_id <- grep(pattern = '<text>|</text>', x = filing, ignore.case = T)[1:2] # identify the main body 
        ## search in the tables and store the outputs 
        item2_cleaned_alter <- item2_html_table(item_html = read_html(paste(filing[x_text_id[1]:x_text_id[2]], collapse = ""), options = c("HUGE", "NSCLEAN")), 
                                                reporting_qrt = info_cleaned[4]) ## updated July 15, 2023
        if (!is.na(item2_cleaned_alter$parts)) { # only replace the old one if the new output is valid. 
          item2_cleaned <- item2_cleaned_alter 
        }
      }
    }
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
        filing_info = c(filing_cleaned$info[1:26], filing_cleaned$table_unit, filing_cleaned$parts, filing_cleaned$table_html_code), 
        repurchase_tbl = filing_cleaned$table
      ))
    }
  }
}

# h. item2_html_table(): extract the table of interest directly from the filing ----
item2_html_table <- function(item_html, reporting_qrt) { ## updated July 15, 2023 
  ## normally put the whole filing in html format in the function
  item_tbls <- html_nodes(item_html, "table")
  ## check for tables 
  if (length(item_tbls) == 0) { # if no table found in the item 
    # print("No Table!")
    return(list(table = matrix(NA, nrow = 1, ncol = 4),
                parts = NA, 
                table_unit = NA))
  } else { # if there are tables!
    item_tbl_id <- which(str_count(string = as.character(item_tbls), pattern = "/tr") > 1 & # number of rows > 1
                           str_count(string = as.character(item_tbls), pattern = "/td") > 6 & # number of columns > 6
                           grepl(pattern = "Average.*Price.*Paid.*Per.*Share", x = html_text(item_tbls), ignore.case = T))[1] # identify the correct table ## updated July 15, 2023 ----
    
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
        .[, colSums(. == "$") == 0 & !is.na(colSums(. == "$")), drop=F] %>% # remove columns having only $ or NA 
        .[-which(apply(., 1, FUN = function(r) sum(nchar(r))) == 0), , drop=F] %>% # remove the empty rows
        unique.matrix(x = ., MARGIN = 2) # remove repeated columns 
      
      
      ### identify the rows to keep
      #### the header row 
      item_table_headerid <- max(which(apply(item_table, 1, FUN = function(x) sum(grepl("[a-zA-Z]", x))) == max(apply(item_table, 1, FUN = function(x) sum(grepl("[a-zA-Z]", x)))))) ## record the number of cells with letters in each row 
      #### the number rows (after removing the header row(s) )
      item_table_numbersid <- item_table_headerid + which(apply(item_table[-(1:item_table_headerid), -1], 1, FUN = function(x) sum(grepl("\\W|\\w", x))) != 0)
      #### the new `period` variable and rows to be kept 
      tbl_rowkeep_info <- tbl.rowkeep2(row_name = item_table[,1], reporting_qrt = reporting_qrt)
      
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
        tbl_numbers <- item_table %>% .[tbl_rowkeep, ,drop=F] %>% # keep the rows after the headers
          cbind(., `length<-`(tbl_periods, nrow(.))) %>%  # add 'period' column 
          .[match(item_table_numbersid[item_table_numbersid >= (tbl_rowkeep)[1]], tbl_rowkeep), ,drop=F] # keep the rows with values 
        
        ### create the tbl_titles
        if (item_table_headerid == 1) {
          tbl_title0 <- item_table[item_table_headerid,-1,drop=T] %>% gsub(pattern = "\\([a-zA-Z0-9]{1}\\)", replacement = "", x = .)
        } else {
          tbl_title0 <- apply(item_table[1:item_table_headerid,-1,drop=F], MARGIN = 2,
                              FUN = function(name) paste(name, collapse = " ") ) %>%
            gsub(pattern = "\\([a-zA-Z0-9]{1}\\)", replacement = " ", x = .)
        }
        
        tbl_title <- c("item", as.vector(tbl_title0), "period")
        
        
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
        ## extract the unit information ## updated July 16, 2023
        item_table_unit <- str_extract(string = html_text(item_html, trim = T), pattern = "\\((I|i)(N|n)\\s*[^()0-9c][^()0-9]+\\)")
        
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
                   
                   
# Appendix. list of built-in functions----
lsf.str()

# =====================================================


# a. filing.cleaned_errorid(): identify the output with errors ---- 
## From function `filing.cleaned_parallel()`, the `$filing_info` only exists in the correct outputs, 
## while the info is stored in `$info` and the `$error` can distinguish cases that the file cannot be read. 
filing.cleaned_errorid <- function(cleaned_dt) { # the cleaned data after the `parallel` 
  error_id <- which(sapply(cleaned_dt, function(x) {length(x$filing_info) == 0}))
  return(error_id)
}

# b. filing.cleaned_parts(): extract correct cleaned data > the `$filing_info` section ---- 
filing.cleaned_parts <- function(cleaned_dt) {
  # remove the entries with errors 
  error_id <- filing.cleaned_errorid(cleaned_dt)
  if (length(error_id) != 0) {
    dt_errorfree <- cleaned_dt[-error_id]
  } else {
    dt_errorfree <- cleaned_dt
  }
  info_matrix <- do.call(rbind, lapply(dt_errorfree, function(x) x$filing_info))
  
  # record empty tables
  dt_errorfree_na_id <- which(sapply(dt_errorfree, function(x) {NA %in% x$repurchase_tbl}))
  repurchase_matrix <- do.call(rbind, lapply(dt_errorfree[-dt_errorfree_na_id],
                                             function(x) cbind(id = x$filing_info[1],
                                                               cik = x$filing_info[10],
                                                               x$repurchase_tbl) ))
  return(list(
    info_matrix = info_matrix, 
    repurchase_matrix = repurchase_matrix
  ))
}



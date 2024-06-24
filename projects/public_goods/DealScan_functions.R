# =========================================================================
# Functions to clean the DealScan dataset 
# Date created: June 13, 2023 
# Date updated: June 13, 2024
# Operating: MacBook Pro  
# Previous File: > ~/Library/CloudStorage/OneDrive-HandelshögskolaniStockholm/Projects_2024/Dealscan_LinkTable/DealScan_Loan_Path_Jun2024
# Files: ~/Library/CloudStorage/OneDrive-HandelshögskolaniStockholm/Projects_2024/Dealscan_LinkTable/DealScan_Functions/DealScan_functions.R
# Next File: > 
# ======================================================
# call function file: source("https://hongyileoxu.github.io/research/RepurchaseProject/SEC_web_v3cfunctions.R", encoding = "UTF-8") 
# 
# ======================================================

# 0. load libraries:
library(tidyverse)
library(readxl)
library(data.table)

library(ggplot2)
library(ggthemes)
library(shadowtext)
library(egg)
library(gt)

library(psych)
library(zoo)
library(fedmatch)

library(igraph) # for network analysis 


# a. function `group_or()` 
group_or <- function(
    data = dt.data, # dataset 
    # the grouping ID(s) > use "borrowercompanyid" as it has little NA terms, while `LoanConnector Company ID` has a lot (66 observations) 
    id1 = "gvkey", # the first id
    id2 = "borrowercompanyid", # the second id 
    operator = "or"
) {
  ## this function is used to create groupings based on the "OR" operation for the given variables. 
  data1 <- data[c(id1, id2)] %>% ## only keeps the `id`(s) 
    distinct() %>% 
    group_by(!!! syms(id1)) %>% ## call the names of variable `id1` 
    mutate(id1_group0 = cur_group_id()) %>% # create a grouping based on the first id 
    ungroup() 
  
  ## generate the set of `id1` within the same `id2` group. 
  data2 <- data1 %>% 
    group_by(!!! syms(id2)) %>% 
    summarise(id2_to_id1 = paste0(unique(get(id1)), collapse = ";") , # for each unique `id2`, collect all unique `id1`(s). 
              n_id1 = length(unique(get(id1))) # number of unique `id1` within each `id2` group. 
    ) %>% 
    ungroup() 
  
  ## (`data2`) rejoin the original dataset (`data1) and create new `id1_group1` group > `data1_3` 
  data1_3 <- data1 %>% 
    left_join(data2, by = id2) %>% 
    group_by(!!! syms(id1)) %>% 
    summarise( ## link previous `id1` to other `id1` based on connected `id2` 
      connected_id1 = paste( sort(unique(as.numeric(str_split(id2_to_id1, pattern = ";", simplify = T)))), collapse = ";"), 
    ) %>% 
    ungroup() %>% 
    # select(connected_id1) %>% 
    distinct() # %>% 
  # mutate(id1_group1 = 1:nrow(.)) ## re-generate the `id1` group variable 
  
  ## using the network analysis to connect linked `gvkey`(s) and group them 
  ## use `library(igraph)`: 
  data1_4 <- data1_3 %>% 
    separate_rows(connected_id1) %>% # create edges for one-to-one connections 
    graph_from_data_frame() %>% # create the network graphs 
    components() %>% 
    getElement('membership') %>% # for instance, for gvkey == 1040 and 1599, both are classified into membership-14. 
    # imap(~str_detect(data$Names, .y)*.x) %>% 
    cbind.data.frame(id1 = as.double(names(.)), id1_group1 = .) %>% 
    as_tibble() 
  
  data_output <- data1 %>% 
    left_join(data1_4, by = join_by((!! id1) == id1) ) %>% 
    select((!! id1), (!! id2),
           (!! paste0(id1, "_group1")) := id1_group1 ## rename the new grouping number. 
    ) 
  
  return(data_output) 
  
}


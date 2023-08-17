## Notes: 
1. This folder contains the code for the 2023 summer project.
2. A great source for the document: https://sraf.nd.edu/sec-edgar-data/cleaned-10x-files/
3. IV?: [monthly edgar filing numbers](https://www.sec.gov/about/sec-docket.shtml) -> EDGAR Company Filings Indexes: [Daily](https://www.sec.gov/Archives/edgar/daily-index/) and [Quarterly](https://www.sec.gov/Archives/edgar/full-index/)
4. Dataset: updated August 17, 2023 [[link]](https:/hongyileoxu.github.io/research/RepurchaseProject/ShaRep_AIA_merge_Aug17_2023.csv) / [[P0]](https:/hongyileoxu.github.io/research/RepurchaseProject/Repurchase_BBAIA_merge_v1b.html)






## Errors in Edgar Filing: 
1. "0001193125-11-133527": wrong month name in the period column; 
2. "0001193125-13-338522": 21st century fox > no column "total number under the program" ;
3. "0000950123-11-019686": gives the column name "Cumulative Shares Repurchased Under The Program" ; > map to `vars_id = 5`.
4. "0001193125-11-050024": wired first column ; 
5. "0001564590-20-020599": Dual Class Share Firms: BERKSHIRE HATHAWAY INC (BRK-B, BRK-A) (CIK 0001067983); 


| id | issue | 
| :---:   | --- |
| 0001193125-11-133527 | wrong month name in the period column  | 
| 0001193125-13-338522 | 21st century fox > no column "total number under the program"  | 
| 0000950123-11-019686 | gives the column name "Cumulative Shares Repurchased Under The Program" ; > map to `vars_id = 5`. | 
| 0001193125-11-050024 | wired first column  | 
| 0001193125-11-133527 | wrong unit info -> not in thousands  | 
| 0001193125-13-425259 | wrong units in all tables | 
| 0001193125-11-003706 | did not report for each month | 
| 0000318154-14-000004 | the total is given by the whole year rather than "total" |
| cik: 1757898 | vars_id is incorrect | 

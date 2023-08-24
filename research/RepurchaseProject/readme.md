## Notes: 
1. This folder contains the code for the 2023 summer project.
2. A great source for the document: https://sraf.nd.edu/sec-edgar-data/cleaned-10x-files/
3. IV?: [monthly edgar filing numbers](https://www.sec.gov/about/sec-docket.shtml) -> EDGAR Company Filings Indexes: [Daily](https://www.sec.gov/Archives/edgar/daily-index/) and [Quarterly](https://www.sec.gov/Archives/edgar/full-index/)
4. Dataset: updated August 17, 2023 [[link]](https:/hongyileoxu.github.io/research/RepurchaseProject/ShaRep_AIA_merge_Aug17_2023.csv) / [[P0]](https:/hongyileoxu.github.io/research/RepurchaseProject/Repurchase_BBAIA_merge_v1b.html)






## Errors in Edgar Filing: 
1. "0001564590-20-020599": Dual Class Share Firms: BERKSHIRE HATHAWAY INC (BRK-B, BRK-A) (CIK 0001067983);
2. ["0000950123-11-000744"](https://www.sec.gov/Archives/edgar/data/5133/000095012311000744/0000950123-11-000744.txt) : Dual Class and the Table is not well formatted; > Need to add another indicator `dualclass` with `regex = 'class'`.
3. ["0001020710-21-000094"](https://www.sec.gov/Archives/edgar/data/1020710/000102071021000094/0001020710-21-000094.txt) : **A threat to my story: (potentially driven by the start of the repurchase program)** > Need to double check by identifying the active program, program start and ending time. > While ["0000095052-13-000014.txt"](https://www.sec.gov/Archives/edgar/data/95052/000009505213000014/0000095052-13-000014.txt) may tell a different story that variation in the repurchase amount that is not at the beginning or end of the program or the extension time of the program.
4. ["0000831641-20-000154"](https://www.sec.gov/Archives/edgar/data/831641/000083164120000154/0000831641-20-000154.txt) : contains multiple tables and cannot be used correctly identified. > `CIK 0000831641`


| id | issue | Status | 
| :---:   | --- |  :---: |
| 0001193125-11-133527 | wrong month name in the period column  | 
| 0001193125-13-338522 | 21st century fox > no column "total number under the program"  | 
| 0000950123-11-019686 | gives the column name "Cumulative Shares Repurchased Under The Program" ; > map to `vars_id = 5`. | 
| 0001193125-11-050024 | wired first column  | 
| 0001193125-11-133527 | wrong unit info -> not in thousands  | 
| 0001193125-13-425259 | wrong units in all tables | 
| 0001193125-11-003706 | did not report for each month | 
| 0000318154-14-000004 | the total is given by the whole year rather than "total" |
| CIK: 1757898 | vars_id is incorrect | ✔️ | 
| 0001193125-11-084825 | the third column gives the cumulative number repurchased rather than the monthly repurchase amount. > CIK: 0001102238 |
| 0000950123-11-025185 | the last column is read twice -> 24.4 million$24.4 million | 
| 0001047469-11-004635 | many cells are repeated twice when use `html_table` > need to solve this, urgent! ! 
| [0000950123-11-025185](https://www.sec.gov/Archives/edgar/data/56679/000095012311025185/0000950123-11-025185.txt) | Column headers are in different rows and cells in the table. | 
| [0001144204-17-014104](https://www.sec.gov/Archives/edgar/data/1130144/000114420417014104/0001144204-17-014104.txt) | Need to transpose the table at first | Double Check! | 
| [0000950123-11-018714](https://www.sec.gov/Archives/edgar/data/917273/000095012311018714/0000950123-11-018714.txt) | Did not cover the full colname (e.g. return only "Average") | 
| [0001299709-11-000007](https://www.sec.gov/Archives/edgar/data/1299709/000129970911000007/0001299709-11-000007.txt) | Cumulative/Balance Rather than the monthly repurchase amount. THis issue seems to disappear afterwods. > `CIK 0001299709` | 
| [0001193125-20-307086](https://www.sec.gov/Archives/edgar/data/1145255/000119312520307086/0001193125-20-307086.txt) | Wired table, maybe caused by `header = F` in `html_table` function. | [Updated Cleaned File](https://github.com/hongyileoxu/hongyileoxu.github.io/blob/3971fa1dcf41da6f542e61aa3552b9e1999e54c6/research/RepurchaseProject/0001193125-20-307086_updated.txt) | 
| [0001144204-11-060090](https://www.sec.gov/Archives/edgar/data/1301611/000114420411060090/0001144204-11-060090.txt) | Several tables and only the last one is for the monthly repurchase amount | Cannot be solved | 
| [0000897101-11-000818](https://www.sec.gov/Archives/edgar/data/875355/000089710111000818/0000897101-11-000818.txt) | Multiple Tables and include different monthly info | Cannot be solved | 
| 0001047469-14-000555 | multiple over-headers | Unsolved | 










## Additional Data: 
1. [disclose firm-day social media sentiment and attention series from 2012-2021, drawn from the PC1 across Twitter, Seeking Alpha and StockTwits subgroups.](https://data.mendeley.com/datasets/xffyybvw4j/1) by Cookson et al. (2024) 


## Notes: 
1. This folder contains the code for the 2023 summer project.
2. A great source for the document: https://sraf.nd.edu/sec-edgar-data/cleaned-10x-files/
3. IV?: [monthly edgar filing numbers](https://www.sec.gov/about/sec-docket.shtml) -> EDGAR Company Filings Indexes: [Daily](https://www.sec.gov/Archives/edgar/daily-index/) and [Quarterly](https://www.sec.gov/Archives/edgar/full-index/)
4. Dataset: updated August 17, 2023 [[link]](https:/hongyileoxu.github.io/research/RepurchaseProject/ShaRep_AIA_merge_Aug17_2023.csv) / [[P0]](https:/hongyileoxu.github.io/research/RepurchaseProject/Repurchase_BBAIA_merge_v1b.html)






## Errors in Edgar Filing: 
1. "0001564590-20-020599": Dual Class Share Firms: BERKSHIRE HATHAWAY INC (BRK-B, BRK-A) (CIK 0001067983);
2. ["0000950123-11-000744"](https://www.sec.gov/Archives/edgar/data/5133/000095012311000744/0000950123-11-000744.txt) : Dual Class and the Table is not well formatted; > Need to add another indicator `dualclass` with `regex = 'class'`.
3. ["0001020710-21-000094"](https://www.sec.gov/Archives/edgar/data/1020710/000102071021000094/0001020710-21-000094.txt) : **A threat to my story: (potentially driven by the start of the repurchase program)** > Need to double check by identifying the active program, program start and ending time. > While ["0000095052-13-000014.txt"](https://www.sec.gov/Archives/edgar/data/95052/000009505213000014/0000095052-13-000014.txt) may tell a different story that variation in the repurchase amount that is not at the beginning or end of the program or the extension time of the program.
4. ["0000831641-20-000154"](https://www.sec.gov/Archives/edgar/data/831641/000083164120000154/0000831641-20-000154.txt) : contains multiple tables and cannot be used correctly identified. > `CIK 0000831641` also in filings: "0000831641-20-000012" etc.
5. "0001193125-11-091536" : report the full year monthly repurchase in 2010.
6. "0001193125-11-131657" : unregular headers > [Solved]
7. "0001104659-12-073995" : unregular headers > [Solved]
8. "0001193125-12-026335" : dual class shares and numbers are collapsed together. > Needs manual checking. 
9. ["UFP INDUSTRIES INC (UFPI) (CIK 0000912767)"](https://www.sec.gov/edgar/search/#/dateRange=custom&category=custom&ciks=0000912767&entityName=UFP%2520INDUSTRIES%2520INC%2520(UFPI)%2520(CIK%25200000912767)&startdt=2010-01-01&enddt=2023-08-18&forms=10-K%252C10-KT%252C10-Q%252C10-QT) : wired table format in which the header rows are not specified. 
10. Also, there exists filings with item called <span style="color: red;">"Item 1 to Item 6"</span> etc in the table of contents, which can not be identified in the current parsing function `filing.cleaned`. Has to be updated. (The CIK [`0000776867`](https://www.sec.gov/Archives/edgar/data/0000776867/000077686717000012/0000776867-17-000012-index.html).) 

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
| [0001299709-11-000007](https://www.sec.gov/Archives/edgar/data/1299709/000129970911000007/0001299709-11-000007.txt) | Cumulative/Balance Rather than the monthly repurchase amount. THis issue seems to disappear afterwods. > `CIK 0001299709` > Also, `0001299709-18-000040` did not report the repurchase amount for each month in the OMR. | I decide to equally divide the amount into the three months covered in the report. This way the effect will be attenuated, if it exists. |
| [0001193125-20-307086](https://www.sec.gov/Archives/edgar/data/1145255/000119312520307086/0001193125-20-307086.txt) | Wired table, maybe caused by `header = F` in `html_table` function. | [Updated Cleaned File](https://github.com/hongyileoxu/hongyileoxu.github.io/blob/3971fa1dcf41da6f542e61aa3552b9e1999e54c6/research/RepurchaseProject/0001193125-20-307086_updated.txt) | 
| [0001144204-11-060090](https://www.sec.gov/Archives/edgar/data/1301611/000114420411060090/0001144204-11-060090.txt) | Several tables and only the last one is for the monthly repurchase amount | Solved after updateing the `table.cleaned` function. | 
| [0000897101-11-000818](https://www.sec.gov/Archives/edgar/data/875355/000089710111000818/0000897101-11-000818.txt) | Multiple Tables and include different monthly info | Can be solved using the new  `filing.cleaned_multiple` function. | 
| 0001047469-14-000555 | multiple over-headers | Unsolved | 
| 0000914025-11-000013 | Check the number in this filing | 
| [0000950123-11-038128](https://www.sec.gov/Archives/edgar/data/48898/000095012311038128/0000950123-11-038128.txt) | DIfferent unit information in two columns and may not be captured. potential variations: `(000\u0092s); (in 000's); (000's); ($000) ; (000s)` | Solution: grepl(pattern = "\\((in\\s*|\\$)?0{3}", x = c("(000\u0092s)", "(in 000's)", "(000's)", "($000)","(000s)", "(in  000")) | 
| [0000950123-11-029301] | No value for the maximum amount | 
| [0001022408-11-000019] | Value = ` - (13)` > `regex = str_count(string = value, pattern = "\\d") > 2 | 
| [0000796343-11-000006] | negative value for the maximu amount > actually, the total cost of repurchase. | 
| [0000020212-12-000019] | wired period expression `4/1/12-4/30/2012` | 
| [0000020212-13-000039](https://www.sec.gov/Archives/edgar/data/20212/000002021213000039/0000020212-13-000039.txt) | Need to impute missing values (also in `0000020212-14-000034`) | manually checked. | 
| [0001084869-11-000004](https://www.sec.gov/Archives/edgar/data/1084869/000108486911000004/0001084869-11-000004.txt) | Meed to check again both the unit and column values | Manually corrected | 
| [0000310354-16-000097] | The dollar sign is missing for `vars_id == 4`. | 
| [0001564590-20-033611](https://www.sec.gov/Archives/edgar/data/110621/000156459020033611/0001564590-20-033611.txt) | Suspend the OMR in respone to the pandamic | 
| [0000920148-17-000018](https://www.sec.gov/Archives/edgar/data/0000920148/000092014817000018/0000920148-17-000018-index.html) | Unit is expressed in `(dollar amounts in millions)` in the text and many similar expression exists. | The unit identification regex needs to be updated (to be done!) | 
| [0001628280-15-007764](https://www.sec.gov/Archives/edgar/data/0001032033/000162828015007764/0001628280-15-007764-index.html) | The column. `3` is recorded even though no OMR at this stage. | Will. dilute the effect we find. |
| [0001437749-20-019622](https://www.sec.gov/Archives/edgar/data/0001084869/000143774920019622/0001437749-20-019622-index.html) | Wrong unit measure | manually corrected. 
| [0001193125-14-383437](https://www.sec.gov/Archives/edgar/data/320193/000119312514383437/0001193125-14-383437.txt) | Apple: unconventional unit info: (in millions, except number of shares, which are reflected in thousands, and per share amounts): | needs to update for all observations. | 
| [0001193125-14-157311](https://www.sec.gov/Archives/edgar/data/320193/000119312514157311/0001193125-14-157311-index.html) | Apple: March info is missing. | 





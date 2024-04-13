## Abstract

^1e9546

- Patents are pledged as collateral to raise significant debt financing, contributing to the financing of innovation.
- The pledgeability of patents plays a crucial role in financing innovation among public firms.
- Stronger creditor rights to patents can both increase collateral value and financing capacity, but may also discourage risk-taking.
- Empirical evidence from court decisions shows that strengthening creditor rights to patents leads to increased debt financing and investment in research and development (R&D).
- The increase in patent collateral value alleviates credit constraints for investment in R&D, leading to a subsequent increase in innovation output.
- The study highlights the importance of intangible assets, such as patents, in corporate finance and innovation, providing insights into the role of patents as collateral for financing innovative activities.

## Intro
- traditional thinking: moral hazard & adverse selection $\Rightarrow$ credit rationing $\Rightarrow$ underinvestment in R&D and an inefficient level of innovation. 
- finding: ==strong creditor rights can increase collateral value and thus financing capacity, but they can also discourage risk-taking by allocating more bargaining power to creditors in the event of financial distress==. 
- **Patents**: records from the United States Patent and Trademark Office (USPTO) on the use of patents as collateral, and examine the characteristics of patents used as collateral. 
	- Patents are more valuable in terms of high number of citation counts and generality. 
	- Patent pledging activities concentrate in a small set of high-tech firms. 
- **Identification**: increased patent collateral value via a strengthening of creditor rights. 
	- Delaware’s procreditor Asset-Backed Securities Facilitation Act (ABSFA). 
	- The court decisions thus represented a relative strengthening of creditor rights for patenting firms incorporated in Delaware. 
	- a ==difference-in-difference== that examines the evolution of financing and investment for Delaware- relative to non Delaware-incorporated firms around the dates of the four court decisions. 
- Findings： 
	- Treated firms increase their debt-to-asset ratio by roughly 4% (average debt-to-asset ratio is 0.27), or $25 million debt given the average book assets of $2.6 billion. $\Rightarrow$ This shows that stronger creditor protection in default increases the patent collateral value to creditors, thus facilitating firms’ financing. 
	- Treated firms also increase their R&D spending. 
	- ==**CapEx**==: a traditional measure of investment. **has no effect**. 
	- results for firms with different level of financial constraints: 
		1. the firms relying on patent collateral face significant financial constraints. 
		2. an increase in the collateral value of their important intangible assets increased their ability to raise capital and invest it. 
## Descriptive 
- Patents are used as collateral in low tangibility industries that are important to aggregate corporate research investment. 
	![[Pasted image 20240405141616.png]]
- Table 3 shows that companies pledging patents as collateral feature significantly higher total debt as a fraction of total assets. 
	![[Pasted image 20240405145320.png]]
- Figure 4A shows (1) a net increase in the debt-to-asset by 4% when the patents are pledged as collateral and (2) a reduction in cash holdings afterwards. While the Figure 4B shows that capex (measure for investments) does not impact by this and patent pledging activity, the R&D expense witnessed a sharp peak following the pledging. > ==suggesting that companies that are reliant on the collateral value of their intangible assets invest primarily in R&D==. 

## Identification
- cross-sectional variation in the creditor protection across different states: 
	- Delaware (stronger creditor rights) vs. Other States. 
	- However, direct DiD for Delaware firms versus Other firms is not credible: 
		1. Differences in other factors in the two states may be unobserved confounders. 
		2. the incorporation decision (in Delaware) is endogenous. 
		3. Law is applied to all assets, not only on the patents. 
	- address the issues by additional time-series variation in the perceived importance of state laws for the ownership of patents. 
	- Study the financing and investment decisions of Delaware-incorporated firms ==around these decision dates==. 
	- Overall, the evidence suggests that ==the court decisions elevated, nationwide, the perceived extent to which state property laws govern the ownership of patent collateral==. 
- To implement a difference-in-difference approach, I isolate an event window extending eight quarters before and after each court decision date. I extract all four of these event windows from the full panel, then “stack” them together and run a single regression. ![[Pasted image 20240408113151.png]]
	where i indexes firms, s indexes states of incorporation, k ∈ {1, 2, 3, 4} indexes court decisions and their associated 16-quarter windows, and q ∈ [−8, 8] indexes quarters in event time relative to the court decision date (q = 0) within a given window
### Results: 
- ![[Pasted image 20240408120755.png]]
	- Column (1): In the two-year window (*8 quarters*) after a decision date, total debt increased by an average of roughly 1% of total assets. & Column (3): ==The estimated effect for high-tech firms is consistent with, and in fact 40% larger than==, for the full sample, given that they normally have low tangibility and leverage and highly frequently patents pledging activities. 
	- Three interpretation of the results:  ^9e8d8d
		- the interpretation of these results is that creditors of Delaware-incorporated firms became increasingly confident in the speed and probability with which they could foreclose against patent collateral in the event of default. They therefore became willing to extend additional credit to borrowers who had previously borrowed up to their maximum willingness to lend. 
		- If patent collateral was not economically important, we would observe no effect at all. 
		- ==If the primary effect of strengthening creditor rights was instead on firms’ incentive to borrow, with credit constraints not playing a key role, we would observe a negative effect==. > see this: https://www.perplexity.ai/search/Given-this-paragraph-Yi6MkSRzRCGHQYBw2.KiGg#0 
			- Also as supporting evidence from past literature: > Previous empirical studies of creditor rights and innovation often reach the opposite conclusions to mine: Acharya and Subramanian (2009) and Seifert and Gonenc (2012) find lower rates of patenting and usage of secured debt by innovative industries in countries that have strong creditor rights or recently strengthened creditor rights. Acharya et al. (2011) demonstrate a negative relationship between creditor rights and firms’ willingness to take risks. Vig (2013) shows that firms used less secured debt, and invested more conservatively, in response to a strengthening of secured creditor rights in India. 
	- [ ] > ==*Better to look into long-term versus short-term debt. As in this argument and also the Hart and Moore (1994), an increase in the value of collateral should help firms get debts with longer maturity* ==. 

- ![[Pasted image 20240408130709.png]]
	- The impact of creditor protection also induces firms to take more R&D investment and the magnitude is particularly larger among high-tech firms. 
- ==**Lerner and Seru (2017) point out that, in empirical innovation research, regional differences in research and patenting activity can swamp the magnitude of any other desired comparison**==. 
### Heterogeneity
#### financial constraints 
![[Pasted image 20240408135730.png]]
#### IP portfolio 
![[Pasted image 20240408140215.png]]
- Using the same subsample, ==**column 3**== estimates a much larger effect on debt financing among the 9% of sample firms that had already pledged their patents as collateral in the USPTO data before the start of the event window: for these firms, the effect on debt financing is 4.7% of total assets, compared with roughly 1% for the rest of the sample. > ==This means that *past patent pledging record has a positive effect* on the lending relationship. We can potentially interpret this as a reputation effect==? 
- Q: what is the problem of right-truncation in the patent application number? 
	- A: ==That is the patent needs time to be assessed and granted and the near term growth of the patent numbers and patent citations, ***measured by data up to that point, only contain information about the already granted patents***, but not a large group of patents currently in application==. > This issue will be even more severe for citations. E.g. a very novel and important patent may not have enough citations only because it is not mature yet. 
	- [ ] *==One work around is to standardise patents citations by its granting year-tech space cohorts. In this way, the issue of ”young patents”/“right-truncation” can be avoided==*. > `[Key Idea!!!]` [[#^15e429|better patent citation measures]] 
- The author also find that 
> 	- This section (***Section 5.5***) demonstrates another corollary: firms that had not previously pledged their patents as collateral were increasingly likely to do so in response to their increased pledgeability. 
- The author knows that [[#^2c5483|New Idea!!!]]     
> 	- The results of this and the previous section, taken together, also suggest an intriguing feedback effect between debt capacity and investment: when the collateral value of patents increased, firms used them as collateral to produce more patents. ==The collateral value itself may have provided a marginal incentive to invest in patents as opposed to other forms of capital==. However, identifying and quantifying this mechanism would likely require a different empirical strategy than pursued in this paper, and I do not attempt it here.  
^e26ba7

## Personal Ideas
- [ ] If consider the human capital as an _inalienable_ asset in a corporation, can I see that patenting is a way to ==__convert it from an inalienable into an alienable__== asset? 
- [ ] Does the natural decay of the patent value affect their financing ability over time? -> ==`obsolescenec`== measure by Song Ma. 
- [ ] Copyrights should be important as well. > For softwares, e.g.. 
- [ ] It is difficult to measure ultimately unsuccessful patent applications at the firm level, as the applications are typically held in the inventor’s name until they are granted by the USPTO. > Thus, we need employee-employer matching data to do this. 
- [ ] Standardise the patent citation by ranking it or using Poisson distribution to standardise it. >  `[Key Idea!!!]` 
	- [ ] So, how to ==**standardise** a Poisson distributed variable==? 
- [ ] This channel is interesting and not being studied. Using the debt renegotiation or callable bonds, we can argue/study whether R&D provides the manager an incentive to reduce its cost of capital, instead of alleviating its debt overhang problem > [[#^9e8d8d|the three hypothetical theories]]. 
	- [ ] ~> Answer this question: [[#^e26ba7|Future research]].   ^2c5483
	- This idea says relative to tangible assets like machinery, whose value may depreciate over time, the role of patents may have a different identity being similar to land and property, which may become more valuable over time. 
- [ ] A first step may be to expand this study to EU and check its validity? 
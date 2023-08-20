# Notes:

- “The overall conclusion from our results is that firms should be regarded as large and patient investors when they buy back their own stock.” ([Hillert et al., 2016, p. 187](zotero://select/library/items/Z52BYGPS)) ([pdf](zotero://open-pdf/library/items/NLTNGQJT?page=2&annotation=P6GL3KHS))
- “a large literature seeks to understand whether firms provide or demand liquidity when they repurchase shares” ([Hillert et al., 2016, p. 186](zotero://select/library/items/Z52BYGPS)) ([pdf](zotero://open-pdf/library/items/NLTNGQJT?page=1&annotation=6YP2T9X5)) \> the key here is that whether the market thinks the sellers are selling for liquidity or information reason.
- “Following Foucault, Kadan, and Kandel (2005), we conceive of limit order markets as markets for immediacy, in which traders can either demand immediacy, e.g. through placing market orders, or supply immediacy through placing limit orders” ([Hillert et al., 2016, p. 187](zotero://select/library/items/Z52BYGPS)) ([pdf](zotero://open-pdf/library/items/NLTNGQJT?page=2&annotation=UPVD9Y3F)) (types of orders: market order, limit order and stop order)
- Data:
    
    - 2004 - 2010;
    - 10-Q and 10-K;
    - “Our data set covers 6,537 repurchase programs with an average (median) size of 6.59% (5.27%) of the firm's market capitalization.” ([Hillert et al., 2016, p. 187](zotero://select/library/items/Z52BYGPS)) ([pdf](zotero://open-pdf/library/items/NLTNGQJT?page=2&annotation=UERTS2GW))
    - also info on program characteristics > used for constructing instruments.
    - focus on “repurchases under previously announced repurchase programs” ([Hillert et al., 2016, p. 187](zotero://select/library/items/Z52BYGPS)) ([pdf](zotero://open-pdf/library/items/NLTNGQJT?page=2))
- Methods:
    
    - no contemporaneous controls;
    - firm and time fixed effects;
    - first instrument ***for repurchase***: size & the time that has elapsed since the inception of the program > for predicted share repurchase and does not relate to Y (the dynamic development of liquidity).
        
        - i.e. Y: liquidity
        - X: actual share repurchase
        - Z: the IV (size or time periods)
        - Z will affect X (potentially?), but Z will not directly influence Y.
        - ***It might be a bit questionable in my story.***
    - a second instrument ***for liquidity***: “median monthly trading volume of all firms that never undertake a repurchase” ([Hillert et al., 2016, p. 187](zotero://select/library/items/Z52BYGPS)) ([pdf](zotero://open-pdf/library/items/NLTNGQJT?page=2&annotation=T7W4IIVL)) or “lagged trading volume“
    - “The third instrument is the absolute difference between the” ([Hillert et al., 2016, p. 187](zotero://select/library/items/Z52BYGPS)) ([pdf](zotero://open-pdf/library/items/NLTNGQJT?page=2&annotation=MBQ7JZGP))
- Findings:
    
    - they hypothesis that “firms attempt to reduce their transaction costs and repurchase more shares when the market is more liquid” ([Hillert et al., 2016, p. 188](zotero://select/library/items/Z52BYGPS)) ([pdf](zotero://open-pdf/library/items/NLTNGQJT?page=3&annotation=7ZAEJBB3)) .
        
        - **surprisingly, they find support for both hypotheses !!!**.
        - actually, their findings do not contradict with my framework. In this one, their conjecture is that the cost of transaction is the main factor, while our framework does not predict the repurchase behavior in a specific period of the program. Our model is more a static rather than a dynamic version.
        - However, my model does not have that risk-averse component and actually indicates a drop in the repurchase amount when the market is more liquid for both a good and bad firm. Therefore, a risk shift can be interpreted as a change in $\omega$ in our framework. In our framework, we can definitely add in the transaction costs into the model, which is a cost function conditional on the market liquidity and the size of the actual repurchase. i.e. $f(\frac{1}{\lambda}, m)$ and check ([Brockman and Chung, 2001](zotero://select/library/items/FLGC6FY2)).  
    - “In addition, if firms are risk-averse and try to minimize price impact, they should spread their repurchases over time but front-load the execution of the program to the earlier months in the program.” ([Hillert et al., 2016, p. 188](zotero://select/library/items/Z52BYGPS)) ([pdf](zotero://open-pdf/library/items/NLTNGQJT?page=3))
        
        - **this one is hard to explain. why do they what to front-load the execution?**
    - “In our sample, repurchases provide even more liquidity on average when they are followed by higher abnormal stock returns around the filing date. Analyzing subsequent abnormal returns leads to a similar conclusion. This finding is inconsistent with the notion that information-based repurchases reduce market liquidity.” ([Hillert et al., 2016, p. 188](zotero://select/library/items/Z52BYGPS)) ([pdf](zotero://open-pdf/library/items/NLTNGQJT?page=3))
        
        - my framework can explain this. Simply as in this case, when there are other informed traders in the market, a bad firm will reduce their trading.
- # Data:
    
    - “(CRSP) to identify all ordinary shares (share codes 10 and 11) that are traded on the NYSE, Amex, and Nasdaq (exchange codes 1, 2, and 3), which gives us 6,504 firms over the period from January 2004 to December 2010” ([pdf](zotero://open-pdf/library/items/NLTNGQJT?page=4))
    - “extract the repurchase data from all 10-Q and 10-K filings between January 1, 2004 and March 31, 2011” ([pdf](zotero://open-pdf/library/items/NLTNGQJT?page=4))
    - “The average completion rates in our sample are 45.53%, 53.17%, and 59.31%, respectively, one, two, and three years after the beginning of the program.” ([pdf](zotero://open-pdf/library/items/NLTNGQJT?page=4)) … below numbers in the earlier literature.
    - “The final sample contains 6,150 firms. Of these, 2,930 firms have repurchase programs. We have 106,898 firm-months with an active program. Firms conduct share repurchases in 50,204 of these firm-months.” ([pdf](zotero://open-pdf/library/items/NLTNGQJT?page=5))
        
        - This is actually very surprising that in only half of these firm-months observations, we see an actual share repurchase. *This may actually be hard to explain in other frameworks*.

- maybe our paper should be called: “clean the house after blockholder’s exit“.
- a key point to link our framework with the empirical tests is a proxy for managerial myopia - one way is to use the CEO equity vesting amount.
    
    - a side note is that “blockholder exit” will be most efficient when the manager cares about his stock price - a higher managerial myopia actually makes such exit as a more powerful governing tool. Therefore, we definitely needs to control for this $\omega$ parameter.
- a key issue with their framework is that how do they know when to start a repurchase program? especially this paper finds that “they should spread their repurchases over time but front-load the execution of the program to the earlier months in the program.” ([pdf](zotero://open-pdf/library/items/NLTNGQJT?page=3))
- “The further a stock trades away from this assumed center of the trading range, in either direction, the less it is traded.” ([Hillert et al., 2016, p. 8](zotero://select/library/items/Z52BYGPS)) ([pdf](zotero://open-pdf/library/items/NLTNGQJT?page=8&annotation=MZPWB4WE)) Maybe you sing stock splits and instruments the identifying assumption exact the decision to make a stock splits will directly increase the liquid at the office stock, but it’s shit and not directly affect the share purchase behavior.
- “For example, a firm could disclose share repurchases executed in January by mid-May, when it files the 10-Q statement for the first quarter.” ([Hillert et al., 2016, p. 20](zotero://select/library/items/Z52BYGPS)) ([pdf](zotero://open-pdf/library/items/NLTNGQJT?page=20&annotation=EI59852F))
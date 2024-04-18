## Abstract
- The market for callable bonds growth quickly (35% (2000) $\rightarrow$ 89% (2020) in all newly issued corporate bonds). 
- Feature of callable bonds: high yield–low price combination is consistent with the argument that 
	1. the market compensates bond investors for the option  value embedded in callable instruments through higher yields at issue and 
	2. calls impose  a cap on bond prices after issue. 
- Authors propose that the important empirical role of call features can be best understood with a simple, coherent view of corporate debt, which stresses that ==call rights can improve investment incentives for firms==. 
	- Its role and connection with the patents. 
	- The conventional view of callable feature is an interest rate option (exercised when the interest rate drops) + bond. 
- ”credit view”: more on the change in the firm-specific credit condition. Versus the “interest-rate view”: on the change in the macro environment - the risk-free rate changes. 
	- Diamond and He (2014) show that callability reduces problems associated with debt overhang and that firm deci sions are shaped by the ability to call debt early. 
- [ ] #Findings : 
	1. Issuers are more likely to call  their bonds after issuer-specific credit improvements. 
	2. call rights reduce agency costs of debt. 
	3. callable bonds increase the likelihood that a firm will be the target of a bid and reduce  the merger gains that flow to target debtholders, consistent with a reduction of debt overhang from target debt. 
	4. callable debt plays an under-appreciated role  in reducing the agency costs associated with corporate leverage. 
## Data 
- bond data: Mergent Fixed Income Securities Database (Mergent FISD) 
- Call provision information and actions after bond issuance: FISD redemption table. 
- Collect data on the bond convertibles and covenants. & YTM in Mergent. 
- Type of callable bonds: 
	1. Fixed-price calls: callable at a fixed, predetermined price. 
	2. Make-whole calls: Bonds can also be callable with a ==“make-whole”== provision, which ***requires issuers to compensate bondholders for the maximum of the face value or the present value of lost coupons and principal discounted at market interest rates when calling***. > [for illustration!](https://www.investopedia.com/terms/m/make-wholecall.asp) 
		- make-whole bonds require issuers to compensate bondholders for the maximum of the face value or the present value of lost coupons and principal discounted at a prevailing interest rate, customarily given by a benchmark risk-free rate plus a fixed spread that is below the issuer’s credit spread. > meaning that the ==**make-whole callable bond will never below the market price**==. 
	3. Bonds can have both a make-whole and a fixed-price provision and such bonds constitute more than 50% of all bonds issued after 2010. 
	4. For bonds that have both make-whole and  fixed-price call provisions, ==we **classify them as (fixed-price) callable** if the period during which the fixed-price  call provision is active exceeds one year== (see data section). 
- use Mergent FISD tables to identify which bonds are alive—that  is, not matured, restructured, called, converted, or otherwise ended—at any given point. 
- **secondary market bond prices** from TRACE. 
- **bond credit ratings** from Mergent FISD. 
- **treasury yields** and **credit spreads** from the FRED database. 
- **call decisions** based on action variables in Mergent FISD, as well as the redemption file. 
- time horizon: Jan 1980 - Dec 2017. 
- ==M&A sample== consists of all completed merger and acquisition deals in Thomson  Financial’s SDC Database. & the targets need to be public firms. 
- To ==identify investment opportunity shocks==, we use ***annual price changes of intermediate inputs for each industry*** (see Dasgupta, Li, and Yan 2018 for details). **A decrease in input prices  is a positive shock to investment opportunities**. 
	- [ ] However, a decrease in the input price may have two opposing effects. On the one hand, it reduces the cost of production for incumbents in the industry and increases their profit margin. This forces will incentivise firms to expand their economic of scale and invest more. `The positive effect!` On the other hand, it may lead to more fierce market competition, given firms now can reduce their product price in exchange for a larger market share. The impact of the second force may be hard to determine. Although they may choose to invest to expand their economic of scope, instead of scale, they may also choose to have some cartels and limit their investments. 

## Credit quality and callable bonds
- High-Yield  (HY) bonds of all maturities are typically callable. 
	- [ ] Q: Why does the adverse selection problem not present in the callable bonds issuance? In other words, the credit rationing problem? The callable bond seems to be a more inferior financial contract than the traditional bond contract. 
	- [ ] [!!!] Study the role of patents in the debt financing with callable bonds is a very unique and nice setting ==as the only role of patent in this place is its value of future cash flow generation to the managers and shareholders==. ***Its collateral value is not studied*** and it will be a particularly nice setting. 
- Call features are more important for riskier issuers, who have worse credit ratings and suffer more from debt overhang. 
- Changes in **issuer credit ratings**, **market leverage** and **secondary market bond price** all statistically and economically significantly predict the call action. 
- Call provisions limit the potential upside for bondholders and this presents in the price distribution of the call option. 
- For the same issuer, callable bonds are issued with higher yields but are quickly called when their secondary market prices rise. > Since callable bonds do not provide their holders the same upside potential as non-callable bonds, which ==serves as the financial mechanism for why they mitigate debt overhang==. 
	- Arguably, they can get a bigger and better loan to finance their additional investment and bypass the debt overhang in the previous scenario. 

## Model on callable bonds 
- credit view of callable bonds: callable bonds improve investment incentives  by reducing ex-post debt overhang. 
- study the effect of **callability** and **debt overhang** in **corporate takeovers**. 
	- takeovers are seen as ==“credit positive” for target debtholders==. Conditional on the acquirers usually are larger and financially stronger than the target, the target debtholders become the acquirer’s creditor and thus receives a positive shock. 
	- this is a wealth transfer from acquirer’s shareholders to the target debtholders. 
- [ ] ==Wrong setup in P12== - $D \in (C_L. C_H)$ . 
- the synergy from the merger towards the target is $\delta > D - c_L$, which is large enough to cover the target’s debt liability. 
- ![[Pasted image 20240411151010.png]]

## Empirical Evidence 
- Using the corporate merger as an exogenous shock to the bond investors, authors identifies the change in value between callable and non-callable bonds. 
	- target  bond announcement returns are most sensitive to bond callability in deals in which the acquirer has an IG rating and the target has an HY rating。 
	- ![[Pasted image 20240411210022.png]]
- Firms with callable debt are more likely to be targets of acquisitions. 
	- ![[Pasted image 20240411211738.png]]
	- concerns of causality: the proportion of callable bonds issued by the firm is an endogenous choice, which depends on the scope of future debt overhang, there may exist unobserved confouders threatening the causal interpretation. > New identification strategy! 
	- [ ] Why the callable bond is attractive? 
		- [ ] For a given lender and assume that the actual default prob of the bond is minimum, entering into a callable bond contract grants the lender a higher coupon payment, which should be attractive and they can always walk away before the first call date. 
	- the argument is that ==the initially set call protection period== is possibly exogenous to the exact call time by the firm. 
		- Just-callable (just pass the first call date) vs. not-yet callable. 
		- assign to the “Callable” group those firm–year observations where some  bonds have passed the first call date. 
		- Use matching. 
		- Column 1 of Table 9 shows that firms in the “treated group” (firms whose bonds have  become callable) have 2.0 percentage points higher probability of becoming acquisition targets after the entire stock of their outstanding bonds become callable, which corresponds  to a 57 percent increase in the probability of being taken over. Even if acquisitions are happening before the first call date, it only lead to an underestimation of the treatment effect (i.e. the true treatment effect may be larger.) 
		- Thus, show that callable bonds facilitate takeovers. 
- Evidence from deregulation
	- Prior studies use the deregulation list in Viscusi, Harrington, and Vernon (2005). The list was recently updated in Viscusi, Harrington, and Vernon (2018) to reflect events that occurred from 2002 to 2018. The list is presented in Table A.3. 
	- firms with more callable bonds prior to deregulation events have a significantly higher probability of being targeted in the post-deregulation window. 
- Evidence from the placebo: make-whole callable bonds 
	- the strike price of make-whole bonds will virtually never be below the market value. & educed issuer credit risk or a general credit spread compression will not trigger issuers to exercise their make-whole provisions. 
		- As once these information is priced into the market, it is suboptimal to call back bonds with make-whole provisions. 
		- However, it can still be argued that the information asymmetry causes the manager knowing things that the market does not know. Thus it will still be favorable for the manager to call back those bonds.  
		- [ ] [!!!]==Can we use information asymmetry from the equity market to infer its impact on the debt side?==
	- authors conjecture that make-whole bonds are not likely to impact debt overhang. 

## Capital Investment and Payout 
- the assumption in the literature is that a decline in the intermediate input price will make the investment more profitable. > In other words, the timing of the treatment, i.e. the debts become callable, is unrelated to the investment opportunities. 
- Find that firms with more callable bonds are willing to invest more when experiencing favorable investment opportunities. 
	- The callable bond can further increase the payoff to the shareholders in the upside by granting them the right to exercise the option ex-post. This resolves/mitigates the underinvestment problem from debt overhang and risk-shifting from the investment.
- also less payout when the investment opportunity arises for firms with (more) active callable bonds. 
- [ ] #concern What if callable bonds only present as a signal that the firm is in good quality? however, the reality that bonds are not called back means that *the manager might be incompetent*. Therefore, these firms, still having a large amount of callable debt outstanding, are more likely to be acquired. The subsequent investment $\uparrow$  & payout $\downarrow$ may also be the result of mismanagement. 
	- [ ] So, I conjecture that some time-varying top management behavior may be the unobserved confounders in this relationship. Also, investment inputs and outputs are two distinct aspects and should also be studied. 


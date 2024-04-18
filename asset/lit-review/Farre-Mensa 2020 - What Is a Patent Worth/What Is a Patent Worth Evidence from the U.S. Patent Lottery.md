Farre-Mensa, J., Hegde, D., Ljungqvist, A., 2020. What Is a Patent Worth? Evidence from the U.S. Patent “Lottery.” The Journal of Finance 75, 639–682. [https://doi.org/10.1111/jofi.12867](https://doi.org/10.1111/jofi.12867) 

## Intro
- benefits of patents: 
	- deterring copycats 
	- defensive shields in litigations. 
	- bargaining chips in licensing negotiations 
	- signaling devices to attract investors and customers 
- cost of patenting process
	- patents are abused
	- costly enforcement process 
	- deter future outside innovation by imposing a tax on e.g. derivative innovations. 
- The value of a patent is ==the incremental economic benefit accruing to its holder from the legal right to exclude others from exploiting the invention, beyond what would be earned if the invention were not granted a patent==.
	- two parts: (1) the direct benefit/ economic value of the invention (intrinsic value before the patent being granted) and (2) the incremental value from the exclusive ownership (may *link to exploitation and competition*?). 
	- more succinctly, the value of the underlying invention and the (incremental) value attached to the right itself. 
	- separating the two parts is challenging. 
- Contribution: 
	- data on all patent grants and rejections from USPTO: this can help separate three cases of firms lack of patents $\rightarrow$ 
		1. did not apply for patent in the first place; 
		2. applied but denied; 
		3. protect inventions in other ways (e.g. [trade secrets](https://www.law.com/2022/05/12/choosing-between-trade-secret-and-patent-protection-a-primer-for-businesses/?slreturn=20240314050109)). 
	- disentangle the value of a patent from that of the underlying invention. 
	- the IV approach: based on two features of the patent application process
		1. applications are randomly assigned to examiners. 
		2. examiners have different propensity to approve applications. (leniency)
		3. the success of the application is **==a *quasi-random process* that applicants with more lenient examiners are more likely to win==**. 
- #Findings Findings: 
	- The first-time applicants who won patent lottery observe a large growth in future employment, sales and subsequent number and quality of patents. 
	- However, winning the subsequent patents have much less obvious benefits and the effect is not as larger as that from the first patent. 
	- study the funding channel of the economic value brought by patents, dissecting the direct economic value and the incremental value from the patent. 
		- Empirically, we find that the first patent increases a startup’s  chances of securing funding from *venture capitalists (VCs) over the next three years* by ==47%==, of securing *a loan by pledging the patent as collateral* by ==76%==, and of raising funding from *public investors through an IPO* by ==128%==. 
		- The first patent can be used to signal its quality in the fundraising stage and reduce the information asymmetry. However, this positive impact does not presence on the second patent application. 
		- **Patents facilitate startups’ access to external finance in contexts in which information frictions, and thus contractual hazards, are especially high**. 
	- [[#^important-2sls|How to interpret the causal effect from 2SLS]]. 
	- [[#^important-patentpledge|Even failed or pending patent applications can be pledged as collateral. WOW!]]  

## Institutional detail and data 
- Process: applicant/application $\rightarrow$ art unit $\rightarrow$ examiners $\rightarrow$ decision. 
- main argument: the matching of application to examiner is orthogonal to the quality of the application or the applicant. 
	- first-action decision: After receiving an assignment, the examiner evaluates the application and makes ==a preliminary ruling on its validity==, which is sent to he applicant.  
	- three time stamps: the filing date, the first-action date, and the ***final-decision date***. $\Rightarrow$ [**choice of starting point of measuring firm outcomes**] !!!
		>Our choice of starting point is guided by two considerations: how uncertainty about the patentability of a startup’s invention evolves over time, and from what point the startup’s behavior could affect the timing of the USPTO’s decision. Resolution of uncertainty is necessary but not sufficient for a patent application to affect firm outcomes. Endogenous timing of the final approval decision may contaminate our causal estimates.
		- the time before the first-action date does not resolve any related uncertainty. 
		- The timing of the final decision is likely endogenous. $\rightarrow$ that is if the applicant chooses to appeal. 
		- Thus, it is appropriate to use the "first-action date" as the starting point. 
- Data: patent data directly from the USPTO’s internal databases for both approved and rejected patent applications going back to 1976. 
	- Because of missing applicants names before the enactment of the American Inventors Protection Act, sample starts in 2001. 
	- 



## Empirical strategy 
- IV: examiner leniency 
	- the approval rate of examiner $j$ belonging to art unit $a$ and assigned to review startup $i$’s patent application submitted at time $\tau$ . 
- 2SLS 
	- Table II, column (1), reports the first stage of our 2SLS specification, that is,
	$$
	\text { Patent approval }_{i j a t}=\theta \text { Examiner approval rate }_{i j a \tau}+\Pi X_{i j a t}+v_{a \tau}+u_{i j a t} . \quad (3)
	$$
	- ==relevance== (a strong predictor in the first stage) & not subject to ==weak-instrument bias== (F stat > 10). 
- identification threats: 
	- exclusion restriction: $[\checkmark]$  
	- unobserved confounders. > potentially if the characteristics of the application, the applicant, or the examiner influenced assignment. 
		1. a validation test of quasi-random assignment proposed by Righi and Simcoe (2017). > under the null of quasi-random assignment, the first-stage coefficient estimate of $\theta$ in equation (3) should be invariant to the inclusion of controls for application, applicant, or examiner characteristics. 
- ![[Pasted image 20240415105306.png]] 
## Results 
- Differences over one to five years ![[Pasted image 20240415105405.png]]
	- The positive results for startups following a successful first patent application is unsurprising, as the R&D process for the startup is different from that in the mature firms. The time filing the patent application can be seen as a transition time that the focus of the firm shifts to the product development and advertising. The success of patent application definitely will be a strong endorsement for its following growth in all aspects. 
	- Relatively, the impact of first-patent application success has limited/modest effect on the extensive margin of a firm's survival from Panel C in Table III. > This shows that the a lot of other factors determine the future success of a startup. 
	- Potential confounder of "Review Speed": follow follow Hegde, Ljungqvist and Raj (2019) and instrument "review speed" using ==a measure of administrative delays==. The time it takes to receive the first-action decision can be decomposed into the review assignment time and the application examination time. Authors argue that the first period, the quasi-random administrative delay, is unrelated to the invention quality or application complexity. Thus should be viewed as exogenous in the review speed. 
		- Specifically, we ==instrument review speed== (for applicant $i$, at examiner $j$ , etc. ) using the *sum of the time an application takes from filing to being assigned to an examiner’s docket and the average time that the examiner has taken in the past from docket to first action*.  
- the effects of subsequent patent applications 
	- the second approved patent has limited to none effect on the startup's subsequent employment and sales. 
	- has some positive effects on its follow-on innovation, measured by the # applications, the # approved patents, the application success rate, and the total # citations, but *not on the average citations to future patents*. > B/c the right truncation, the average citation may not be that matter. 
	- for ==follow-on innovation==, the average sample startup submits its next patent application 1.5 years after first-action on its first application. 
- these evidence suggests that the benefits startups derive from obtaining patent grants (over and above the benefits they derive from the underlying inventions) change over time. 
- ==**External Validity**== (Part E)
	- The population: 
		- The extremely bad units: applications fail the legal patenting standards will always be rejected. > [Never-takers]
		- The extremely good units: applications that are exceptionally good and will always be approved. > [Always-takers] 
		- the [compliers] here are the subpopulation of interests, whose claims are open to disagreement. 
		- although authors argue that [defiers] should not be there. 
	- ==the 2SLS estimates is the local ATE (LATE) and should not be generalized to the average startup==. ^important-2sls
		- smaller treatment effects among never-takers and always-takers than the compliers. 
		- thus for the whole population, i.e. compliers + never-takers + always-takers (+ defiers), the ATE should be smaller than the LATE estimated here. 

## Drivers for the real effects of patents 
establish the causal link between patent grants and access to (three sources of) capital. 
- three sources of capital: 
	1. VC funding 
	2. IPO
	3. a loan obtained by pledging a patent or patent application as collateral > ==even patent application can be a collateral?== 
- winning the patent lottery facilitates the startup to quickly raise VC funding. 
	- This timing fits our conjectured mechanism well: startups first use patent grants to raise external capital; they then use the capital to fund investments in operations and marketing to turn their patented ideas into new products and processes that subsequently yield increases in sales. 

 > As Hochberg, Serrano, and Ziedonis (2018) and Mann (2018) document, firms frequently pledge their patent rights as collateral for loans obtained from banks or specialized patent lenders. ==What is less well known is that firms can also **pledge pending patent** applications (after first action but before final approval) and **even rejected patent applications**==. ^important-patentpledge
- Table VIII, Panel A, shows that startups whose first patent application is approved ==are 8.6 percentage points (p < 0.001) more likely to pledge that application as collateral== than startups whose first application is rejected, an increase of 119% over the unconditional sample probability of 7.2%. 
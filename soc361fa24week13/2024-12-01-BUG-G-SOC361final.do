//INTRO + preliminary tasks

capture log close
cd "U:\SOC 361\Paper"
log using GJMBur361final.txt, replace
// program: Proxy class model
// task: Gauge the relative effects of class, status,
// race and gender on income 
// author: Griffin JM Bur 

// program setup
version 14
clear all
set linesize 80
macro drop _all
set more off

// loading data
// source: GSS 2012
cd "U:\SOC 361\Paper"
use "U:\SOC 361\Paper\GSS2012.dta" 

//==========================

// PART I: creating a scale for proxy class: selecting 
// variables and deleting missing values

	// I.i: subjective class ranking
	
	codebook class
	// this is a measure of the way that respondents rank
	// themselves in terms of their class--seems like it might
	// be useful *as one part* of a scale that
	// aims at a more objective measure of class

	keep if class < 8
	// getting rid of some missing values
	
	codebook class
	// checking work
	
	//I.ii: ignored at work
	
	codebook ignorwk
	// this is a Likert-type measure of how often respondents 
	// feel ignored at work 
	// again, seems like this would track pretty 
	// well to class for obvious reasons
	
	keep if ignorwk <5
	//dropping missing values
	
	codebook ignorwk
	//checking work

	// I.iii: put down at work
	
	codebook putdown
	// this is a Likert-type measure of how often 
	// respondents feel ignored at work
	// it is similar to the last item but helps us
	// zero in on a "type"
	
	keep if putdown < 5
	// deleting missing values

	// I.iv: financial satisifaction
	
	codebook satfin
	// this is a measure of satisifed respondents are with 
	// their financial situation
	// while in some ways we might think this is an obvious
	// derivative function of income, it can also be an index
	// for the "class consciousness" of respondents.some people 
	// with low incomes who are, say, dependents, or have a small 
	// trust as their primary form of income may feel less
	// exploited than relatively well-paid longshore workers, 
	// for example.
	keep if satfin<4
	
	//I.v: relative financial position

	codebook finrela 
	// this asks respondents to rank their family income 
	// relative to their perception of the income of other 
	// families--a useful proxy for r's subjective
	// sense of their *relative* class position
	keep if finrela<6
	// dropping missing values

	// I.vi: unjustly denied raises
	
	codebook denyrais 
	// this asks respondents to indicate if, and how often, 
	// they've ever been denied a raise at work--this is a 
	// very rough measure of class but I am again working
	// off of the hypothesis that general unhappiness at work
	// might correspond to a sense of lower-class-ness
	keep if denyrais<5
	//dropping missing values

	//I.xi: shouted at during work
	
	codebook shout
	// this asks respondents to rank how often they are shouted at
	// at work--a good indicator of a low position in the workplace
	// hierarchy. Nb that there are no missing values here
	tab shout, missing
	// confirming that there are no missing mvalues

	// I.xii: others are rude to r at work 
	
	codebook rudewk
	// This asks how often respondents feel that they
	// are treated rudely at work seems good for our 
	// scale--and, no missing values
	
	codebook wksub
	keep if wksub <3
	
	// I.xiii: does r supervise others at work
	
	// At this point I'm going to have to stop
	// adding commentary -- there will simply be 
	// too many items to comment on.
	codebook wksubs 
	keep if wksubs < 5
	
	// I.xiv: does r's supervisor care?
	codebook supcares
	keep if supcares <5
	
	
	// I.xv: Does r or r's spouse supervise
	// people at work?
	codebook wksup
	keep if wksup <3
	
	// I.xvi: Are relations good between
	// bosses and employees at r's firm?
	codebook bossemps
	keep if bossemps < 6
	
	
	// I.xvii: Are some people held to 
	// different stanards at r's work? 
	codebook difstand
	keep if difstand <5
	
	// I.xviii: Do people ever throw
	// things at r when they are upset
	// with r at work?
	
	codebook actupset
	tab actupset, missing
	
	// I.xix: Is r satisified with r's
	// financial situation?
	
	codebook satfin
	tab satfin, missing
	
	// I.xx: Is r generally satisfied with
	// r's job?
	
	codebook satjob
	keep if satjob <5
	
	// I.xi: Do others take credit for
	// r's work and or ideas in the
	// workplace?
	
	codebook othcredt
	tab othcredt, missing
	
// It is time to check the alpha.	

alpha wksup class shout ignorwk denyrais putdown ///
finrela satjob7 jobsecok supcares bossemps ///
difstand actupset satfin satjob othcredt rudewk

// This alpha looks pretty decent--time to create the scale.
alpha wksup class shout ignorwk denyrais putdown ///
finrela satjob7 jobsecok supcares bossemps difstand ///
actupset satfin satjob othcredt rudewk, ///
gen(proxyclass)

// Let's see what the scale item looks like.
hist proxyclass
sum proxyclass, detail
// It's a little left-skewed, perhaps the opposite of 
// what we'd think--but normal enough, which is good. 
// no negative values or extreme outliers, so it's time 
// to move on to the other variables.


// Since the values of the scale are not intrinsically
// meaningful, I standardize
// the scale by dividing it by its standard deviation

gen stdproxyclass = proxyclass / .411

//==========================
// PART II: Generating some control variables and 
// recoding other non-scale items

	// II.i: Gender
	
	// Now I make a dummy with women as the reference category
	gen gender = sex - 1
	
	// I check my work 
	tab sex gender
	
	// II.ii: Race
	
	// I begin by checking out the race variable--I
	// notice it does not include
	// many catgories. on a tip from John A Logan,
	// I looked at the "hispanic" variable
	codebook race
	codebook hispanic
	// GSS 2012 codebook commands are not very helpful--I ended up
	// consulting the actual codebook to find out what values 
	// meant what on "hispanic"
	

	// I generate a dummy for Black individuals.
	gen Black = 1 if race == 2
	replace Black = 0 if race ~=2

	// I also generate a new variable for Hispanic
	// respondents
	gen Hispanic =1 if hispanic ~=1
	replace Hispanic = 0 if hispanic == 1
	
	// I check for overlap with Black respondents.
	tab Black Hispanic
	
	// We do have some overlapping categories 
	// here--some people code themselves as Black 
	// and Hispanic. Since race as a social relation
	// operates according to a "one-drop" 
	// rule in the US, we'll go ahead and code
	// the eight overlapping cases as "Black" since they will 
	// almost certainly be "socially coded" in this way.
	
	replace Hispanic = 0 if Black ==1 & Hispanic ==1
	
	// I double check my work.
	tab Black Hispanic
	// Good--we have no one with a "1" value on both
	// Black and Hispanic.
	
	// Now I generate a dummy for white respondents.
	// We won't actually need to use this in a regression 
	// since I plan to use white as the reference category
	// but we do need to check and see if there is an overlap 
	// between white and Hispanic respondents.

	gen white =1 if race ==1		
	replace white = 0 if race ~=1
	
	// It's time to check this variable for overlap
	// with respondents who self-identify as Hispanic
	tab white Hispanic
	// So, there is quite a bit of overlap. Here the social 
	// scientist faces a problem: how do we code people without
	// "racializing" them ourselves?
	
	// As I explain in the paper, social theory tells me
	// that white Hispanics probably benefit from "whiteness" 
	// so I elect to make white Hispanics "white" in my schema.
	replace white = 0 if Hispanic ==1 & white ==1
	
	// I check my work.
	tab white Hispanic
	//Looks good -- no overlap.
	
	// Now we have to create a dummy for people who
	// answered that their race was neither Black nor white.
	// I believe that we would run the risk of reifying race
	// as a social construct if we went in and created dummies
	// for each other race--there is simply too much heterogeneity.
	gen otherrace =1 if race ==3
	replace otherrace = 0 if race ~=3

	// I again look for overlap.
	tab otherrace Hispanic
	// It turns out that there is a lot of overlap here,
	// too, since the GSS method of coding is far from ideal.
	// To try to make the "other" category as small as possible
	// since it is so unsatisfactory, I assign all of the 
	// overlapping individuals to "Hispanic".
	
	// I also code a factor variable for convenience 
	// of use later on.
	replace otherrace = 0 if otherrace ==1 & Hispanic ==1
	gen racenew = 0 if white == 1
	replace racenew = 1 if Black == 1
	replace racenew = 2 if Hispanic ==1
	replace racenew =3 if otherrace == 1

	//II.iii: Education

	// I check out the education variable.
	codebook educ
	sum educ, detail
	hist educ

	// The data doesn't look too bad. It is a little uneven,
	// which makes sense for an ordinal variable with 
	// certain "silos" into which individuals fall--12, 16,
	// 20. It is otherwise normal.

	tab educ, missing 
	// And, after checking for missing data, it appears
	// that there are none.
	
	//II.iv
	
	// Finally, we generate the new response variable with topcat.
	topcat rincom06, gen(TCrinc)
	
	// I check for missing values.
	tab TCrinc, missing
	// There *are* a number of missing values here, so 
	// we drop those cases.
	keep if TCrinc ~=.
	
	// I divide by 1000 and generate a new variable
	// for ease of interpretation.
	gen topcatincome = TCrinc/1000
	
//==========================
// PART III: specifying models and running regressions

	// Part III.i: the basic race model 
	
	//I start with a basic race and income model for reference.
	reg topcatincome Black Hispanic otherrace
	outreg2 using paperRD1, excel replace title("imputed income") ///
	ctitle(Model 1) 
	// At this point all of the estimators are statistically significant,
	// but the R-squared is awfully low.
	
	// Though it's not especially germane
	// to my purposes, we might as well test
	// the included coefficients
	
	test Black = Hispanic
	test Black = otherrace
	test Hispanic = otherrace
	
	// The only surprising -- although not 
	// *that* surprising -- result is that
	// the coefficient estimates for Black 
	// and Hispanic respondents is not
	// statistically different. 

	// Part III.ii: the race and gender model 
	
	// Now I add in gender to see what this does to the basic
	// race model.
	reg topcatincome Black Hispanic otherrace gender
	outreg2 using paperRD1, excel append title("imputed income") ///
	ctitle(Model 2)
	// Gender is clearly significant at this stage, and the R-squared
	// has increased to about eight percent. 
	
	// I again test the included categories.
	test Black = Hispanic
	test Black = otherrace
	test Hispanic = otherrace
	
	// Part III.iii: the race, gender and education model 
	
	// Now I add in the continuous education model. 
	reg topcatincome Black Hispanic otherrace gender educ
	outreg2 using paperRD1, excel append title("imputed income") ///
	ctitle(Model 3)
	//Unsurprisingly, education is very significant in its own right. 
	//Perhaps more surprisingly, it also makes each race estimator 
	//insignificant, although gender is still significant. 
	//The R-squared increases substantially. 
	
	// Part III.iv: the race, gender, education and class model 

	//Finally, I put my measure of class in.
	reg topcatincome Black Hispanic otherrace gender educ stdproxyclass
	outreg2 using paperRD1, excel append title ("imputed income") /// 
	ctitle (Model 4)
	// Class is clearly significant, although it does not add 
	//much to the explanatory power of the model. 
	
	// For full analysis, let's test whether or not
	// a standard deviation of education and a standard 
	// deviation of class differ statistically.
	
	// First I remind myself of what education's
	// standard deviation is.
	
	sum educ, detail
	
	// Now I generate the new variable.
	
	gen stdeduc = educ/3.02
	
	// Now I perform the regression.
	reg topcatincome Black Hispanic otherrace gender ///
	stdeduc stdproxyclass

	test stdeduc = stdproxyclass
	

//PART IV: some non-linear specifications of the model
		
		//Part IV.i: a non-linear model of education
		
		// Part IV.i.a: creating the dummy variables for education
		// First, I decided to create a non-continuous/"dummied up"
		// education variable.
		gen lessthanHSed = 1 if educ<12
		replace lessthanHSed = 0 if educ>=12
		
		gen HSed = 1 if educ ==12
		replace HSed = 0 if educ ~=12
		
		gen somecollege = 1 if educ>12 & educ<16
		replace somecollege = 0 if educ<=12 | educ>=16
		
		gen BA = 1 if educ == 16
		replace BA = 0 if educ ~=16
		
		gen postgrad = 1 if educ >16
		replace postgrad = 0 if educ <=16
		
		// Now we can perform a regression with these variables.
		reg topcatincome gender ///
		HSed somecollege BA postgrad stdproxyclass
		
		// It looks like our R-squared has improved from Model 4; 
		// since the outcome variable is in the same units the 
		// R-squareds are directly comparable--good news.
		
		// Plus, as shown directly below a general linear 
		// F-test of the null hypothesis that the change in
		// Y between continguous dummies is the same gives 
		// us evidence for rejecting the null. 
		
		test HSed = somecollege - HSed = BA - somecollege ///
		= postgrad - BA
		
		// I export the results
		
		outreg2 using nonlinearmodels , excel replace title /// 
		("imputed income") ctitle (full model with non-linear ed.)
		
		// Part IV.i.b: representing this non-linearity visually
		
		// I now use factor coding and the margins commands
		// for ease of coding.
		
		// First I recreate the education dummies 
		// using factor coding.
		
		gen categed = 0 if educ >=1 & educ <12
		replace categed = 1 if educ == 12
		replace categed = 2 if ed>12 & ed<16
		replace categed = 3 if educ == 16
		replace categed = 4 if educ >16
		
		// Now I run the regression, using 
		// no high-school education as the 
		// excluded category
		
		// As John A. Logan pointed out to me, this
		// is not a particularly convinced excluded
		// category but I thought I would show it
		// to have a visual representation of the 
		// benefits of completing high school.
		
		// It also helps make the regression output
		// less awkward -- having just one column 
		// is not ideal. 
		reg topcatincome gender i.categed stdproxyclass
		
		// I now export the output.
		outreg2 using nonlinears, excel replace ///
		title ("imputed income") ctitle ///
		(Model V)
		
		// For comparison I re-rerun the model
		// with a high school education as the 
		// excluded category 
		reg topcatincome gender b1.categed stdproxyclass
		
		// I now export the output.
		outreg2 using nonlinears, excel append ///
		title ("imputed income") ctitle ///
		(Model VI)
		
		// Maybe it is now time to generate a new
		// education variable to take account of
		// the fact that there is no statistically
		// significant differene between 
		// a HS ed and "some college"
		
		gen newcateged = 0 if educ >=1 & educ <12
		replace newcateged = 1 if educ >= 12 & educ <16
		replace newcateged = 2 if educ == 16
		replace newcateged = 3 if educ >16

		reg topcatincome gender b1.newcateged stdproxyclass
		
		// Hmmm...the R-squared actually went down slightly. 
		// Perhaps it is best to keep the original model.
		
		outreg2 using nonlinears, excel append ///
		title ("imputed income") ctitle ///
		(Model VII)
	
		//Part IV.ii: a logged-income model
		
		// First, I generate a logged version of income and perform
		// a regression with it.
		gen logincome = ln(topcatincome)
		
		// Now I test out model VI from before 
		reg logincome gender b1.categed stdproxyclass
		
		// Following Gordon, I save the predicted values and residuals 
		// from this natural log model.
		predict logYhat
		predict logResid, residuals
		
		// Next, I exponentiate both the Y-hats and the residuals 
		// in order to get their non-log values.
		generate explogYhat=exp(logYhat)
		generate explogResid=exp(logResid)
		
		// Finally, I regress the natural units on the exponentiated
		// Y-hats.
		reg TCrinc explogYhat
		
		// Comparing the R-squared with the R-squared from 
		// III.ii.a, it looks like the log-lin model 
		// is slightly better.
		
		// So, from here on out we will use logged income.
		
		// Now I export that last model.
		reg logincome gender b1.categed stdproxyclass
		outreg2 using nonlinears, excel append ///
		title ("imputed income") ctitle ///
		(Model VIII)
				
//==============
// PART V: including interactions
		// Now it's time to generate some interaction terms.		
		// I begin with gender and education.
		reg logincome i.gender b1.categed stdproxyclass ///
		gender##categed
		// This turns out not to be significant. Below
		// I export the results
		outreg2 using interactions, excel replace title /// 
		("imputed income (logged)") ctitle ///
		(gender and education)
		
		// Just for fun, let's try using the old polytomous
		// "educ" category and an interaction term
		// between that and gender
		gen womensed = gender*educ
		reg logincome i.gender educ stdproxyclass womensed
		// Still not getting anywhere. 
		
		// Next it's on to class and gender. 
		gen WCwomen = gender*stdproxyclass
		reg logincome i.gender b1.categed ///
		stdproxyclass WCwomen
		// Nothing of interest here. I export the results below.
		
		outreg2 using interactions, excel append title /// 
		("imputed income (logged)") ctitle (class and gender)
		
		// Finally, the trickiest interaction: class and education.
		gen lessthanHSedclass = lessthanHSed*stdproxyclass
		gen HSedclass = HSed*stdproxyclass
		gen somecollegeclass = somecollege*stdproxyclass
		gen BAclass = BA*stdproxyclass
		gen postgradclass = postgrad*stdproxyclass
		
		reg logincome gender b1.categed stdproxyclass HSedclass ///
		somecollegeclass BAclass postgradclass
		// This is a total mess -- one interaction is significant
		// but now class is insignificant and 
		// "a high school education" and "some college" are
		// not statistically different from 
		// a less than HS education. Time to export results.
		
		outreg2 using interactions, excel append title /// 
		("imputed income (logged)") ctitle (class and education)
		
		// Again, just to see what happens, let's check
		// an interaction between the polytomous "educ" category
		// and class
		gen classed = educ*stdproxyclass
		
		reg logincome gender educ stdproxyclass classed
		// As we can see, there is still not
		// a significant interaction
		
// PART VI: Outliers, heteroskedasticity, and multicollinearity

	// Part VI.i: Performing the five diagnostic tests
		
		reg logincome Black Hispanic otherrace gender /// 
		lessthanHSed somecollege BA postgrad stdproxyclass
		
		predict HatDiagonal, hat
		predict RStudent, rstudent
		predict CooksD, cooksd
		predict DFFITS, dfits
		predict DFB_spclass, dfbeta(stdproxyclass)
		
		generate HatDiagonal3Hi = HatDiagonal>(3* (10-1))/797
		generate RStudentHi =abs(RStudent)>2
		generate CooksDHi =CooksD>4/797
		generate DFFITSHi =abs(DFFITS)>2*sqrt(9/797)
		generate DFB_class =abs(DFB_spclass)>2/sqrt(797)
		
		summarize HatDiagonal3Hi RStudentHi CooksDHi DFFITSHi ///
		DFB_class
		
		graph box HatDiagonal
		// It looks like the values above 0.04 are really
		// outliers, although we could maybe make a case for values
		// above 0.035
		
		graph box RStudent
		// This time the outliers look like they're all negative
		// so maybe a cut-off point could be -3.
		
		graph box CooksD 
		// Cook's D is unfortunately highly right-skewed
		// Maybe we can say that a cut-off point is 0.015.
		
		graph box DFFITS
		// DFFITS is relatively normally distributed--let's say
		// our cut-off point is -0.4.
		
		graph box DFB_spclass
		// Clearly there is a single outlier here close to -0.2
		// It might be worth thinking of values above 0.15 as
		// outliers as well. 
		
		generate anyhi=HatDiagonal3Hi==1 | RStudentHi==1 ///
		| CooksDHi==1 | DFFITSHi==1 ///
		| DFB_class==1 
		
		sum anyhi, detail
		
		reg logincome gender lessthanHSed somecollege ///
		BA postgrad ///
		stdproxyclass if anyhi == 0
		
		outreg2 using hetsked, excel replace title ///
		("imputed income (log)") ctitle (partial model)
		
		reg logincome gender lessthanHSed somecollege BA ///
		postgrad stdproxyclass
		
		outreg2 using hetsked, excel append title ///
		("imputed income (log)") ctitle (full model)
		
		reg logincome gender lessthanHSed somecollege /// 
		BA postgrad stdproxyclass, vce(hc3)
		
		outreg2 using hetsked, excel append title ///
		("imputed income (log)") ctitle (robust SEs)
		
		reg logincome gender lessthanHSed ///
		somecollege BA postgrad /// 
		stdproxyclass, vce(hc3)
		
		estat vif

// PART VII: Indirect effects and omitted variable biases
	
	// Let's go back and look at the case of the changing
	// significance of race when education is entered

	// First I find the total effect of being Hispanic on income
	// through bivariate regression.
	reg topcatincome Hispanic 
	// I export the results.
	outreg2 using graph6, excel replace title ///
	("imputed income") ctitle (Hispanic model)
	
	// Now I find the direct effect and one of the indirect 
	// effects with a multivariate regression.
	reg topcatincome Hispanic educ
	// I export the results.
	outreg2 using graph6, excel append title ///
	("imputed income") ctitle (Hispanic+educ model)
	
	// Finally, I find the other indirect effect with
	// a bivariate regression.
	reg educ Hispanic
	
	// Now I find the total effect of "other" on income.
	reg topcatincome otherrace
	// I export the results.
	outreg2 using graph6, excel append title ///
	("imputed income") ctitle (other race model)
	
	// Now I find the direct effect and one of the 
	// indirect effects with a multivariate regression
	reg topcatincome otherrace educ
	// I export the results.
	outreg2 using graph6, excel append title ///
	("imputed income") ctitle (other race+education model)
	
	// Finally, I find the other indirect effect with
	// a bivariate regression.
	
	reg educ otherrace
	
	// Now, I try the same side-by-side estimation
	// for Black respondents
	
	reg topcatincome Black
	
	// Looks good so far. I export the results.
	
	outreg2 using graph6, excel append title ///
	("imputed income") ctitle (Black model)
	
	// I add in education
	
	reg topcatincome Black educ
	
	// Uh-oh. The addition of education has *not*
	// caused the effect of being Black to be 
	// insignificant as it has done for the other
	// two race categories. 
	// I export the results.
	outreg2 using graph6, excel append title ///
	("imputed income") ctitle (Black + educ model)
	
	// I decide to check out the relationship between
	// the Black race-category and education.
	
	reg educ Black
	
	// Mystery solved! There is no relationship
	// between being Black and education. So there
	// must be something else going on.
	
	// Now I try just putting in gender, since this
	// was one of the other controls in Model III
	// where the effect of being Black disappeared.
	
	reg topcatincome Black gender
	
	// Interestingly, the effect of being Black
	// *does* go away to some extent. 
	// I export the results. 
	
	outreg2 using graph6, excel append title ///
	("imputed income") ctitle (Black+gender model)
	
	// What could be behind this? Why would controlling
	// for gender matter? Well, maybe the gender
	// distribution conditional on race matters.
		
	tab gender if Black == 1
	
	// Hmmm. This seems like it's more skewed towards
	// women than I remember the population being.
	// Let's formally test that there is a statistically
	// significant difference between races.

	ttest gender, by(Black)
	
	// A-ha! The p-value that the mean gender of Black
	// respondents would be larger than that of all other
	// race-categories is very small. Since "woman" is coded
	// as a numerically higher value on the dummy variable
	// this all makes sense. 
	
	// OK, so perhaps there is some logic behind
	// the observed effect of gender on the 
	// effect of race.
	
	// Now I try to add in class, just to see what
	// happens.
	
	reg topcatincome Black gender stdproxyclass
	
	// Bingo--the effect has gone away.
	// I export the results.
	outreg2 using graph6, excel append title ///
	("imputed income") ctitle (Black+gender+class model)
	// Let's see why.
	
	reg stdproxyclass Black
	
	// More good news(well, "good" only in a statistical sense).
	// It turns out that Black respondents are
	// more likely to score lower on the class score.
	// There are some plausible pathways here, in other words.

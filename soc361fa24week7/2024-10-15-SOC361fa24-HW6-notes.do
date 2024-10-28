* DATE: 2024-10-15
* AUTHOR: Griffin JM Bur
* TASK: Complete Assignment 6
* DUE: Friday, October 18 at noon
* PART I

* Use the 1994 General Social Survey (the file, labelled "gss94.dta" is 
	* available in the folder, "Data files and do files for exercises and 
	* lecture demos" on Canvas) to analyze whether and how education, race, gender, 
	* Christian beliefs, and personal income affect views about legalization of 
	* abortion. Conduct the following analyses, save your results in a log 
	* file (omit incorrect runs and unnecessary output; make sure to include all 
	* information that is relevant to the questions) and answer the questions:
	
	cd ~/desktop/code/soc361fa24
	clear all 
	capture drop all
	use ./data/gss94
	
	* 1. The variables you will need are: abnomore, absingle, abpoor, educ, sex, 
		* race, relig, and rincom91. First, inspect each variable.
		
		local vars "abnomore absingle abpoor educ sex race relig rincom91"
		keep `vars'
		d `vars'
		insp `vars'
		codebook `vars'
		fre `vars'
		missings report `vars'
		
	* 2. Create the independent variables you need for the analysis: dummy 
		* variables for women, blacks, and Christians (chrstn), and an 
		* interval-variable for respondent's income based on rincom91. Label 
		* each variable & provide an appropriate set of descriptive statistics.
		
		* Making an income variable 
	
		fre rincom91
		lab lis rincom91 
		
		* Here's how Ted makes his income var
		
			gen inc91ths=rincom91
			recode inc91ths (0 22 98 99 = .) ///
				(1=.5)(2=2)(3=3.5)(4=4.5)(5=5.5)(6=6.5)(7=7.5)(8=9)(9=11.25) ///
				(10=13.75)(11=16.25)(12=18.75)(13=21.25)(14=23.75) ///
				(15=27.5)(16=32.5)(17=37.5)(18=45)(19=55)(20=67.5)(21=90)
		
		* How I might proceed in making an income var by taking value labels 
		* and do midpoint imputation using them, inspired to some extent by this
		* answer on Stackexchange: 
			* https://archive.ph/HxE2G
		
		gen realinc = .
		
		* As a first step, let's replace numeric as missing and make a clearer 
		* value label for rincom91==1. 
		
		replace realinc = . if rincom91 == 22 // this is "refused"
		
		lab def rincom91 1 "$0-1000", modify
		
		levelsof rincom91, local(levs)
			* This stores all possible values of the variable in a local 
			* called "levs"
		local inclab : value label rincom91
			* We also put the value label itself into a local, using Stata's
			* extended macro functions, which let us use the syntax above (for
			* more on this, see p. 4 of this and on: 
				* https://www.stata.com/manuals13/pmacro.pdf)

		foreach l of local levs {
			local strlab : label `inclab' `l'
				* What's happening here? We access the string label associated
					* with numeric value l, for l in the set of all possible
					* levels of income
			local n2 = strrpos("`strlab'", "-") - 2
				* Now, I want to turn that string into two different numbers
				* but the problem is that the numbers are of variable length
				* so I just say "tell me at what position in the string the 
				* hyphen first occurs" and store that as n2. I subtract two 
				* for reasons mentioned below
			local lb = substr("`strlab'", 2, `n2')
				* Now, I get the lower bound of the interval by taking the sub-
				* string from the second position of the string label for a 
				* length of n2. Now we see why I took away two above in defining
				* n2: I didn't want to include the hyphen itself, and I was 
				* starting the string after the first character, a dollar sign
			local ub = substr("`strlab'", `n2'+3, strlen("`strlab'"))
				* Now I get the ub. I add three to n2 to start the second string
				* after the hyphen and then go until the end of the string label
				* using the length of the string
			replace realinc = round((real("`lb'") +  real("`ub'"))/2, 1)  ///
				if rincom91 == `l'
				* Finally, I replace income with the average of my two values
		}
		lab var realinc "Income (real, midpoint imputation)"
		tab realinc
		
		* Make the other dummies. By the way, you *must* cross-check your 
		* dummy variable creation in general. It is a very bad idea to omit
		* this step. 
		
		* Black respondents 
		fre race
		gen black = race == 2
		replace black = . if missing(race)
		lab def bl 0 "non-black" 1 "black"
		lab val black bl
		lab var black "black (or not)"
		tab black race, mis
		
			* A fast alternative is this, by the way
			* Note that we can make value label
			recode race (1 3 = 0 "non-black") (2 = 1 "black"), gen(black2)
			tab black*, mis
			drop black2
		
		* Female respondents 
		fre sex
		gen female = sex == 2 
		replace fem = . if missing(sex)
		lab def fem 0 "male" 1 "female"
		lab var female "female (or not)"
		tab fem sex, mis
		
		fre relig
		gen chrstn = relig < 3 
		replace chrstn = . if missing(relig)
		lab def christ 0 "non-christian" 1 "christian"
		lab val chrstn christ
		lab var chrstn "christian (or not)"
		tab relig chrstn, mis
		
		fre bla fem chrst
			
	* 3. Create a scale called "abscale" measuring support for legal abortion 
		* that combines the three specific measures (which refer respectively to 
		* whether a woman shld be allowed to have an abortion if she is married 
		* and doesn't want any more kids, is single, and is too poor to afford
		* another child.) Code the scale so that higher values = more support 
		* for legalized abortion. Inspect the scale and present the appropriate 
		* descriptive and correlations. What is the reliability coefficient
		* for the scale, and how do you interpret it?
		
		* Let's inspect the abortion dummies.
		
		fre ab* 
			
			* OK, they are reverse-coded from how we would want them -- smaller
			* values are associated with greater support for abortion. That's
			* generally not ideal, and the problem tells us to avoid this. Let's
			* fix that. 
		
		foreach var of varlist abnomore absingle abpoor { 
			sum `var'
			gen `var'_rev = -1*`var' + r(max)
				* This works generally, even when the scale has some values
				* that are equal to 0.
			corr `var' `var'_rev
		}
		
		* I personally think it's safer to avoid using people who are missing
		* on any value of the variable, but of course reasonable minds differ. 
		* Here, I show both ways. By the way, -alpha- uses the same behavior as
		* does -rowmean-, so you can just use it: both recalculate the mean for
		* rows with missings to adjust for that.
		
		alpha abnomore_rev absingle_rev abpoor_rev, gen(abscalealt)
			* just checking -> 
			egen abscalealt2 = rowmean(*_rev)
			corr abscaleal*
			drop abscalealt2
		
		* So, an alternative is to only keep observations who have values on 
		* all variables. 
		
		* Note that there is *zero* difference to alpha since we can write
		* alpha as (k/[k-1]) * (1 - \sum_p=1^k \sigma^2_p / \sigma^2)
		* and if we take the mean of the variables, this is the same as 
		* their total but with each var divided by k. Then, 1/k^2 will 
		* factor out of numerator and denominator in our alpha formula. 
		
		foreach var of varlist abnomore_r absingle_r abpoor_r { 
			gen `var'k  = `var'/3
		}
		alpha abnomore_rev absingle_rev abpoor_rev
		alpha abnomore_revk absingle_revk abpoor_revk
		gen abscale = abnomore_revk + absingle_revk + abpoor_revk
		gen abscaletot = abnomore_rev + absingle_rev + abpoor_rev

		sum absca*
		
	* 4. Regress abscale on education, race, and gender. Then add the dummy 
		* variable for Christian beliefs. Then add measure of personal income. 
		* Check sample sizes and make any adjustment necessary (explain why 
		* an adjustment is necessary). Interpret results: do each of the five 
		* independent variables affect views toward the legality of abortion? 
		* What is your evidence? Describe each effect that you identify.
		
		* Very widely missed. People forgot that you *must* have the same sample
		* sizes in order to compare. You can either drop everyone now who is
		* missing or use a flag variable like I show below. 
		
		* Bonus: I will show how to do F-tests. 
		
		sum * 
		preserve 
		drop if missing(educ, sex, race, relig, inc91ths, ///
			abnomore, absingle, abpoor)
		sum * 	
		reg abscale educ black fem 
		reg abscale educ black fem chrs 
		reg abscale educ black fem chrs inc91ths 
		restore 
		sum * 
		
		gen lack_key_obs = ///
			missing(educ, sex, race, relig, inc91ths, ///
			abnomore, absingle, abpoor)
		
		reg abscale educ black fem if lack_key_obs == 0
		reg abscale educ black fem chrs if lack_key_obs == 0
		reg abscale educ black fem chrs inc91ths if lack_key_obs == 0
		
		ssc install ftest
		
		local base_vars = "educ black fem"
		local incr_vars = "chrs inc91ths"
		local covariates = ""
		local k : word count `incr_vars'
		forvalues p = 1/`k' { 
			reg abscale `base_vars' `covariates' if lack_key_obs == 0
			local SSE_r = e(rss)
			estimates clear
			estimates store model1
			local thiscovariate: word `p' of `incr_vars'
			local covariates "`covariates' `thiscovariate'"
			di "Our new set of covariates is `covariates'"
			reg abscale `base_vars' `covariates' if lack_key_obs == 0
			local SSE_f = e(rss)
			di `SSE_f'
			local df_ef = e(df_r)
			di `df_ef'
			local incr_F = (`SSE_r' - `SSE_f') * (`df_ef'/`SSE_f')
			estimates store model2
			di "Our incremental F-statistic is `incr_F'"
			ftest model1 model2
			test `thiscovariate'
		}
		
	* 5. Center the measures of education and personal income at their sample
		* means and re-run the analysis. Do any of your findings differ? If so, 
		* how? What is the predicted score on abscale of a Muslim Asian woman 
		* with average education and average personal earnings?
	
		foreach var of varlist educ realinc inc91ths { 
			sum `var'
			gen c_`var' = `var' - r(mean)
		}
		
		reg abscalealt c_ed c_inc91ths black fem chrs if lack_key_obs == 0
		reg abscaletot c_ed c_inc91ths black fem chrs if lack_key_obs == 0
		margins, at(chrs=0 fem=1 c_ed = 0 c_inc91ths = 0 black = 0)
		
	* Part 2
	* Conduct a multiple regression that includes at least two independent 
	* variables using your project data. (If you still do not have project data, 
	* then you better get some soon! However, in the meantime you can complete 
	* this part of the assignment using the 1994 GSS.)
	
	*1. Briefly state the hypotheses you will test with regression. What are 
		* the dependent variable, the independent variables, and the expected 
		* effects, and why do you expect them?
	* 2. Present descriptive statistics for your variables. If you needed to 
		* transform the orig. variables in the data file in order to construct 
		* them, show the descriptive for the original variables and your syntax 
		* for creating the new (operational) variables.
	* 3. Run the regression, display the output, and interpret the results. 

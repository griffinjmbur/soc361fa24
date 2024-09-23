* TECHNICAL POINTS: 

* MY PREFERRED E-MAIL IS NOT MY WISC E-MAIL. PLEASE DO NOT E-MAIL ME THERE. 
	* Wisc mail is a terrible system. You don't have to agree, but please take
	* my opinion as a legitimate one as a "data management expert". (I learned
	* this practice from some extremely productive demographers in our dept., so
	* this is not just my own crank POV.)
	
* PLEASE NAME YOUR FILES IN A COHERENT WAY AND USE THE STANDARD HEADER AND 
* COMMENTS, ETC. 
	* To grade your work, I need to download your do-files unless you submit a
	* log file (that's one reason log files are useful; they can display without
	* Stata being opened; Canvas can't open Stata, of course). It's much more
	* efficient for me if I know whose file is whose, etc.. 
	
	* Ideal format is YYYY-MM-DD-SOC361fa24-lastname-firstinitial-task.extension
	
* Below is the standard header. Please use it. Ask me about any part that 
* you don't understand.
capture log close
	* -capture- says "ignore if command is invalid". Often dangerous, here
	* useful. We close a log if any is open and ignore if none is. Just saves
	* you annoying errors. 
log using ///
	"~/desktop/code/soc361fa24/soc361fa24week3/2024-09-19-soc361fa24-hw2", ///
	text replace
	* Logs have been discussed at length. 
	
* AUTHOR: Griffin JM Bur
* DATE: 2024-09-23
* TASK: demonstrate homework
version 17 
	// good to know what version so that if commands have changed, you can set
	// the version at a later date to one that will run the code. 
cd ~/desktop/code/soc361fa24
	// If your filepath doesn't exactly match mine, don't worry! Logically, our
	// computers are probably organized differently! This should just go to a 
	// path on *your* computer. If you have iCloud or something, this can be
	// complicated, I know -- but you need to know how files on your computer
	// are organized. If iCloud is spiriting away documents to a remote server
	// and you don't know what's actually on your local storage, that is smthn
	// you will want to address anyways! (My strong suggestion is to avoid 
	// all cloud storage that you don't actually directly manage; Github is a
	// remote storage mechanism that you have to manually use.)

clear all 
	* Many people did not include this command in their code and then had 
	* annoying errors. That's why we include this line! "Won't it delete all 
	* of my data?" Yes! That's why you always store changes in your do-files. 
	* If you were working on another task *before* using this do-file, that
	* work should be saved in its own do-file. Then, you can clear it with 
	* another do-file for another task with no fear. 
	
use "./data/ICPSR_28721/ds0004/28721-0004-data.dta"

* General cleaning taks
	rename *, lower
	* This is generally helpful. Asterisks are wild-cards, so here it just 
	* makes every variable lowercase. 

* Looking for our vars of interest
	lookfor household family sex age race hisp vigorous bmi
	* Prints results of searching variable window on screen. 
	tab1 *rac*
	* -tab1- prints one-way tables for all values of race; if you just write
	* tab, it will try to make a k-way table for all matches, which will throw
	* up an error. 

* looks like our varlist should be ...
	keep hhx fmx fpx sex age_p racerpi2 hispan_i vigfreqw bmi

* STEP 1: CHECK FOR MISSING VALUES. I'll just put some of the codebook's lang.
* in the do-file, often a helpful step. 

	* HHX: 

	/* The variables HHX and FMX can be used to link the 2009 Paradata File 
	with the 2009 NHIS health data files. HHX is a household identification
	number  for each record in both files.

	FMX represents the family number of the case within the household. 

	For approximately 98% of 201 or 203 cases (complete or sufficiently complete 
	interviews), there is a single family in the household, thus the FMX value 
	will be "01". For those cases with more than one family in the household, 
	HHX will be the same, but the FMX will have values of "01", "02", etc. */ 

	* No MVs on HHX, FPX, or FMX. All are strings, which is generally not a 
	* problem for ID variables, but does limit the usefulness of other types of 
	* variables, so fixing this is a good thing to know how to do in general. 
	* First I'll show how to fix one, and then just show a loop to do the same.

	d hhx
	destring hhx, replace
	codebook hhx

* Here it is with a loop

	* set trace on // normally too much out but helpful in debugging loops

	clear all
	use "./data/ICPSR_28721/ds0004/28721-0004-data.dta"
	rename *, lower
	lookfor household family sex age race hisp vigorous bmi
	tab1 *rac*
	* looks like our varlist should be ...
	keep hhx fmx fpx sex age_p racerpi2 hispan_i vigfreqw bmi
		
	local ids = "hhx fmx fpx"
	foreach var of varlist fmx fpx { 
		d `var' 
			// we see that each is string
			// but this is not easy if we had, say, 30 of them
		* We may want to make sure, if we have a big list, that each one is in
		* fact a string variable
		local vartype: type `var'
			* put the variable type in a local
		assert ustrpos("`vartype'", "str") > 0
			* This asks whether the vartype contains the phrase "str" anywhere
			* It will stop the loop if the vartype does not contain "str"
			* can't just be an equality b/c stata irritatingly incldues
			* the length of a str. in the type. So, I tell Stata to stop if 
			* the vartype does not have "str" listed anywhere
		destring `var', replace
		codebook `var'
		inspect `var'
	}

* Let's put our IDs first if they aren't already 
	order `ids', first
* And let's also verify that these uniquely identify our observations. I'll show
* what this looks like when it is *FALSE* first. -capture- says, again, not to 
	capture noisily isid hhx
	capture noisily isid hhx fpx fmx // no news is good news

* We have no MVs on any of the other demographic variables either, fortunately. 

* Let's make sex a genuine dummy though
	ssc install fre
	fre sex 
	// -fre- is useful to get actual values listed all in one go
	// you can also access the value label directly, as shown in other dofiles
	d sex
	lab lis SEX
	
	gen female = sex == 2 
	* Note the Boolean assignment here; this tags people for whom the condition
	* is true as 1s and those for whom it is false as 0s.  
	replace sex = . if missing(sex)
	* Not necessary here b/c no MVs on sex but good habit to get into
	* b/c one way for it to be false that sex == 2 is for it to be missing, but
	* missing != male (!!)

	lab def fem 0 "male" 1 "female" // let's make a value label
	lab val female fem // remember to paste it on!
	tab fem sex, mis // this is how we check our work

* Now let's move on to the variables that did have MVs. 

	* For vigfreqw, 95==never. I'd frankly just recode to 0; that deserves "0" 
	* more than "rarely". >95 is missing. So...

	replace vigfreqw = 0 if vigfreqw == 95
	replace vigfreqw = . if vigfreqw > 95

* For BMI, 9999 is missing. NB all others lack a decimal

	replace bmi = . if bmi == 9999

* STEP 2: RECODING	

* Some people did some basic recoding here. Let's try that. Here's a simple one
* that tags people as "active" if they worked out more than twice weekly.

	gen active = vigfreqw > 2 if !missing(vigfreqw)

	* Note that once we feel good about MVs we can often write one-liners
	* to get desired results. Here, I put the "if !missing()" into the command
	* so that now missings on vig. are just directly sent to missing on active.
	
	table active, stat(min vigfreqw) stat(max vigfreqw) 
		* This checks that our boundaries for non-MV observations look right
	
	bysort active: missings report vigfreqw
		
		* This makes sure that we *only* have MVs on vigfreqw that are also 
		* MVs on active. 
		
* Now that we like our var, let's label it and make an interesting graph. 
	
	lab def active 0 "exercise <=2x/week" 1 "exercise >2x/week"
	lab val active active
	
	ssc install heatplot
	ssc install palettes, replace
	ssc install colrspace, replace
	qui sum bmi if !missing(age) & !missing(active)
	heatplot bmi age i.active, colors(plasma) xdiscrete(0.9) sizeprop ///
		title("BMI by age and frequency of exercise") ///
		note("Source: NHIS 2009, {it: n} = `r(N)'")

* Key point to note here is that some people used the following syntax, 
* which just makes a new variable that *does not make a dummy var* but simply 
* reproduces the "exercise" var, but assigns to missing those who did not
* exercise more than twice a week. This is sometimes useful! However, it does 
* not do what some people thought it did, so it is wrong from that POV. 

	gen exerciseifactive = vigfreqw if vigfreqw > 2 & !missing(vigfreqw)
	sum exerciseifactive, d // note the problem


* Let's try recoding BMI using the NHlBI categories. 

	* NHLBI categories ->
		* Underweight = <18.5; Normal weight = 18.5–24.9; Overweight = 25–29.9
		* Obesity = BMI of 30 or greater
	
	* First, let's get BMI on the regular scale
	replace bmi = bmi/100
	* Let's explore the -recode- syntax, which is a handy way to do recodes that
	* don't obey any general logic (e.g. make five groups or cut the continuous
	* variable every ninth integer; for that use -egen, cut()-). We can also
	* make a value label at the same time, conveniently. 
	sum bmi
	recode bmi (0/18.49 = 1 "underweight") (18.5/24.99 = 2 "normal") ///
		(25/29.99 = 3 "overweight") (30/`r(max)' = 4 "obese") ///
		, pre(cat_) label(bmi_cat)
		* Note that any time you invoke a local variable, as I did above with 
		* `r(max)', the command defining it -- here, implicitly, the sum -- must
		* be run in the same "go", i.e. you must run both commands "at once" 
		* by highlighting at least the two of them (more if you want!) before
		* executing the file. 
		
	table cat_bmi, stat(min bmi) stat(max bmi)
	bysort cat_bmi: missings report bmi

* You can do this with a loop, too, which is a more general and flexible method.

	sum bmi
	local ranges `"0 18.5" "18.5 24.9" "25 29.9" "30 `r(max)'"'
	local labs "underweight" "normal" "overweight" "obese"
	local n : word count `ranges'
	capture gen bmi_cat = . 
	forvalues i=1/`n' { 
		local vals : word `i' of `ranges'
		local labval : word `i' of `labs'
		local val1 : word 1 of `vals' 
		local val2 : word 2 of `vals' 
		*di `i'
		*di "`vals'"
		di "lab val is `labval'"
		di "lb is `val1'"
		di "ub is `val2'"
		di "new round"
	}





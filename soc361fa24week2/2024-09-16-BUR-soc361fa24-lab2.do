capture log close
* DATE: 2024-09-16
* AUTHOR: Griffin JM Bur
* PURPOSE: Learn to clean data in Stata

cd "~/desktop/code/soc361fa24"
version 17
log using "./SOC361fa24week2/2024-09-16-BUR-soc361fa24-lab2", text replace

* Working on the GSS2018 data
clear all
use "./data/gss2018"
sum educ
gen retirement_age = age>66
replace retirement_age = . if missing(age) // we do this in order to 
	// assign people who are missing on the oldvar TO missing on the newvar
bysort retirement_age: sum age, d
ssc install missings
bysort retirement_age: missings report age
label define r_a /// 
	0 "working age" 1 "retirement age" 
label values retirement_age r_a
bysort retirement_age: sum age, d
label variable retirement_age ///
	"Is the respondent of full American retirement age"

* Working on the CPS2019 data
clear all
use "./data/cps2019extract"
describe marstat
label list marstat
gen married = (marstat == 1) 
tab marstat married, missing
label define marr /// 
	0 "unmarried in any way" 1 "married" 
label values married marr
label var married "Whether a respondent was married at time of interview"
tab married, sum(wage1)
ttest wage1, by(married) unequal
drop if hourslw >60 & !missing(hourslw)

* Working on the DAS1967 data
clear all 
use "./data/DAS1967"
rename *, lower
label define marr 1 "Single" 2 "Married" 3 "Divorced" ///
	4 "Separated or spouse absent" 5 "Widowed" 
label values v24 marr
replace v24 = . if v24 == 9
tab v24, missing

* Loops: they are basically similar to sums 
clear all
sysuse auto
local samptotal = 0
local sumsq = 0
local n = 74
forvalues j = 1/`n' {
local samptotal = `samptotal' + mpg[`j']
}
di `samptotal'/`n'
local ybar = `samptotal'/`n'
local sumsq = 0
forvalues j = 1/`n' {
local sumsq = `sumsq' + (mpg[`j'] - `ybar')^2
}
di `sumsq'/(`n'-1)
sum mpg, d

* Standardizing and tagging outliers with loops
clear all
use "./data/cps2019extract"
foreach var of varlist hourslw age wage1 {
	quietly sum `var', d
	local q3 = r(p75)
	local q1 = r(p25)
	local ybar = r(mean)
	local s = r(sd)
	local iqr = `q3' - `q1'
	gen outlier_`var' = (`var' >`q3' + 1.5*`iqr') | (`var' <`q1' - 1.5*`iqr')
	replace outlier_`var' = . if missing(`var')
	gen z_`var' = (`var' - `ybar')/`s'
}

sum z*
sum outlier*

* NOTE I WILL NO LONGER DOCUMENT THE FUNCTIONS OF THE STANDARD HEADER
* TOO MUCH TEXT NOW THAT WE KNOW. I WILL INCLUDE A FEW FRIENDLY REMINDERS
capture log close 
log using ///
	"~/desktop/code/soc361fa24/soc361fa24week3/2024-09-19-soc361fa24-lab3", ///
	text replace
	
* AUTHOR: Griffin JM Bur
* DATE: 2024-09-23
* TASK: demonstrate Lab 3 correct answers

version 17 
cd ~/desktop/code/soc361fa24
	* I will note this: to get this to run with minimal changes
	* just change this to your working directory
clear all 
	* MAKE SURE YOU DON'T HAVE CHANGES TO A DATASET THAT YOU HAVEN'T
	* DOCUMENTED ELSEWHERE IN A DO-FILE OR ELSE THIS WILL DESTROY THOSE.
use ./data/nhanes1719-extract

* 1 Find correlation by hand 
	gen x = bmxht
	gen y = bmxwt
	* I'm doing this rename so that I remember what's what and put it in terms
	* of standard statistical theory. 
	
	drop if missing(y, x)
    
	* The fancy version (with the simpler and simplest version folded in)
	
	* Let's make a "product var"; since COV[X,Y] in population = 
	* E[(X-mu_X)(Y-mu_Y)] = E[XY] - E[X]E[Y] (this is just the variance 
	* identity but applied to covariance; V[X] = COV[X, X] as some of you noted)
	* we can manually calculate the covariance easily. Note that it will be 
	* SLIGHTLY off for large data-sets because the sample cov is divided by 
	* n instead of n-1, but the whole "n-1 thing" is technically correct but 
	* makes it harder to understand what COV really is. It is *conceptually* the 
	* average product of the centered variables in the population.
	
    gen prod = y*x
    sum prod
    local prodmean = r(mean)
    sum x 
    local mean1 = r(mean)
    sum y 
    local mean2 = r(mean)
	local cov = `prodmean' - `mean1'*`mean2'
    di "The covariance of x and y is approximately `cov'"
    corr x y, cov 
	local realcov = r(C)[2,1]
	di "The exact covariance with n-1 is `realcov'"
	* checks out
	
    * make variance approximation using V[X] = E[X^2] - E[X]^2
    sum x 
	local realsdx = r(sd)
    gen xsq = (x - r(mean))^2
    sum xsq 
    di sqrt(r(mean)) // this should be ~= to the sd; if it is store in a local
    local sd_x = sqrt(r(mean))
	di "The SD of x is approximately `sd_x'; exact value is `realsdx'"
	* checks out
   
   * same but with Y
    sum y
	local realsdy = r(sd)
    gen ysq = (y - r(mean))^2
    sum ysq 
    di sqrt(r(mean)) // this should be ~= to the sd; if it is store in a local
    local sd_y = sqrt(r(mean))
	di "The SD of y is approximately `sd_y'; exact value is `realsdy'"
	* checks out
	
	local r = `cov'/(`sd_x' * `sd_y')
	corr x y
	local realr = r(C)[2,1]
	di "r_xy by our method is `r'; exact value is `realr'"
		* note that this is *exactly* correct because the n-1 "fudge factor"
		* drops out -- the correlation formula does not *have to* involve
		* sample size (as in "the cosine formula")
		
	* As mentioned in lab, it's also the ~average of the z-product
	foreach var of varlist x y {
		sum `var'
		gen z_`var' = (`var' - r(mean))/r(sd)
	}
	gen zprod = z_x * z_y
	sum zprod
	di "r_xy is approximately `r(mean)'; exact value is `realr'"

* 2 Find regression slope by hand
	
	* Here, I'll just directly use the covariance command

	corr x y, cov
	local cov = r(C)[2, 1]
	local vx = r(C)[1,1]
	local vy = r(C)[2,2]
	local b1 = `cov'/`vx'
	di `b1'
	sum y 
	local ybar = r(mean)
	sum x
	local xbar = r(mean)
	local b0 = `ybar' - `b1'*`xbar'
	reg bmxwt bmxht
	di "This is close to our approximation, with slope `b1' and intercept `b0'"
	
	* Interp: based on the sample, we estimate that for American children in the
	* recent past, a centimer increase in height is associated with a 1.05kg
	* increase in weight. Children with no height are estimated to have a weight
	* of -95kg; this obviously makes NO SENSE IN CONTEXT since the x-value is 
	* impossible. 
	
	scatter y x || lfit y x
	
		* Wow! Strong evidence of non-linearity. Perhaps we will cover this
		* in the future ... Note that *ESTIMATING A LINEAR MODEL _ASSUMES_
		* otherwise. 
	
* 3 Standardize each variable

	* Shown above, but here is how to do it with no reference to 
	* locals, just for one var. repeat as needed
	drop z_y // we already made this, so we need to drop it to avoid error
	sum y
	gen z_y = (y-r(mean))/r(sd)
	
* 4 What will the regression slope for standardized variables be? 

	* Based on the steps in the exercises slide, it should just be the 
	* correlation coefficient.
	
	corr x y, cov
	local cov = r(C)[2, 1]
	local vx = r(C)[1,1]
	local vy = r(C)[2,2]
	local b1 = `cov'/`vx'
	
	di `b1' * sqrt(`vx')/sqrt(`vy')
	reg z_y z_x
	
* 5 Convert to pounds and inches. How will the original slope change? How about
	* the standardized slope, AKA the correlation? 
	
	* The correlation shouldn't change because COV(aX, bY) = abCOV(X, Y) and 
	* since V(aX) = a^2 V(X), SD(aX) = aSD(X). So, the a and b in the numerator
	* will cancel with the a and b in the denominator. 
	
	gen htin = x * 0.393701 
	gen wtlbs = y * 2.20462 
	

	corr x y 
	corr htin wtlbs // checks out
	
	* Now, our slope for the unstandardized variables should change as follows, 
	* using the following. I'll round values a bit for simplicity.
		* COV(2.2X, 0.39Y)/V(0.39X) = (0.39 * 2.2)/(0.38^2) B1 = 2.2/3.9 B1
		
	reg wtlbs htin 
		
		* comparing to the old slope, we have...
		reg y x
		di 1.051904 * (2.20462/0.393701) // checks out
	
* 6. Find the standard error for the regression slope by hand, and then
		* use it to construct a 95 CI and a two-tailed hypothesis test against 
		* 𝐻_0 ∶ 𝛽1 = 0.
	
	* Standard error is RMSE/sqrt(SS_X)
	* We can get the RMSE from the regular regression output for simplicity; 
	* you can get this from the return results, but let's skip for now. 
	
	reg y x // RMSE = 19.378
	sum x
	di 19.378/(r(sd)*sqrt(r(N)-1)) // this is approximately equal to output
	local SE = 19.378/(r(sd)*sqrt(r(N)-1))
	
	* Thus, the CI is...(using 1.96 as an approximation since n is very large)
		
	corr x y, cov
	local cov = r(C)[2, 1]
	local vx = r(C)[1,1]
	local vy = r(C)[2,2]
	local b1 = `cov'/`vx'
	local lb = `b1' - 1.96*`SE'
	local ub = `b1' + 1.96*`SE'
	di "The 95 CI for the slope is (`lb', `ub')" // checks out
		
* 7. Find the conditional standard deviation of the regression.
	
	* Note that we already had to find this from the regression above. 
	* However, how else could we find it? We can make a residuals variable
	* by hand. Let's do that now. What follows below is just repeat, to get
	* the results in working memory (if you run this whole thing at once, 
	* then you won't need to do this).
	
	corr x y, cov
	local cov = r(C)[2, 1]
	local vx = r(C)[1,1]
	local vy = r(C)[2,2]
	local b1 = `cov'/`vx'
	di `b1'
	sum y 
	local ybar = r(mean)
	sum x
	local xbar = r(mean)
	local b0 = `ybar' - `b1'*`xbar'
	
	gen yhat = `b1'*x + `b0'
	gen resid = (y - yhat)
	sum resid // this is approximately correct, but our df is n-2
	
	reg bmxwt bmxht
	predict ehat, residuals
	sum ehat

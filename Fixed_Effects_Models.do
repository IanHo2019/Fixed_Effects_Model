* This do file uses various commands to run fixed effects models. The data used is extracted from World Development Indicators (2000-2021).
* Author: Ian He
* Institution: The University of Oklahoma
* Date: Apr 22, 2023
*************************************************************************

clear all

global localdir "D:\research\Fixed Effects Model"

global dtadir   "$localdir\Data"
global tabdir   "$localdir\Table"



*************************************************************************
**# FE regressions
use "$dtadir\WDI21.dta", clear

* Use "xtreg, fe"
eststo xtreg1: xtreg ln_gdppc ln_trade ln_labor, fe robust

eststo xtreg2: xtreg ln_gdppc ln_trade ln_labor i.year, fe robust

estout xtreg*, keep(ln_trade ln_labor) ///
	coll(none) cells(b(star fmt(3)) se(par fmt(3))) ///
	starlevels(* .1 ** .05 *** .01) legend ///
	stats(N r2_a, nostar labels("Observations" "Adjusted R-Square") fmt("%9.0fc" 3))


* Use "areg, absorb( )"
eststo areg1: areg ln_gdppc ln_trade ln_labor, absorb(country_code) cluster(country_code)

eststo areg2: areg ln_gdppc ln_trade ln_labor i.year, absorb(country_code) cluster(country_code)

estout xtreg1 areg1 xtreg2 areg2, keep(ln_trade ln_labor) ///
	coll(none) cells(b(star fmt(3)) se(par fmt(3))) ///
	starlevels(* .1 ** .05 *** .01) legend ///
	stats(N r2_a, nostar labels("Observations" "Adjusted R-Square") fmt("%9.0fc" 3))


* Use "reghdfe, absorb( )"
eststo hdreg1: reghdfe ln_gdppc ln_trade ln_labor, absorb(country_code) cluster(country_code)

eststo hdreg2: reghdfe ln_gdppc ln_trade ln_labor, absorb(country_code year) cluster(country_code)

estout xtreg1 areg1 hdreg1 xtreg2 areg2 hdreg2, keep(ln_trade ln_labor) ///
	coll(none) cells(b(star fmt(3)) se(par fmt(3))) ///
	starlevels(* .1 ** .05 *** .01) legend ///
	stats(N r2_a, nostar labels("Observations" "Adjusted R-Square") fmt("%9.0fc" 3))


* Export results to LaTeX
estout xtreg1 areg1 hdreg1 xtreg2 areg2 hdreg2 using "$tabdir\compare_reg_commands.tex", keep(ln_trade ln_labor) ///
	sty(tex) label mlab(none) coll(none) ///
	cells(b(star fmt(3)) se(par fmt(3))) ///
	starlevels(* .1 ** .05 *** .01) ///
	preh("\begin{tabular}{p{0.2\textwidth}p{0.1\textwidth}p{0.1\textwidth}p{0.1\textwidth}p{0.1\textwidth}p{0.1\textwidth}p{0.1\textwidth}}" "\hline \hline" ///
		"& (1) & (2) & (3) & (4) & (5) & (6) \\" ///
		"& xtreg & areg & reghdfe & xtreg & areg & reghdfe \\ \hline" ) ///
	prefoot("\hline" ///
		"Country FE      & \checkmark & \checkmark & \checkmark & \checkmark & \checkmark & \checkmark \\ " ///
		"Year FE      &  &  &  & \checkmark & \checkmark & \checkmark \\ ") ///
	stats(N r2_a, nostar labels("Observations" "Adjusted R-Squared") fmt("%9.0fc" 3)) ///
	postfoot("\hline\hline" "\end{tabular}") replace


	*************************************************************************
**# Is time FE a good ingredient for our lunch?
use "$dtadir\WDI21.dta", clear

* Null: We don't need time FE.
* If `r(p)' is less than 0.05, reject the null and add time FE.
xtreg ln_gdppc ln_trade ln_labor i.year, fe robust
testparm i.year



*************************************************************************
**# Choose FE or RE?

* Here I don't use "robust" option because the "hausman" command cannot work with it (and all cluster-robust covariance estimators).
xtreg ln_gdppc ln_trade ln_labor, fe
estimates store fixed

xtreg ln_gdppc ln_trade ln_labor, re
estimates store random

* If `r(p)' is less than 0.05, use FE regression.
hausman fixed random, sigmaless



*************************************************************************
**# Choose RE or OLS?

* Null: We don't need a RE model.
* If `r(p)' is less than 0.05, reject the null and use the RE model.
xtreg ln_gdppc ln_trade ln_labor, re robust
xttest0



*************************************************************************
**# Test the correlation among countries (or individuals, in general)

* Null: No correlation.
* If `Pr' is less than 0.05, reject the null; the data are correlated across countries.

* ssc install xttest2, replace
xtreg ln_gdppc ln_trade ln_labor, fe robust
xttest2 // Breusch-Pagan Lagrange multiplier test



*************************************************************************
**# Hetero or Homo?

* Null: Homoskedasticity.
* If `r(p)' is less than 0.05, reject the null; there exists heteroskedasticity.

* ssc install xttest3, replace
xtreg ln_gdppc ln_trade ln_labor, fe robust
xttest3



*************************************************************************
**# Test the serial correlation

* Null: No serial correlation.
* If `r(p)' is less than 0.05, reject the null; there is serial correlation.

* net install xtserial.pkg, replace
xtreg ln_gdppc ln_trade ln_labor, fe robust
xtserial ln_gdppc ln_trade ln_labor
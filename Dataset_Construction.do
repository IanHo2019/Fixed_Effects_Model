* This do file constructs a panel dataset with data from World Development Indicators (2000-2021) and does summary satistics.
* Author: Ian He
* Date: Apr 22, 2023
*************************************************************************

clear all

global localdir "D:\research\Fixed Effects Model"

global dtadir   "$localdir\Data"
global figdir   "$localdir\Figure"



*************************************************************************
**# Clean Data
import excel "$dtadir\P_Data_Extract_From_World_Development_Indicators.xlsx", sheet("Data") cellrange(A1:H4775) firstrow clear

drop TimeCode CountryName

rename Time year
rename CountryCode country
rename GDPpercapitaconstant2015US gdppc
rename Exportsofgoodsandservicesc export
rename Importsofgoodsandservicesc import
rename LaborforcetotalSLTLFTOTL labor

label var gdppc "GDP per capita (constant 2015 USD, billion)"
label var export "Exports of goods and services (constant 2015 USD, billion)"
label var import "Imports of goods and services (constant 2015 USD, billion)"
label var labor "Labor force, total (thousand)"

* Drop some observations
drop if missing(gdppc) | missing(export) | missing(import) | missing(labor)

duplicates tag country, gen(tag)
drop if tag==0
drop tag

* Define "trade" as a summation of import and export
gen trade = import + export



*************************************************************************
**# Set a Panel and See Summary Statistics
encode country, gen(country_code)
xtset country_code year

* Panel descriptive statistics
xtsum gdppc trade labor


* See the heterogeneity across countries and years
bysort year: egen gdppc_mean = mean(gdppc)

twoway (scatter gdppc year, msymbol(circle_hollow) color(gs14)) ///
	(connected gdppc_mean year, sort msymbol(diamond)), ///
	ylabel(, angle(0) labsize(2) format(%9.0fc)) ///
	xlabel(2000/2021, angle(45) labsize(2) grid) ///
	title("GDP per capita (constant 2015 USD)") xtitle("Year", size(2.5)) ///
	legend(label(1 "GDP pc per country") label(2 "Mean of GDP pc per year")) ///
	plotregion(fcolor(white) lcolor(white)) ///
	graphregion(fcolor(white) lcolor(white))
graph export "$figdir\GDPpc_heterogeneity.pdf", replace


* Log transformations
local varlist = "gdppc labor trade"
foreach v in `varlist' {
	gen ln_`v' = ln(`v')
	label var ln_`v' "ln(`v')"
}

xtsum ln_gdppc ln_labor ln_trade


* Distribution density
local varlist = "gdppc labor trade"

foreach v in `varlist' {
	if "`v'"=="gdppc" {
		local number = "A"
		local title = "GDPpc"
	}
	
	if "`v'"=="labor" {
		local number = "B"
		local title = "Labor"
	}
	
	if "`v'"=="trade" {
		local number = "C"
		local title = "Trade"
	}
	
	hist gdppc, name(`v'_level, replace) ///
		ylabel(, labsize(2)) ///
		xlabel(, labsize(2) format(%9.0fc)) ///
		title("(`number'1) `title'") xtitle("", size(2.5)) ///
		plotregion(fcolor(white) lcolor(white)) ///
		graphregion(fcolor(white) lcolor(white))
	
	hist ln_`v', name(`v'_log, replace) ///
		ylabel(, labsize(2)) ///
		xlabel(, labsize(2)) ///
		title("(`number'2) ln(`title')") xtitle("", size(2.5)) ///
		plotregion(fcolor(white) lcolor(white)) ///
		graphregion(fcolor(white) lcolor(white))
}

graph combine gdppc_level gdppc_log labor_level labor_log trade_level trade_log, ///
	name(distribution, replace) cols(2) ///
	ysize(6.5) xsize(5) ///
	graphregion(fcolor(white) lcolor(white))
graph export "$figdir\variable_distribution.pdf", replace


save "$dtadir\WDI21.dta", replace

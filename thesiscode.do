* Step 1: Load your data
use XXXXXXXXXXXXXXX, clear // please add correct file path

tsset Year

* Calculate growth rates for each country
gen GrowthRate_Switzerland = (Switzerland - L1.Switzerland) / L1.Switzerland
gen GrowthRate_Austria = (Austria - L1.Austria) / L1.Austria
gen GrowthRate_France = (France - L1.France) / L1.France
gen GrowthRate_Germany = (Germany - L1.Germany) / L1.Germany

* Step 2: Explore the data
describe  // Display variable names, types, and other information

* Check summary statistics for numeric variables
summarize GrowthRate_Switzerland GrowthRate_Austria GrowthRate_France GrowthRate_Germany ylw yotv

* Plot production over years for Germany
twoway line Germany Year, title("Germany production over year") xtitle("Year") ytitle("Production")

* Plot days of low water over years
twoway line ylw Year, title("Days low water over year") xtitle("Year") ytitle("Days of low water")

* Convert variables to mt
foreach var of varlist Austria France Germany Switzerland yrail ywater yroad yotv {
    replace `var' = `var' * 1e-6
}

* Run 2SLS regression using ivreg2
ivregress 2sls GrowthRate_Germany GrowthRate_Austria GrowthRate_France GrowthRate_Switzerland (L1.yotv = L1.ylw), first
ivhettest

* Run 2SLS regressionand get autocorrelation stats
ivregress 2sls GrowthRate_Germany GrowthRate_Austria GrowthRate_France GrowthRate_Switzerland (L1.yotv = L.ylw)
dwstat

*  2SLS regression using low and high waterlevel count robustness check
ivregress 2sls GrowthRate_Germany GrowthRate_Austria GrowthRate_France GrowthRate_Switzerland (L1.yotv = L1.ylowandhigh)
estimates store main_results

*2nd robustness check
* Run the first regression and store results
ivregress 2sls GrowthRate_Germany GrowthRate_Austria GrowthRate_France GrowthRate_Switzerland (yotv = ylowandhigh)

* Generate lagged variable and run 2SLS regression
gen yotv_lag2 = L2.yotv
ivregress 2sls GrowthRate_Germany GrowthRate_Austria GrowthRate_France GrowthRate_Switzerland (yotv_lag2 = L2.ylw)

* Generate another lagged variable and run 2SLS regression
gen yotv_lag3 = L3.yotv
ivregress 2sls GrowthRate_Germany GrowthRate_Austria GrowthRate_France GrowthRate_Switzerland (yotv_lag3 = L3.ylw)

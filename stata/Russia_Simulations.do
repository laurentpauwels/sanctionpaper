clear 
set more off
local dir `c(pwd)'

quietly{
    cd "../matlab/output/"
    import delimited "simulation_output.txt"

    encode country_i, g(ctry_i) 
    encode sector_r, g(sect_r)
    encode sectorcode_r, g(code_r)
    egen cross = group(country_i sectorcode_r)


    //Removing RoW and Public Sector
    gen restofworld = (country_i == "ROW")
    gen public_r = (sectorcode_r=="r51"|sectorcode_r=="r52"|sectorcode_r=="r53"|/*
    */sectorcode_r=="r54"|sectorcode_r=="r55"|sectorcode_r=="r56")
    drop if public_r==1
    drop if restofworld ==1
    //sort country_i sectorcode_r year

}
describe

replace rho = rho*100
replace eps = eps*100
replace psi = psi*100

quiet cd "`dir'/output/plots


////// rho==2.5 & eps==1.5 & psi==2 //////

reg lnv lnvhat if rho==250 & eps==150 & psi==200 

graph drop _all
graph twoway (scatter lnv lnvhat if rho==250 & eps==150 & psi==200, msize(tiny)) /*
*/ (function y = x, ra(-0.02 0.001) lwidth(thick)), /*
*/ xtitle("Approximated response of value added", size(small)) /*
*/ plotr(m(vsmall)) graphregion(m(small) fcolor(white)) title("") note("") name(x1, replace) /*
*/ ytitle("Simulated response of value added", size(small)) plotr(m(vsmall)) /*
*/ graphregion(m(small) fcolor(white)) /*
*/ legend(bplacement(n) col(1) position(3)  ring(0) /*
*/ order(- "Y = 1.13 X, R{superscript:2} = 0.97, p-value < 0.001") /*
*/ size(small) region(lstyle(none)))

quietly graph export scatter_rho250_eps150.pdf, replace


////// rho==2.5 & eps==0.5 & psi==2 //////

replace lnvhat =. if rho==250 & eps==5 & psi==200 & lnvhat>0.2
replace lnv =. if rho==250 & eps==5 & psi==200 & lnv>0.2

reg lnv lnvhat if rho==250 & eps==5 & psi==200 

graph drop _all
graph twoway (scatter lnv lnvhat if rho==250 & eps==5 & psi==200, msize(tiny)) /*
*/ (function y = x, ra(-0.11 0.06) lwidth(thick)), /*
*/ xtitle("Approximated response of value added", size(small)) /*
*/ plotr(m(vsmall)) graphregion(m(small) fcolor(white)) title("") note("") name(x1, replace) /*
*/ ytitle("Simulated response of value added", size(small)) plotr(m(vsmall)) /*
*/ graphregion(m(small) fcolor(white)) /*
*/ legend(bplacement(n) col(1) position(3)  ring(0) /*
*/ order(- "Y = 0.90 X, R{superscript:2} = 0.90, p-value < 0.001") /*
*/ size(small) region(lstyle(none)))

quietly graph export scatter_rho250_eps5.pdf, replace

////// rho==0.5 & eps==1.5 & psi==2 //////

reg lnv lnvhat if rho==5 & eps==150 & psi==200 

graph drop _all
graph twoway (scatter lnv lnvhat if rho==5 & eps==150 & psi==200, msize(tiny)) /*
*/ (function y = x,  ra(-0.01 0.01) lwidth(thick)), /*
*/ xtitle("Approximated response of value added", size(small)) /*
*/ plotr(m(vsmall)) graphregion(m(small) fcolor(white)) title("") note("") name(x1, replace) /*
*/ ytitle("Simulated response of value added", size(small)) plotr(m(vsmall)) /*
*/ graphregion(m(small) fcolor(white)) /*
*/ legend(bplacement(n) col(1) position(3)  ring(0) /*
*/ order(- "Y = 0.97 X, R{superscript:2} = 0.31, p-value < 0.001") /*
*/ size(small) region(lstyle(none)))

quietly graph export scatter_rho5_eps150.pdf, replace

////// rho==0.5 & eps==0.5 & psi==2 //////

replace lnvhat =. if rho==5 & eps==5 & psi==200 & lnvhat>20
replace lnv =. if rho==5 & eps==5 & psi==200 & lnv>20

reg lnv lnvhat if rho==5 & eps==5 & psi==200 

graph drop _all
graph twoway (scatter lnv lnvhat if rho==5 & eps==5 & psi==200, msize(tiny)) /*
*/ (function y = x,  ra(-20 21) lwidth(thick)), /*
*/ xtitle("Approximated response of value added", size(small)) /*
*/ plotr(m(vsmall)) graphregion(m(small) fcolor(white)) title("") note("") name(x1, replace) /*
*/ ytitle("Simulated response of value added", size(small)) plotr(m(vsmall)) /*
*/ graphregion(m(small) fcolor(white)) /*
*/ legend(bplacement(n) col(1) position(3)  ring(0) /*
*/ order(- "Y = 0.97 X, R{superscript:2} = 0.97, p-value < 0.001") /*
*/ size(small) region(lstyle(none)))

quietly graph export scatter_rho5_eps5.pdf, replace

////// rho==0.5 & eps==0.1 & psi==2 //////

replace lnvhat =. if rho==5 & eps==10 & psi==200 & lnvhat<-20
replace lnv =. if rho==5 & eps==10 & psi==200 & lnv<-20

reg lnv lnvhat if rho==5 & eps==10 & psi==200 
graph drop _all
graph twoway (scatter lnv lnvhat if rho==5 & eps==10 & psi==200, msize(tiny)) /*
*/ (function y = x, ra(-20 20) lwidth(thick)), /*
*/ xtitle("Approximated response of value added", size(small)) /*
*/ plotr(m(vsmall)) graphregion(m(small) fcolor(white)) title("") note("") name(x1, replace) /*
*/ ytitle("Simulated response of value added", size(small)) plotr(m(vsmall)) /*
*/ graphregion(m(small) fcolor(white)) /*
*/ legend(bplacement(n) col(1) position(3)  ring(0) /*
*/ order(- "Y = 0.89 X, R{superscript:2} = 0.92, p-value < 0.001") /*
*/ size(small) region(lstyle(none)))

quietly graph export scatter_rho5_eps10.pdf, replace

////// rho==0.1 & eps==0.1 & psi==2 //////

replace lnvhat =. if rho==10 & eps==10 & psi==200 & lnvhat<-10
replace lnvhat =. if rho==10 & eps==10 & psi==200 & lnvhat>10
replace lnv =. if rho==10 & eps==10 & psi==200 & lnv<-10
replace lnv =. if rho==10 & eps==10 & psi==200 & lnv>10

reg lnv lnvhat if rho==10 & eps==10 & psi==200 

graph drop _all
graph twoway (scatter lnv lnvhat if rho==10 & eps==10 & psi==200, msize(tiny)) /*
*/ (function y = x, ra(-10 10) lwidth(thick)), /*
*/ xtitle("Approximated response of value added", size(small)) /*
*/ plotr(m(vsmall)) graphregion(m(small) fcolor(white)) title("") note("") name(x1, replace) /*
*/ ytitle("Simulated response of value added", size(small)) plotr(m(vsmall)) /*
*/ graphregion(m(small) fcolor(white)) /*
*/ legend(bplacement(n) col(1) position(3)  ring(0) /*
*/ order(- "Y = 0.83 X, R{superscript:2} = 0.86, p-value < 0.001") /*
*/ size(small) region(lstyle(none)))
quietly graph export scatter_rho10_eps10.pdf, replace
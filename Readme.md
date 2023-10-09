# Replication Code for 'An Empirical Approximation of the Effects of Trade Sanctions with an Application to Russia'


## Introduction
The code in this repository replicate all tables and figures in Imbs and Pauwels (2023, Economic Policy). 

If you are only interested in approximating the costs of trade sanctions for sets of countries and industries, please visit the Sanction Impact Dashboard at https://exposure.trade. The Python (and MATLAB) core code for the dashboard is available from the https://github.com/laurentpauwels/sanctiondashboard repository.

### Citation
If you use any of these materials, please cite:

	Imbs, Jean and Pauwels, Laurent, 2023, "An Empirical Approximation of the Effects of Trade Sanctions with an Application to Russia," Economic Policy, Forthcoming.

### Licence
The software and programming provided (.m, .mat, .py, and .ipynb files) is licensed under [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html). Please check the license terms of the original data providers listed in [Data](#data).

## Software 
### Requirements
The software used for replications are:
 - MATLAB Version: 9.14.0.2206163 (R2023a)
 - STATA 17
 - Python 3.11.5 
	- os
	- zipfile
	- pandas (2.0.1)

	For the full python requirements check *Requirements.txt* in the `/python` folder.
	
MATLAB is used to produce Figures 2 - 6 and Tables 1 - 8. STATA is used for Figure 1 (scatter plots). Python is only used to convert XLSB format into CSV. It is not required to replicate any result of the paper. See [Data](#data) for more details. 

### Runtime
The runtime of the master file `evaluateTradeSanction.m` on 10 Apple M1 CPU cores is approximately 36 minutes. `getSubstituteMarket.m` takes up most of the computing time (around 35 minutes). The runtime of `evaluateApproximation.m` on 10 Apple M1 CPU cores is approximately 84 minutes. Most of the computing time is taken by the simulation script `getSimulationOutput.m` which takes around 42 minutes to run.

## Data

### Access
The raw and processed data can be downloaded from the folder `sanctionpaper/matlab/data` available from this [Google Drive folder](https://drive.google.com/drive/folders/1m9ka-S38a01ptVbp-jJPMy9uXinoR2kB?usp=sharing). If you clone this git repository, make sure to place the downloaded `data` folder from Google Drive within the `matlab` folder of this repository (see [Folder Structure](#folder-structure) for details). The data folder contains `Raw` and `Processed` data folders.

For convenience and to save time, the simulation output (*simulation_output.txt*) required to build the scatter plots in Figure 1 with STATA is available in the [Google Drive folder](https://drive.google.com/drive/folders/1m9ka-S38a01ptVbp-jJPMy9uXinoR2kB?usp=sharing) `sanctionpaper/matlab/output`. Place the file in the `matlab/output/` folder of this repository if you do not want to run the simulations as detailed in [Instructions](#instructions).

### Sources
The raw data come from these sources:

- OECD Inter-Country Input-Output (ICIO) data November 2021 release  (downloaded on 2 July 2023) 
	- Source: OECD-ICIO 2021 release data is available at <http://oe.cd/icio>

- WIOD Socio-Economic Accounts (SEA) data 2016 release (downloaded on 30 May 2023)
	- Source: <https://www.rug.nl/ggdc/valuechain/wiod/wiod-2016-release>

- WIOD World Input-Output Tables (WIOT) data November 2016 (downloaded on 23 June 2023)
	- Source: <https://www.rug.nl/ggdc/valuechain/wiod/wiod-2016-release>

In the [Google Drive](https://drive.google.com/drive/folders/1m9ka-S38a01ptVbp-jJPMy9uXinoR2kB?usp=sharing), the `matlab/data/raw` folder contains an `ICIO21` folder with the ICIO21 data, and a `WIOD` folder with the SEA16 data (in `data/raw/WIOD/SEA16`) and the WIOT16 data in CSV format (in `data/raw/WIOD/WIOT16`).

IMPORTANT NOTE: WIOD provides the data in XLSB format. The XLSB WIOD data is in the `WIOT_in_EXCEL.zip` located in the [Google Drive folder](https://drive.google.com/drive/folders/1m9ka-S38a01ptVbp-jJPMy9uXinoR2kB?usp=sharing) `matlab/data/raw/WIOD/`. Python is used to convert XLSB into CSV files. See `python/convertXlsb2Csv.py` code for unzipping and conversion to CSV. The converted CSV files are provided for convenience.

### Cleaning
All the data parsing and preprocessing are done with MATLAB, see `matlab/processData.m`. The script parses and pre-processes the ICIO21, SEA16, and WIOT16 data using three specific scripts in `matlab/scripts/`: `processICIO21.m`, `processSEA16.m`, and `processWIOT16.m`. Processing the ICIO21 and WIOT16 data requires two functions (in `/matlab/functions`): `idExtract.m` and  `netInventCorrect.m`. 

### Processing
The processed ICIO21, SEA16, and WIOT16 data are stored in the Google Drive in the `/matlab/data/processed` folder into three separate `.mat` structure files:

- `icio21_strc.mat` contains:
	1. the meta data (`icio21_text`), i.e., the information about the structure of the numerical data such as lists of countrycode, countries, industrycode, industries, isic_rev4 codes, years covered, name of final categories, etc.

	2. the numerical data (`icio21_data`): 
		- Z (`icio21_data.Z`), the intermediate IO data for the listed industries (R), countries (N), and years (T). Its structure is 3-dimensionsal: (NxR)x(NxR)xT. 
		- F (`icio21_data.F`), the final demand data for the same countries, industries and years. Its structure is 3-dimension: (NxR)x(NxC)xT. The columns are NxC where C are the number of final demand categories.

- `wiod16_strc.mat` has the same structure as `icio21_strc.mat` with the meta data in `wiot16_text` and the numerical data in `wiot16_data`.

- `sea16_strc.mat` has the meta data in `sea16_text` and the numerical data in `sea16_data`. SEA16 contains 16 variables instead of Input-Output type data. The country, industry, and year coverage is not the same as ICIO21. See [WIOD](https://wiod.org).

NOTE: `matlab/scripts/convertMatlabStruc2data.m` converts *MATLAB v7.3* format ("structure data") to an updated format without structure so that it is more easily compatible with other software.


## Instructions
 
 There are two main executable MATLAB 'master' codes, `evaluateTradeSanction.m` and `evaluateApproximation.m`, and one STATA Jupyter Notebook `Russia_Simulations.ipynb`. 

1. `evaluateTradeSanction.m` : Run this script to produce Tables 1 - 8 and Figures 2 - 4. It relies on 5 separate scripts (stored in the `scripts` folder) and several functions (stored in the `functions` folder). More details are available in [Scripts and Functions](#scripts-and-functions). Running the code will compare high order measure with direct measure of trade (`compareDirectTrade.m`), approximate the effect of sanctions (`approxEffectSanction.m`), produce a list of historical substitute markets (`getSubstituteMarket.m`) based on the downstream measure HOT and the upstream measure SHOT, and plot the historical substitute markets (`graphSubstituteMarket.m`) according to HOT and SHOT. The focus of the code is on the European Union (+ GBR) and the Russian Federation. The data required are: `sea16_strc.mat` and `icio21_strc.mat`.

	- NOTE 1: The graphs produced by `graphSubstituteMarket.m` depend on having run `getSubstituteMarket.m`.
	- NOTE 2: The script `concordanceAlpha.m` produces $\alpha_r$ which is required to approximate the cost of trade sanctions (`approxEffectSanction.m`).
	- NOTE 3: Make sure to download and place the downloaded `data` within the `matlab` folder, or change the file paths in the code accordingly.

2. `evaluateApproximation.m`: Run this script to produce the simulation results to produce 3D Figures B.1 - B.4 and the simulation output for Figure 1. It relies on 3 separate scripts (stored in the `scripts` folder) and several functions (stored in the `functions` folder). There are two 3D graphs showing the correlation (from regression) of simulated and approximated responses of value added ($\beta$ coefficient and $R^2$), and two 3D graphs showing the downstream approximate response of real value added (HOT) and upstream (SHOT) approximate response of real value added. The simulations are run inside each scenario script with `getSimulationOutput.m`.
	
	- The first scenario  (`scenarioSanctionRus.m`) simulate a refined petroleum shock from Russia and looks at the Russian response to the shock as well as the response from the Chemical industry in Germany (Figures B.1 and B.2). 

 	- The second scenario (`scenarioSanctionEur.m`) simulates a German Chemical shock and looks at the German approximate response and the Russian refined petroleum approximate response (Figures B.3 and B.4). 

3. `Russia_Simulations.ipynb`: The graphs in Figure 1 are constructed with STATA in this Jupyter Notebook located in the `/stata/` folder. The Jupyter Notebook outputs all the graphs in `/stata/output/plots`. The `scenarioSanctionRus.m` produces a simulation output file *simulation_output.txt* in `matlab/output`.  The *simulation_output.txt* is available in the [Google Drive folder](https://drive.google.com/drive/folders/1m9ka-S38a01ptVbp-jJPMy9uXinoR2kB?usp=sharing) `sanctionpaper/matlab/output/`.  The code in the Jupyter notebook is also available as a `.do` file in `stata/Russia_Simulations.do`.

## Folder Structure

- `matlab`: main MATLAB folder with the master files running all the necessary computations.
	- `doc`: stores documentation about the concordance of industries between ICIO21 and WIOT16.
	- `functions`: stores all matlab functions. 
	- `output`: stores tables and plots.
	- `scripts`: stores specific scripts that produce tables and figures. 

	NOTE: add the downloaded `data` folder to the `matlab` folder structure.

- `stata`: main STATA folder with a Jupyter Notebook that produces all the scatter plots (also available as a `.do` file).
	- `output/plots`: stores all the scatter plots.
	
- `python`: main executable `convertXlsb2Csv.py` relies on `matlab/data/processed` folder to convert the MATLAB data. See [Data](#data) Sources for details.  


## Scripts and Functions

### Scripts
- `compareDirectTrade.m` compares high order measures with direct measure of trade. 
- `approxEffectSanction.m` approximates the effect of trade sanctions.
- `getSubstituteMarket.m` produces a list of historical substitute markets. 
- `graphSubstituteMarket.m` plots the historical substitute markets.
- `concordanceAlpha.m` produces $\alpha_r$, the fraction of Labor Compensation over Value Added in national currency, which is required to approximate the effect of sanctions. It matches the ICIO21 industry list with the WIOT16 industry list.
- `getSimulationOutput.m` simulates the Huo et al. (2023) model to get a response of production to trade shocks so that the simulated response can be evaluated against the approximation.
- `scenarioSanctionRus.m` produces 3D Figures B.1 and B.2. 
- `scenarioSanctionEur.m` produces 3D Figures B.3 and B.4. 
- `processICIO21.m` parses and pre-processes OECD ICIO21 data.
- `processSEA16.m` parses and pre-processes WIOD SEA16 data.
- `processWIOT16.m` parses and pre-processes WIOD WIOT16 data.
- `convertMatlabStruc2data.m` converts the MATLAB structure in MATLAB v7.3 format to an updated format without structure for compatibility with other software.

### Functions
- `directTrade.m` calculates the total final goods exports and intermediate goods imports for pairs of countries and industries.
- `downstreamBan.m` computes HOT for the downstream impact of trade sanctions on the country/ies-sector(s) sanctioned.
- `upstreamBan.m` computes SHOT for the upstream impact of trade sanctions on the countries imposing the sanctions.
- `approxResponse.m` calculates the approximate real value added response according to HOT or SHOT.
- `getShares.m` creates shares out of a matrix by applying element-by-element division
- `getTransportCostImpact.m` computes the equilibrium in deviations from a steady state created by shocks to the transport costs. The main model follows Huo et al. (2021). It produces $\ln Y_t$, $\ln P_t$, $\ln PY_t$, and $\ln V_t$.
- `idMultilateral.m` creates 3 ID lists to identify sectors, sector codes, and country codes. 
- `idExtract.m` extracts specific information from a cell containing spreadsheet information.
- `netInventCorrect.m` corrects for inventories (INVNT) as discussed in Antras and Chor (2013, 2018).
- `getScriptMatrix.m` computes the main components of the Huo et al (2023) model: $\mathcal{H}$, $\mathcal{P}$, $\mathcal{M}$, and $\Lambda$.
- `getScriptH.m` computes $\mathcal{H}$.
- `getScriptM.m` computes $\mathcal{M}$.
- `getScriptP.m` computes $\mathcal{P}$.
- `getLambda.m` computes $\Lambda$.
- `grah3Dresponse.m` produces 3D graphs of the simulated $\ln V_t$ vs HOT (SHOT) implied approximation.
- `grah3Dregression.m` regresses the simulated responses to a transport cost shock on the approximate simulated responses. The regressions coefficient beta and the R2 are extracted. Then constructs 3D graph surface for a selection of elasticities rho and epsilon


## Output
In summary the Tables and Figures are 

 File                     		 	 | Exhibit                  | Script
-------------------------------------|--------------------------|--------------------------------------
matlab/output/result_tables.xlsx     | Tables 1 - 8          	| matlab/evaluateTradeSanction.m
matlab/output/simulation_output.txt	 | Dataset for Figure 1 	| matlab/evaluateApproximation.m
stata/output/plots 	 			  	 | Figure 1	    			| stata/Russia_Simulations.ipynb
matlab/output/plots				 	 | Figures 2,3,4 			| matlab/evaluateTradeSanction.m
matlab/output/plots/scenario1 	 	 | Figures B.1 & B.2 		| matlab/evaluateApproximation.m
matlab/output/plots/scenario2 	 	 | Figures B.3 & B.4| matlab/evaluateApproximation.m

NOTE: *simulation_output.txt* is not included in the repository as it is over 100MB. You can download it from the [Google Drive folder](https://drive.google.com/drive/folders/1m9ka-S38a01ptVbp-jJPMy9uXinoR2kB?usp=sharing) `sanctions/matlab/output`
## References
Antràs, P. and Chor, D. (2013). Organizing the Global Value Chain. Econometrica, 81(6):2127– 2204.

Antràs, P. and Chor, D. (2018). On the Measurement of Upstreamness and Downstreamness in Global Value Chains. In Ing, L. Y. and Yu, M., editors, World Trade Evolution: Growth, Productivity and Employment, chapter 5. Routledge.

Huo, Z., Levchenko, A. A., and Pandalai-Nayar, N. (2023). International Comovement in the Global Production Network. Working Paper 25978, National Bureau of Economic Research.

OECD (2021), OECD Inter-Country Input-Output Database, http://oe.cd/icio.

Timmer, M. P., Dietzenbacher, E., Los, B., Stehrer, R. and de Vries, G. J. (2015), "An Illustrated User Guide to the World Input-Output Database: the Case of Global Automotive Production" , Review of International Economics, 23: 575-605




## Contact Information

Laurent Pauwels, email: <laurent.pauwels@nyu.edu>


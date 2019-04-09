/*********************************************************************************
*
*	Study of Environment Lifestyle & Fibroids (SELF)
*	Hoffman Dissertation -- Aim 1 NSFG 2011-2013
*	03/26/2019
*
*********************************************************************************/

libname self "C:\Users\srhoffma\Documents\SELF\SAS Data";

/*********************************************************************************
*	Setup
*********************************************************************************/

data self.data1;
set data1;
run;

proc freq data=self.data1;
tables uf age_r race ager;
format race ager ;
run;

proc means data=self.data1; var age_r ager; run; 
*they are the same, would use ager but it does not work in later steps for some reason;

*Code Guidance From: https://www.cdc.gov/nchs/data/nsfg/Using_the_NSFG_from_2015_NCHS_conference.pdf; 

*open dataset and keep specified variables;
data FEMALE;
set self.data1/* (replace with your PUF fem resp file filename) */
(keep=caseid uf age_r race sest secu wgt2011_2013 );
*divide weight by 1000 to get numbers in thousands – optional;
wgt1000=wgt2011_2013/1000;
*Create subpopulation variable for all black women aged 23-35;
bwattf=2;
if 23 le age_r le 35 and race=1 then bwattf=1;
run;

proc sort data=female out=FSORTED;
by SEST SECU;
run;

proc freq data=female; tables bwattf; run;

proc sql; select count (distinct caseid) from female where 23 le age_r le 35 and race=1; quit;

proc freq data=female; tables bwattf*uf; run;

ods rtf style=minimal startpage = no;
title "Percentage of black women aged 23-35 who had ever been diagnosed with uterine fibroids: 2011-2013";
title2 "Unweighted counts";
proc freq data=female; tables bwattf*uf; run;

/*********************************************************************************
*	PROC SURVEYFREQ
*********************************************************************************/

*weighted frequency SE and 95% CI;
proc surveyfreq data=Fsorted;
cluster SECU;
stratum SEST;
title "Percentage of black women aged 23-35 who had ever been diagnosed with uterine fibroids: 2011-2013";
title2 "Weighted to produce national estimates";
table bwattf*uf/ NOCELLPERCENT NOTOTAL NOFREQ NOWT CL row NOSPARSE;
weight wgt2011_2013;
*format hadsex yesno.;
run;
ods rtf close;

ods rtf style=minimal bodytitle startpage = no;
proc surveyfreq data=Fsorted;
cluster SECU;
stratum SEST;
title "Percentage of women who had ever been diagnosed with uterine fibroids by race and age: 2011-2013";
table race*age_r*uf/ NOCELLPERCENT NOTOTAL NOFREQ NOWT CL row NOSPARSE;
weight wgt2011_2013;
*format hadsex yesno.;
run;
ods rtf close;

/*********************************************************************************
*	Verification (Compare to Existing Literature)
*********************************************************************************/

data FEMALE;
set self.data1/* (replace with your PUF fem resp file filename) */
(keep=caseid CONSTAT1 age_r race sest secu wgt2011_2013 );
*divide weight by 1000 to get numbers in thousands – optional;
wgt1000=wgt2011_2013/1000;
*Create subpopulation variable for all black women aged 23-35;
bwattf=2;
if 15 le age_r le 44 then bwattf=1;
run;

proc sort data=female out=FSORTED;
by SEST SECU;
run;

ods rtf style=minimal bodytitle startpage = no;
proc surveyfreq data=Fsorted;
cluster SECU;
stratum SEST;
title "Current contraceptive use among black women aged 23-35 in the United States: 2011-2013";
table bwattf*CONSTAT1/ NOCELLPERCENT NOTOTAL NOFREQ NOWT CL row NOSPARSE;
weight wgt2011_2013;
*format hadsex yesno.;
run;
ods rtf close;

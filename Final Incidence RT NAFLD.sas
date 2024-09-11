
* /////////////////////////;
* Start date  4.1.23
* title 'Incidence rates of hepatocellular carcinoma based on risk stratification in steatotic liver disease for precision medicine:
         a real-world longitudinal nationwide study';


* *********************************************************************;
* *********************************************************************;
options nodate nocenter nodate;

* **********************;
* RECEIVED DATA UPDATE 4/10/2022;
* IMPORT TRUVEN DATA;
    proc import
      datafile="S:\users\v2985\Lai\Data\NAFLD_finaltable_5.8.23.csv"
      dbms=csv out=a replace; getnames=yes; guessingrows=max; run;

* **********************;
* Data formats;
 proc format;
   value sexfmt 1='Male'  2='Female';
   value yesnofmt 1='Yes' .,0=' No';
   value regionfmt 1='Northeast' 2='North Central' 3='South' 4='West' 5='Unknown';
   value aefmt 1='HCC';


* //////////////////////////;
* DATA MGMT;

  data a1; set a;
  format
   ald_index pepulcer_index plegia_index /* cerebrovascular_index chf_index pvd_index */
   ckd_index dcc_index copd_index  hbV_index hcc_index gibleed_index mildliver_index
   hcv_index hiv_index plegia_index dementia_index overweight_index obese_index mildliver_index
   medsev_liver_index  mmddyy10.;

   Age = round((NAFLD_indexdate-mdy(7,1,DOByear))/365.25);
   Age_le60=(age < 60);
   Enrollment_time=round(Enrollment_end-enrollment_start);
   Enrollment_12mth_flag=Enrollment_time < 366;

* create age category;
  if 18 <= age <= 29 then Age_cat ='1. 18-29'; else
  if 30 <= age <= 39 then Age_cat ='2. 30-39'; else
  if 40 <= age <= 49 then Age_cat ='3. 40-49'; else
  if 50 <= age <= 59 then Age_cat ='4. 50-59'; else
  if 60 <= age <= 69 then Age_cat ='5. 60-69'; else
  if 70 <= age <= 79 then Age_cat ='6. 70-79'; else
  if 80 <= age <= 110 then Age_cat ='7. 80+';

* create second age category (Dr Lai 5/10/23);
  if  0 <= age <  40 then Age_cat2 ='1. <40  '; else
  if 40 <= age <= 49 then Age_cat2 ='2. 40-49'; else
  if 50 <= age <= 59 then Age_cat2 ='3. 50-59'; else
  if 60 <= age <= 69 then Age_cat2 ='4. 60-69'; else
  if 70 <= age <= 110 then Age_cat2 ='5. 80+';

* create index year category;
  NAFLD_year=year(nafld_indexdate);
  if 2006 <= year(nafld_indexdate) <= 2010 then NAFLD_Indexyear_cat ='1. 2006-2010'; else
  if 2011 <= year(nafld_indexdate) <= 2015 then NAFLD_Indexyear_cat ='2. 2011-2015'; else
  if 2016 <= year(nafld_indexdate) <= 2021 then NAFLD_Indexyear_cat ='3. 2016-2021';

  if mdy(3,1,2006) <= nafld_indexdate <= mdy(3,31,2007) then NAFLD_Indexyear_cat2 ='01. 2006.03-2007.03'; else
  if mdy(4,1,2007) <= nafld_indexdate <= mdy(3,31,2008) then NAFLD_Indexyear_cat2 ='02. 2007.04-2008.03'; else
  if mdy(4,1,2008) <= nafld_indexdate <= mdy(3,31,2009) then NAFLD_Indexyear_cat2 ='03. 2008.04-2009.03'; else
  if mdy(4,1,2009) <= nafld_indexdate <= mdy(3,31,2010) then NAFLD_Indexyear_cat2 ='04. 2009.04-2010.03'; else
  if mdy(4,1,2010) <= nafld_indexdate <= mdy(3,31,2011) then NAFLD_Indexyear_cat2 ='05. 2010.04-2011.03'; else
  if mdy(4,1,2011) <= nafld_indexdate <= mdy(3,31,2012) then NAFLD_Indexyear_cat2 ='06. 2011.04-2012.03'; else
  if mdy(4,1,2012) <= nafld_indexdate <= mdy(3,31,2013) then NAFLD_Indexyear_cat2 ='07. 2012.04-2013.03'; else
  if mdy(4,1,2013) <= nafld_indexdate <= mdy(3,31,2014) then NAFLD_Indexyear_cat2 ='08. 2013.04-2014.03'; else
  if mdy(4,1,2014) <= nafld_indexdate <= mdy(3,31,2015) then NAFLD_Indexyear_cat2 ='09. 2014.04-2015.03'; else
  if mdy(4,1,2015) <= nafld_indexdate <= mdy(3,31,2016) then NAFLD_Indexyear_cat2 ='10. 2015.04-2016.03'; else
  if mdy(4,1,2016) <= nafld_indexdate <= mdy(3,31,2017) then NAFLD_Indexyear_cat2 ='11. 2016.04-2017.03'; else
  if mdy(4,1,2017) <= nafld_indexdate <= mdy(3,31,2018) then NAFLD_Indexyear_cat2 ='12. 2017.04-2018.03'; else
  if mdy(4,1,2018) <= nafld_indexdate <= mdy(3,31,2019) then NAFLD_Indexyear_cat2 ='13. 2018.04-2019.03'; else
  if mdy(4,1,2019) <= nafld_indexdate <= mdy(3,31,2020) then NAFLD_Indexyear_cat2 ='14. 2019.04-2020.03'; else
  if mdy(4,1,2020) <= nafld_indexdate <= mdy(3,31,2021) then NAFLD_Indexyear_cat2 ='15. 2020.04-2021.03';
  if mdy(4,1,2021) <= nafld_indexdate <= mdy(3,31,2022) then NAFLD_Indexyear_cat2 ='16. 2021.04-2022.03';

* convert missing to 'No';
  array x(*) HCC HBV HCV HIV ALD otherliverdiseases CC DCC Varices gibleed overweight obese MI CHF CKD PVD COPD Rheuma pcp1
             Overweight Cerebrovascular Dementia Mildliver ModerateSevereLiver Plegia pvd pepticulcer hyperlipidemia hypertension
             dm_uncomplicated dm_complicated malignancy1 malignancy2 ;
   do i = 1 to dim(x);
    if x(i)=. then x(i)=0; end; drop i;

* create viral combo variable;
  Viral_hep=(HBV=1 OR HCV=1);

* create non-liver cancer variable;
   non_liver_cancer=(malignancy1=1 OR malignancy2=1);

* create new CC group (3 levels); length cc_new $14.;
  if CC = 0                                  then CC_new = '0. No CC'; else
  if CC = 1 & (cc_index-nafld_indexdate) < 181 then CC_new = '1. CC <= 6mths'; else
  if CC = 1 & (cc_index-nafld_indexdate) > 180 then CC_new = '2. CC  > 6mths';

* calc study time;
  if HCC_index ne . then do;
     HCC_prior_excl=(HCC_index <= NAFLD_indexdate); end;
  else HCC_prior_excl=0;

  if HCC_index ne . then do;
     HCC_time = (HCC_index - nafld_indexdate); end;
  else HCC_Time = enrollment_end - NAFLD_indexdate;
     HCC_timeYrs=(HCC_time/365.25);

* calc corrected time for developed CC;
  if HCC_index ne . & CC_new='1. CC <= 6mths' then do;
     HCC_timecorr = (HCC_index - nafld_indexdate); end; else

  if HCC_index ne . & CC_new='2. CC  > 6mths' then do;
     HCC_timecorr = (HCC_index - cc_index); end; else
  if HCC_index = . & CC_new='2. CC  > 6mths' then do;
     HCC_timecorr = (enrollment_end - cc_index); end; else

  if CC_new='0. No CC' then do;
     HCC_Timecorr=HCC_time; end; else
     HCC_Timecorr=HCC_time;
     HCC_timeYrscorr=(HCC_timecorr/365.25);

 *** Calculate the Charlson Comorbidity Score for prior conditions;
 Cardiovascular = (MI OR CHF OR cerebrovascular or pvd);
 Charlson =
 1*(MI) +
 1*(CHF) +
 1*(PVD) +
 1*(Cardiovascular) +
 1*(COPD) +
 1*(dementia) +
 2*(plegia) +
 1*(DM_uncomplicated) +
 2*(DM_complicated) +
 2*(CKD) +
 1*(mildliver) +
 3*(Moderatesevereliver) +
 1*(pepticulcer) +
 1*(rheuma) +
 6*(HIV);

  label
     PATID                    = 'Patient ID'                         Overweight            = 'Overweight Index Date'
     NAFLD_indexdate          = 'NAFLD Index Date'                   MI_index              = 'MI Index Date'
     DOBYEAR                  = 'Date of Birth Year'                 CHF_index             = 'CHF Index Date'
     SEX1                     = 'Sex'                                PVD_index             = 'PVD Index Date'
     Enrollment_start         = 'Enrollment Start'                   COPD_index            = 'COPD Index Date'
     Enrollment_end           = 'Enrollemnt End'                     Rheuma                = 'Rheumatoid Arthritis'
     Region_final             = 'Region Final'                       Rheuma_index          = 'Rheumatoid Arthritis Index Date'
     HCC                      = 'HCC'                                Overweight            = 'Overweight'
     HCC_index                = 'HCC Index Date'                     Overweight_index      = 'Overweight Index Date'
     HBV                      = 'HBV'                                Cerebrovascular       = 'Cerebrovascular Dis'
     hbv_index                = 'HBV Index Date'                     Cerebrovascular_index = 'Cerebrovascular Dis Index Date'
     HCV                      = 'HCV'                                Dementia              = 'Dementia'
     HCV_index                = 'HCV Index Date'                     Dementia_index        = 'Dementia Index Date'
     HIV                      = 'HIV'                                Mildliver             = 'Mild Liver Dis'
     HIV_index                = 'HIV Index Date'                     Plegia                = 'Plegia'
     ALD                      = 'ALD'                                CKD                   = 'CKD'
     ALD_index                = 'ALD Index Data'                     CKD_index             = 'CKD Index Date'
     OtherLiverDiseases       = 'Other Liver Disease'                Malignancy1           = 'Malignancy 1'
     Otherliverdiseases_index = 'Other Liver Disease Index Date'     Malignancy1_index     = 'Malignancy 1 Index Date'
     DM_uncomplicated         = 'DM-uncomplicated'                   Malignancy2           = 'Malignancy 2'
     DM_uncomplicated_index   = 'DM-uncomplicated Index Date'        Malignancy2_index     = 'Malignancy 2 Index Date'
     CC                       = 'CC'                                 DrugUse               = 'Drug use'
     CC_index                 = 'CC Index Date'                      Druguse_index         = 'Drug use Index Date'
     DCC                      = 'DCC'                                CHF                   = 'CHF'
     DCC_index                = 'DCC Index Date'                     CHF_index             = 'CHF Index Date'
     Varices                  = 'Varices'                            PVD                   = 'PVD'
     Varices_index            = 'Index Varices Date'                 Pepticulcer           = 'Peptic Ulcer'
     GIBLEED                  = 'GI Bleed'                           Hyperlipidemia        = 'Hyperlipidemia'
     Gibleed_index            = 'GI Bleed Index Data'                Hypertension          = 'HTN'
     ModerateSevereLiver      = 'Mod Severe Liver Dis'               Specialist1           = 'Gastroenterologist/Inf Dis Doctor'
     App1                     = 'Adv Practive Provider'              Age                   = 'Age, yrs'
     Enrollment_time          = 'Time Enrolled'                      PCP1                  = 'Primary Care Provider'
     DM_complicated         = 'DM-complicated'                       CC_new                = 'CC stratifed +/- 6 mths NAFLD'
     DM_complicated_index   = 'DM-complicated Index Date'            non_liver_cancer      = 'Non-liver Cancer';

  format Sex1 sexfmt. region_final region_final regionfmt.
         HCC HBV HCV HIV ALD otherliverdiseases CC DCC varices gibleed overweight obese MI CHF PVD COPD Rheuma App1 Specialist1 PCP1
         Overweight Cerebrovascular Dementia Mildliver Plegia ModerateSevereLiver CKD dm_uncomplicated dm_complicated
         hyperlipidemia hypertension pepticulcer hcc_prior_excl viral_hep age_le60
         Enrollment_12mth_flag cardiovascular age_le60 non_liver_cancer yesnofmt.; run;

dm 'odsresults; clear';
* for CONSORT graph;
  proc sql; select count(*) from a; quit;
  proc freq data=a1; tables viral_hep  ald otherliverdiseases hcc_prior_excl Enrollment_12mth_flag; run;
  proc freq data=a1; tables viral_hep* ald *otherliverdiseases* hcc_prior_excl* Enrollment_12mth_flag /list; run;



* ////////////////////////////////////////////////////////////////////;
* ///////////////////////////////////////////////////;
* FINAL ANALYSIS DATASET;
  data b; set a1;
   where (age >17) &
   (Viral_hep ne 1) &
         (ALD ne 1) &
         (otherliverdiseases ne 1) &
         (HCC_prior_excl ne 1) &
         (Enrollment_12mth_flag ne 1);

  * Age_cat3, per Mindie 6/5;
  if       age <= 50 then age_cat3='1. <=50'; else
  if 51 <= age <= 64 then age_cat3='2. 51-64'; else
  if       age >  64 then age_cat3='3. 65+'; run;


* test exclusion criteria
  examine preliminary results;
dm 'odsresults; clear';
  proc freq data=a1; tables viral_hep* ald *otherliverdiseases* hcc_prior_excl* Enrollment_12mth_flag /list; run;
  proc freq data=b; tables viral_hep* ald *otherliverdiseases* hcc_prior_excl* Enrollment_12mth_flag /list; run;
  proc freq data=b; tables cc hcc cc*hcc (pcp1 specialist1)*cc cc*age_cat*sex1; run;
  proc freq data=b; tables age*age_cat age_le60 sex1 cc dm_uncomplicated /norow nocol nopercent missing; *where age_cat = ''; run;


proc means data=b maxdec=1 n mean stddev; var age charlson ; run;
proc means data=b maxdec=1 n mean stddev; class cc; var age charlson; run;
proc means data=b maxdec=1 n mean stddev; class cc_new; var age charlson; run;

proc freq data=b; tables (sex1 pcp1 specialist1 malignancy1 age_cat malignancy2 nafld_indexyear_cat
     dm_uncomplicated ckd cardiovascular non_liver_cancer)*(cc)/norow ; run;

proc freq data=b page; where cc_new ne '0. No CC';
   tables (sex1 pcp1 specialist1
     dm_uncomplicated ckd cardiovascular non_liver_cancer)*(cc_new)/norow chisq ; run;

proc freq data=b page;
   tables cc*dm_uncomplicated*age_cat3*sex1/norow nocol nopercent; run;

* //////////////////////////////;
* Generate tables;
%let x1 = age_cat sex1 dm_uncomplicated specialist1 pcp1 app1 Nafld_indexyear_cat;
%let x2 = age_le60  sex1 cc dm_uncomplicated ckd cardiovascular non_liver_cancer;
%let x3 = age_cat age_cat2 sex1 cc dm_uncomplicated;
 proc tabulate data=b missing;
   class cc hcc &x1 &x2 NAFLD_Indexyear_cat2 cc_new;
   var hcc_time age charlson;
  * tables (age charlson), cc*(mean stddev) / rts=20 printmiss;
  * tables (&x1), cc*(n colpctn) all*(n colpctn) /rts=20 printmiss box='Table 1';
  * tables (&x2), cc*(n colpctn) all*(n colpctn) /rts=20 printmiss box='Table 1';
  * tables (&x3), (n colpctn) all*(n colpctn) /rts=20 printmiss box='Final Table 2';
  * tables (NAFLD_Indexyear_cat2), cc*(n colpctn) all*(n colpctn) /rts=20 printmiss box='Table 1';
   tables (age charlson), cc_new*(mean stddev) / rts=20 printmiss;
   tables (&x1), cc_new*(n colpctn) /rts=20 printmiss box='Table 1';
   tables (&x2), cc_new*(n colpctn) /rts=20 printmiss box='Table 1';
   keylabel n='N' sum='Sum' colpctn='%'; run; quit;


/*

NAFLD 2006-2021 n=985841

Exclusion
  n=66881 Viral Hep
  n=105988 Alcoholic Liver Dis
  n=34716 Other liver disease
  n=6162 HCC at Baseline
  n=67836 < 12 mth Followup
  n=age<18 8500

**Final data set ****
  n=741816 patients w/NAFLD
  n=110538 w/Cirrhosis
    n=1440 HCC
    n=109098  wo/HCC

  n=639773 wo/cirrhosis
    n=298 HCC
    n=639475 wo/HCC
*/


* flag variables for exclusion criteria - CONSORT figure;

proc sql; select min(enrollment_start) format mmddyy10., max(enrollment_end) format mmddyy10. from a1; quit;
proc sql; select count(*) as total_count from a; quit;
proc sql; select count(*) as total_count from a1; quit;
proc sql; select count(*) as total_count from b; quit;


* *************************************;
* TABULATE DATA;

%let x1=sex1 region_final HCC HBV HCV HIV ALD otherliverdiseases DM_uncomplicated
        CC DCC Varices gibleed overweight obese MI CHF PVD COPD Rheuma
        Overweight  Cerebrovascular Dementia Mildliver ModerateSevereLiver Plegia pvd pepticulcer hyperlipidemia hypertension;
  proc tabulate data=a1 missing; class &x1;
       tables (&x1),(n colpctn) /rts=21  printmiss box='Demographics';
       keylabel n='N' colpctn='%'; run;


proc means data=b maxdec=1 n sum; var hcc_timeyrs; run;
proc means data=b maxdec=1 n sum; class hcc; var hcc_timeyrs; run;
proc means data=b maxdec=1 n mean stddev min max; var age; run;
proc freq data=b; tables age_cat nafld_indexYear_cat hcc; run;
proc freq data=b; tables cc cc_new hcc cc*hcc cc_new*hcc cc*cc_new/list; run;


* PT rate calculator
* REPLACE DV AS NEEDED;

%let AE1 = hcc;           * event/outcome;
%let AE0 = hcc_timeyrs;   * PT variable;

creates event count numerator;
  data Long_N; set b;
    array x [*] &AE1;                    /* <== specify explanatory variables HERE */
     do varNum = 1 to dim(x);
      VarName = vname(x[varNum]);        /* variable name in char var              */
      Value = x[varNum];                 /* value for each variable for each obs   */
      output; end; run;

* creates PT denominator;
  data Long_D; set b;
    array x [*] &AE0;                    /* <== specify explanatory variables HERE */
     do varNum = 1 to dim(x);
      VarName = vname(x[varNum]);        /* variable name in char var              */
      Value = x[varNum];                 /* value for each variable for each obs   */
      output; end; run;


 dm 'odsresults; clear';
  %let dv = cc_new;
  proc sql; create table _temp as select distinct(varname), varnum from long_N; quit;
  proc sql; create table N as select varnum, &DV, sum(value) as N
            from long_N group by varnum, &DV order by &DV; quit;

  proc sql; create table D as  select varnum, &DV,  sum(value) as PT
            from long_D group by varnum, &DV order by &DV; quit;

  proc sql; create table PT1 as select N.&DV, N.*, D.PT
            from N N left join D D
            on N.varnum=D.varnum AND N.&DV=D.&DV order by N.&DV, N.varnum; quit;

  proc sql; create table PT2 as select PT1.*, _temp.varname from PT1 a left join _temp b
           on a.varnum=b.varnum order by a.&DV, b.varnum; quit;
  data PT3; set pt2; rate=round(n/pt*1000,.01);
                    LCL=round((n-1.96*(sqrt(n)))/pt*1000,.01);
                    UCL=round((n+1.96*(sqrt(n)))/pt*1000,.01);
                    array X LCL UCL; do i = 1 to dim(x); if x(i) <0.0 then x(i)=0.0; end;
            format rate lcl ucl 6.1 varnum aefmt.;
            rate_U_L=catx('~',rate,lcl,ucl); n_pt=catx('~',n,pt); /* rate w/CI */
            n_py_rate_U_L=catx('~',n,pt,rate,lcl,ucl); n_pt=catx('~',n,pt);  /* n pt rate w/CI */
            label rate='Rate per 1,000/PY'; run;
  proc sort data=pt3; by varnum; run;
  proc transpose data=pt3 out=pt3ta; by varnum; id &dv; var n_pt; run;
  proc print data=pt3ta; title "by &dv N, Person Years"; run;
  proc transpose data=pt3 out=pt3tb; by varnum; id &dv; var rate_u_l; run;
  proc print data=pt3tb; title "by &dv Rate per 1,000 PY"; run;


* ///////////////////////////////////////////////////////;
* use for overall incidence;
dm 'odsresults; clear';
data frank; set b;  where cc=0 & dm_uncomplicated=0 & age_le60=0;
  data Long_N; set frank;
    array x [*] &AE1;                    /* <== specify explanatory variables HERE */
     do varNum = 1 to dim(x);
      VarName = vname(x[varNum]);        /* variable name in char var              */
      Value = x[varNum];                 /* value for each variable for each obs   */
      output; end; run;

* creates PT denominator;
  data Long_D; set frank;
    array x [*] &AE0;                    /* <== specify explanatory variables HERE */
     do varNum = 1 to dim(x);
      VarName = vname(x[varNum]);        /* variable name in char var              */
      Value = x[varNum];                 /* value for each variable for each obs   */
      output; end; run;

 dm 'odsresults; clear';
  %let dv = sex1;
  proc sql; create table _temp as select distinct(varname), varnum from long_N; quit;
  proc sql; create table N as select varnum, &DV, sum(value) as N
            from long_N group by varnum, &DV order by &DV; quit;

  proc sql; create table D as  select varnum, &DV,  sum(value) as PT
            from long_D group by varnum, &DV order by &DV; quit;

  proc sql; create table PT1 as select N.&DV, N.*, D.PT
            from N N left join D D
            on N.varnum=D.varnum AND N.&DV=D.&DV order by N.&DV, N.varnum; quit;

  proc sql; create table PT2 as select PT1.*, _temp.varname from PT1 a left join _temp b
           on a.varnum=b.varnum order by a.&DV, b.varnum; quit;
  data PT3; set pt2; rate=round(n/pt*1000,.01);
                    LCL=round((n-1.96*(sqrt(n)))/pt*1000,.01);
                    UCL=round((n+1.96*(sqrt(n)))/pt*1000,.01);
                    array X LCL UCL; do i = 1 to dim(x); if x(i) <0.0 then x(i)=0.0; end;
            format rate lcl ucl 6.1 varnum aefmt.;
            rate_U_L=catx('~',rate,lcl,ucl); n_pt=catx('~',n,pt); /* rate w/CI */
            n_py_rate_U_L=catx('~',n,pt,rate,lcl,ucl); n_pt=catx('~',n,pt);  /* n pt rate w/CI */
            label rate='Rate per 1,000/PY'; run;
  proc sort data=pt3; by varnum; run;
  proc transpose data=pt3 out=pt3ta; by varnum; id &dv; var n_pt; run;
  proc print data=pt3ta; title "by &dv N, Person Years"; run;
  proc transpose data=pt3 out=pt3tb; by varnum; id &dv; var rate_u_l; run;
  proc print data=pt3tb; title "by &dv Rate per 1,000 PY"; run;


proc freq data=b; where cc=1 & sex1=1 & age_le60=1; tables dm_uncomplicated*hcc; run;


* >>>>>>>>>>>>>__________>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;
* >>>__________>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;
* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>__________>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;
* >>>>>>>>>>>>>>>>>>>>>>>____________>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;
* SECOND AGE CAT VARIABLE;

 data c; set b; where cc=1 and sex1=1; run;

* creates event count numerator;
  data Long_Nc; set c;
    array x [*] &AE1;                    /* <== specify explanatory variables HERE */
     do varNum = 1 to dim(x);
      VarName = vname(x[varNum]);        /* variable name in char var              */
      Value = x[varNum];                 /* value for each variable for each obs   */
      output; end; run;

* creates PT denominator;
  data Long_Dc; set c;
    array x [*] &AE0;                    /* <== specify explanatory variables HERE */
     do varNum = 1 to dim(x);
      VarName = vname(x[varNum]);        /* variable name in char var              */
      Value = x[varNum];                 /* value for each variable for each obs   */
      output; end; run;

dm 'odsresults; clear';
* stratified;
  %let dv = dm_uncomplicated;
  %let sv = age_cat3;
  proc sql; create table _tempc as select distinct(varname), varnum from long_Nc; quit;
  proc sql; create table Nc as select varnum, &SV, &DV, sum(value) as N
            from long_Nc group by varnum, &SV, &DV order by &SV, &DV; quit;

  proc sql; create table Dc as select varnum, &SV, &DV,  sum(value) as PT
            from long_Dc group by varnum, &SV, &DV order by &SV,&DV; quit;

  proc sql; create table PT1c as select N.&SV, N.&DV, N.*, D.PT
            from Nc N left join Dc D
            on N.varnum=D.varnum AND N.&DV=D.&DV AND N.&SV=D.&SV
          order by N.&DV, N.varnum; quit;

  proc sql; create table PT2c as select a.*, b.varname from PT1c a left join _tempc b
           on a.varnum=b.varnum order by a.&SV, a.&DV, b.varnum; quit;
  data PT3c; set pt2c; rate=round(n/pt*1000,.01);
                    LCL=round((n-1.96*(sqrt(n)))/pt*1000,.01);
                    UCL=round((n+1.96*(sqrt(n)))/pt*1000,.01);
                    array X LCL UCL; do i = 1 to dim(x); if x(i) <0.0 then x(i)=0.0; end;
            format rate lcl ucl 6.01 varnum aefmt.;
            rate_U_L=catx('~',rate,lcl,ucl); n_pt=catx('~',n,round(pt,.1)); /* rate w/CI */
            n_py_rate_U_L=catx('~',n,pt,rate,lcl,ucl); n_pt=catx('~',n,round(pt,.1));  /* n pt rate w/CI */
            label rate='Rate per 1000/PY'; run;
  proc sort data=pt3c; by varnum; run;
  proc transpose data=pt3c out=pt3tac; by varnum; id &SV &dv; var n_pt; run;
  proc print data=pt3tac; run; proc contents data=pt3tac; run;
 /* proc print data=pt3tac; title "by &dv N, Person Years"; run; */
  proc transpose data=pt3tac out=pt3tac2y; var _1____50Yes _2__51_6Yes _3__65_Yes;
  proc transpose data=pt3tac out=pt3tac2n; var _1____50No _2__51_6No _3__65_No;
  data pt3tac3; set pt3tac2y pt3tac2n;
  proc print data=pt3tac3; title "by &dv Rate per 1,000 PY"; run;
  proc transpose data=pt3c out=pt3tbc; by varnum; id &SV &dv; var rate_u_l; run;
/*  proc print data=pt3tbc; title "by &dv Rate per 1,000 PY"; run; */
  proc transpose data=pt3tbc out=pt3tbc2y; var _1____50Yes _2__51_6Yes _3__65_Yes;
  proc transpose data=pt3tbc out=pt3tbc2n; var _1____50No _2__51_6No _3__65_No;
  data pt3tbc3; set pt3tbc2y pt3tbc2n;
  proc print data=pt3tbc3; title "by &dv Rate per 1,000 PY"; run;



* KAPLAN-MEIER CUMULATIVE INCIDENCE;
 data u; set b; where cc=1 and sex1=1; run;
%let xxx=dm_uncomplicated;
 ods output cif=cif1;
  proc lifetest data=u plots=cif(test) timelist=5.0 10.0;
   time hcc_timeyrs*HCC(0)/eventcode=1;
   strata &xxx age_cat2 / order=internal; format Dm_uncomplicated yesnofmt.; run;
  data cif1a; set cif1;  est=catx('~',round(CIF,.001),round(CIF_LCL,.001),round(CIF_UCL,.001)); run;
  proc print data=cif1a; run;
  proc transpose data=cif1a out=cif1at; by &xxx age_cat2 ; id timelist; var est; run;
  proc print data=cif1at; run;


* KAPLAN-MEIER CUMULATIVE INCIDENCE - OVERALL BY AGE CAT;
 data u; set b; where cc=1; run;
%let xxx=sex1;
 ods output cif=cif2;
  proc lifetest data=u plots=cif(test) timelist=5.0 10.0;
   time hcc_timeyrs*HCC(0)/ eventcode=1;
   strata cc &xxx age_cat2/ order=internal; run;
  data cif2a; set cif2;  est=catx('~',round(CIF,.001),round(CIF_LCL,.001),round(CIF_UCL,.001)); run;
  proc print data=cif2a; run;
  proc transpose data=cif2a out=cif2at; by cc &xxx age_cat2;  id timelist; var est; run;
  proc print data=cif2at; run;

* //////////////////////////////////////;
* TEMPLATE FOR FIGURES 2, 3 AND 4;

  proc template;
  delete Stat.Lifetest.Graphics.ProductLimitSurvival / store=sasuser.templat;
  delete Stat.Lifetest.Graphics.ProductLimitSurvival2 / store=sasuser.templat;
  run;

* create temp dataset;
data crap; set b; hcc_timeyrs=abs(hcc_timeyrs); run;
%let xxx=age_cat3;
ods trace on;
ods graphics on; ods output cif=cifout;
  proc lifetest data=crap plots=cif(test) timelist=0 1 2 3 4 5 6 7 8 9 10.0 atrisk outcif=cif2 reduceout;
   time hcc_timeyrs*HCC(0)/eventcode=1;
   strata &xxx / order=internal; label hcc_timeyrs='Time, years'; run;
ods trace off;
proc print data=cifout; run;

proc lifetest data=crap plots=survival intervals = 0 to 10 by 1 maxtime=10
     plots=survival (cb=hw atrisk=0 to 10 by 1); time hcc_timeyrs*HCC(0); strata cc; run;

* Generate figure 3;
  data fred; set b; hcc_timeyrs=abs(hcc_timeyrs); run;
  ods graphics on; ods output cif=cifout;
  proc lifetest data=fred plots=cif(test) timelist=0 1 2 3 4 5 6 7 8 9 10.0 atrisk outcif=cif2 reduceout;
   by cc dm_uncomplicated age_cat3;
   time hcc_timeyrs*HCC(0)/eventcode=1;
   strata age_cat3 / order=internal; label hcc_timeyrs='Time, years'; run;
  ods trace off;
  proc print data=cifout; run;

* Generate figure 4;
  data rack; set b; hcc_timeyrs=abs(hcc_timeyrs); run;
  ods graphics on; ods output cif=cifout10;
  proc sort data=rack; by cc dm_uncomplicated age_cat2;
  proc lifetest data=rack plots=cif(test) timelist=0 1 2 3 4 5 6 7 8 9 10.0 atrisk reduceout;
      by cc dm_uncomplicated age_cat2;
   time hcc_timeyrs*HCC(0)/eventcode=1;
   strata sex1 / order=internal; label hcc_timeyrs='Time, years'; run;
  ods trace off;
  proc print data=cifout10; run;
  proc freq data=b; where cc=0 & dm_uncomplicated=0 & age_le60=0; tables sex1 /list; run;


/*
  data cif2a; set cif2;  est=catx('~',round(CIF,.001),round(CIF_LCL,.001),round(CIF_UCL,.001)); run;
  proc print data=cif2a; run;
  proc transpose data=cif2a out=cif2at; by &xxx;  id timelist; var est; run;
  proc print data=cif2at; run;
*/

*** for cell counts in tables;
 dm 'odsresults; clear';
 proc tabulate data=b; class age_cat age_cat2 cc hcc sex1 dm_uncomplicated dcc;
*tables cc*age_cat,sex1;
*tables cc*age_cat2,sex1;
*tables dm_uncomplicated*age_cat,sex1;
*tables dm_uncomplicated*age_cat2,sex1;
tables dm_uncomplicated*age_cat,cc*sex1;
tables dm_uncomplicated*age_cat2,cc*sex1;
*tables dcc*age_cat,sex1;
*tables dcc*age_cat2,sex1;
*tables dm_uncomplicated*age_cat,dcc*sex1;
*tables dm_uncomplicated*age_cat2,dcc*sex1; run;


* //////////////////////////////////////////////////////////;
* VARIABLE TO CONSIDER IN ADJUSTMENT:
  age sex charlston cc dm_uncomplicated NAFLD_Indexyear_cat;

 data b9; set b;
* create new dcc variable to create 3-levels for Lai;
  if dcc=0 and cc=0 then dcc_new ='0. None'; else
  if dcc=1 and cc=0 then dcc_new ='1. Comp'; else
  if dcc=0 and cc=1 then dcc_new ='1. Comp'; else
  if dcc=1 and cc=1 then dcc_new ='2. Decomp';

 hcc_timeyrs=abs(hcc_timeyrs);
  run;

proc phreg data=b9;
   class sex1 (ref='Female') dm_uncomplicated (ref='No') NAFLD_Indexyear_cat (ref='1. 2006-2010') cc (ref='No') dcc (ref='No');
   model hcc_timeyrs*hcc(0)= sex1 /rl; *hazardratio age/ units=1; *hazardratio charlson/ units=1; run;

proc phreg data=b9;
   class sex1 (ref='Female') dm_uncomplicated (ref='No') NAFLD_Indexyear_cat (ref='1. 2006-2010') cc (ref='No') dcc (ref='No');
   model hcc_timeyrs*hcc(0)= age sex1 charlson cc dm_uncomplicated nafld_indexyear_cat /rl;
   hazardratio age/ units=1; hazardratio charlson/ units=1; run;

* with new 3-level dcc variable;
  proc phreg data=b9;
    class sex1 (ref='Female') dm_uncomplicated (ref='No') NAFLD_Indexyear_cat (ref='1. 2006-2010') cc (ref='No') dcc (ref='No')
          dcc_new (ref='0. None');
    model hcc_timeyrs*hcc(0)= dm_uncomplicated /rl; *hazardratio age/ units=1; *hazardratio charlson/ units=1; run;

  proc phreg data=b9;
    class sex1 (ref='Female') dm_uncomplicated (ref='No') NAFLD_Indexyear_cat (ref='1. 2006-2010') cc (ref='No')
          dcc (ref='No') dcc_new (ref='0. None');;
    model hcc_timeyrs*hcc(0)= age sex1 charlson dcc_new dm_uncomplicated /rl; run;

* /////////////////////////////////////////////////////////;
* NEW TABLES FOR RT;
* create new var for RT;
 data picle; set b;
  if age_le60 =1 and cc = 0 and dm_uncomplicated = 0 then new_grp=0; else
  if age_le60 =0 and cc = 0 and dm_uncomplicated = 0 then new_grp=1; else
  if age_le60 =1 and cc = 0 and dm_uncomplicated = 1 then new_grp=2; else
  if age_le60 =0 and cc = 0 and dm_uncomplicated = 1 then new_grp=3; else

  if age_le60 =1 and cc = 1 and dm_uncomplicated = 0 then new_grp=4; else
  if age_le60 =0 and cc = 1 and dm_uncomplicated = 0 then new_grp=5; else
  if age_le60 =1 and cc = 1 and dm_uncomplicated = 1 then new_grp=6; else
  if age_le60 =0 and cc = 1 and dm_uncomplicated = 1 then new_grp=7;

  if age_le60 =1 and sex1 = 2 and dm_uncomplicated = 0 then new_grp2=0; else
  if age_le60 =0 and sex1 = 2 and dm_uncomplicated = 0 then new_grp2=1; else
  if age_le60 =1 and sex1 = 2 and dm_uncomplicated = 1 then new_grp2=2; else
  if age_le60 =0 and sex1 = 2 and dm_uncomplicated = 1 then new_grp2=3; else

  if age_le60 =1 and sex1 = 1 and dm_uncomplicated = 0 then new_grp2=4; else
  if age_le60 =0 and sex1 = 1 and dm_uncomplicated = 0 then new_grp2=5; else
  if age_le60 =1 and sex1 = 1 and dm_uncomplicated = 1 then new_grp2=6; else
  if age_le60 =0 and sex1 = 1 and dm_uncomplicated = 1 then new_grp2=7; run;


 dm 'odsresults; clear';
 proc sort data=picle; by sex1;
 proc phreg data=picle; by sex1;
    class new_grp (ref='0') ckd (ref='No') specialist1 (ref='No') cardiovascular (ref='No') non_liver_cancer (ref='No') ;
    model hcc_timeyrs*hcc(0)= new_grp specialist1 charlson ckd cardiovascular non_liver_cancer  / rl;
    *model hcc_timeyrs*hcc(0)= non_liver_cancer  / rl;
    *model hcc_timeyrs*hcc(0)= /*new_grp2  specialist1 charlson ckd  cardiovascular*/ non_Liver_cancer / rl; run;

************************************************************************************** ;
************************************************************************************** ;
************************************************************************************** ;
************************************************************************************** ;
* old code;

* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>;
* Original Age Cat variable;

 data c; set b; where sex1=1 & cc=1;

* creates event count numerator;
  data Long_Nc; set c;
    array x [*] &AE1;                    /* <== specify explanatory variables HERE */
     do varNum = 1 to dim(x);
      VarName = vname(x[varNum]);        /* variable name in char var              */
      Value = x[varNum];                 /* value for each variable for each obs   */
      output; end; run;

* creates PT denominator;
  data Long_Dc; set c;
    array x [*] &AE0;                    /* <== specify explanatory variables HERE */
     do varNum = 1 to dim(x);
      VarName = vname(x[varNum]);        /* variable name in char var              */
      Value = x[varNum];                 /* value for each variable for each obs   */
      output; end; run;

dm 'odsresults; clear';
* stratified;
  %let dv = dm_uncomplicated;
  %let sv = age_cat;
  proc sql; create table _tempc as select distinct(varname), varnum from long_Nc; quit;
  proc sql; create table Nc as select varnum, &SV, &DV, sum(value) as N
            from long_Nc group by varnum, &SV, &DV order by &SV, &DV; quit;

  proc sql; create table Dc as select varnum, &SV, &DV,  sum(value) as PT
            from long_Dc group by varnum, &SV, &DV order by &SV,&DV; quit;

  proc sql; create table PT1c as select N.&SV, N.&DV, N.*, D.PT
            from Nc N left join Dc D
            on N.varnum=D.varnum AND N.&DV=D.&DV AND N.&SV=D.&SV
          order by N.&DV, N.varnum; quit;

  proc sql; create table PT2c as select a.*, b.varname from PT1c a left join _tempc b
           on a.varnum=b.varnum order by a.&SV, a.&DV, b.varnum; quit;
  data PT3c; set pt2c; rate=round(n/pt*1000,.01);
                    LCL=round((n-1.96*(sqrt(n)))/pt*1000,.01);
                    UCL=round((n+1.96*(sqrt(n)))/pt*1000,.01);
                    array X LCL UCL; do i = 1 to dim(x); if x(i) <0.0 then x(i)=0.0; end;
            format rate lcl ucl 6.01 varnum aefmt.;
            rate_U_L=catx('~',rate,lcl,ucl); n_pt=catx('~',n,round(pt,.1)); /* rate w/CI */
            n_py_rate_U_L=catx('~',n,pt,rate,lcl,ucl); n_pt=catx('~',n,round(pt,.1));  /* n pt rate w/CI */
            label rate='Rate per 1000/PY'; run;
  proc sort data=pt3c; by varnum; run;
  proc transpose data=pt3c out=pt3tac; by varnum; id &SV &dv; var n_pt; run;
/* proc print data=pt3tac; title "by &dv N, Person Years"; run; */
  proc transpose data=pt3tac out=pt3tac2y; var _1__18_29Yes _2__30_39yes _3__40_49yes _4__50_59yes _5__60_69yes _6__70_79yes _7__80_yes;
  proc transpose data=pt3tac out=pt3tac2n; var _1__18_29no _2__30_39no _3__40_49no _4__50_59no _5__60_69no _6__70_79no _7__80_no;
  data pt3tac3; set pt3tac2y pt3tac2n;
  proc print data=pt3tac3; title "by &dv Rate per 1,000 PY"; run;
  proc transpose data=pt3c out=pt3tbc; by varnum; id &SV &dv; var rate_u_l; run;
/*  proc print data=pt3tbc; title "by &dv Rate per 1,000 PY"; run; */
  proc transpose data=pt3tbc out=pt3tbc2y; var _1__18_29Yes _2__30_39yes _3__40_49yes _4__50_59yes _5__60_69yes _6__70_79yes _7__80_yes;
  proc transpose data=pt3tbc out=pt3tbc2n; var _1__18_29no _2__30_39no _3__40_49no _4__50_59no _5__60_69no _6__70_79no _7__80_no;
  data pt3tbc3; set pt3tbc2y pt3tbc2n;
  proc print data=pt3tbc3; title "by &dv Rate per 1,000 PY"; run;

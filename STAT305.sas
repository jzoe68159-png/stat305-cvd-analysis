/* STAT305 Assignment - Heart Data Analysis */
/* Import Excel file from your specific location */
PROC IMPORT DATAFILE="/home/u63523225/sasuser.v94/STAT305/Assignment/Heart Data.xlsx"
    OUT=heart
    DBMS=XLSX
    REPLACE;
    SHEET="Heart Data";  
    GETNAMES=YES;    
RUN;

/* Check data imported correctly */
PROC PRINT DATA=heart (OBS=10);
    TITLE "First 10 Observations of Heart Data";
RUN;

/* Task 1: Acquaint yourself with the data */
PROC FREQ DATA=heart; 
    TABLES cvd anaemia diabetes high_blood_pressure gender smoking;
    TITLE "One-Way Frequency Tables for Categorical Variables";
RUN;

PROC UNIVARIATE DATA=heart;
    VAR age creatinine_phosphokinase ejection_fraction platelets serum_sodium;
    TITLE "Descriptive Statistics for Quantitative Variables";
RUN;

/* Characteristics  :
Age: 
Median=60
Mode=60
Mean=60.83389
Min=40
Max=95
 
Creatine Phosphokinase:
 
Median=250
Mode=582
Mean=581.8395
Min=23
Max=7861

Ejection fraction :
Median=38
Mode=35
Mean=38.083612
Min=14
Max=80

Platelets:
Median=262000
Mode=263358
Mean=263358
Min=25100
Max=850000

Serum sodium:
Median=137
Mode=136
Mean=136.625418
Min=113
Max=148

*/

/* Task 2: Tests of association */
PROC FREQ DATA=heart; 
    TABLES anaemia*cvd / CHISQ;
    TITLE "Association between Anaemia and CVD";
RUN; 

PROC FREQ DATA=heart; 
    TABLES diabetes*cvd / CHISQ;
    TITLE "Association between Diabetes and CVD";
RUN;

PROC FREQ DATA=heart; 
    TABLES high_blood_pressure*cvd / CHISQ;
    TITLE "Association between High Blood Pressure and CVD";
RUN;   


PROC FREQ DATA=heart; 
    TABLES gender*cvd / CHISQ;
    TITLE "Association between Gender and CVD";
RUN; 

PROC FREQ DATA=heart; 
    TABLES smoking*cvd / CHISQ;
    TITLE "Association between Smoking and CVD";
RUN; 

/* Task 3: Full logistic regression model */
PROC LOGISTIC DATA=heart DESCENDING; 
    CLASS anaemia (REF='No') diabetes (REF='No') 
          high_blood_pressure (REF='No') gender (REF='Female') 
          smoking (REF='No') / PARAM=REF;
    MODEL cvd = age anaemia creatinine_phosphokinase diabetes 
                ejection_fraction high_blood_pressure platelets 
                serum_sodium gender smoking;
    TITLE "Full Logistic Regression Model with All Predictors";   
RUN; 

/* Task 4: Find best fitting model using stepwise selection */
PROC LOGISTIC DATA=heart DESCENDING;
    CLASS anaemia (REF='No') diabetes (REF='No') 
          high_blood_pressure (REF='No') gender (REF='Female') 
          smoking (REF='No') / PARAM=REF;
    MODEL cvd = age anaemia creatinine_phosphokinase diabetes 
                ejection_fraction high_blood_pressure platelets 
                serum_sodium gender smoking / 
                SELECTION=STEPWISE SLENTRY=0.05 SLSTAY=0.05;
    TITLE "Stepwise Selection for Best Fitting Model";
RUN;

/* Based on stepwise results, fit reduced model */
/* Adjust these variables based on what stepwise selects */
PROC LOGISTIC DATA=heart DESCENDING;
    MODEL cvd = age ejection_fraction serum_sodium / LACKFIT; /* LACKFIT For Hosmer–Lemeshow goodness-of-fit test */
RUN;

/* Forced Aggregation to Estimate Overdispersion */

proc genmod data=Heart descending;
    class anaemia (ref='No') high_blood_pressure (ref='No') / param=ref;
    model cvd = age anaemia ejection_fraction high_blood_pressure serum_sodium
          / dist=binomial link=logit
            aggregate=(age anaemia ejection_fraction high_blood_pressure serum_sodium)
            scale=PEARSON;
    title "Forced Aggregation to Estimate Overdispersion"; 
run;

/* Compute φ from the captured table */
data phi_calc;
    set Heart;
    if Criterion in ('Deviance','Pearson Chi-Square') then phi = Value / DF;
run;

proc print data=phi_calc noobs;
    var Criterion Value DF phi;
run;

/* Check for influential observations */

PROC LOGISTIC DATA=heart DESCENDING;
    MODEL cvd = age ejection_fraction serum_sodium / INFLUENCE;
    TITLE "Influence Diagnostics for Final Model";
RUN;


/* Task 5: Interpret results - Odds ratios */
PROC LOGISTIC DATA=heart DESCENDING;
    MODEL cvd = age ejection_fraction serum_sodium / CLPARM=PL;
    ODDSRATIO age;
    ODDSRATIO ejection_fraction;
    ODDSRATIO serum_sodium;
    TITLE "Odds Ratios for Final Model with Confidence Intervals"; 
RUN;


/* Predicted probabilities for first 3 observations */
PROC LOGISTIC DATA=heart DESCENDING;
    MODEL cvd = age ejection_fraction serum_sodium;
    OUTPUT OUT=predicted P=pred_prob;
    TITLE "Predicted Probabilities from Final Model";
RUN;

PROC PRINT DATA=predicted (OBS=3);
    VAR cvd age ejection_fraction serum_sodium pred_prob;
    TITLE "Predicted Probabilities for First 3 Observations";
RUN;

/* Additional summary statistics for final report */
PROC MEANS DATA=heart N MEAN STD MIN MAX;
    CLASS cvd;
    VAR age ejection_fraction serum_sodium;
    TITLE "Summary Statistics by CVD Status for Final Model Variables";
RUN;




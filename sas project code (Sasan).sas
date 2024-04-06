/*version 1 (non-delimited ds)*/
filename df '/home/u63666019/New_Wireless_Fixed.txt';

data sasan;
infile df;
format  acctno $13.  actdt mmddyy10.  deactdt mmddyy10.  deactreason $4.  goodcredit 1.  rateplan 1. dealertype $2.
 AGE 2. Province $2. sales dollar10.2;
input @1 acctno $13. @15 actdt mmddyy10. @26 deactdt mmddyy10. @41 deactreason $4. @53 goodcredit 1. @62 rateplan 1. @65 dealertype $2.
@74 AGE 2. @80 Province $2. sales dollar10.2;
run;

proc print data= sasan (obs=10);
run;

proc contents data=sasan; 
run;



/*Q1: number of unique values in acctno variable*/


/* Check if acctno is unique */
proc sort data=sasan nodupkey out=sasan_unique;
    by acctno;
run;
proc sql;
    select count(*) as total_records,
           count(distinct acctno) as unique_acctno
    from sasan;
quit;

/* Number of accounts activated and deactivated */
proc sql;
    select sum(case when actdt ne . then 1 else 0 end) as num_activated,
           sum(case when deactdt ne . then 1 else 0 end) as num_deactivated
    from sasan;
quit;

/* Earliest and latest activation/deactivation dates */
proc sql;
    select min(actdt) format=mmddyy10. as earliest_actdt,
           max(actdt) format=mmddyy10. as latest_actdt,
           min(deactdt) format=mmddyy10. as earliest_deactdt,
           max(deactdt) format=mmddyy10. as latest_deactdt
    from sasan;
quit;

/* Create a dataset with the status of the accounts */
data account_status;
    set sasan;
    if actdt ne . and deactdt = . then status = 'Active';
    else if deactdt ne . then status = 'Deactivated';
run;

/* Create a frequency table for the status */
proc freq data=account_status noprint;
    tables status / out=status_freq;
run;

/*the main reason of deactivation*/
proc freq data=sasan;
    tables deactreason;
run;

/* To find out the percentage of people with good credit, you can use a SQL procedure*/

proc sql;
    select (sum(goodcredit)/count(*))*100 as percent_good_credit
    from sasan;
quit;

/*To find out the proportion of each rate plan, you can use a frequency procedure*/

proc freq data=sasan;
    tables rateplan;
run;
/*To find out the number and percentage of each dealer type, you can use a frequency procedure */

proc freq data=sasan;
    tables dealertype;
run;

/*To create a histogram of customer ages, you can use a univariate procedure*/

proc univariate data=sasan;
    histogram age / normal;
    title 'Histogram of Customer Ages with Normal Density Curve';
run;


/* To create a bar chart for the number of active and deactivated accounts 
in each province, first create a dataset that includes the status of the 
accounts (active or deactivated) and then use a frequency procedure */

/* Create a dataset with the status of the accounts */
data account_status;
    set sasan;
    if actdt ne . and deactdt = . then status = 'Active';
    else if deactdt ne . then status = 'Deactivated';
run;

/* Create a frequency table for the status in each province */
proc freq data=account_status noprint;
    tables province*status / out=province_status_freq;
run;

/* Create the bar chart */
proc sgplot data=province_status_freq;
    vbar province / response=count group=status;
    title 'Number of Active and Deactivated Accounts in Each Province';
run;



/*Q2: distribution of age grouped by province for customers with both act and deact*/

/* Sort the data by Province and Status */
proc sort data=account_status;
    by Province status;
run;

/* Create a histogram of Age for each combination of Province and Status */
proc sgplot data=account_status;
    by Province status;
    histogram Age / fillattrs=(color=blue) transparency=0.4 name='a';
    density Age / lineattrs=(color=red) name='b';
    keylegend 'a' 'b' / location=inside position=topright across=1;
    xaxis label='Age';
    yaxis label='Frequency';
run;


/*Q3: Segment the customers based on age, province and sales amount:*/

/* Define the formats for the sales and age segments */
proc format;
    value sales
        low-<100 = '< $100'
        100-<500 = '$100 - $500'
        500-<800 = '$500 - $800'
        800-high = '$800 and above';
    value age
        low-<20 = '< 20'
        20-<41 = '21 - 40'
        41-<61 = '41 - 60'
        61-high = '60 and above';
run;

/* Create a dataset with the segments */
data segmented;
    set sasan;
    sales_segment = put(sales, sales.);
    age_segment = put(age, age.);
run;

/* Print the frequency of each segment */
proc freq data=segmented;
    tables Province sales_segment age_segment;
run;
/* Create a bar chart for the sales segments */
proc sgplot data=segmented;
    vbar sales_segment / datalabel;
    xaxis label='Sales Segment';
    yaxis label='Frequency';
    title 'Distribution of Sales Segments';
run;

/* Create a bar chart for the age segments */
proc sgplot data=segmented;
    vbar age_segment / datalabel;
    xaxis label='Age Segment';
    yaxis label='Frequency';
    title 'Distribution of Age Segments';
run;
/* Create a bar chart for the provinces */
proc sgplot data=segmented;
    vbar Province / datalabel;
    xaxis label='Province';
    yaxis label='Frequency';
    title 'Distribution of Provinces';
run;



/*Q4. Statistical Analysis:*/
/*1) Calculate the tenure in days for each account */
/* dataset containing tenure */
data tenure0 (drop=fiscal_date);
    set sasan;
    format end_date MMDDYY10.;
    fiscal_date = input('03/31/2001',MMDDYY10.);
    tenure= intck('day', actdt, deactdt);
    if deactdt=. then tenure= intck('day', actdt, fiscal_date);
run;

/* min and max tenure */
proc sql;
    TITLE 'min and max tenure ';
    select min(tenure) as min, max(tenure) as max
    from tenure0;
quit;

/* tenure distribution */
proc univariate data=tenure0;
    TITLE 'tenure distribution ';
    var tenure;
    histogram tenure/ endpoints=(0 to 801 by 30) normal kernel;
run;
proc sgplot data=tenure0;
    histogram tenure / fillattrs=(color=blue) transparency=0.4;
    density tenure / lineattrs=(color=red);
    xaxis label='Tenure (days)';
    yaxis label='Frequency';
    title 'Distribution of Tenure';
    keylegend / location=inside position=topright across=1;
run;



/*2) Calculate the number of accounts deactivated for each month.*/

/*create a table only containing deactivated cutomers with deactivated month*/
/* Create a dataset with the deactivation month for each account */
data deactivation;
    set sasan;
    if deactdt ne . then deact_month = month(deactdt);
run;

/* Calculate the number of accounts deactivated for each month */
proc sql;
    create table deactivation_counts as
    select deact_month, count(*) as num_deactivated
    from deactivation
    group by deact_month;
quit;
/* Create a bar chart for the number of accounts deactivated each month */
proc sgplot data=deactivation_counts;
    vbar deact_month / response=num_deactivated datalabel;
    xaxis label='Month (1=January, 12=December)';
    yaxis label='Number of Deactivated Accounts';
    title 'Number of Accounts Deactivated Each Month';
run;

/* Print the deactivation_counts table */
proc print data=deactivation_counts;
    title 'Number of Accounts Deactivated Each Month';
run;






/*3) Segment the account, first by account status active�and deactivated� then by
Tenure: < 30 days, 31---60 days, 61 days--- one year, over one year. Report the
number of accounts of percent of all for each segment.*/


proc format;
value deact
	. = 'activated'  
	other = 'deactivated'  ;
value tenure 
	low  -  30 = "<30]"       
      31 -  60 = "[31,60)"        
      61 -  365 = "[61,365]"   
      366 - high = "over 1 yr"  
	 
   ;
run;

/*dataset containning activation status and tenure segment*/
data sasan2;
set tenure0;
activation = put(deactdt,deact.);
tenure_seg= put(tenure,tenure.);
run;

/*frequency table including tenure segment and both activated and deactivated account*/

Proc Tabulate data=sasan2  ;
title'frequency table including tenure segment and both activated and deactivated account';
    Class activation tenure_seg;
    Table (activation all),(tenure_seg all)*(n pctn)/row=float;
    Keylabel ALL='margin sum'
    n = 'Count'
    pctn = 'Percent';
Run;

/*frequency table including tenure and only deactivated account*/

Proc Tabulate data=sasan2  ;
title'frequency table including tenure and only deactivated account';
    Class activation tenure_seg;
    Table (activation all),(tenure_seg all)*(n pctn)/row=float;
	where activation= 'deactivated';
    Keylabel ALL='margin sum'
    n = 'Count'
    pctn = 'Percent';
Run;


/*frequency table including tenure and only active account*/

Proc Tabulate data=sasan2  ;
title'frequency table including tenure and only deactivated account';
    Class activation tenure_seg;
    Table (activation all),(tenure_seg all)*(n pctn)/row=float;
	where activation= 'activated';
    Keylabel ALL='margin sum'
    n = 'Count'
    pctn = 'Percent';
Run;

proc sgplot data=sasan2;
  vbar activation / group=tenure_seg stat=freq datalabel;
  yaxis grid label='Frequency';
  xaxis display=(nolabel);
  title 'Bar Chart for Frequency Analysis';
run;

proc sgplot data=sasan2;
  histogram tenure;
  yaxis grid;
  xaxis display=(nolabel);
  title 'Histogram for Tenure Distribution';
run;

proc sgplot data=sasan2;
  vbox tenure / category=activation;
  yaxis grid;
  xaxis display=(nolabel);
  title 'Box Plot for Tenure by Activation Status';
run;




/*4)Test the general association between the tenure segments and “Good Credit*/

proc freq data=sasan2 ;
title 'Test the general association between the tenure segments and “Good Credit';
table tenure_seg * goodcredit/ expected norow  nocol chisq ;
table tenure_seg * rateplan/ expected norow nocol chisq ;
table tenure_seg * dealertype/ expected norow  nocol chisq;
run;




/* 5)is there any association between the account status and the tenure segments?
Could you find out a better tenure segmentation strategy that is more associated
with the account status?*/

proc freq data=sasan2;
title 'chisq freq table between the activation status and tenure segments';
table tenure_seg * activation/ expected cellchi2 norow  nocol chisq;
run;





/*8) Does Sales amount differ among different account status, GoodCredit, and customer age segments?*/

/*Does Sales amount differ among different account status*/
Proc Ttest Data=ds2 COCHRAN side=2 alpha=0.05 h0=0 test=diff; * t-p is lower than the 0.05, reject H0;
title'method1:t test (paramatric): compare activation status';
class activation;
var sales;
Run;

proc NPAR1WAY data=ds2 wilcoxon median;
title'method2: Wilcoxon rank-sum test(same as the Mann-Whitney U test)(non-paramatric)';
class activation;
var sales;
run;





/*Does Sales amount differ among different gredit*/
Proc Ttest Data=sasan2 COCHRAN side=2 alpha=0.05 h0=0 test=diff; * t-p is lower than the 0.05, reject H0;
title'method1:t test (paramatric): compare credit groups';
class GoodCredit;
var sales;
Run;

proc NPAR1WAY data=ds2 wilcoxon median;
title'method2: Wilcoxon rank-sum test(same as the Mann-Whitney U test)(non-paramatric)';
class GoodCredit;
var sales;
run;










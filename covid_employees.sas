
**********************************************

Program to backtrace known close associates of
anyone affected by the COVID-19 outbreak.

Input: Emplid of affected
Output: TAB1: Table of Employees within Affected's dept.
		TAB2: Table of Employees within Supervisor's dept.


by Jared Kelly
Last edit: 3/19/20 - Solved BOTH LEVELS

***********************************************;
* Input Emplid of COVID affected employee here;
%let affected = 11199620; *<<<<<<<<<<<<<<<<;

%let empldata = "S:\UIS\Shared\SAS Data Projects\COVID\empl_data.csv";

*import employee relations data;
PROC IMPORT OUT= WORK.empl_data 
            DATAFILE= &empldata. 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

*ISOLATE AFFECTED EMPLOYEE;
DATA AFFECT;
	SET EMPL_DATA;
	WHERE HRIS_ID = "&AFFECTED.";
RUN;

*ISOLATE AFFECTED EMPLOYEE'S ENTIRE DEPT;
PROC SORT DATA=EMPL_DATA OUT=DEPT_SORT;
	BY _DEPT_ID;
RUN;
DATA REL_ASSOC;
	MERGE AFFECT(IN=A) DEPT_SORT;
	BY _DEPT_ID;
	IF A=1;
RUN;

************* Start Calculating Second Level*********************;
DATA SECOND_LVL;   * CAPTURE THE SUPERVISORS FROM THE LAST STEP ABOVE;
	SET AFFECT(RENAME=(_SUPERVISOR_EMPLID=EMPLID));
	KEEP EMPLID;
RUN;
DATA SECOND_LVL;	* RENAME VARIABLE TO SWITCH SUPERVISOR TO NEW AFFECTED;
	SET SECOND_LVL(RENAME=(EMPLID=HRIS_ID));
RUN;
PROC SORT DATA=EMPL_DATA OUT=EMPL_SORT; * SORT THE EMPLOYEE DATA BY EMPLID;
	BY HRIS_ID;
RUN;
	
DATA SECOND_LVL_IDS; * GRAB OBSERVATIONS FOR SUPERVISORS;		
	MERGE SECOND_LVL(IN=A) EMPL_SORT;
	BY HRIS_ID;
	IF A=1;
RUN; 

DATA SECOND_LVL_ASSOC;
	MERGE SECOND_LVL_IDS(IN=A) DEPT_SORT;
	BY _DEPT_ID;
	IF A=1;
RUN;
************* Finish Calculating Second Level*********************;

******* REPORT RESULTS TO USER;
title1 "Report of employees related to the affected person (EMPLID: &affected.)";
ods tagsets.excelxp file="S:\UIS\Shared\SAS Data Projects\COVID\reports\employees\&affected._COVID_employees_%sysfunc(today(), mmddyy6).xml" style=XLsansprinter;
ODS TAGSETS.EXCELXP	options(embedded_titles='yes' autofit_height='yes' sheet_interval='none'
			sheet_name='1st Level' absolute_column_width='15,25,15,20,15,15,15');
proc report data=REL_ASSOC HEADLINE MISSING;
	COLUMN _FULL_NAME _JOB_TITLE HRIS_ID _EMAIL _DEPT_ID _DEPT_NAME _SUPERVISOR_FULL_NAME;
	DEFINE _FULL_NAME / DISPLAY 'Name';
	DEFINE _JOB_TITLE / DISPLAY 'Title';
	DEFINE HRIS_ID / ORDER 'EmplID';
	DEFINE _EMAIL / DISPLAY 'Email';
	DEFINE _DEPT_ID / DISPLAY 'Dept ID';
	DEFINE _DEPT_NAME / DISPLAY 'Dept. Name';
	DEFINE _SUPERVISOR_FULL_NAME / DISPLAY 'Supervisor';
run;

ODS TAGSETS.EXCELXP	options(embedded_titles='yes' autofit_height='yes' sheet_interval='none'
			sheet_name='2nd Level' absolute_column_width='15,25,15,20,15,15,15');
proc report data=SECOND_LVL_ASSOC HEADLINE MISSING;
	COLUMN _FULL_NAME _JOB_TITLE HRIS_ID _EMAIL _DEPT_ID _DEPT_NAME _SUPERVISOR_FULL_NAME;
	DEFINE _FULL_NAME / DISPLAY 'Name';
	DEFINE _JOB_TITLE / DISPLAY 'Title';
	DEFINE HRIS_ID / ORDER 'EmplID';
	DEFINE _EMAIL / DISPLAY 'Email';
	DEFINE _DEPT_ID / DISPLAY 'Dept ID';
	DEFINE _DEPT_NAME / DISPLAY 'Dept. Name';
	DEFINE _SUPERVISOR_FULL_NAME / DISPLAY 'Supervisor';
run;

ods tagsets.excelxp close;
title;

proc template;
 	define style styles.XLsansPrinter;
 	parent = styles.sansPrinter;

 	* Change attributes of the column headings;

 	style header from header /
 	font_size = 11pt
 	just = center
 	BACKGROUND=GREEN
 	vjust = bottom;
 	end;
run;



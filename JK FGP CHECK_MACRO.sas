%let curdate = %sysfunc(today(),mmddyy7.);	* CURRENT DATE;
options dlcreatedir;

libname newdir "C:\Users\jrk0200\UNT System\New College - Reports\&curdate.";	*DIRECTORY PATH TO FRISCO REPORTS;


DATA TOTAL_LEFT;
RUN;

options mprint mlogic;
%MACRO GATEWAY(PROG,SHORT,VARN,CNAME,FNAME);

	* 1) CREATE GUIDED PATH DATASET FROM GUIDED PATH EXCEL SHEET;
	* WORK.GUIDEDPATH = ALL DATA FROM EXCEL SPREADSHEET FOR THIS PROGRAM;
	PROC IMPORT OUT= WORK.GUIDEDPATH 
		            DATAFILE= "S:\UIS\Shared\Allen Clark\Frisco\Guided Pathway.xlsx" 
	            DBMS=EXCELCS REPLACE;
	     RANGE="&SHORT"; 
	     SCANTEXT=YES;
	     USEDATE=YES;
	     SCANTIME=YES;
	RUN;

	* 2) DROP UNNECCESARY FIELDS FROM GUIDED PATH;
	* WORK.GUIDEDPTH = SEMESTER, FIELD, AND CLASS NUMBER OF GUIDED PATH DATASET;
	DATA GUIDEDPTH;
		SET GUIDEDPATH;
		KEEP SEMSTER FIELD CLASSNBR;
	RUN;

	* 3) create VARN(AME) dataset from intersection of Frisco and program;
	* WORK.&VARN = ALL ENROLLMENT AND SIMSTERM DATA FOR ALL "FRISCO" STUDENTS (FOR CURRENT SEMESTER) REGISTERED IN THIS PARTICULAR PROGRAM;
	DATA &VARN;
		SET FRISCO_COURSES;
		IF ACAD_PLAN = "&PROG";
	RUN;

	* 4) Sort VARN dataset by EMPLID2;
	PROC SORT DATA=&VARN;
		BY EMPLID2;
	RUN;

	* 5) Create FIRST dataset from VARN;
	* WORK.ID_&VARN = ONLY THE EMPLID'S OF ALL FRISCO STUDENTS IN THIS PROGRAM, WITH NO DUPLICATES;
	DATA ID_&VARN;
		SET &VARN;
		BY EMPLID2;
		IF FIRST.EMPLID2=1;
		KEEP EMPLID2 ACAD_PLAN;
	RUN;
	 
	* 6) Sort ALLCOURSES by EMPLID2;
	PROC SORT DATA = ALLCOURSES;
		BY EMPLID2;
	RUN;

	* 7) Create HIST dataset from FIRST/ALLCOURSES merge by EMPLID2;
	* WORK.ALLCOURSES_&VARN = ALL OF THE COURSE HISTORY FOR THE N STUDENTS IN THE PROGRAM;
	DATA ALLCOURSES_&VARN;
		MERGE ID_&VARN (IN=A) ALLCOURSES (IN=B);
		BY EMPLID2;
		IF A=1;
	RUN;

	* 8) Modify GUIDEDPTH dataset to contain course;
	* WORK.GUIDEDPTH = WORK.GUIDEDPTH = SEMESTER, FIELD, CLASS, AND COURSE NUMBER OF GUIDED PATH DATASET; 
	DATA GUIDEDPTH;
		SET GUIDEDPTH;
		COURSE =CATX('-',FIELD,CLASSNBR);
	RUN;

	* 9) Modify HIST dataset TO CONTAIN COURSE;
	* WORK.HIST_&VARN = EMPLID'S AND COURSE HISTORY FOR PROGRAM STUDENTS, WITH NEW COURSE DESGINATION;
	DATA HIST_&VARN;
		SET ALLCOURSES_&VARN;
		COURSE = CATX('-',SUBJECT,CATALOG_NBR);
		KEEP EMPLID2 COURSE;
	RUN;

	* 10) Create GUIDEDPTH_ONLY dataset from GUIDEDPTH with only COURSE;
	* WORK.GUIDEDPTH_ONLY = ONLY COURSES;
	DATA GUIDEDPTH_ONLY;
	    SET GUIDEDPTH;
		KEEP COURSE;
	RUN;

	* 11) SQL tABLE GENERATION;
	* WORK.EMPLID_PTHY = TABLE OF EACH STUDENT AND EACH CLASS IN THE PROGRAM (IDEAL COMPLETION TABLE);
	proc sql;
		CREATE TABLE EMPLID_PTHY AS select *
	      from ID_&VARN CROSS join GUIDEDPTH_ONLY;


	* 12) Sort HIST by EMPLID2 and then COURSE;
	PROC SORT DATA = HIST_&VARN;
		BY EMPLID2 COURSE;
	RUN;

	* 13) Sort EMPLID_PTHY by EMPLID2 and then COURSE;
	PROC SORT DATA = EMPLID_PTHY;
		BY EMPLID2 COURSE;
	RUN;

	* 26) Create two datasets, TAKEN_ and LEFT_, based on whether EMPLID2 and COURSE appear in HIST and EMPLID_PTHY;
	* WORK.TAKEN_&VARN = THE DATASET OF CLASSES (FROM GP) WHICH HAVE BEEN TAKEN BY THE FRISCO STUDENTS OF THIS PARTICULAR PROGRAM;
	* WORK.LEFT_&VARN = THE DATASET OF CLASSES (FROM GP) WHICH STILL NEED TO BE TAKEN BY THE FRISCO STUDENTS OF THIS PARTICULAR PROGRAM;
	DATA TAKEN_&VARN LEFT_&VARN;
		MERGE HIST_&VARN (IN=A) EMPLID_PTHY (IN=B);
		BY EMPLID2 COURSE;
		IF A=1 AND B=1 THEN OUTPUT TAKEN_&VARN;
		IF A=0 AND B=1 THEN OUTPUT LEFT_&VARN;
	RUN;

	* Adding steps to include semester in course name in report;
	PROC SORT DATA=LEFT_&VARN;
	   BY COURSE;
	RUN;

	PROC SORT DATA=GUIDEDPTH;
	   BY COURSE;
	RUN;

	* WORK.PRNT_&VARN = COURSE, EMPLID AND SEMESTER INFO FOR EACH CLASS LEFT TO BE TAKEN;
	DATA PRNT_&VARN;
		MERGE LEFT_&VARN GUIDEDPTH;
		BY COURSE;
		KEEP COURSE EMPLID2 SEMSTER ACAD_PLAN; 
	RUN;

	DATA TOTAL_LEFT;
		SET TOTAL_LEFT PRNT_&VARN;
	RUN;	

/*	DATA PRNT_&VARN;*/
/*		SET PRNT_&VARN;*/
/*		COURSE2 = CATX('-',SEMSTER,COURSE);*/
/*		KEEP EMPLID2 COURSE2;*/
/*	RUN;*/

	



	* 28) Export data to Excel to create pivot table; 


/*	title1 "List of Courses Remaining to be taken by &CNAME Spring 2019 Cohort";*/

/*ods tagsets.excelxp file="S:\UIS\Shared\SAS Data Projects\Frisco Guided Paths\RESULTS\&FNAME" style=XLSANSPRINTER*/
/*    options( embedded_titles='yes' AUTOFIT_HEIGHT='YES' */
/*			 skip_space='3,2,0,0,1' sheet_interval='none'*/
/*             sheet_name="&PROG" suppress_bylines='no'*/
/*			 ABSOLUTE_COLUMN_WIDTH='16,6');*/
/**/
/*	proc tabulate data=WORK.PRNT_&VARN;*/
/*		class COURSE2;*/
/*		TABLE COURSE2=' ', N='Need';*/
/*	RUN;*/
/*	title;*/
/*	ods tagsets.excelxp close;*/
%MEND GATEWAY;
run;

%let fname1 = %sysfunc(today(),mmddyy7.);
%put =====> fname= &fname;

options dlcreatedir;


libname newdir "S:\UIS\Shared\SAS Data Projects\Frisco Guided Paths\RESULTS\&fname1.";
*************************** GATEWAY(PROG,SHORT,VARN,CNAME,FNAME);
%GATEWAY(KINE-BS, KINE$, KIN, Kinesiology BS, &fname1./kin_courses_&fname1..xml);
%GATEWAY(CEXM-BS, CEMB$, CEM, Consumer Experience Managemenent BS, &fname1./cem_courses_&fname1..xml);
%GATEWAY(JOUR-BA, JOUR$, JOU, Journalism BA, &fname1./jou_courses_&fname1..xml);
%GATEWAY(LSCM-BS, LSCM$, LSC, Logistics and Supply Chain Management BS, &fname1./lsc_courses_&fname1..xml);
%GATEWAY(PSYC-BA, PSYC$, PSY, Psychology BA, &fname1./psy_courses_&fname1..xml);
%GATEWAY(RESM-BS, RESM$, RES, Recreation Event and Sport Management BS, &fname1./res_courses_&fname1..xml);
%GATEWAY(BUIS-BBA, BUIS$, BUIS, Business Integrated Studies Sports Track BBA, &fname1./buis_courses_&fname1..xml);
%GATEWAY(APAS-BAAS, BAAS$, BAAS, Bachelor of Applied Arts and Sciences, &fname1./baas_courses_&fname1..xml);
%GATEWAY(INDE-BS, EDUC$, EDUC, Education Interdisciplinary Studies BS, &fname1./educ_courses_&fname1..xml);
%GATEWAY(IGST-BS, IGST$, IGST, Integrative Studies BS, &fname1./igst_courses_&fname1..xml);
%GATEWAY(CSIT-BA, ITBA$, CSIT, Information Technology BA, &fname1./csit_courses_&fname1..xml); 


PROC SORT DATA=TOTAL_LEFT;
	BY EMPLID2;
RUN;

PROC SORT DATA=SIMSTERM;
	BY EMPLID2;
RUN;

DATA TOTAL_DETAILS;
	MERGE TOTAL_LEFT (IN=A) SIMSTERM;
	BY EMPLID2;
	IF A=1;
RUN;

PROC SORT DATA=TOTAL_DETAILS;
BY COURSE ACAD_PLAN EMPLID2;
RUN;

title1 "List of Courses Remaining to be taken by all of Spring 2019 Frisco Cohort";

ods tagsets.excelxp file="C:\Users\jrk0200\UNT System\New College - Reports\&curdate.\LEFTOVER_TOTAL.xml" style=XLSANSPRINTER
    options( embedded_titles='yes' AUTOFIT_HEIGHT='YES' 
			 skip_space='3,2,0,0,1' sheet_interval='none'
             sheet_name="TOTAL" suppress_bylines='no'
			 ABSOLUTE_COLUMN_WIDTH='16,6');

proc tabulate data=WORK.TOTAL_LEFT;
	class COURSE;
	TABLE COURSE=' ', N='Need';
RUN;


title1 "Details for Remaining Courses of Spring 2019 Frisco Cohort";
ods tagsets.excelxp options( embedded_titles='yes' AUTOFIT_HEIGHT='YES' 
			 skip_space='3,2,0,0,1' sheet_interval='none'
             sheet_name="DETAILS" suppress_bylines='no'
			 ABSOLUTE_COLUMN_WIDTH='7,8,8,10,5,15,15,9,9,9');
PROC REPORT DATA=TOTAL_DETAILS;
	COLUMN EMPLID2 COURSE ACAD_PLAN ACAD_SUB_PLAN CUM_GPA SORT_NAME EMAIL_ADDRESS CELL_PHONE_NMBR MAIN_PHONE_NMBR PERM_PHONE_NMBR;
	LABEL EMPLID2='ID'
			COURSE='Course'
			ACAD_PLAN='Acad. Plan'
			ACAD_SUB_PLAN='Subplan'
			CUM_GPA='GPA'
			SORT_NAME='Name'
			EMAIL_ADDRESS='Email'
			CELL_PHONE_NMBR='Cell Phone'
			MAIN_PHONE_NMBR='Main Phone'
			PERM_PHONE_NMBR='Perm Phone';

RUN;
title;
ods tagsets.excelxp close;

PROC SORT DATA = TOTAL_LEFT;
	BY ACAD_PLAN SEMSTER COURSE;
RUN;

DATA TOTAL_LEFT;
	SET TOTAL_LEFT;
	COURSE2 = CATX('-',SEMSTER,COURSE);
RUN;

TITLE 'Courses left remaining for the current Frisco cohort';
ods tagsets.excelxp file="C:\Users\jrk0200\UNT System\New College - Reports\&curdate.\LEFTOVER.xml" style=XLSANSPRINTER
    options( embedded_titles='yes' AUTOFIT_HEIGHT='YES' 
			 skip_space='3,2,0,0,1' sheet_interval='BYGROUP'
             sheet_name="#byval1" suppress_bylines='no'
			 ABSOLUTE_COLUMN_WIDTH='22,8');

PROC FREQ DATA=TOTAL_LEFT ORDER=DATA;
	BY ACAD_PLAN;
	TABLE COURSE2/NOCUM NOPERCENT;
RUN;
title;
ods tagsets.excelxp close;

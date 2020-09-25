*****************************************************************
**                                                             **
**    PROGRAM NAME:  Frisco Enrollment Report - Summer         **
** 			   												   **
**    LAST REVISED:  04/24/2020      BY: Jared Kelly           **
**    4/2/20: Changed headings for MC 						   **
**	  4/24/20: Added executive report						   **
**                                                             **
**     Every Week                                              **
**  1) add the week's enrollment to the trajectory calc        **	input for each monday in 2019 -JK 11/1/19
**  2) change old_enroll to closest archive date               **	can we reconfigure this to automatically grab from trajectory?                         **
**                                                             **
**     Every Semester                                          **
**  3) change trajectory set to current semester               **
**  4) change all labels to current year/semester              **
**  5) update NTSR (and the rest) link                         **
**  6) change name of report/trajectory in link                **
**                                                             **
**                                                             **
*****************************************************************;

* This is an archived enrollment file, used to compare to a date in time (closest date to one year prior);
*%let old_date=04;
*%let old_enroll='S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019z_040519'; *LAST YEAR'S FILE;

* This loads today's Simsterm data;
%let SIMSTERM="S:\UIS\Shared\SAS Data Projects\simsterm_records\s2020gim_%sysfunc(today(),mmddyy6.)";
*%let SIMSTERM="C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\Simsterm\s2020c_010720";

* This loads today's Enrollment data;
%let new_enroll="S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020gim_%sysfunc(today(),mmddyy6.)"; *THIS YEAR'S FILE;
*%let new_enroll="S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020c_010720"; *THIS YEAR'S FILE;

* This loads the suummer census enrollment data from the previous years;
%LET SUM_CENSUS_19="S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019gim_census";
%LET SUM_CENSUS_18="S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2018gim_census";

* This loads the registrar's current enrollment file, for class capacity and room information;
%LET REG_DATAFILE="C:\Users\jrk0200\UNT System\Registrar - Summer 2020\ntsr_class_listing_all_summer_1203.xls"; *REGISTRAR FILE LOCATION;

* MACRO VAR: REPORT FILE SAVE LOCATION/NAME;
%LET REPORT_FNAME="S:\UIS\Shared\SAS Data Projects\ATOM\devdata\Summer_Enrollment_Report_%sysfunc(today(),DATE9.).XML";

/*LIBNAME IN1 "S:\TRANSFER";*/
**-------------------------------------------------------------**;

PROC FORMAT;		*format for groups to be able to force arrangement;
	VALUE $GROUP
		"Col of Health & Public Service"="SOCS - Health and Public Services"
		"Col of Lib Arts & Social Sci"="CLASS - Liberal Arts and Social Sciences"
		"College of Business"="BUAD - Ryan College of Business"
		"College of Education"="COE - College of Education"
		"College of Engineering"="COEng - College of Engineering"
		"College of Information"="LIBR - College of Information"
		"College of Mrch, Hosp, Tourism"="SMHM - College of Mrch, Hosp, Tourism"
		"College of Science"="COS - College of Science"
		"College of Visual Arts & Dsgn"="SOVA - College of Visual Arts & Design"
		"Graduate School"="Toulouse Graduate School"
		"New College"="NCL - New College - Non BAAS"
		"Program (BAAS)"="NCL - New College - BAAS"
		"Site (CHEC)"="CHEC - Collin Higher Education Center";
RUN;

PROC FORMAT;		*format for grouping in reports;
	VALUE $GROUPING
		"sum1"="3W1 Session"
		"sum2"="8W1 Session"
		"sum3"="5W1 Session"
		"sum4"="10W Session"
		"sum5"="8W2 Session"
		"sum6"="5W2 Session"
		"sum7"="SUM Session";

RUN;


*** IMPORT COURSE DETAILS FROM REGISTRAR;
PROC IMPORT OUT= WORK.REGISTRAR
            DATAFILE= &REG_DATAFILE.
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$";
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

*** STEP TO GRAB ONLY THE OBSERVATIONS WE WANT, AND TO CONVERT THEM TO THE ENROLLMENT FORMAT;
DATA REG_ENR;
	SET REGISTRAR(RENAME=(TOT_ENRL=TOT_ENRL_NUM CAP_ENRL=CAP_ENRL_NUM MTG_START=NEW_MTG_START MTG_END=NEW_MTG_END));
	WHERE LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK') OR SUBJECT IN ('BAAS');
	TOT_ENRL = INPUT(TOT_ENRL_NUM, BEST12. -L);
	CAP_ENRL = INPUT(CAP_ENRL_NUM, BEST12. -L);
   	MTG_START = INPUT(NEW_MTG_START, TIME.);
	MTG_END = INPUT(NEW_MTG_END, TIME.);
	STRM = TERM;
	ACAD_GROUP = College_School;
	A_GRP_DESCR = College_School_Descr;
	SUBJECT_AORG_DSCR = Department;
	CATALOG_NBR = Catalog;
	CLASS_SECTION = SECTION;
	CRSE_CAREER = CAREER;
	CRSE_DESCR = Course_Descr;
	ENRL_CAP = Cap_Enrl;
	ENRL_TOT = Tot_Enrl;
	CLASS_FACILITY_ID = Facil_ID;
	COURSE = CATX('-', SUBJECT, CATALOG_NBR, CLASS_SECTION);
	REG_MT_DAYS = Days_of_the_Week;
	IF START_DATE = "22046" AND END_DATE = "22063" THEN SUMMER_TERM="3W1";	*ADD VARIABLE FOR SUMMER TERM;
	ELSE IF START_DATE = "22046" AND END_DATE = "22099" THEN SUMMER_TERM="8W1";
	ELSE IF START_DATE = "22067" AND END_DATE = "22099" THEN SUMMER_TERM="5W1";
	ELSE IF START_DATE = "22067" AND END_DATE = "22134" THEN SUMMER_TERM="10W";
	ELSE IF START_DATE = "22067" AND END_DATE = "22120" THEN SUMMER_TERM="8W2";
	ELSE IF START_DATE = "22102" AND END_DATE = "22134" THEN SUMMER_TERM="5W2";
	ELSE IF START_DATE = "22046" AND END_DATE = "22134" THEN SUMMER_TERM="FULL";
	ELSE SUMMER_TERM = "MISC";
	DROP TERM College_School College_School_Descr Department Catalog SECTION
	CAREER Course_Descr Cap_Enrl Tot_Enrl Crse_Level Instr_Type Facil_ID Facil_Type
	Days_of_the_Week MON TUES WED THURS FRI SAT SUN
	EMPLID NAME GRADE_BASE SESSION ACAD_ORG Course_ID CIP_Code
	Wait_Cap Wait_Tot ROOM_CAP TOT_ENRL_NUM;
RUN;

*** SANITY CHECK TO MAKE SURE THAT GROUPS ARE PROPERLY ASSIGNED;
*PROC FREQ DATA=REG_ENR; *sanity check;
*	TABLE SUMMER_TERM;
*RUN;

*** SORT REG DATA FOR MERGE WITH ROOMSIZES;
PROC SORT DATA=REG_ENR;
	BY CLASS_FACILITY_ID;
RUN;

*** IMPORTING TABLE TO IMPORT CLASSROOM CAPACITIES;
PROC IMPORT OUT= WORK.ROOMSIZES
            DATAFILE= "C:\Users\jrk0200\UNT System\Clark, Allen - Frisco
Enrollment\FriscoRoomCapacities.xlsx"
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$";
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
*** ROOMSIZES dataset contains all classrooms and their capacities from the lookup table;
DATA ROOMSIZES;
	SET ROOMSIZES;
	DROP LOC;
	LABEL ROOM_CAP = "Room Cap.";
RUN;
*** SORT FOR MERGE;
PROC SORT DATA=ROOMSIZES;
	BY CLASS_FACILITY_ID;
RUN;

*** MERGE REGISTRAR DATA WITH ROOM SIZE DATA;
DATA REG_ENR1;
	MERGE REG_ENR(IN=A) ROOMSIZES;
	BY CLASS_FACILITY_ID;
	IF A=1;
RUN;


PROC FORMAT;	* format for missing values;
	VALUE MISSING
		.=0
		OTHER=[BEST.];
RUN;

PROC SORT DATA=REG_ENR1;
	BY SUMMER_TERM;
RUN;


**************************************************
				EXECUTIVE REPORT CONSTRUCTION
*************************************************;
%MACRO ENROLL_SNAP(DSNAME, DSOURCE, LABEL);			* WE CAN'T COUNT THE PERIPHERAL ENROLLMENT YET BECAUSE IT ISN'T INDIVIDUAL OBSERVATIONS;
	DATA &DSNAME;
		SET &DSOURCE;
		WHERE LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK') OR SUBJECT IN ('BAAS');
		IF LOCATION IN ('FRSC', 'Z-INSPK') THEN GROUP = 'FRISCO';
		ELSE IF SUBJECT IN ('BAAS') THEN GROUP = 'BAAS';
		ELSE IF LOCATION IN ('Z-CHEC') THEN GROUP = 'CHEC';
		COUNT = 1;
		*KEEP GROUP SESSION_CODE;
	RUN;
	PROC SORT DATA=&DSNAME;
		BY SESSION_CODE GROUP;
	RUN;
	DATA F&DSNAME;
		SET &DSNAME;
		BY session_code GROUP;
		IF LAST.GROUP;                 /*Go back if not last.id     */
	  	COUNT=_n_-sum(lag(_n_),0);  /*At last.id, calculate COUNT*/
		&LABEL = COUNT;
		LABEL GROUP='CAMPUS';
		DROP COUNT;
	run;
%MEND ENROLL_SNAP;
RUN;

/* %ENROLL_SNAP(DS NAME, DS SOURCE, TIME LABEL)*/
%ENROLL_SNAP(EX1, &new_enroll, TODAY);
%ENROLL_SNAP(EX2, &SUM_CENSUS_19, FY19);
%ENROLL_SNAP(EX3, &SUM_CENSUS_18, FY18);

DATA EX_REPORT;		*ALL FOUR TIME PERIODS MERGED;
	MERGE FEX1 FEX2 FEX3;
	BY session_code GROUP;
RUN;

PROC FORMAT;
	VALUE $SUMMER
		"10W"="10-Week Summer Session"
		"3W1"="3-Week Summer Session"
		"5W1"="First 5-week Summer Session"
		"5W2"="Second 5-week Summer Session"
		"8W1"="First 8-week Summer Session"
		"8W2"="Second 8-week Summer Session";
RUN;


DATA EX_REPORT;		*TYPE ADDED FOR LATER SEPARATION IN REPORT;
	SET EX_REPORT;
	LENGTH TYPE $8.;
	IF GROUP IN ('BAAS') THEN TYPE='PROGRAM';
	ELSE TYPE='CAMPUS';
	FORMAT session_code $summer.;
RUN;
PROC SORT DATA=EX_REPORT;
	BY session_code type;
RUN;


title1 "Summer Enrollment Report";
ods tagsets.excelxp file="C:\Users\jrk0200\UNT System\UNT at Frisco - Shared Documents - Enrollment Reports\Summer 2020\ENROLL_SUM20_%sysfunc(today(), mmddyy6).xml" style=XLsansprinter;

options nobyline;
ods tagsets.excelxp options(embedded_titles='yes' autofit_height='yes' sheet_interval='none'
						sheet_NAME='Executive Report' absolute_column_width='8,15,8,8,8,8,8,10');

PROC REPORT DATA=EX_REPORT HEADLINE HEADSKIP;
	BY SESSION_CODE;
	COLUMN GROUP ('Executive Enrollment Report'('Enrollment' TODAY FY19 FY18)
				('Growth Since' FY19_CHANGE FY18_CHANGE)) TYPE;
	DEFINE GROUP / DISPLAY 'Campus';
	DEFINE TODAY / ANALYSIS "%sysfunc(today(), WORDDATE.)";
	DEFINE FY19 / ANALYSIS 'Summer 2019';
	DEFINE FY18 / ANALYSIS 'Summer 2018';
	DEFINE FY19_CHANGE / COMPUTED 'Summer 2019' FORMAT=PERCENTN8.1;
	DEFINE FY18_CHANGE / COMPUTED 'Summer 2018' FORMAT=PERCENTN8.1;
	DEFINE TYPE / GROUP NOPRINT;
	COMPUTE FY19_CHANGE;
		FY19_CHANGE = (TODAY.SUM - FY19.SUM) / FY19.SUM;
	ENDCOMP;
	COMPUTE FY18_CHANGE;
		FY18_CHANGE = (TODAY.SUM - FY18.SUM) / FY18.SUM;
	ENDCOMP;
	*BREAK AFTER TYPE / SUMMARIZE OL UL;
	RBREAK AFTER / SUMMARIZE OL UL;
	title '#byval(session_code)';
RUN;

ods tagsets.excelxp options(embed_titles_once='yes' autofit_height='yes' sheet_interval='none'
						sheet_NAME='Course Report' absolute_column_width='5,7,7,7,6,6,6,18,9,9,9,7,7');

proc report data=REG_ENR1 HEADLINE HEADSKIP;
	by SUMMER_TERM;
	column ('Capacity' ROOM_CAP ENRL_CAP USE)
			('Course' CLASS_FACILITY_ID SUBJECT CATALOG_NBR CLASS_SECTION CRSE_DESCR REG_MT_DAYS MTG_START MTG_END)
			('Enrollment' ENRL_TOT PERCENT_ENROL);
	DEFINE ROOM_CAP / ANALYSIS 'Room' FORMAT=MISSING.;
	DEFINE PERCENT_ENROL / COMPUTED FORMAT=PERCENT. '%';
	DEFINE REG_MT_DAYS / DISPLAY "Meeting Schedule";
	DEFINE MTG_START / DISPLAY 'Start Time' FORMAT=TIMEAMPM.;
	DEFINE MTG_END / DISPLAY 'End Time' FORMAT=TIMEAMPM.;
	DEFINE CLASS_FACILITY_ID / DISPLAY 'Room';
	DEFINE SUMMER_TERM / ORDER 'Term';
	DEFINE CRSE_DESCR / DISPLAY 'Description';
	*DEFINE PREV_FALL / ANALYSIS "Fall '18 (C)" FORMAT=MISSING.;
	*DEFINE PREV_SPRING / ANALYSIS "Spring '19 (C)" FORMAT=MISSING.;
	DEFINE ENRL_CAP / ANALYSIS 'Course';
	*DEFINE PREVIOUS_ENROL / ANALYSIS '2018 (PIT)' FORMAT=MISSING.;
	DEFINE ENRL_TOT / ANALYSIS 'Current';
	*DEFINE NEW_TOTAL / ANALYSIS 'New//X-fer';
	DEFINE USE / COMPUTED 'Use %' format=PERCENT.;
	*DEFINE FCHANGE / COMPUTED 'Since Fall' FORMAT=MISSING.;
	*DEFINE SCHANGE / COMPUTED 'Since Spring' FORMAT=MISSING.;
	DEFINE SUBJECT / DISPLAY 'Subj';
	DEFINE CATALOG_NBR / DISPLAY 'Cat';
	DEFINE CLASS_SECTION / DISPLAY 'Sec';
	COMPUTE USE;
		USE = ENRL_CAP.sum/ROOM_CAP.sum;
	ENDCOMP;
	COMPUTE PERCENT_ENROL;
		PERCENT_ENROL = ENRL_TOT.SUM/ENRL_CAP.SUM;
	ENDCOMP;
	*COMPUTE FCHANGE;
	*	IF PREV_FALL.SUM > 0 THEN FCHANGE = ENRL_TOT.SUM - PREV_FALL.SUM;
	*	ELSE FCHANGE = ENRL_TOT.SUM;
	*ENDCOMP;
	*COMPUTE SCHANGE;
	*	IF PREV_SPRING.SUM > 0 THEN SCHANGE = ENRL_TOT.SUM - PREV_SPRING.SUM; 	*IF statement to return ENRL_TOT.SUM in the event that PREV_SPRING.SUM =[.,0];
	*	ELSE SCHANGE = ENRL_TOT.SUM;
	*ENDCOMP;
	RBREAK AFTER /SUMMARIZE OL UL;
run;
ods tagsets.excelxp close;
title;

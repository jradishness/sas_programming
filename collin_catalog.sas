/*
PROC IMPORT OUT= WORK.Offerings 
            DATAFILE= "C:\Users\jrk0200\UNT System\Clark, Allen - Frisco
Enrollment\Fall19FriscoOfferings.xlsx" 
            DBMS=EXCELCS REPLACE;
     RANGE="Sheet1$"; 
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
*/

DATA OFFERINGS2;
	SET OFFERINGS;			*set of courses from molly's records;
	SECTION=PUT(CLASS_SECTION, z3.);					*attempt to reformat with leading zeros;
	COURSE=CATX('-',SUBJECT,CATALOG_NBR,SECTION);		*create course variable;
	KEEP COURSE ;		*Final set is list of courses in molly's report;
RUN;
PROC SORT DATA=OFFERINGS2 nodupkey;
	BY COURSE;
RUN;

DATA FRISCO_ENROLLMENT;
	SET ENROLLMENT;
	IF LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK');
	KEEP COURSE CRSE_DESCR SUBJECT CATALOG_NBR CLASS_SECTION UNT_TAKEN LOCATION 
		SUBJECT_AORG_DSCR A_GRP_DESCR CLASS_MTG_PAT CLASS_FACILITY_ID CLASS_MTG_TIME
		INSTR_FIRST_NAME INSTR_LAST_NAME;
RUN;

PROC SORT DATA=FRISCO_ENROLLMENT NODUPKEY;
	BY COURSE;
RUN;

DATA FRISCO_CATALOG;
	MERGE OFFERINGS2 FRISCO_ENROLLMENT;
	BY COURSE;
RUN;	

proc sort data=frisco_catalog nodupkey;
	by course;
run;

PROC EXPORT DATA= WORK.frisco_catalog
            OUTFILE= "Desktop\sample.xls"
            DBMS=EXCELCS LABEL REPLACE;
     SHEET="total";
RUN;

proc print data=enrollment;
/*	where INSTR_LAST_NAME='Takarli';*/
	where subject='UCRS' and CATALOG_NBR='2020';
run;

PROC IMPORT OUT= WORK.fall_19_offers 
            DATAFILE= "S:\UIS\Shared\SAS Data Projects\ATOM\fall19offerings.xls"
            DBMS=EXCELCS REPLACE;
     RANGE="total$"; 
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

PROC SORT DATA=FALL_19_OFFERS;
	BY COLLEGE;
RUN;

DATA FALL_19_OFFERS;
	SET FALL_19_OFFERS;
	LENGTH FIRST_INI $ 1;
	FIRST_INI=(INSTR_FIRST_NAME);
	INST_NAME=CATX(" ",INSTR_LAST_NAME,FIRST_INI);;
RUN;

PROC FORMAT;
	VALUE $LOCATION 'FRSC'='Hall Park'
					'MAIN'='Main Campus'
					'Z-CHEC'='CHEC'
					'Z-INSPK'='Inspire Park'
					'Z-INET-TX'='Internet (TX)'
					'Z-INET-OS'='Internet (Not-TX)'
					'Z-AOP'='AOP';
RUN;

title1 "Courses Offered in Fall '19";
ods tagsets.excelxp file="S:\UIS\Shared\SAS Data Projects\SAS Output\FALL_2019_CAT_%sysfunc(today(), mmddyy6).xml" style=XLsansprinter
	options(embedded_titles='yes' autofit_height='yes' sheet_interval='bygroup' skip_space='0,0,0,0,0'
			sheet_name='#byval1' absolute_column_width='5,4,3,4,18,5,10,8,12,10');
proc report data=fall_19_offers;
	by COLLEGE;
	column 	('Course' SUBJECT CATALOG_NBR CLASS_SECTION UNT_TAKEN CRSE_DESCR class_mtg_pat CLASS_MTG_TIME CLASS_FACILITY_ID INST_NAME LOCATION);
	DEFINE CLASS_MTG_TIME / DISPLAY 'Meeting Time';
	DEFINE CLASS_FACILITY_ID / DISPLAY 'Room';
	DEFINE CRSE_DESCR / DISPLAY 'Description';
	DEFINE SUBJECT / DISPLAY 'Subj';
	DEFINE CATALOG_NBR / DISPLAY 'Cat';
	DEFINE CLASS_SECTION / DISPLAY 'Sec';
	DEFINE COURSE / ORDER;
	DEFINE UNT_TAKEN / DISPLAY 'Cred';
	DEFINE INST_NAME / DISPLAY 'Instructor';
	DEFINE LOCATION / DISPLAY 'Campus' FORMAT=$LOCATION.;
	define class_mtg_pat / display 'Days';
run;
ods tagsets.excelxp close;
title;


/*	COMPUTE USE;*/
/*		USE = ENRL_CAP.sum/ROOM_CAP.sum;*/
/*	ENDCOMP;*/
/*	COMPUTE PERCENT_ENROL;*/
/*		PERCENT_ENROL = ENRL_TOT.SUM/ENRL_CAP.SUM;*/
/*	ENDCOMP;*/
/*	COMPUTE FCHANGE;*/
/*		IF PREV_FALL.SUM > 0 THEN FCHANGE = ENRL_TOT.SUM - PREV_FALL.SUM;*/
/*		ELSE FCHANGE = ENRL_TOT.SUM;*/
/*	ENDCOMP;*/
/*	COMPUTE SCHANGE;*/
/*		IF PREV_SPRING.SUM > 0 THEN SCHANGE = ENRL_TOT.SUM - PREV_SPRING.SUM; 	*IF statement to return ENRL_TOT.SUM in the event that PREV_SPRING.SUM =[.,0];*/
/*		ELSE SCHANGE = ENRL_TOT.SUM;*/
/*	ENDCOMP;*/
/*	RBREAK AFTER /SUMMARIZE OL UL;*/

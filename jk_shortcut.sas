**************************************************************
							CODE SNIPPETS
*************************************************************;

**** LOAD TODAY'S ENROLLMENT AND SIMSTERM INTO MEMORY;
DATA WORK.SIMSTERM;
	SET "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\Simsterm\s2019z_%sysfunc(today(),mmddyy6.)";
RUN;
DATA WORK.ENROLLMENT;
	SET "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\ENROLLEMENT_DW_2019Z_%sysfunc(today(),mmddyy6.)";
RUN;

************************************** CREATING A DIRECTORY;
options dlcreatedir;		*To give SAS "Create Directory" priviledges;
libname newdir "S:\UIS\Shared\SAS Data Projects\Frisco Guided Paths\RESULTS\&fname1.";	*To name the new directory;


****************************************** CURRENT DATE;
%let curdate = %sysfunc(today(),mmddyy7.);	

************************************************************** iMPORT TO eXCEL; 
PROC IMPORT OUT= WORK.OFFERINGS 
            DATAFILE= "C:\Users\jrk0200\UNT System\Clark, Allen - Frisco
Enrollment\Fall19FriscoOfferings.xlsx" 
            DBMS=EXCELCS REPLACE;
     RANGE="Sheet1$"; 
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

************************************************************** Export data to Excel to create pivot table; 
title1 "List of Courses Remaining to be taken by &CNAME Spring 2019 Cohort";
ods tagsets.excelxp file="S:\UIS\Shared\SAS Data Projects\Frisco Guided Paths\RESULTS\&FNAME" style=XLSANSPRINTER
    options( embedded_titles='yes' AUTOFIT_HEIGHT='YES' 
			 skip_space='3,2,0,0,1' sheet_interval='none'
             sheet_name="&PROG" suppress_bylines='no'
			 ABSOLUTE_COLUMN_WIDTH='16,6');

	proc tabulate data=WORK.PRNT_&VARN;
		class COURSE2;
		TABLE COURSE2=' ', N='Need';
	RUN;
	title;
	ods tagsets.excelxp close;

************************************** Export function ********************;
PROC EXPORT DATA= WORK.PSYC_LEFT 
            OUTFILE= "C:\Users\vac0019\Desktop\newdata.xls" 
            DBMS=EXCEL LABEL REPLACE;
     SHEET="PSYCH"; 
RUN;

************************************** Concatenation of a pair of variables into a single new variable;
DATA TOTAL_LEFT;
	SET TOTAL_LEFT;
	COURSE2 = CATX('-',SEMSTER,COURSE);
RUN;

********************************************* Filter by location;

IF LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK');			* Value for campus we want considered;


**************************************************** Remove duplicates from FRISCO_MULT;
* WORK.FRISCO_MULT = ONLY THE FIRST COURSE FOR EACH STUDENT;
* WORK.FRISCO_STUD = THE REST OF THE COURSES;
PROC SORT DATA=FRISCO_MULT
			DUPOUT=FRISCO_STUD 
			NODUPKEY;
	BY EMPLID2;
RUN;

***************************************** PROC REPORT INTO ODS;
title1 &xprog.;
ods tagsets.excelxp file="S:\UIS\Shared\SAS Data Projects\Frisco Guided Paths\FRISCO COURSE LIST\FALL_2019_%sysfunc(today(), mmddyy6).xml" style=XLsansprinter 
	options(embed_titles_once='yes' autofit_height='yes' sheet_interval='none' 
			sheet_name='Course Report' absolute_column_width='6,6,5,7,5,4,3,18,10,5,6,6,6,6,5,5,7,15');
proc report data=one_class1_crs3 HEADLINE HEADSKIP;
	by a_grp_descr;
	column ('Capacity' ROOM_CAP ENRL_CAP USE) 
			('Course' CLASS_FACILITY_ID SUBJECT CATALOG_NBR CLASS_SECTION CRSE_DESCR CLASS_MTG_TIME) 
			('Enrollment' PREV_FALL PREV_SPRING PREVIOUS_ENROL ENRL_TOT NEW_TOTAL PERCENT_ENROL) 
			('Change' FCHANGE SCHANGE) WARNING;
	DEFINE ROOM_CAP / ANALYSIS 'Room' FORMAT=MISSING.;
	DEFINE PERCENT_ENROL / COMPUTED FORMAT=PERCENT. '%';
	DEFINE CLASS_MTG_TIME / DISPLAY 'Meeting Time';
	DEFINE WARNING / DISPLAY FORMAT=$WARNING.;
	DEFINE CLASS_FACILITY_ID / DISPLAY 'Room';
	DEFINE CRS / ORDER 'Code';
	DEFINE CRSE_DESCR / DISPLAY 'Description';
	DEFINE PREV_FALL / ANALYSIS "Fall '18 (C)" FORMAT=MISSING.;
	DEFINE PREV_SPRING / ANALYSIS "Spring '19 (C)" FORMAT=MISSING.;
	DEFINE ENRL_CAP / ANALYSIS 'Course';
	DEFINE PREVIOUS_ENROL / ANALYSIS '2018 (PIT)' FORMAT=MISSING.;
	DEFINE ENRL_TOT / ANALYSIS 'Current';
	DEFINE NEW_TOTAL / ANALYSIS 'New//X-fer';
	DEFINE USE / COMPUTED 'Use %' format=PERCENT.;
	DEFINE FCHANGE / COMPUTED 'Since Fall' FORMAT=MISSING.;
	DEFINE SCHANGE / COMPUTED 'Since Spring' FORMAT=MISSING.;
	DEFINE SUBJECT / DISPLAY 'Subj';
	DEFINE CATALOG_NBR / DISPLAY 'Cat';
	DEFINE CLASS_SECTION / DISPLAY 'Sec';
	COMPUTE USE;
		USE = ENRL_CAP.sum/ROOM_CAP.sum;
	ENDCOMP;
	COMPUTE PERCENT_ENROL;
		PERCENT_ENROL = ENRL_TOT.SUM/ENRL_CAP.SUM;
	ENDCOMP;
	COMPUTE FCHANGE;
		IF PREV_FALL.SUM > 0 THEN FCHANGE = ENRL_TOT.SUM - PREV_FALL.SUM;		
		ELSE FCHANGE = ENRL_TOT.SUM;
	ENDCOMP;
	COMPUTE SCHANGE;
		IF PREV_SPRING.SUM > 0 THEN SCHANGE = ENRL_TOT.SUM - PREV_SPRING.SUM; 	*IF statement to return ENRL_TOT.SUM in the event that PREV_SPRING.SUM =[.,0];
		ELSE SCHANGE = ENRL_TOT.SUM;		
	ENDCOMP;
	RBREAK AFTER /SUMMARIZE OL UL;
run;
ods tagsets.excelxp close;
title;




**************************************************************
							FORMATS
**************************************************************

********************** Format for SIMSTERM LOCATION VAR;
PROC FORMAT;
	VALUE $LOCATION 'FRSC'='Hall Park'
					'MAIN'='Main Campus'
					'Z-CHEC'='CHEC'
					'Z-INSPK'='Inspire Park'
					'Z-INET-TX'='Internet (TX)'
					'Z-INET-OS'='Internet (Not-TX)'
					'Z-AOP'='AOP';
RUN;

*********************** FORMAT STATEMENT FOR ADMIT_N VALUES;
PROC FORMAT;			
	VALUE ADMIT
	1='Continuing Student'
	2='First Time in College'
	3='Transfer'
	4='New Grad'
	6='Transient';
RUN;

************************ FORMAT FOR ENROLLMENT WARNING;
PROC FORMAT;
	VALUE $WARNING
		"0"=''
		"1"="!REACHING FULL!"
		"2"="!!!FULL!!!"
		"3"="ERROR! OVERFILLED?"
		"4"="LOW ENROLLMENT";

************************ FORMAT TO ELIMINATE EMPTY/MISSING VALUES;
PROC FORMAT;
	VALUE MISSING
		.=0
		OTHER=[BEST.];
RUN;




**************************************************************
							TEMPLATES
**************************************************************

******************* UNT REPORT TEMPLATE FOR EXCEL;
proc template;
 define style styles.XLsansPrinter;
 parent = styles.sansPrinter;

 /* Change attributes of the column headings */

 style header from header /
 font_size = 11pt
 just = center
 BACKGROUND=GREEN
 vjust = bottom;
 end;
run; quit; 



**************************************************************
							MACROS
**************************************************************

options mprint mlogic;
%MACRO GATEWAY(PROG,SHORT,VARN,CNAME,FNAME);	*INITIALIZE THE MACRO: ;
	*PROGRAM: Everything in the Program indented;
	PROC IMPORT OUT= WORK.GUIDEDPATH DATAFILE= "S:\UIS\Shared\Allen Clark\Frisco\Guided Pathway.xlsx" ;
		RANGE="&SHORT"; 						* REFERENCE MACRO VARIABLE WITH AMPERSAND;
	RUN;
%MEND GATEWAY;
run;

*************************** GATEWAY(PROG,SHORT,VARN,CNAME,FNAME);		*TEMPLATE HELPER LINE;
%GATEWAY(KINE-BS, KINE$, KIN, Kinesiology BS, &fname1./kin_courses_&fname1..xml);		*EXECUTION LINES;
%GATEWAY(CEXM-BS, CEMB$, CEM, Consumer Experience Managemenent BS, &fname1./cem_courses_&fname1..xml);
%GATEWAY(JOUR-BA, JOUR$, JOU, Journalism BA, &fname1./jou_courses_&fname1..xml);




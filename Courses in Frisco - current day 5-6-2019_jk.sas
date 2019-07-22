*****************************************************************
**                                                             **
**    PROGRAM NAME:  EIS-ANNUAL COURSE COMPARISON              **
**    FRISCO COURSES                                           **
** 			   												   **
**    LAST REVISED:  07/16/2019      BY: Jared Kelly           **
**                                                             **
*****************************************************************;


%let datetoday=%sysfunc(today(),mmddyy6.);
%LET fancydate=%sysfunc(today(),mmddyy10.);
%LET XTERM=FALL 2019 (UNOFFICIAL 7/11/19);   /* # */
%LET XOFFICE=uis, UNT;
%LET XCENSUS=09/11/2019;           /*CENSUS DATE (YYYYMMDD)... <-- # */
%LET XPROG="COURSES IN FRISCO- CURRENT DAY %sysfunc(today(),mmddyy10.)";
%let SIMSTERM="C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\Simsterm\s2019z_%sysfunc(today(),mmddyy6.)";
%let new_enroll="C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\ENROLLEMENT_DW_2019Z_%sysfunc(today(),mmddyy6.)"; *THIS YEAR'S FILE;
%let old_enroll='C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2018z_071818'; *LAST YEAR'S FILE;
%LET LAST_FALL_CENSUS="C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2018z_census";  * LAST FALL'S CENSUS ENROLLMENT FILE;
%LET LAST_SPRING_CENSUS="C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019c_census";	* LAST SPRING'S CENSUS ENROLLMENT FILE;
/*LIBNAME IN1 "S:\TRANSFER";*/
**-------------------------------------------------------------**;
%MACRO ZTERM;
  DATE = TODAY();                                 /*TODAY'S DATE*/
  PUT  @23  'FALL 2019 UNOFFICIAL ENROLLMENT' /* # */
       @102 DATE DATE9.;
%MEND ZTERM;

* Import new enrollment dataset;
DATA THECBSET_ORIG;
  SET &new_enroll;	
  RUN;
PROC SORT DATA=THECBSET_ORIG;		***THECBSET_ORIG is enrollment data from new_enroll sorted by emplid;
	BY EMPLID;
RUN;


**************************************************************
					NEW STUDENT CALCULATION
**************************************************************


* create dataset for counting new students;
DATA NEW_STUDENTS;
	SET &SIMSTERM.;		* must have current simsterm loaded;
	WHERE ADMIT_N IN (2,3,4);
	NEW_STUD = 1;
	KEEP EMPLID NEW_STUD;
RUN;
PROC SORT DATA=NEW_STUDENTS;		***NEW_STUDENTS is a list of emplids of new students with a column for new_stud=1;
	BY EMPLID;
RUN;

* Merge simsterm with enrollment;
DATA THECBSET_NEW;					***THECBSET_NEW is the same as THECBSET_ORIG (all current enrollment data),
										with a column for new_stud=1/0;
	MERGE NEW_STUDENTS THECBSET_ORIG;
	BY EMPLID;
RUN;

*Create NEW_TOTAL dataset from new merged dataset, keeping only course and new_stud;
* To help calculate how many students are new;
DATA NEW_TOTAL;
	SET THECBSET_NEW;
	KEEP COURSE NEW_STUD;
RUN;
PROC SORT DATA=NEW_TOTAL;
	BY COURSE;
RUN;

* THIS IS WHERE THE TOTAL NEW STUDENTS ARE CALCULATED (NEW_TOTAL);
DATA NEW_TOTAL;  
	SET NEW_TOTAL;
	BY COURSE;
	IF FIRST.COURSE THEN NEW_TOTAL = 0;		* SET VALUE OF NEW_TOTAL TO ZERO AT EVERY NEW COURSE;
	NEW_TOTAL + NEW_STUD;					* INCREMENT NEW_TOTAL FOR EACH NEW_STUDENT;
	IF LAST.COURSE;							* ONLY RETURN LAST OBSERVATION (HIGHEST VALUE (COUNT TOTAL));
RUN;
DATA NEW_TOTAL;
	SET NEW_TOTAL;
	CRS = COURSE;
	DROP NEW_STUD;
RUN;


**************************************************************
					POINT-IN-TIME CALCULATION
**************************************************************


*Load comparison enrollment data from previous year;
DATA  OLD_FILE;		
  SET &old_enroll;
  RUN;
DATA OLD_FILE;
  SET OLD_FILE;
  IF X_LOCATION IN ('FRSC');	*filter by location (BROKEN?);
  ENROL=1;						* add a new var for ENROL;
  CRS = COURSE;					
RUN;
PROC SORT DATA=OLD_FILE;			***OLD_FILE is the reference enrollment set, filtered to frisco, sorted by CRS;
BY CRS;
RUN;

* NOT SURE, maybe a narrowing, or filtering of duplicates?;
DATA OLD_FILE2;						***OLD_FILE2 is the set of unrepeated courses with the total previous enrollment;
SET OLD_FILE;
BY CRS;
IF LAST.CRS= 1 THEN OUTPUT OLD_FILE2;
KEEP CRS ENRL_TOT;
RUN;

*End up with a dataset with only previous enrollment;
DATA OLD_FILE3;						***OLD_FILE3 is the set of unrepeated courses with the total previous enrollment;
  SET OLD_FILE2;
  PREVIOUS_ENROL=ENRL_TOT;
  LABEL PREVIOUS_ENROL="2018 Enrolled (PIT)";
  DROP ENRL_TOT;
  RUN;




*grab current enrollment (with new stud) and create a var for ENROL to count enrollment;
DATA THECBSET1;						***THECBSET1 is the current enrollment, with new_stud column, 
										and a ENROL var for counting enrollments;	
  SET THECBSET_NEW;
  IF X_LOCATION IN ('FRSC');	*Filter by location; 
  ENROL=1;
  CRS = COURSE;
RUN;


**************************************************************
					PREVIOUS SEMESTER CALCULATION
**************************************************************


*** IMPORT ARCHIVED ENROLLMENT;
%MACRO SEMESTER(DS_NAME, DS_SOURCE, VAR, LABEL);
	DATA &DS_NAME;			
		SET &DS_SOURCE;					* LOAD FROM MACRO;
		IF LOCATION IN ('FRSC');				* FILTER FOR FRISCO;
		&VAR = ENRL_TOT;					* RENAME VAR FOR LATER;
		CRS = COURSE;
		KEEP CRS &VAR;						* KEEP ONLY NECESSARY VARS;
		LABEL &VAR=&LABEL;
	RUN;
	PROC SORT DATA=&DS_NAME NODUPKEY;			* REMOVE DUPLICATES;
		BY CRS;
	RUN;
%MEND SEMESTER;
RUN;

%SEMESTER(LAST_FALL, &LAST_FALL_CENSUS, PREV_FALL, 'Fall 2018 (Census)')			*PREVIOUS FALL SEMESTER IMPLEMENTATION;
%SEMESTER(LAST_SPRING, &LAST_SPRING_CENSUS, PREV_SPRING, 'Spring 2018 (Census)')			*PREVIOUS SPRING SEMESTER IMPLEMENTATION;

**************************************************************
					PREVIOUS SPRING CALCULATION
**************************************************************


*** IMPORT ARCHIVED ENROLLMENT;
/*DATA LAST_SPRING;			*/
/*	SET &LAST_SPRING_CENSUS;					* LOAD FROM MACRO;*/
/*	IF LOCATION IN ('FRSC');				* FILTER FOR FRISCO;*/
/*	PREV_SPRING = ENRL_TOT;					* RENAME VAR FOR LATER;*/
/*	CRS = COURSE;*/
/*	KEEP CRS PREV_SPRING;						* KEEP ONLY NECESSARY VARS;*/
/*	LABEL PREV_SPRING='Spring 2019 (Census)';*/
/*RUN;*/
/*PROC SORT DATA=LAST_SPRING NODUPKEY;			* REMOVE DUPLICATES;*/
/*	BY CRS;*/
/*RUN;*/

**************************************************************
					CLASSROOM CAP. CALCULATION
**************************************************************


*** IMPORTING TABLE TO IMPORT CLASSROOM CAPACITIES;
PROC IMPORT OUT= WORK.ROOMSIZES 		
            DATAFILE= "C:\Users\jrk0200\UNT System\Clark, Allen - Frisco
Enrollment\FriscoRoomCapacities.xlsx" 
            DBMS=EXCELCS REPLACE; 			
     RANGE="Sheet1$"; 
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
DATA ROOMSIZES;					*** ROOMSIZES dataset contains all classrooms and their capacities from the lookup table;
	SET ROOMSIZES;
	DROP LOC;
	LABEL ROOM_CAP = "Room Cap.";
RUN;
PROC SORT DATA=ROOMSIZES;		*** SORT FOR MERGE;
	BY CLASS_FACILITY_ID;
RUN;
PROC SORT DATA=THECBSET1; 		*** SORT FOR MERGE;
	BY CLASS_FACILITY_ID;
RUN; 

DATA THECBSET2;				***THECBSET2 is the current enrollment, with new_stud column, 
								and a ENROL var for counting enrollments, AND Room Size limits;
	MERGE THECBSET1(IN=A) ROOMSIZES;
	BY CLASS_FACILITY_ID;
	IF A=1;
RUN;

PROC SORT DATA=THECBSET2;			
BY CRS;
RUN;

**************************************************************
				ARCHIVE MERGE
*************************************************************;


DATA OLD_FILE4;
	MERGE OLD_FILE3 (IN=A) LAST_FALL LAST_SPRING;
	BY CRS;
	IF A=1;
RUN;


**************************************************************
					CURRENT ENROLLMENT CALCULATION
**************************************************************


***ONE_CLASS1_CRS is a set of the courses with current enrollment counts 	;
DATA ONE_CLASS1_CRS;
SET THECBSET2;
BY CRS;
IF LAST.CRS= 1 THEN OUTPUT ONE_CLASS1_CRS;
KEEP CRS a_grp_descr CRSE_DESCR ENRL_TOT ENRL_CAP CLASS_MTG_TIME SUBJECT CATALOG_NBR CLASS_FACILITY_ID ROOM_CAP SUBJECT CATALOG_NBR CLASS_SECTION;
RUN;
pROC SORT DATA=ONE_CLASS1_CRS;		
BY CRS;
RUN;
pROC SORT DATA=OLD_FILE4;
BY CRS;
RUN;

DATA ONE_CLASS1_CRS2;				
MERGE ONE_CLASS1_CRS (IN=A) OLD_FILE4 (IN=B);
BY CRS;
IF A=1;
RUN;
pROC SORT DATA=ONE_CLASS1_CRS2;		***ONE_CLASS1_CRS2 is the same as ONE_CLASS1_CRS except with previous_total included;
BY SUBJECT CATALOG_NBR;
RUN;


**************************************************************
					ENROLLMENT PERCENTAGE CALCULATION
**************************************************************


***ONE_CLASS1_CRS2 is the same as CRS except with previous_total included;
DATA ONE_CLASS1_CRS2;			
    SET ONE_CLASS1_CRS2;		***now it has the Percent Enrolled Var as well;
	IF ENRL_CAP =0 THEN DELETE;
    PERCENT_ENROLLED=ENRL_TOT/ENRL_CAP;
	IF PERCENT_ENROLLED = 1.0 THEN WARNING="2";
	ELSE IF .9 <= PERCENT_ENROLLED < 1.0 THEN WARNING="1";
	ELSE IF .20 <= PERCENT_ENROLLED < .9 THEN WARNING="0";
	ELSE IF 0 <= PERCENT_ENROLLED < .20 THEN WARNING = "4";
	ELSE WARNING="3";
	LABEL PERCENT_ENROLLED = "Enrollment %"
			WARNING = "Warning";
RUN;
PROC SORT DATA=ONE_CLASS1_CRS2;
	BY CRS;
RUN;


**************************************************************
					FINAL DATASET MERGER
*************************************************************;


DATA ONE_CLASS1_CRS3;			
	MERGE ONE_CLASS1_CRS2 (IN=A) NEW_TOTAL;
	BY CRS;
	IF A=1;
	LABEL CLASS_MTG_TIME = "Class Mtg Time"
			CLASS_FACILITY_ID = "Room No."
			CRS = "Course Code"
			CRSE_DESCR = "Course" 
			A_GRP_DESCR = "College"
			ENRL_TOT = "2019 Enrolled"
			ENRL_CAP = "Class Cap."
			NEW_TOTAL = "New Students";
RUN;

proc sort data =one_class1_crs3;   ***ONE_CLASS1_CRS3 is the same as CRS2 except with New Student Totals Included;
	by a_grp_descr;						*** sorted by the college;
run;


**************************************************************
			FORMATS AND TEMPLATES
*************************************************************;


PROC FORMAT;
	VALUE $WARNING
		"0"=' '
		"1"="!REACHING FULL!"
		"2"="!!!FULL!!!"
		"3"="ERROR! OVERFILLED?"
		"4"="LOW ENROLLMENT";
RUN;

PROC FORMAT;
	VALUE MISSING
		.=0
		OTHER=[BEST.];
RUN;

proc template;
 define style styles.XLsansPrinter;
 parent = styles.sansPrinter;

 style header from header /
 font_size = 11pt
 just = center
 BACKGROUND=GREEN
 vjust = bottom;
 end;
run;

**************************************************************
			TRAJECTORY CALCULATION
*************************************************************;

%MACRO SEMESTER(DS_NAME, DS_SOURCE, VAR, LABEL, YEAR);
	DATA &DS_NAME;			
		SET &DS_SOURCE;					* LOAD FROM MACRO;
		IF LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK');				* FILTER FOR FRISCO;
		COUNT = ENRL_TOT;					* RENAME VAR FOR LATER;
		CRS = COURSE;
		SEM = &LABEL;
		KEEP CRS COUNT SEM;						* KEEP ONLY NECESSARY VARS;
	RUN;
	PROC SORT DATA=&DS_NAME NODUPKEY;			* REMOVE DUPLICATES;
		BY CRS;
	RUN;
	DATA &DS_NAME;
		SET &DS_NAME END=LAST;
		BY CRS;
		TOTAL + COUNT;
		IF LAST THEN OUTPUT;
		KEEP SEM TOTAL;
	RUN;	
%MEND SEMESTER;
RUN;

* 2018 EXECUTION;
%SEMESTER(MAY_A_18, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2018z_050418", MAY_A, 'A-Early May', 2018)
%SEMESTER(MAY_B_18, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2018z_051618", MAY_B, 'B-Mid May', 2018)
%SEMESTER(JUN_A_18, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2018z_060618", JUN_A, 'C-Early June', 2018)
%SEMESTER(JUN_B_18, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2018z_061518", JUN_B, 'D-Mid June',  2018)
%SEMESTER(JUL_A_18, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2018z_070318", JUL_A, 'E-Early July', 2018)
%SEMESTER(JUL_B_18, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2018z_071818", JUL_B, 'F-Mid July', 2018)
%SEMESTER(AUG_A_18, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2018z_080218", AUG_A, 'G-Early August', 2018)
%SEMESTER(AUG_B_18, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2018z_081618", AUG_B, 'H-Mid August', 2018)
%SEMESTER(SEP_A_18, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2018z_090418", SEP_A, 'I-Early September', 2018)
%SEMESTER(SEP_B_18, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2018z_091718", SEP_B, 'J-Mid September', 2018)

*2019 EXECUTION;
%SEMESTER(MAY_A_19, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019z_050219", MAY_A, 'A-Early May', '2019')
%SEMESTER(MAY_B_19, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019z_051319", MAY_B, 'B-Mid May', '2019')
%SEMESTER(JUN_A_19, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019z_060319", JUN_A, 'C-Early June', '2019')
%SEMESTER(JUN_B_19, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019z_061819", JUN_B, 'D-Mid June', '2019')
%SEMESTER(JUL_A_19, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019z_070219", JUL_A, 'E-Early July', '2019')
%SEMESTER(JUL_B_19, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019z_071619", JUL_B, 'F-Mid July', '2019')


DATA TRAJECTORY_18;				* COMBINE EACH TOTAL FOR THE PREVIOUS YEAR;
	SET MAY_A_18 MAY_B_18 JUN_A_18 JUN_B_18 JUL_A_18 JUL_B_18 AUG_A_18 AUG_B_18 SEP_A_18 SEP_B_18;
	FY18=TOTAL;
	KEEP SEM FY18;
RUN;

DATA TRAJECTORY_19;			* COMBINE EACH TOTAL FOR THIS YEAR;
	SET MAY_A_19 MAY_B_19 JUN_A_19 JUN_B_19 JUL_A_19 JUL_B_19;
	FY19=TOTAL;
	KEEP SEM FY19;
RUN;
PROC SORT DATA=TRAJECTORY_18;
	BY SEM;
RUN;
PROC SORT DATA=TRAJECTORY_19;
	BY SEM;
RUN;

DATA TRAJECTORY;				* MERGE BOTH YEARS INTO A COMMON SET TO GRAPH;
	MERGE TRAJECTORY_18 TRAJECTORY_19;
	BY SEM;
RUN;

PROC SGPLOT DATA = TRAJECTORY;
	SERIES X = SEM Y = FY19 / LEGENDLABEL = '2019'
 MARKERS LINEATTRS = (THICKNESS = 2);
	SERIES X = SEM Y = FY18 / LEGENDLABEL = '2018'
 MARKERS LINEATTRS = (THICKNESS = 2);
	XAXIS TYPE = DISCRETE GRID; 
	YAXIS LABEL = 'Enrollment Total' GRID VALUES = (0 TO 2200 BY 200);
	TITLE 'Enrollment trajectories';
RUN;




**************************************************************
			ODS AND REPORT CONSTRUCTION
*************************************************************;

title1 &xprog.;
ods _all_ close;
ods tagsets.excelxp file="C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\FALL_2019_%sysfunc(today(), mmddyy6).xml" style=XLsansprinter;

ods tagsets.excelxp options(embed_titles_once='yes' autofit_height='yes' sheet_interval='none' 
			sheet_NAME='Course Report' absolute_column_width='6,6,5,7,5,4,3,18,10,5,6,6,6,6,5,5,7,15');

proc report data=one_class1_crs3 HEADLINE HEADSKIP;
	by a_grp_descr;
	column ('Capacity' ROOM_CAP ENRL_CAP USE) 
			('Course' CLASS_FACILITY_ID SUBJECT CATALOG_NBR CLASS_SECTION CRSE_DESCR CLASS_MTG_TIME) 
			('Enrollment' PREV_FALL PREV_SPRING PREVIOUS_ENROL ENRL_TOT NEW_TOTAL PERCENT_ENROL) 
			('Difference' FCHANGE SCHANGE) WARNING;
	DEFINE ROOM_CAP / ANALYSIS 'Room' FORMAT=MISSING.;
	DEFINE PERCENT_ENROL / COMPUTED FORMAT=PERCENT. '%';
	DEFINE CLASS_MTG_TIME / DISPLAY 'Meeting Time';
	DEFINE WARNING / DISPLAY FORMAT=$WARNING. 'Notes';
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
run; QUIT;

ods tagsets.excelxp options(autofit_height='yes' sheet_interval='none' 
			sheet_NAME='Trajectory' absolute_column_width='9,6,6');
proc report data=trajectory;
run;
ods _all_ close;
ods listing;





****** TRAJECTORY GRAPH*************;

footnote;
ods tagsets.msoffice2k_x path='C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment' (url=none)
                        gpath='C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment' (url=none)
    file="trajectory_%sysfunc(today(),mmddyy6.).xls" style=XLsansprinter ;
ods tagsets.msoffice2k_x  options(sheet_name="Trajectory") ;

PROC SGPLOT DATA = TRAJECTORY;
	SERIES X = SEM Y = FY19 / LEGENDLABEL = '2019'
 MARKERS LINEATTRS = (THICKNESS = 2);
	SERIES X = SEM Y = FY18 / LEGENDLABEL = '2018'
 MARKERS LINEATTRS = (THICKNESS = 2);
	XAXIS TYPE = DISCRETE GRID; 
	YAXIS LABEL = 'Enrollment Total' GRID VALUES = (0 TO 2200 BY 200);
	TITLE 'Enrollment trajectories';
RUN;


ods msoffice2k close;

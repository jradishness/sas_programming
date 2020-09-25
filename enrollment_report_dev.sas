*****************************************************************
**                                                             **
**    PROGRAM NAME:  EIS-ANNUAL COURSE COMPARISON              **
**    FRISCO COURSES                                           **
** 			   												   **
**    LAST REVISED:  03/17/2020      BY: Jared Kelly           **
**                                                             **
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
%let old_enroll='S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019z_040519'; *LAST YEAR'S FILE;

* This loads today's Simsterm data;
%let SIMSTERM="S:\UIS\Shared\SAS Data Projects\simsterm_records\s2020z_%sysfunc(today(),mmddyy6.)";
*%let SIMSTERM="C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\Simsterm\s2020c_010720";

* This loads today's Enrollment data;
%let new_enroll="S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020z_%sysfunc(today(),mmddyy6.)"; *THIS YEAR'S FILE;
*%let new_enroll="S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020c_010720"; *THIS YEAR'S FILE;

* This loads the fall census enrollment data from the previous year;
%LET LAST_FALL_CENSUS="S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019z_census";  * LAST FALL'S CENSUS ENROLLMENT FILE;

* This loads the spring census enrollment data from the previous year;
%LET LAST_SPRING_CENSUS="S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020c_2census_dt";	* LAST SPRING'S CENSUS ENROLLMENT FILE;

* This loads the registrar's current enrollment file, for class capacity and room information;
%LET REG_DATAFILE="C:\Users\jrk0200\UNT System\Registrar - Fall 2020\ntsr_class_listing_all_fall_1208.xls"; *REGISTRAR FILE LOCATION;
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
		"1-UGRD"='Undergraduate, By College'
		"2-GRAD"="Graduate, By College"
		"3-CHEC"="Collin Higher Education Center (non-BAAS)"
		"4-BAAS"="BAAS (incl. CHEC)";
RUN;


DATA THECBSET_PRE;	* Import new enrollment dataset;
  SET &new_enroll;
  RUN;
PROC SORT DATA=THECBSET_PRE; * sort enrollment dataset by course;
	BY COURSE;
RUN;


*IMPORT COURSE DETAILS FROM REGISTRAR;
PROC IMPORT OUT= WORK.REGISTRAR
            DATAFILE= &REG_DATAFILE.
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$";
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
DATA REG_ENR;	*STEP TO GRAB ONLY THE OBSERVATIONS WE WANT, AND TO CONVERT THEM TO THE ENROLLMENT FORMAT;
	SET REGISTRAR(RENAME=(TOT_ENRL=TOT_ENRL_NUM));
	WHERE LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK') OR SUBJECT IN ('BAAS');
	TOT_ENRL = INPUT(TOT_ENRL_NUM, BEST12. -L);
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
	DROP TERM College_School College_School_Descr Department Catalog SECTION
	CAREER Course_Descr Cap_Enrl Tot_Enrl Crse_Level Instr_Type Facil_ID Facil_Type
	Mtg_Start Mtg_End Days_of_the_Week MON TUES WED THURS FRI SAT SUN Start_Date
	End_Date EMPLID NAME GRADE_BASE SESSION ACAD_ORG Course_ID CIP_Code
	Wait_Cap Wait_Tot ROOM_CAP TOT_ENRL_NUM;
RUN;
***********************************************************************************************************************************
						NEED TO REFACTOR - NEED TO COLLECT ROOM SIZE DETAILS
**********************************************************************************************************************************;
/*DATA MISC_ENROLLMENT;	*FILTER FURTHER, GRABBING ONLY EMPTY COURSES;
	***********************************************************************************************************************************
						NEED TO REFACTOR - NEED TO COLLECT INFO FOR ALL COURSES, THEN MERGE
	**********************************************************************************************************************************;
	SET REG_ENR;
	WHERE ENRL_TOT = 0;
RUN;*/
* PREPARE ENROLLMENT DATA TO MERGE WITH REGISTRAR DATA;
DATA TEST_ENROLLMENT;
	SET &new_enroll;			*SET ENROLLMENT;	*Old command here;
	WHERE LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK') OR SUBJECT IN ('BAAS');
RUN;
PROC SORT DATA=TEST_ENROLLMENT NODUPKEY;	*REMOVE DUPLICATE COURSES;
	BY COURSE;
RUN;
PROC SORT DATA=REG_ENR NODUPKEY;		*REMOVE DUPLICATE COURSES;
	BY COURSE;
RUN;
DATA REGIS;					*DROP OUT ANYTHING THAT IS ALREADY IN ENROLLMENT;
	MERGE TEST_ENROLLMENT (IN=A) REG_ENR;
	BY COURSE;
	IF A=0;
RUN;
DATA THECBSET_ORIG;				* MERGE REGISTRAR WITH ENROLLMENT;
	SET THECBSET_PRE REGIS;
RUN;
PROC SORT DATA=THECBSET_ORIG;		***THECBSET_ORIG is enrollment data from new_enroll sorted by emplid;
	BY EMPLID;
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
		KEEP GROUP;
	RUN;
	PROC SORT DATA=&DSNAME;
		BY GROUP;
	RUN;
	DATA F&DSNAME;
		SET &DSNAME;
		BY GROUP;
		IF LAST.GROUP;                 /*Go back if not last.id     */
	  	COUNT=_n_-sum(lag(_n_),0);  /*At last.id, calculate COUNT*/
		&LABEL = COUNT;
		LABEL GROUP='CAMPUS';
		DROP COUNT;
	run;
%MEND ENROLL_SNAP;
RUN;

/* %ENROLL_SNAP(DS NAME, DS SOURCE, TIME LABEL)*/
%ENROLL_SNAP(EX1, &new_enroll, TODAY);	*%ENROLL_SNAP(EX1, ENROLLMENT, TODAY);
%ENROLL_SNAP(EX2, &OLD_ENROLL, LAST_YEAR);
%ENROLL_SNAP(EX3, &LAST_SPRING_CENSUS, SPRING);
%ENROLL_SNAP(EX4, &LAST_FALL_CENSUS, FALL);

DATA EX_REPORT;		*ALL FOUR TIME PERIODS MERGED;
	MERGE FEX1 FEX2 FEX3 FEX4;
	BY GROUP;
RUN;

DATA EX_REPORT;		*TYPE ADDED FOR LATER SEPARATION IN REPORT;
	SET EX_REPORT;
	LENGTH TYPE $8.;
	IF GROUP IN ('BAAS') THEN TYPE='PROGRAM';
	ELSE TYPE='CAMPUS';
RUN;
PROC SORT DATA=EX_REPORT;
	BY TYPE;
RUN;

**************************************************************
					NEW STUDENT CALCULATION
*************************************************************;



DATA NEW_STUDENTS;			* create dataset for counting new students;
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


* To help calculate how many students are new;
DATA NEW_TOTAL;		*Create NEW_TOTAL dataset from new merged dataset, keeping only course and new_stud;
	SET THECBSET_NEW;
	KEEP COURSE NEW_STUD;
RUN;
PROC SORT DATA=NEW_TOTAL;
	BY COURSE;
RUN;

DATA NEW_TOTAL;  * THIS IS WHERE THE TOTAL NEW STUDENTS ARE CALCULATED (NEW_TOTAL);
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

/**/
/**Load comparison enrollment data from previous year;*/
/*DATA  OLD_FILE;			*P-I-T calculation;	*/
/*  SET &old_enroll;*/
/*  RUN;*/
/*DATA OLD_FILE;*/
/*	SET OLD_FILE;*/
/*	IF LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK') OR SUBJECT IN ('BAAS');			* Value for campus we want considered;*/
/*  	ENROL=1;						* add a new var for ENROL;*/
/*  	CRS = COURSE;					*/
/*RUN;*/
/*PROC SORT DATA=OLD_FILE;			***OLD_FILE is the reference enrollment set, filtered to frisco, sorted by CRS;*/
/*BY CRS;*/
/*RUN;*/
/**/
/** NOT SURE, maybe a narrowing, or filtering of duplicates?;*/
/*DATA OLD_FILE2;						***OLD_FILE2 is the set of unrepeated courses with the total previous enrollment;*/
/*SET OLD_FILE;*/
/*BY CRS;*/
/*IF LAST.CRS= 1 THEN OUTPUT OLD_FILE2;*/
/*KEEP CRS ENRL_TOT;*/
/*RUN;*/
/**/
/**End up with a dataset with only previous enrollment;*/
/*DATA OLD_FILE3;						***OLD_FILE3 is the set of unrepeated courses with the total previous enrollment;*/
/*  SET OLD_FILE2;*/
/*  PREVIOUS_ENROL=ENRL_TOT;*/
/*  LABEL PREVIOUS_ENROL="2018 Enrolled (PIT)";*/
/*  DROP ENRL_TOT;*/
/*  RUN;*/




*grab current enrollment (with new stud) and create a var for ENROL to count enrollment;
DATA THECBSET1;						***THECBSET1 is the current enrollment, with new_stud column,
										and a ENROL var for counting enrollments;
	SET THECBSET_NEW;
	IF LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK') OR SUBJECT IN ('BAAS');			* Value for campus we want considered;
	IF ENRL_STAT IN ('C', 'O') THEN ENROL = ENRL_TOT;
	ELSE ENROL=1;
	CRS = COURSE;
RUN;


**************************************************************
					PREVIOUS SEMESTER CALCULATION
*************************************************************;

%MACRO SEMESTER(DS_NAME, DS_SOURCE, VAR, LABEL);	*** IMPORT ARCHIVED ENROLLMENT;
	DATA &DS_NAME;
		SET &DS_SOURCE;					* LOAD FROM MACRO;
		IF LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK') OR SUBJECT IN ('BAAS');	* Value for campus we want considered;
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
					CLASSROOM CAP. CALCULATION
*************************************************************;


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

DATA CAPACITY; *CAPACITY CALCULATIONS FOR HP/IP;
	SET THECBSET2;
	WHERE LOCATION IN ('FRSC', 'Z-INSPK') AND  CLASS_FACILITY_ID ~= ' ';
	GROUP = 1;
	KEEP GROUP COURSE ROOM_CAP ENRL_CAP ENRL_TOT;
RUN;
PROC SORT DATA=CAPACITY NODUPKEY;
	BY COURSE;
RUN;
proc summary data=CAPACITY;
	var ROOM_CAP ENRL_CAP ENRL_TOT;
	output out=CAPS sum=;
run;

**************************************************************
				ARCHIVE MERGE
*************************************************************;
DATA OLD_FILE4;		* merge of the archived semesters (last spring, fall, year) for report;
	MERGE LAST_FALL LAST_SPRING;
	BY CRS;
RUN;

**************************************************************
					CURRENT ENROLLMENT CALCULATION
*************************************************************;
DATA ONE_CLASS1_CRS;	*ONE_CLASS1_CRS is a set of the courses with current enrollment counts 	;
SET THECBSET2;
BY CRS;
IF LAST.CRS= 1 THEN OUTPUT ONE_CLASS1_CRS;
KEEP CRS a_grp_descr CRSE_DESCR ENRL_TOT ENRL_CAP CLASS_MTG_TIME CLASS_MTG_PAT SUBJECT CATALOG_NBR CLASS_FACILITY_ID ROOM_CAP SUBJECT CATALOG_NBR CLASS_SECTION;
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
*************************************************************;
DATA ONE_CLASS1_CRS2;			***ONE_CLASS1_CRS2 is the same as CRS except with previous_total included;
    SET ONE_CLASS1_CRS2;		***now it has the Percent Enrolled Var as well;
	*IF ENRL_CAP =0 THEN DELETE;
    PERCENT_ENROLLED=ENRL_TOT/ENRL_CAP;
	IF ENRL_TOT < 8 THEN WARNING ="4";
	ELSE IF PERCENT_ENROLLED = 1.0 THEN WARNING="2";
	ELSE IF .9 <= PERCENT_ENROLLED < 1.0 THEN WARNING="1";
	ELSE IF 0 <= PERCENT_ENROLLED < .9 THEN WARNING="0";
	*ELSE IF 0 <= PERCENT_ENROLLED < .20 THEN WARNING = "4";
	ELSE WARNING="3";
	LABEL PERCENT_ENROLLED = "Enrollment %"
			WARNING = "Warning";
RUN;
PROC SORT DATA=ONE_CLASS1_CRS2;
	BY CRS;
RUN;

**************************************************************
					FINAL DATASET MERGER FOR COURSE REPORT
*************************************************************;
DATA ONE_CLASS1_CRS3;
	MERGE ONE_CLASS1_CRS2 (IN=A) NEW_TOTAL;
	BY CRS;
	IF A=1;
	LABEL CLASS_MTG_TIME = "Class Mtg Time"
			CLASS_MTG_PAT = "Class Mtg Pattern"
			CLASS_FACILITY_ID = "Room No."
			CRS = "Course Code"
			CRSE_DESCR = "Course"
			A_GRP_DESCR = "College"
			ENRL_TOT = "2019 Enrolled"
			ENRL_CAP = "Class Cap."
			NEW_TOTAL = "New Students";
RUN;
* 	REFORMAT GROUP CONSTRUCTION FOR SORTING;
DATA ONE_CLASS1_CRS3;
	SET ONE_CLASS1_CRS3;
	LENGTH GROUP $30. NOTES $30.;
	IF SUBJECT = "NCPS" THEN GROUP = 'New College';
	ELSE IF SUBJECT = "BAAS" THEN GROUP = 'Program (BAAS)';
	ELSE IF CLASS_FACILITY_ID IN ("CHEC") THEN GROUP = 'Site (CHEC)';
	ELSE GROUP = A_GRP_DESCR;
	FORMAT GROUP $GROUP.;
RUN;
proc sort data =one_class1_crs3;   ***ONE_CLASS1_CRS3 is the same as CRS2 except with New Student Totals Included;
	by GROUP;						*** sorted by the college;
run;

**************************************************************
			FORMATS AND TEMPLATES
*************************************************************;

/*PROC FORMAT;
	VALUE $GROUP
		1 = 'New College'
		2 = 'BAAS'
		3 = 'Mayborn School of Journalism'
		4 = 'Graduate School'	*/

PROC FORMAT;		*format for enrollment warnings;
	VALUE $WARNING
		"0"=' '
		"1"="!REACHING FULL!"
		"2"="!!!FULL!!!"
		"3"="ERROR! OVERFILLED?"
		"4"="LOW ENROLLMENT";
RUN;

PROC FORMAT;	* format for missing values;
	VALUE MISSING
		.=0
		OTHER=[BEST.];
RUN;

proc template;		* template for UNT-colored report;
 define style styles.XLsansPrinter;
 parent = styles.sansPrinter;

 style header from header /
 font_size = 11pt
 just = center
 BACKGROUND=LILG
 vjust = bottom;
 end;
run;

**************************************************************
			TRAJECTORY CALCULATION
*************************************************************;

%MACRO SEMESTER(DS_NAME, DS_SOURCE, VAR, LABEL, YEAR);  	*macro for Trajectory calculations;
	DATA F&DS_NAME;
		SET &DS_SOURCE;					* LOAD FROM MACRO;
		IF LOCATION IN ('FRSC', 'Z-INSPK');				* FILTER FOR FRISCO;
		COUNT = ENRL_TOT;					* RENAME VAR FOR LATER;
		CRS = COURSE;
		SEM = &LABEL;
		LABEL SEM = 'Time Point';
		KEEP CRS COUNT SEM;						* KEEP ONLY NECESSARY VARS;
	RUN;
	PROC SORT DATA=F&DS_NAME NODUPKEY;			* REMOVE DUPLICATES;
		BY CRS;
	RUN;
	DATA F&DS_NAME;
		SET F&DS_NAME END=LAST;
		BY CRS;
		TOTAL + COUNT;
		IF LAST THEN OUTPUT;
		KEEP SEM TOTAL;
	RUN;

	DATA C&DS_NAME;
		SET &DS_SOURCE;					* LOAD FROM MACRO;
		IF LOCATION IN ('Z-CHEC');				* FILTER FOR FRISCO;
		COUNT = ENRL_TOT;					* RENAME VAR FOR LATER;
		CRS = COURSE;
		SEM = &LABEL;
		KEEP CRS COUNT SEM;						* KEEP ONLY NECESSARY VARS;
	RUN;
	PROC SORT DATA=C&DS_NAME NODUPKEY;			* REMOVE DUPLICATES;
		BY CRS;
	RUN;
	DATA C&DS_NAME;
		SET C&DS_NAME END=LAST;
		BY CRS;
		TOTAL + COUNT;
		IF LAST THEN OUTPUT;
		KEEP SEM TOTAL;
	RUN;
%MEND SEMESTER;
RUN;


*WHEN RUNNING FOR FALL ENROLLMENT;
* 2019 EXECUTION;
%SEMESTER(APR_A_18, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019z_040519", APR_A, 'C-Early April', 2019)
%SEMESTER(APR_B_18, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019z_041719", APR_B, 'D-Mid April', 2019)
%SEMESTER(MAY_A_18, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019z_050219", MAY_A, 'E-Early May', 2019)
%SEMESTER(MAY_B_18, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019z_052019", MAY_B, 'F-Mid May', 2019)
%SEMESTER(JUN_A_18, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019z_060319", JUN_A, 'G-Early June', 2019)
%SEMESTER(JUN_B_18, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019z_061719", JUN_B, 'H-Mid June',  2019)
%SEMESTER(JUL_A_18, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019z_070219", JUL_A, 'I-Early July', 2019)
%SEMESTER(JUL_B_18, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019z_071919", JUL_B, 'J-Mid July', 2019)
%SEMESTER(AUG_A_18, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019z_080219", AUG_A, 'K-Early August', 2019)
%SEMESTER(AUG_B_18, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019z_081519", AUG_B, 'L-Mid August', 2019)
%SEMESTER(SEP_A_18, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019z_090319", SEP_A, 'M-Early September', 2019)
%SEMESTER(SEP_B_18, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019z_census", SEP_B, 'N-Census', 2019)


*2020 EXECUTION;
%SEMESTER(MAR_A_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020z_031720", MAR_A, 'A-Mid March', 2020)
%SEMESTER(MAR_B_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020z_032320", MAR_B, 'B-Late March', 2020)
%SEMESTER(APR_A_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020z_040220", APR_A, 'C-Early April', 2020)
%SEMESTER(APR_B_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020z_042020", APR_B, 'D-Mid April', 2020)
%SEMESTER(MAY_A_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020z_050420", MAY_A, 'E-Early May', '2020')
%SEMESTER(MAY_B_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020z_051820", MAY_B, 'F-Mid May', '2020')
%SEMESTER(JUN_A_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020z_060120", JUN_A, 'G-Early June', '2020')
%SEMESTER(JUN_B_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020z_061520", JUN_B, 'H-Mid June', '2020')
%SEMESTER(JUL_A_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020z_070220", JUL_A, 'I-Early July', '2020')
%SEMESTER(JUL_B_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020z_072020", JUL_B, 'J-Mid July', '2020')
%SEMESTER(AUG_A_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020z_080320", AUG_A, 'K-Early August', '2020')
%SEMESTER(AUG_B_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020z_081720", AUG_B, 'L-Mid August', '2020')
%SEMESTER(SEP_A_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020z_090320", SEP_A, 'M-Early September', '2020')
%SEMESTER(SEP_B_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement", SEP_B, 'N-Census', '2020')


DATA CTRAJECTORY_18;				* CHEC - COMBINE EACH TOTAL FOR THE PREVIOUS YEAR;
	SET CAPR_A_18 CAPR_B_18 CMAY_A_18 CMAY_B_18 CJUN_A_18 CJUN_B_18 CJUL_A_18 CJUL_B_18 CAUG_A_18 CAUG_B_18 CSEP_A_18 CSEP_B_18;
	C18=TOTAL;
	KEEP SEM C18;
RUN;
DATA CTRAJECTORY_19;			* CHEC - COMBINE EACH TOTAL FOR THIS YEAR;
	SET CMAR_A_19 CMAR_B_19 CAPR_A_19 CAPR_B_19 CMAY_A_19 CMAY_B_19 CJUN_A_19 CJUN_B_19 CJUL_A_19 CJUL_B_19 CAUG_A_19 CAUG_B_19 CSEP_A_19 CSEP_B_19;
	C19=TOTAL;
	KEEP SEM  C19;
RUN;
PROC SORT DATA=CTRAJECTORY_18;
	BY SEM;
RUN;
PROC SORT DATA=CTRAJECTORY_19;
	BY SEM;
RUN;
DATA FTRAJECTORY_18;				*Frisco - COMBINE EACH TOTAL FOR THE PREVIOUS YEAR;
	SET FAPR_A_18 FAPR_B_18 FMAY_A_18 FMAY_B_18 FJUN_A_18 FJUN_B_18 FJUL_A_18 FJUL_B_18 FAUG_A_18 FAUG_B_18 FSEP_A_18 FSEP_B_18;
	F18=TOTAL;
	KEEP SEM F18;
RUN;

DATA FTRAJECTORY_19;			* Frisco - COMBINE EACH TOTAL FOR THIS YEAR;
	SET FMAR_A_19 FMAR_B_19 FAPR_A_19 FAPR_B_19 FMAY_A_19 FMAY_B_19 FJUN_A_19 FJUN_B_19 FJUL_A_19 FJUL_B_19 FAUG_A_19 FAUG_B_19 FSEP_A_19 FSEP_B_19;
	F19=TOTAL;
	KEEP SEM F19;
RUN;

* END OF FALL EXECUTION;
/*

*WHEN RUNNING FOR SPRING ENROLLMENT;
* 2019 EXECUTION;
%SEMESTER(OCT_C_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019c_102918", OCT_C, 'C-Oct 4th Week', 2019)
%SEMESTER(NOV_A_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019c_110518", NOV_A, 'D-Nov 1st Week', 2019)
%SEMESTER(NOV_B_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019c_111218", NOV_B, 'E-Nov 2nd Week', 2019)
%SEMESTER(NOV_C_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019c_111918", NOV_C, 'F-Nov 3rd Week', 2019)
%SEMESTER(NOV_D_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019c_112618", NOV_D, 'G-Nov 4th Week', 2019)
%SEMESTER(DEC_A_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019c_120318", DEC_A, 'H-Dec 1st Week', 2019)
%SEMESTER(DEC_B_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019c_121018", DEC_B, 'I-Dec 2nd Week', 2019)
%SEMESTER(DEC_C_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019c_121718", DEC_C, 'J-Dec 3rd Week', 2019)
%SEMESTER(DEC_D_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019c_122018", DEC_D, 'K-Dec 4th Week', 2019)
%SEMESTER(JAN_A_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019c_010219", JAN_A, 'L-Jan 1st Week', 2019)
%SEMESTER(JAN_B_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019c_010719", JAN_B, 'M-Jan 2nd Week', 2019)
%SEMESTER(JAN_C_19, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019c_census", JAN_C, 'N-Census', 2019)


*2020 EXECUTION;
%SEMESTER(OCT_A_20, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020c_101519", OCT_A, 'A-Oct 2nd Week', 2020)
%SEMESTER(OCT_B_20, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020c_102119", OCT_B, 'B-Oct 3rd Week', 2020)
%SEMESTER(OCT_C_20, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020c_102819", OCT_C, 'C-Oct 4th Week', 2020)
%SEMESTER(NOV_A_20, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020c_110419", NOV_A, 'D-Nov 1st Week', 2020)
%SEMESTER(NOV_B_20, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020c_111119", NOV_B, 'E-Nov 2nd Week', 2020)
%SEMESTER(NOV_C_20, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020c_111819", NOV_C, 'F-Nov 3rd Week', 2020)
%SEMESTER(NOV_D_20, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020c_112519", NOV_D, 'G-Nov 4th Week', 2020)
%SEMESTER(DEC_A_20, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020c_120219", DEC_A, 'H-Dec 1st Week', 2020)
%SEMESTER(DEC_B_20, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020c_120919", DEC_B, 'I-Dec 2nd Week', 2020)
%SEMESTER(DEC_C_20, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020c_121619", DEC_C, 'J-Dec 3rd Week', 2020)
%SEMESTER(DEC_D_20, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020c_122319", DEC_D, 'K-Dec 4th Week', 2020)
%SEMESTER(JAN_A_20, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020c_010620", JAN_A, 'L-Jan 1st Week', 2020)
%SEMESTER(JAN_B_20, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020c_011320", JAN_B, 'M-Jan 2nd Week', 2020)
%SEMESTER(JAN_C_20, "S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020c_census", JAN_C, 'N-Census', 2020)


DATA CTRAJECTORY_18;				* CHEC - COMBINE EACH TOTAL FOR THE PREVIOUS YEAR;
	SET COCT_C_19 CNOV_A_19 CNOV_B_19 CNOV_C_19 CNOV_D_19 CDEC_A_19 CDEC_B_19 CDEC_C_19 CDEC_D_19 CJAN_A_19 CJAN_B_19 CJAN_C_19;
	C18=TOTAL;
	KEEP SEM C18;
RUN;
DATA CTRAJECTORY_19;			* CHEC - COMBINE EACH TOTAL FOR THIS YEAR;
	SET COCT_A_20 COCT_B_20 COCT_C_20 CNOV_A_20 CNOV_B_20 CNOV_C_20 CNOV_D_20 CDEC_A_20 CDEC_B_20 CDEC_C_20 CDEC_D_20 CJAN_A_20 CJAN_B_20 CJAN_C_20;
	C19=TOTAL;
	KEEP SEM  C19;
RUN;
PROC SORT DATA=CTRAJECTORY_18;
	BY SEM;
RUN;
PROC SORT DATA=CTRAJECTORY_19;
	BY SEM;
RUN;
DATA FTRAJECTORY_18;				*Frisco - COMBINE EACH TOTAL FOR THE PREVIOUS YEAR;
	SET FOCT_C_19 FNOV_A_19 FNOV_B_19 FNOV_C_19 FNOV_D_19 FDEC_A_19 FDEC_B_19 FDEC_C_19 FDEC_D_19 FJAN_A_19 FJAN_B_19 FJAN_C_19;
	F18=TOTAL;
	KEEP SEM F18;
RUN;

DATA FTRAJECTORY_19;			* Frisco - COMBINE EACH TOTAL FOR THIS YEAR;
	SET FOCT_A_20 FOCT_B_20 FOCT_C_20 FNOV_A_20 FNOV_B_20 FNOV_C_20 FNOV_D_20 FDEC_A_20 FDEC_B_20 FDEC_C_20 FDEC_D_20 FJAN_A_20 FJAN_B_20 FJAN_C_20;
	F19=TOTAL;
	KEEP SEM F19;
RUN;
* END OF SPRING EXECUTION;
*/


PROC SORT DATA=FTRAJECTORY_18;
	BY SEM;
RUN;
PROC SORT DATA=FTRAJECTORY_19;
	BY SEM;
RUN;
DATA TRAJECTORY;				* MERGE BOTH YEARS and CAMPUSES INTO A COMMON SET TO GRAPH;
	MERGE CTRAJECTORY_18 CTRAJECTORY_19 FTRAJECTORY_18 FTRAJECTORY_19;
	BY SEM;
RUN;
DATA TRAJECTORY;
	SET TRAJECTORY;
	T18 = C18 + F18;
	T19 = C19 + F19;
RUN;

************************************************************
				COLLEGE REPORT CONSTRUCTION
************************************************************;

DATA UGRD;
	SET THECBSET_ORIG;
	WHERE LOCATION IN ('FRSC', 'Z-INSPK') AND CRSE_CAREER='UGRD';
	GROUPING='1-UGRD';
RUN;
PROC SORT DATA=UGRD OUT=UGENRL;		*COUNTING THE ENROLLMENT;
	BY ACAD_GROUP;
RUN;
DATA UGENRL;						*COUNTING THE ENROLLMENT;
	SET UGENRL;
	BY ACAD_GROUP;
	IF LAST.ACAD_GROUP;                 /*Go back if not last.id     */
  	TODAY=_n_-sum(lag(_n_),0);  /*At last.id, calculate COUNT*/
	KEEP ACAD_GROUP A_GRP_DESCR TODAY COURSE GROUPING;
RUN;
PROC SORT DATA=UGRD OUT=UGSEC NODUPKEY;		*COUNTING THE SECTIONS;
	BY COURSE;
RUN;
PROC SORT DATA=UGSEC;		*COUNTING THE SECTIONS;
	BY ACAD_GROUP;
RUN;
DATA UGSEC;						*COUNTING THE SECTIONS;
	SET UGSEC;
	BY ACAD_GROUP;
	IF LAST.ACAD_GROUP;                 /*Go back if not last.id     */
  	SECTIONS=_n_-sum(lag(_n_),0);  /*At last.id, calculate COUNT*/
	KEEP ACAD_GROUP SECTIONS;
RUN;
DATA UGRD_FALL;		*GATHERING ARCHIVED ENROLLMENT NUMBERS FOR FALL;
	SET &LAST_FALL_CENSUS;
	WHERE LOCATION IN ('FRSC', 'Z-INSPK') AND CRSE_CAREER='UGRD';
	GROUPING='1-UGRD';
RUN;
PROC SORT DATA=UGRD_FALL OUT=UGENRL_FALL;		*COUNTING THE ENROLLMENT;
	BY ACAD_GROUP;
RUN;
DATA UGENRL_FALL;						*COUNTING THE ENROLLMENT;
	SET UGENRL_FALL;
	BY ACAD_GROUP;
	IF LAST.ACAD_GROUP;                 /*Go back if not last.id     */
  	FALL=_n_-sum(lag(_n_),0);  /*At last.id, calculate COUNT*/
	KEEP ACAD_GROUP FALL;
RUN;
DATA UGRD_SPR;		*GATHERING ARCHIVED ENROLLMENT NUMBERS FOR SPRING;
	SET &LAST_SPRING_CENSUS;
	WHERE LOCATION IN ('FRSC', 'Z-INSPK') AND CRSE_CAREER='UGRD';
	GROUPING='1-UGRD';
RUN;
PROC SORT DATA=UGRD_SPR OUT=UGENRL_SPR;		*COUNTING THE ENROLLMENT;
	BY ACAD_GROUP;
RUN;
DATA UGENRL_SPR;						*COUNTING THE ENROLLMENT;
	SET UGENRL_SPR;
	BY ACAD_GROUP;
	IF LAST.ACAD_GROUP;                 /*Go back if not last.id     */
  	SPRING=_n_-sum(lag(_n_),0);  /*At last.id, calculate COUNT*/
	KEEP ACAD_GROUP SPRING;
RUN;
DATA UGFINAL;
	MERGE UGENRL(IN=A) UGSEC UGENRL_FALL UGENRL_SPR;
	BY ACAD_GROUP;
	IF A=1;
	DROP COURSE;
RUN;

DATA GRAD;
	SET THECBSET_ORIG;
	WHERE LOCATION IN ('FRSC', 'Z-INSPK') AND CRSE_CAREER='GRAD';
	GROUPING='2-GRAD';
RUN;
PROC SORT DATA=GRAD OUT=GRENRL;		*COUNTING THE ENROLLMENT;
	BY ACAD_GROUP;
RUN;
DATA GRENRL;						*COUNTING THE ENROLLMENT;
	SET GRENRL;
	BY ACAD_GROUP;
	IF LAST.ACAD_GROUP;                 /*Go back if not last.id     */
  	TODAY=_n_-sum(lag(_n_),0);  /*At last.id, calculate COUNT*/
	KEEP ACAD_GROUP A_GRP_DESCR TODAY COURSE GROUPING;
RUN;
PROC SORT DATA=GRAD OUT=GRSEC NODUPKEY;		*COUNTING THE SECTIONS;
	BY COURSE;
RUN;
PROC SORT DATA=GRSEC;		*COUNTING THE SECTIONS;
	BY ACAD_GROUP;
RUN;
DATA GRSEC;						*COUNTING THE SECTIONS;
	SET GRSEC;
	BY ACAD_GROUP;
	IF LAST.ACAD_GROUP;                 /*Go back if not last.id     */
  	SECTIONS=_n_-sum(lag(_n_),0);  /*At last.id, calculate COUNT*/
	KEEP ACAD_GROUP SECTIONS;
RUN;
DATA GRAD_FALL;		*GATHERING ARCHIVED ENROLLMENT NUMBERS FOR FALL;
	SET &LAST_FALL_CENSUS;
	WHERE LOCATION IN ('FRSC', 'Z-INSPK') AND CRSE_CAREER='GRAD';
	GROUPING='2-GRAD';
RUN;
PROC SORT DATA=GRAD_FALL OUT=GRENRL_FALL;		*COUNTING THE ENROLLMENT;
	BY ACAD_GROUP;
RUN;
DATA GRENRL_FALL;						*COUNTING THE ENROLLMENT;
	SET GRENRL_FALL;
	BY ACAD_GROUP;
	IF LAST.ACAD_GROUP;                 /*Go back if not last.id     */
  	FALL=_n_-sum(lag(_n_),0);  /*At last.id, calculate COUNT*/
	KEEP ACAD_GROUP FALL;
RUN;
DATA GRAD_SPR;		*GATHERING ARCHIVED ENROLLMENT NUMBERS FOR SPRING;
	SET &LAST_SPRING_CENSUS;
	WHERE LOCATION IN ('FRSC', 'Z-INSPK') AND CRSE_CAREER='GRAD';
	GROUPING='2-GRAD';
RUN;
PROC SORT DATA=GRAD_SPR OUT=GRENRL_SPR;		*COUNTING THE ENROLLMENT;
	BY ACAD_GROUP;
RUN;
DATA GRENRL_SPR;						*COUNTING THE ENROLLMENT;
	SET GRENRL_SPR;
	BY ACAD_GROUP;
	IF LAST.ACAD_GROUP;                 /*Go back if not last.id     */
  	SPRING=_n_-sum(lag(_n_),0);  /*At last.id, calculate COUNT*/
	KEEP ACAD_GROUP SPRING;
RUN;
DATA GRFINAL;
	MERGE GRENRL(IN=A) GRSEC GRENRL_FALL GRENRL_SPR;
	BY ACAD_GROUP;
	IF A=1;
	DROP COURSE;
RUN;

DATA CHEC;			* CHEC GROUPING;
	SET THECBSET_ORIG;
	WHERE LOCATION IN ('Z-CHEC');
	GROUPING='3-CHEC';
RUN;
PROC SORT DATA=CHEC OUT=CHENRL;		*COUNTING THE ENROLLMENT;
	BY ACAD_GROUP;
RUN;
DATA CHENRL;						*COUNTING THE ENROLLMENT;
	SET CHENRL;
	BY ACAD_GROUP;
	IF LAST.ACAD_GROUP;                 /*Go back if not last.id     */
  	TODAY=_n_-sum(lag(_n_),0);  /*At last.id, calculate COUNT*/
	KEEP ACAD_GROUP A_GRP_DESCR TODAY COURSE GROUPING;
RUN;
PROC SORT DATA=CHEC OUT=CHSEC NODUPKEY;		*COUNTING THE SECTIONS;
	BY COURSE;
RUN;
PROC SORT DATA=CHSEC;		*COUNTING THE SECTIONS;
	BY ACAD_GROUP;
RUN;
DATA CHSEC;						*COUNTING THE SECTIONS;
	SET CHSEC;
	BY ACAD_GROUP;
	IF LAST.ACAD_GROUP;                 /*Go back if not last.id     */
  	SECTIONS=_n_-sum(lag(_n_),0);  /*At last.id, calculate COUNT*/
	KEEP ACAD_GROUP SECTIONS;
RUN;
DATA CHEC_FALL;		*GATHERING ARCHIVED ENROLLMENT NUMBERS FOR FALL;
	SET &LAST_FALL_CENSUS;
	WHERE LOCATION IN ('Z-CHEC');
	GROUPING='3-CHEC';
RUN;
PROC SORT DATA=CHEC_FALL OUT=CHENRL_FALL;		*COUNTING THE ENROLLMENT;
	BY ACAD_GROUP;
RUN;
DATA CHENRL_FALL;						*COUNTING THE ENROLLMENT;
	SET CHENRL_FALL;
	BY ACAD_GROUP;
	IF LAST.ACAD_GROUP;                 /*Go back if not last.id     */
  	FALL=_n_-sum(lag(_n_),0);  /*At last.id, calculate COUNT*/
	KEEP ACAD_GROUP FALL;
RUN;
DATA CHEC_SPR;		*GATHERING ARCHIVED ENROLLMENT NUMBERS FOR SPRING;
	SET &LAST_SPRING_CENSUS;
	WHERE LOCATION IN ('Z-CHEC');
	GROUPING='3-CHEC';
RUN;
PROC SORT DATA=CHEC_SPR OUT=CHENRL_SPR;		*COUNTING THE ENROLLMENT;
	BY ACAD_GROUP;
RUN;
DATA CHENRL_SPR;						*COUNTING THE ENROLLMENT;
	SET CHENRL_SPR;
	BY ACAD_GROUP;
	IF LAST.ACAD_GROUP;                 /*Go back if not last.id     */
  	SPRING=_n_-sum(lag(_n_),0);  /*At last.id, calculate COUNT*/
	KEEP ACAD_GROUP SPRING;
RUN;
DATA CHFINAL;
	MERGE CHENRL(IN=A) CHSEC CHENRL_FALL CHENRL_SPR;
	BY ACAD_GROUP;
	IF A=1;
	DROP COURSE;
RUN;

DATA BAAS;		*BAAS GROUPING;
	SET THECBSET_ORIG;
	WHERE SUBJECT='BAAS';
	GROUPING='4-BAAS';
RUN;
PROC SORT DATA=BAAS OUT=BAENRL;		*COUNTING THE ENROLLMENT;
	BY ACAD_GROUP;
RUN;
DATA BAENRL;						*COUNTING THE ENROLLMENT;
	SET BAENRL;
	BY ACAD_GROUP;
	IF LAST.ACAD_GROUP;                 /*Go back if not last.id     */
  	TODAY=_n_-sum(lag(_n_),0);  /*At last.id, calculate COUNT*/
	KEEP ACAD_GROUP A_GRP_DESCR TODAY COURSE GROUPING;
RUN;
PROC SORT DATA=BAAS OUT=BASEC NODUPKEY;		*COUNTING THE SECTIONS;
	BY COURSE;
RUN;
PROC SORT DATA=BASEC;		*COUNTING THE SECTIONS;
	BY ACAD_GROUP;
RUN;
DATA BASEC;						*COUNTING THE SECTIONS;
	SET BASEC;
	BY ACAD_GROUP;
	IF LAST.ACAD_GROUP;                 /*Go back if not last.id     */
  	SECTIONS=_n_-sum(lag(_n_),0);  /*At last.id, calculate COUNT*/
	KEEP ACAD_GROUP SECTIONS;
RUN;
DATA BAAS_FALL;		*GATHERING ARCHIVED ENROLLMENT NUMBERS FOR FALL;
	SET &LAST_FALL_CENSUS;
	WHERE SUBJECT='BAAS';
	GROUPING='4-BAAS';
RUN;
PROC SORT DATA=BAAS_FALL OUT=BAENRL_FALL;		*COUNTING THE ENROLLMENT;
	BY ACAD_GROUP;
RUN;
DATA BAENRL_FALL;						*COUNTING THE ENROLLMENT;
	SET BAENRL_FALL;
	BY ACAD_GROUP;
	IF LAST.ACAD_GROUP;                 /*Go back if not last.id     */
  	FALL=_n_-sum(lag(_n_),0);  /*At last.id, calculate COUNT*/
	KEEP ACAD_GROUP FALL;
RUN;
DATA BAAS_SPR;		*GATHERING ARCHIVED ENROLLMENT NUMBERS FOR SPRING;
	SET &LAST_SPRING_CENSUS;
	WHERE SUBJECT='BAAS';
	GROUPING='4-BAAS';
RUN;
PROC SORT DATA=BAAS_SPR OUT=BAENRL_SPR;		*COUNTING THE ENROLLMENT;
	BY ACAD_GROUP;
RUN;
DATA BAENRL_SPR;						*COUNTING THE ENROLLMENT;
	SET BAENRL_SPR;
	BY ACAD_GROUP;
	IF LAST.ACAD_GROUP;                 /*Go back if not last.id     */
  	SPRING=_n_-sum(lag(_n_),0);  /*At last.id, calculate COUNT*/
	KEEP ACAD_GROUP SPRING;
RUN;
DATA BAFINAL;
	MERGE BAENRL(IN=A) BASEC BAENRL_FALL BAENRL_SPR;
	BY ACAD_GROUP;
	IF A=1;
	DROP COURSE;
RUN;

DATA COLLEGE_FINAL;
	SET UGFINAL GRFINAL CHFINAL BAFINAL;
	FORMAT GROUPING $GROUPING.;
RUN;
PROC SORT DATA=COLLEGE_FINAL;
	BY GROUPING;
RUN;


**************************************************************
			ODS AND REPORT CONSTRUCTION
*************************************************************;

title1 "COURSES IN FRISCO- CURRENT DAY %sysfunc(today(),mmddyy10.)";
ods _all_ close;
ods tagsets.excelxp file="S:\UIS\Shared\SAS Data Projects\FriscoEnrollment\Reports\Enrollment\ENROLL_FALL20_%sysfunc(today(), mmddyy6).xml" style=XLsansprinter;

ods tagsets.excelxp options(embed_titles_once='yes' autofit_height='yes' sheet_interval='none'
			sheet_NAME='Executive Report' absolute_column_width='8,15,8,8,8,8,8,10');

PROC REPORT DATA=EX_REPORT;
	COLUMN GROUP ('Executive Enrollment Report'('Enrollment' TODAY LAST_YEAR SPRING FALL)
				('Growth Since' YEAR_CHANGE SEM_CHANGE)) TYPE;
	DEFINE GROUP / DISPLAY 'Campus';
	DEFINE TODAY / ANALYSIS "%sysfunc(today(), WORDDATE.)";
	DEFINE LAST_YEAR / ANALYSIS 'Last Year';
	DEFINE SPRING / ANALYSIS 'Spring 2020';
	DEFINE FALL / ANALYSIS 'Fall 2019';
	DEFINE YEAR_CHANGE / COMPUTED 'Last Year' FORMAT=PERCENTN8.1;
	DEFINE SEM_CHANGE / COMPUTED 'Last Fall' FORMAT=PERCENTN8.1;
	DEFINE TYPE / GROUP NOPRINT;
	COMPUTE YEAR_CHANGE;
		YEAR_CHANGE = (TODAY.SUM - LAST_YEAR.SUM) / LAST_YEAR.SUM;
	ENDCOMP;
	COMPUTE SEM_CHANGE;
		SEM_CHANGE = (TODAY.SUM - FALL.SUM) / FALL.SUM;
	ENDCOMP;
	BREAK AFTER TYPE / SUMMARIZE OL UL;
	RBREAK AFTER / SUMMARIZE OL UL;
RUN;

PROC REPORT DATA=CAPS;
	COLUMN ('Hall Park-Inspire Park Classrooms' ENRL_TOT('Capacities' ROOM_CAP ENRL_CAP) ('Use Percentage' POT_USE CUR_USE)) ;
	DEFINE ROOM_CAP / 'Room' ANALYSIS;
	DEFINE ENRL_CAP / 'Course' ANALYSIS;
	DEFINE ENRL_TOT /ANALYSIS NOPRINT;
	DEFINE POT_USE / 'Potential' COMPUTED FORMAT=PERCENTN8.1;
	DEFINE CUR_USE / 'Current' COMPUTED FORMAT=PERCENTN8.1;
	COMPUTE POT_USE;
		POT_USE = ENRL_CAP.SUM/ROOM_CAP.SUM;
	ENDCOMP;
	COMPUTE CUR_USE;
		CUR_USE = ENRL_TOT.SUM/ROOM_CAP.SUM;
	ENDCOMP;
RUN;

options nobyline;
ods tagsets.excelxp options(embedded_titles='yes' autofit_height='yes' sheet_interval='none'
			sheet_NAME='College Report' absolute_column_width='20,8,8,8,15,8,8');
PROC REPORT DATA=COLLEGE_FINAL;
	BY GROUPING;
	COLUMN A_GRP_DESCR SECTIONS ('Enrollment' FALL SPRING TODAY) ('Growth Since' FCHANGE SCHANGE);
	DEFINE A_GRP_DESCR / ORDER 'College';
	DEFINE SECTIONS / DISPLAY 'Sections';
	DEFINE FALL / ANALYSIS 'Fall 2019';
	DEFINE SPRING / ANALYSIS 'Spring 2020';
	DEFINE TODAY / ANALYSIS "%sysfunc(today(), WORDDATE.)";
	DEFINE FCHANGE / COMPUTED 'Fall 2019' FORMAT=PERCENTN8.1;
	DEFINE SCHANGE / COMPUTED 'Spring 2020' FORMAT=PERCENTN8.1;
	COMPUTE FCHANGE;
		FCHANGE = (TODAY.SUM - FALL.SUM) / FALL.SUM;
	ENDCOMP;
	COMPUTE SCHANGE;
		SCHANGE = (TODAY.SUM - SPRING.SUM) / SPRING.SUM;
	ENDCOMP;
	title '#byval(grouping)';
RUN;


options nobyline;
ods tagsets.excelxp options(embedded_titles='yes' autofit_height='yes' sheet_interval='none'
			sheet_NAME='Course Report' absolute_column_width='6,6,5,7,5,4,3,18,10,10,5,6,6,6,5,5,7,16,16');

proc report data=one_class1_crs3 HEADLINE HEADSKIP;
	by GROUP;
	column ('Capacity' ROOM_CAP ENRL_CAP USE)
			('Course' CLASS_FACILITY_ID SUBJECT CATALOG_NBR CLASS_SECTION CRSE_DESCR CLASS_MTG_PAT CLASS_MTG_TIME)
			('Enrollment' PREV_FALL PREV_SPRING ENRL_TOT NEW_TOTAL PERCENT_ENROL)
			('Growth' FCHANGE SCHANGE) WARNING NOTES;
	DEFINE ROOM_CAP / ANALYSIS 'Room' FORMAT=MISSING.;
	DEFINE PERCENT_ENROL / COMPUTED FORMAT=PERCENT. 'Enrl %';
	DEFINE CLASS_MTG_PAT / DISPLAY 'Meeting Days';
	DEFINE CLASS_MTG_TIME / DISPLAY 'Meeting Time';
	DEFINE WARNING / DISPLAY FORMAT=$WARNING. 'Enrollment Level';
	DEFINE CLASS_FACILITY_ID / DISPLAY 'Room';
	DEFINE CRS / ORDER 'Code';
	DEFINE CRSE_DESCR / DISPLAY 'Description';
	DEFINE PREV_FALL / ANALYSIS "Fall '19 (C)" FORMAT=MISSING.;
	DEFINE PREV_SPRING / ANALYSIS "Spring '20 (C)" FORMAT=MISSING.;
	DEFINE ENRL_CAP / ANALYSIS 'Course';
	DEFINE ENRL_TOT / ANALYSIS 'Current';
	DEFINE NEW_TOTAL / ANALYSIS 'New//X-fer';
	DEFINE USE / COMPUTED 'Use %' format=PERCENT.;
	DEFINE FCHANGE / COMPUTED 'Since Fall' FORMAT=PERCENTN8.1;
	DEFINE SCHANGE / COMPUTED 'Since Spring' FORMAT=PERCENTN8.1;
	DEFINE SUBJECT / DISPLAY 'Subj';
	DEFINE CATALOG_NBR / DISPLAY 'Cat';
	DEFINE CLASS_SECTION / DISPLAY 'Sec';
	DEFINE NOTES / 'Notes';
	COMPUTE USE;
		USE = ENRL_CAP.sum/ROOM_CAP.sum;
	ENDCOMP;
	COMPUTE PERCENT_ENROL;
		PERCENT_ENROL = ENRL_TOT.SUM/ENRL_CAP.SUM;
	ENDCOMP;
	COMPUTE FCHANGE;
		IF PREV_FALL.SUM = 0 THEN FCHANGE = 0;
		ELSE IF ENRL_TOT.SUM = 0 THEN FCHANGE = 0;
		ELSE FCHANGE = (ENRL_TOT.SUM - PREV_FALL.SUM) / PREV_FALL.SUM;
		*IF PREV_FALL.SUM > 0 THEN FCHANGE = ENRL_TOT.SUM - PREV_FALL.SUM;
		*ELSE FCHANGE = ENRL_TOT.SUM;
	ENDCOMP;
	COMPUTE SCHANGE;
		IF PREV_SPRING.SUM = 0 THEN SCHANGE = 0;
		ELSE IF ENRL_TOT.SUM = 0 THEN SCHANGE = 0;
		ELSE SCHANGE = (ENRL_TOT.SUM - PREV_SPRING.SUM) / PREV_SPRING.SUM;
		*IF PREV_SPRING.SUM > 0 THEN SCHANGE = ENRL_TOT.SUM - PREV_SPRING.SUM; 	*IF statement to return ENRL_TOT.SUM in the event that PREV_SPRING.SUM =[.,0];
		*ELSE SCHANGE = ENRL_TOT.SUM;
	ENDCOMP;
	RBREAK AFTER /SUMMARIZE OL UL;
	title '#byval(group)';
run;

ods tagsets.excelxp options(embedded_titles='no' autofit_height='yes' sheet_interval='none'
			sheet_NAME='Trajectory' ABSOLUTE_COLUMN_WIDTH='12,6,6,6,6,6,6,7,2');
proc report data=trajectory;
	COLUMN ('FALL 2019 Trajectory Report' SEM ('CHEC' C18 C19) ('Frisco' F18 F19)('Total' T18 T19 PERC_CHANGE));
	DEFINE SEM / DISPLAY 'Date';
	DEFINE C18 / DISPLAY '2019';
	DEFINE C19 / DISPLAY '2020';
	DEFINE F18 / DISPLAY '2019';
	DEFINE F19 / DISPLAY '2020';
	DEFINE T18 / DISPLAY '2019';
	DEFINE T19 / DISPLAY '2020';
	DEFINE PERC_CHANGE / COMPUTED 'Change' FORMAT=PERCENTN8.1;
	COMPUTE PERC_CHANGE;
		IF T18 = 0 THEN PERC_CHANGE = 0;
		ELSE IF T19 = 0 THEN PERC_CHANGE = 0;
		ELSE PERC_CHANGE = (T19 - T18) / T18;
	ENDCOMP;
run;
ods _all_ close;
ods listing;




****** TRAJECTORY GRAPH*************;

footnote;
ods tagsets.msoffice2k_x path='S:\UIS\Shared\SAS Data Projects\FriscoEnrollment\Reports\Enrollment\Trajectory' (url=none)
                        gpath='S:\UIS\Shared\SAS Data Projects\FriscoEnrollment\Reports\Enrollment\Trajectory' (url=none)
    file="trajectory_%sysfunc(today(),mmddyy6.).xls" style=XLsansprinter ;
ods tagsets.msoffice2k_x  options(sheet_name="Trajectory") ;

PROC SGPLOT DATA = TRAJECTORY;
	SERIES X = SEM Y = F19 / LEGENDLABEL = 'Frisco 2020'
 MARKERS LINEATTRS = (THICKNESS = 2);
	SERIES X = SEM Y = F18 / LEGENDLABEL = 'Frisco 2019'
 MARKERS LINEATTRS = (THICKNESS = 2);
 	SERIES X = SEM Y = C19 / LEGENDLABEL = 'CHEC 2020'
 MARKERS LINEATTRS = (THICKNESS = 2);
	SERIES X = SEM Y = C18 / LEGENDLABEL = 'CHEC 2019'
 MARKERS LINEATTRS = (THICKNESS = 2);

	XAXIS TYPE = DISCRETE GRID;
	YAXIS LABEL = 'Enrollment Total' GRID VALUES = (0 TO 1800 BY 75);
	TITLE 'Enrollment Growth Trajectory';
RUN;


ods msoffice2k close;

/*proc freq data=COLLEGE_FINAL;*/
/*	table grouping;*/
/*run;*/

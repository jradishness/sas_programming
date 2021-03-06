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
%let old_enroll='C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2018z_082018'; *LAST YEAR'S FILE;
%LET LAST_FALL_CENSUS="C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2018z_census";  * LAST FALL'S CENSUS ENROLLMENT FILE;
%LET LAST_SPRING_CENSUS="C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019c_census";	* LAST SPRING'S CENSUS ENROLLMENT FILE;
/*LIBNAME IN1 "S:\TRANSFER";*/
**-------------------------------------------------------------**;
%MACRO ZTERM;
  DATE = TODAY();                                 /*TODAY'S DATE*/
  PUT  @23  'FALL 2019 UNOFFICIAL ENROLLMENT' /* # */
       @102 DATE DATE9.;
%MEND ZTERM;

DATA THECBSET_ORIG;	* Import new enrollment dataset;
  SET &new_enroll;	
  RUN;
PROC SORT DATA=THECBSET_ORIG;		***THECBSET_ORIG is enrollment data from new_enroll sorted by emplid;
	BY EMPLID;
RUN;



**************************************************
				EXECUTIVE REPORT CONSTRUCTION
*************************************************;
%MACRO ENROLL_SNAP(DSNAME, DSOURCE, LABEL);
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
%ENROLL_SNAP(EX1, ENROLLMENT, TODAY);
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


*Load comparison enrollment data from previous year;
DATA  OLD_FILE;			*P-I-T calculation;	
  SET &old_enroll;
  RUN;
DATA OLD_FILE;
	SET OLD_FILE;
	IF LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK') OR SUBJECT IN ('BAAS');			* Value for campus we want considered;
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
	IF LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK') OR SUBJECT IN ('BAAS');			* Value for campus we want considered;
	ENROL=1;
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
	MERGE OLD_FILE3 (IN=A) LAST_FALL LAST_SPRING;
	BY CRS;
	IF A=1;
RUN;


**************************************************************
					CURRENT ENROLLMENT CALCULATION
*************************************************************;

DATA ONE_CLASS1_CRS;	*ONE_CLASS1_CRS is a set of the courses with current enrollment counts 	;
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
*************************************************************;



DATA ONE_CLASS1_CRS2;			***ONE_CLASS1_CRS2 is the same as CRS except with previous_total included;
    SET ONE_CLASS1_CRS2;		***now it has the Percent Enrolled Var as well;
	IF ENRL_CAP =0 THEN DELETE;
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

* 	REFORMAT GROUP CONSTRUCTION FOR SORTING;

DATA ONE_CLASS1_CRS3;
	SET ONE_CLASS1_CRS3;
	LENGTH GROUP $30.;
	IF SUBJECT = "NCPS" THEN GROUP = 'New College';
	ELSE IF SUBJECT = "BAAS" THEN GROUP = 'Program (BAAS)';
	ELSE IF CLASS_FACILITY_ID IN ("CHEC") THEN GROUP = 'Site (CHEC)';
	ELSE GROUP = A_GRP_DESCR;
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
 BACKGROUND=GREEN
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
%SEMESTER(SEP_C_18, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2018z_census", SEP_C, 'K-Census', 2018)


*2019 EXECUTION;
%SEMESTER(MAY_A_19, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019z_050219", MAY_A, 'A-Early May', '2019')
%SEMESTER(MAY_B_19, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019z_051319", MAY_B, 'B-Mid May', '2019')
%SEMESTER(JUN_A_19, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019z_060319", JUN_A, 'C-Early June', '2019')
%SEMESTER(JUN_B_19, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019z_061819", JUN_B, 'D-Mid June', '2019')
%SEMESTER(JUL_A_19, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019z_070219", JUL_A, 'E-Early July', '2019')
%SEMESTER(JUL_B_19, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019z_071619", JUL_B, 'F-Mid July', '2019')
%SEMESTER(AUG_A_19, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019z_080219", AUG_A, 'G-Early August', '2019')
%SEMESTER(AUG_B_19, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019z_081519", AUG_B, 'H-Mid August', '2019')


DATA CTRAJECTORY_18;				* CHEC - COMBINE EACH TOTAL FOR THE PREVIOUS YEAR;
	SET CMAY_A_18 CMAY_B_18 CJUN_A_18 CJUN_B_18 CJUL_A_18 CJUL_B_18 CAUG_A_18 CAUG_B_18 CSEP_A_18 CSEP_B_18 CSEP_C_18;
	C18=TOTAL;
	KEEP SEM C18;
RUN;

DATA CTRAJECTORY_19;			* CHEC - COMBINE EACH TOTAL FOR THIS YEAR;
	SET CMAY_A_19 CMAY_B_19 CJUN_A_19 CJUN_B_19 CJUL_A_19 CJUL_B_19 CAUG_A_19 CAUG_B_19;
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
	SET FMAY_A_18 FMAY_B_18 FJUN_A_18 FJUN_B_18 FJUL_A_18 FJUL_B_18 FAUG_A_18 FAUG_B_18 FSEP_A_18 FSEP_B_18 FSEP_C_18;
	F18=TOTAL;
	KEEP SEM F18;
RUN;

DATA FTRAJECTORY_19;			* Frisco - COMBINE EACH TOTAL FOR THIS YEAR;
	SET FMAY_A_19 FMAY_B_19 FJUN_A_19 FJUN_B_19 FJUL_A_19 FJUL_B_19 FAUG_A_19 FAUG_B_19 ;
	F19=TOTAL;
	KEEP SEM F19;
RUN;
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

************************************************************
				COLLEGE REPORT CONSTRUCTION
************************************************************;

DATA UGRD;
	SET ENROLLMENT;
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
	SET ENROLLMENT;
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
	SET ENROLLMENT;
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
	SET ENROLLMENT;
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
RUN;
PROC SORT DATA=COLLEGE_FINAL;
	BY GROUPING;
RUN;
















DATA BAAS;
	SET ENROLLMENT;
	WHERE SUBJECT='BAAS';
	GROUPING='BAAS';
RUN;


**************************************************************
			ODS AND REPORT CONSTRUCTION
*************************************************************;

title1 &xprog.;
ods _all_ close;
ods tagsets.excelxp file="C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\FALL_2019_%sysfunc(today(), mmddyy6).xml" style=XLsansprinter;

ods tagsets.excelxp options(embed_titles_once='yes' autofit_height='yes' sheet_interval='none' 
			sheet_NAME='Executive Report' absolute_column_width='8,8,8,8,8,8,8,10');

PROC REPORT DATA=EX_REPORT;	
	COLUMN GROUP ('Executive Enrollment Report'('Enrollment' TODAY LAST_YEAR SPRING FALL) 
				('Growth Since' YEAR_CHANGE SEM_CHANGE)) TYPE;
	DEFINE GROUP / DISPLAY 'Campus';
	DEFINE TODAY / ANALYSIS "%sysfunc(today(), DATE9.)";
	DEFINE LAST_YEAR / ANALYSIS 'Last Year';
	DEFINE SPRING / ANALYSIS 'Spring 2019';
	DEFINE FALL / ANALYSIS 'Fall 2018';
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

ods tagsets.excelxp options(embed_titles_once='yes' autofit_height='yes' sheet_interval='none' 
			sheet_NAME='College Report' absolute_column_width='20,8,8,8,8,8,8');
PROC REPORT DATA=COLLEGE_FINAL;
	BY GROUPING;
	COLUMN A_GRP_DESCR SECTIONS ('Enrollment' FALL SPRING TODAY) ('Growth Since' FCHANGE SCHANGE);
	DEFINE A_GRP_DESCR / ORDER 'College';
	DEFINE SECTIONS / DISPLAY 'Sections';
	DEFINE FALL / ANALYSIS 'Fall 2018';
	DEFINE SPRING / ANALYSIS 'Spring 2019';
	DEFINE TODAY / ANALYSIS "%sysfunc(today(), DATE9.)";
	DEFINE FCHANGE / COMPUTED 'Fall 2018' FORMAT=PERCENTN8.1;
	DEFINE SCHANGE / COMPUTED 'Spring 2019' FORMAT=PERCENTN8.1;
	COMPUTE FCHANGE;
		FCHANGE = (TODAY.SUM - FALL.SUM) / FALL.SUM;
	ENDCOMP;
	COMPUTE SCHANGE;
		SCHANGE = (TODAY.SUM - SPRING.SUM) / SPRING.SUM;
	ENDCOMP;
RUN;


ods tagsets.excelxp options(embed_titles_once='yes' autofit_height='yes' sheet_interval='none' 
			sheet_NAME='Course Report' absolute_column_width='6,6,5,7,5,4,3,18,10,5,6,6,6,5,5,7,15');

proc report data=one_class1_crs3 HEADLINE HEADSKIP;
	by GROUP;
	column ('Capacity' ROOM_CAP ENRL_CAP USE) 
			('Course' CLASS_FACILITY_ID SUBJECT CATALOG_NBR CLASS_SECTION CRSE_DESCR CLASS_MTG_TIME) 
			('Enrollment' PREV_FALL PREV_SPRING ENRL_TOT NEW_TOTAL PERCENT_ENROL) 
			('Growth' FCHANGE SCHANGE) WARNING;
	DEFINE ROOM_CAP / ANALYSIS 'Room' FORMAT=MISSING.;
	DEFINE PERCENT_ENROL / COMPUTED FORMAT=PERCENT. 'Enrl %';
	DEFINE CLASS_MTG_TIME / DISPLAY 'Meeting Time';
	DEFINE WARNING / DISPLAY FORMAT=$WARNING. 'Notes';
	DEFINE CLASS_FACILITY_ID / DISPLAY 'Room';
	DEFINE CRS / ORDER 'Code';
	DEFINE CRSE_DESCR / DISPLAY 'Description';
	DEFINE PREV_FALL / ANALYSIS "Fall '18 (C)" FORMAT=MISSING.;
	DEFINE PREV_SPRING / ANALYSIS "Spring '19 (C)" FORMAT=MISSING.;
	DEFINE ENRL_CAP / ANALYSIS 'Course';
	*DEFINE PREVIOUS_ENROL / ANALYSIS '2018 (PIT)' FORMAT=MISSING.;
	DEFINE ENRL_TOT / ANALYSIS 'Current';
	DEFINE NEW_TOTAL / ANALYSIS 'New//X-fer';
	DEFINE USE / COMPUTED 'Use %' format=PERCENT.;
	DEFINE FCHANGE / COMPUTED 'Since Fall' FORMAT=PERCENTN8.1;
	DEFINE SCHANGE / COMPUTED 'Since Spring' FORMAT=PERCENTN8.1;
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
run;

ods tagsets.excelxp options(autofit_height='yes' sheet_interval='none' 
			sheet_NAME='Trajectory' ABSOLUTE_COLUMN_WIDTH='9,6,6,6,6,2');
proc report data=trajectory;
	COLUMN ('FALL 2019 Trajectory Report' SEM ('CHEC' C18 C19) ('Frisco' F18 F19));
	DEFINE SEM / DISPLAY 'Date';
	DEFINE C18 / DISPLAY '2018';
	DEFINE C19 / DISPLAY '2019';
	DEFINE F18 / DISPLAY '2018';
	DEFINE F19 / DISPLAY '2019';
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
	SERIES X = SEM Y = F19 / LEGENDLABEL = 'Frisco 2019'
 MARKERS LINEATTRS = (THICKNESS = 2);
	SERIES X = SEM Y = F18 / LEGENDLABEL = 'Frisco 2018'
 MARKERS LINEATTRS = (THICKNESS = 2);
 	SERIES X = SEM Y = C19 / LEGENDLABEL = 'CHEC 2019'
 MARKERS LINEATTRS = (THICKNESS = 2);
	SERIES X = SEM Y = C18 / LEGENDLABEL = 'CHEC 2018'
 MARKERS LINEATTRS = (THICKNESS = 2);

	XAXIS TYPE = DISCRETE GRID; 
	YAXIS LABEL = 'Enrollment Total' GRID VALUES = (0 TO 2600 BY 200);
	TITLE 'Enrollment Growth Trajectory';
RUN;


ods msoffice2k close;

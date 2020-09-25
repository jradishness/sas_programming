/************************************************************************************************
*			GUIDED PATHWAYS PROGRAM - PART 1 (Loading Data and Student Info)					|
*																								|
*		THIS PROGRAM CREATES 4 REPORTS AND THE DATASETS FOR THE MACRO PROGRAM					|
*		1. NUMBER OF "FRISCO" STUDENTS BY ACADEMIC PROGRAM										|
*		2. NUMBER OF "FRISCO" STUDENTS BY ACADEMIC PROGRAM, ONLY GUIDED PATHWAYS				|
*		3. SUMMARY OF LOCATIONS OF COURSES TAKEN BY "FRISCO" STUDENTS							|
*		4. STUDENT AND LOCATION DETAILS FOR ALL COURSES TAKEN BY "FRISCO" STUDENTS				|
*																								|
*			VARIABLES FOR ADJUSTMENT															|
*	CHECK EVERY TIME																			|
*		1. Define Frisco Student - 1b 			                        						|
*																								|
*	DO ONLY WHEN NEEDED																			|
*		2. Define location of simsterm files 1d													|
*		3. Define location of report output directory - 1e										|
*		4. Define the location of the enrollment file directory - 1f							|
*																								|
*	DO ONCE EVERY NEW SEMESTER																	|
*		5. Define Semester to report - 1c														|
*		6. ADD NECESSARY SEMESTERS TO STEPS 5 AND 6 (must be manual)							|
*																								|
*					BY Jared Kelly			Last Edit: 10/10/19									|
*																								|
*************************************************************************************************

  1) SET VARS and LIBS
	1a) This sets today's date in the system, and sets other options. No work necessary here */
%let curdate = %sysfunc(today(),mmddyy7.);	* CURRENT DATE;
options dlcreatedir;

* 	1b) How do you want to define Frisco student? COLLIN_ONLY SOME_COLLIN MAJORITY_COLLIN;
%let frisco_student = COLLIN_ONLY;

* 	1c) Which semester are you interested in? Summer 2019 = UNT_80, Fall 2019 = UNT_81, Spring 2020 = UNT_82, etc...;
%LET cursem = UNT_81;		* CURRENT SEMESTER;

* 	1d) Which SIMSTERM file should we use? This is the entire path, directory and all.;
%LET simloc = 'C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\Simsterm\s2019z_091119';	*LOCATION OF DESIRED SIMSTERM;

* 	1e) Where do we want our reports saved? This is the entire path, directory and all.;
libname newdir "C:\Users\jrk0200\UNT System\New College - Reports\&curdate.";	*DIRECTORY PATH TO FRISCO REPORTS;

* 	1f) This is the location of the enrollment files for the archive pull.;
LIBNAME UNT "S:\UIS\Shared\SAS Data Projects\DATA\ENROLLMENT";

* 2) IMPORT student data from SIMSTERM;
DATA SIMSTERM;
    SET &simloc;		*used to use a macro to point to an archived simsterm. If we're querying simsterm daily...;
	*SET SIMSTERM;
  	EMPLID2=INPUT(EMPLID, 15.);
RUN;

* 3) Macro for the term;
%MACRO ZTERM;
  DATE = TODAY();                                 /*TODAY'S DATE*/
  PUT  @23  'SPRING 2019 ENROLLMENT' /* # */
       @102 DATE DATE9.;
%MEND ZTERM;

* 4) Macro for enrollment data;
%MACRO COMBINE(TERM,NO);
DATA UNT_&NO;                            
   SET UNT.&TERM;
   *IF CATALOG_NBR GT '4999'; *change to select course level**;
   RUN; 
 
* 5) Combine step for enrollment data macro;
%MEND COMBINE;

%COMBINE(enrollement_dw_2012zag,60);
%COMBINE(enrollement_dw_2013cag,61);
%COMBINE(enrollement_dw_2013gimag,62);
%COMBINE(enrollement_dw_2013zag,63);
%COMBINE(enrollement_dw_2014cag,64);
%COMBINE(enrollement_dw_2014gimag,65);
%COMBINE(enrollement_dw_2014zag,66);
%COMBINE(enrollement_dw_2015cag,67);
%COMBINE(enrollement_dw_2015gimag,68);
%COMBINE(enrollement_dw_2015zag,69);
%COMBINE(enrollement_dw_2016cag,70);
%COMBINE(enrollement_dw_2016gimag,71);
%COMBINE(enrollement_dw_2016zag,72);
%COMBINE(enrollement_dw_2017cag,73);
%COMBINE(enrollement_dw_2017gimag,74);
%COMBINE(enrollement_dw_2017zag,75);
%COMBINE(enrollement_dw_2018cag,76);
%COMBINE(enrollement_dw_2018gimag,77);
%COMBINE(enrollement_dw_2018zag,78);
%COMBINE(enrollement_dw_2019cag,79);
%COMBINE(enrollement_dw_2019gimag,80);
%COMBINE(enrollement_dw_2019z_census,81);


* 6) Combine all enrollment into ALLCOURSES, NOW have all courses taken by all students in last 5 years;
* WORK.ALLCOURSES = COMBINATION OF ALL ENROLLMENT DATASETS SINCE FALL 2012, WITH ALL FIELDS;
DATA ALLCOURSES;
	SET UNT_60 UNT_61 UNT_62 UNT_63 UNT_64 UNT_65 UNT_66 UNT_67 UNT_68 UNT_69
      UNT_70 UNT_71 UNT_72 UNT_73 UNT_74 UNT_75 UNT_76 UNT_77 UNT_78 UNT_79 UNT_80 UNT_81;
RUN;	

* 7) Reformat EMPLID into EMPLID2 in ALLCOURSES, still all courses taken by all students in last 5 or more years;
* WORK.ALLCOURSES = COMBINATION OF ALL ENROLLMENT DATASETS SINCE FALL 2012, WITH ALL FIELDS, WITH REVISED EMPLID2;
DATA ALLCOURSES;
	  SET ALLCOURSES;
	  EMPLID2 = INPUT(EMPLID,11.0);
	  DROP EMPLID;
  RUN;

* 8) Create FRISCO students dataset from enrollment (one obs per Frisco course), using LOC during this semester as key;
* WORK.FRISCO = ALL OF THE COURSES TAKEN THIS SEMESTER, AT FRISCO, WITH ALL FIELDS FROM ALLCOURSES, WITH REVISED EMPLID2;
DATA FRISCO;
  SET &cursem;			
  IF LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK');			* Value for campus we want considered;
  EMPLID2 = INPUT(EMPLID,11.0);
  DROP EMPLID;
RUN;

* 9) Sort SIMSTERM by EMPLID2;
PROC SORT DATA=SIMSTERM;
	BY EMPLID2;
RUN;

* 10) Sort FRISCO by EMPLID2;
PROC SORT DATA =FRISCO;
	BY EMPLID2;
RUN;

* 11) Create FRISCO_SPEC students dataset from enrollment, using LOC as key, courses taken = 2;
* WORK.FRISCO_SPEC = "WORK.FRISCO" WITH COUNTS OF FRISCO CLASSES FOR EACH STUDENT;
DATA FRISCO_SPEC;
	SET FRISCO;
	COUNT + 1;
	by EMPLID2;
	if first.EMPLID2 then count =1;
	IF LAST.EMPLID2 THEN OUTPUT;
RUN;

* 12) CREATE A LIST OF EMPLID'S FOR EACH FRISCO STUDENT;
*WORK.FRISCO_STUDENTS = 1 COLUMN OF EMPLID'S OF "FRISCO" STUDENTS;
* 12a) "Some Collin" - Frisco students with at least one course in Frisco;
DATA SOME_COLLIN;
	SET FRISCO_SPEC;
	WHERE COUNT ge 1;
	KEEP EMPLID2;
RUN;
* 12b) "Collin Only" - Frisco students who only take courses at (HP, IP, CHEC, or ONLINE);
DATA COLLIN_ONLY;
	SET &CURSEM;
	IF LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK','Z-INET-TX','Z-INET-OS') THEN VOID = 0;				* STILL NEED TO FIX TO INCORPORATE ONLINE COURSES;
	ELSE VOID = 1; 
	IF LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK') THEN COLLIN = 1;				* STILL NEED TO FIX TO INCORPORATE ONLINE COURSES;
	ELSE COLLIN = 0; 	
RUN;
PROC SORT DATA=COLLIN_ONLY;
	BY EMPLID;
RUN;
DATA COLLIN_ONLY;
	SET COLLIN_ONLY;
	BY EMPLID;
	IF FIRST.EMPLID THEN COLLIN_TOT = 0;
	COLLIN_TOT + COLLIN;
	IF FIRST.EMPLID THEN VOID_TOT = 0;
	VOID_TOT + VOID;
	IF LAST.EMPLID THEN OUTPUT;
	KEEP EMPLID COLLIN_TOT VOID_TOT;
RUN;	
DATA COLLIN_ONLY;
	SET COLLIN_ONLY;
	WHERE COLLIN_TOT GE 1 AND VOID_TOT = 0;
	*KEEP EMPLID;
RUN;
* 12c) "Majority Collin" - Taking GE 50% of courses in HP, IP, CHEC;
DATA MAJORITY_COLLIN;
	SET &CURSEM;
	IF LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK') THEN COLLIN = 1;
	ELSE ETC = 1;
	KEEP EMPLID COLLIN ETC;
RUN;
PROC SORT DATA=MAJORITY_COLLIN;
	BY EMPLID;
RUN;
DATA MAJORITY_COLLIN;
	SET MAJORITY_COLLIN;
	BY EMPLID;
	IF FIRST.EMPLID THEN COLLIN_TOT = 0;
	COLLIN_TOT + COLLIN;
	IF FIRST.EMPLID THEN ETC_TOT = 0;
	ETC_TOT + ETC;
	IF LAST.EMPLID THEN OUTPUT;
	KEEP EMPLID COLLIN_TOT ETC_TOT;
RUN;	
DATA MAJORITY_COLLIN;
	SET MAJORITY_COLLIN;
	WHERE COLLIN_TOT GE ETC_TOT;
	*KEEP EMPLID;
RUN;

DATA FRISCO_STUDENTS;
	SET &frisco_student;
RUN;

* 13) OPERATIONS FOR COUNTING STUDENTS OF DIFFERENT CLASSES;
DATA COLLIN_ONLY;
	SET COLLIN_ONLY;
	CLASSIFICATION = "COLLIN_ONLY";
	DROP EMPLID;
RUN;
DATA SOME_COLLIN;
	SET SOME_COLLIN;
	CLASSIFICATION = "SOME_COLLIN";
	DROP EMPLID;
RUN;
DATA MAJORITY_COLLIN;
	SET MAJORITY_COLLIN;
	CLASSIFICATION = "MAJORITY_COLLIN";
	DROP EMPLID;
RUN;
DATA STUDENT_CLASSES;
	SET COLLIN_ONLY SOME_COLLIN MAJORITY_COLLIN;
RUN;
PROC FREQ DATA=STUDENT_CLASSES;
	TABLE CLASSIFICATION/NOCUM NOPERCENT;
RUN;


* 15) MERGE SIMSTERM DETAILS WITH LIST OF CURRENT FRISCO STUDENTS;
* WORK.FRISCO_SIMSTERM = SIMSTERM DATA OF "FRISCO" STUDENTS;
DATA FRISCO_SIMSTERM;
	MERGE SIMSTERM FRISCO_STUDENTS (IN=B);
	BY EMPLID2;
	IF B=1;
RUN;

* 16) REFORMAT CURRENT SEMESTER'S ENROLLMENT TO MATCH OUR EMPLID SCHEME;
* WORK.CURR_ENROLL = CURRENT SEMESTER'S ENROLLMENT DATA (UNIVERSITY-WIDE), WITH REFORMATTED EMPLID2 ;
DATA CURR_ENROLL;
	SET &cursem;		
	EMPLID2 = INPUT(EMPLID,11.0);
	DROP EMPLID;
RUN;

* 17) SORT THE DATA IN THE CURRENT ENROLLMENT DATASET;
PROC SORT DATA=CURR_ENROLL;
	BY EMPLID2;
RUN;

* 18) CREATE A DATASET OF EVERY CURRENT COURSE FOR EACH FRISCO STUDENT;
* WORK.FRISCO_COURSES = ALL CURRENT COURSES AND SIMSTERM DATA FOR ALL CURRENT "FRISCO" STUDENTS;
DATA FRISCO_COURSES;
	MERGE CURR_ENROLL (IN=A) FRISCO_SIMSTERM (IN=B);
	BY EMPLID2;
	IF A=1 & B=1;
RUN;

* 19) CREATE A DATASET OF NON-FRISCO COURSES TAKEN BY "FRISCO" STUDENTS;
* WORK.NONFRISCO_COURSES = THE COURSES FROM FRISCO_COURSES TAKEN AT OTHER CAMPUSES, NOT "FRSC";
DATA NONFRISCO_COURSES;
	SET FRISCO_COURSES;
	*WHERE LOCATION ~= 'FRSC';
	KEEP LOCATION COURSE2 CLASS_MTG_TIME CLASS_MTG_PAT CLASS_FACILITY_ID NAME EMPLID ACAD_PLAN EMAIL_ADDRESS CELL_PHONE_NMBR MAIN_PHONE_NMBR PERM_PHONE_NMBR;
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

* 20) CREATE REPORT OF ALL CLASSES TAKEN BY FRISCO STUDENTS, AT CAMPUSES NOT "FRSC";
title1 'Location of courses taken by "Frisco" students in Fall 19 - Summary';
title2 "(Frisco Student = &frisco_student)";
ods tagsets.excelxp file="C:\Users\jrk0200\UNT System\New College - Reports\&curdate.\FRSTUD_NONFRCOURSE_DATA.xml" style=XLSANSPRINTER 
		options( embedded_titles='yes' AUTOFIT_HEIGHT='YES' 
				 sheet_interval='none' 
	             sheet_name="Summary" suppress_bylines='no' 
				 absolute_column_width='10,8,8,8,8,8,8,8,8' 
				 TITLE_FOOTNOTE_WIDTH='9');

PROC FREQ DATA=FRISCO_COURSES ORDER=FREQ;
	TABLE COURSE2*LOCATION/NOCUM NOPERCENT NOROW NOCOL;
	FORMAT LOCATION $LOCATION.;
RUN; 

* 21) REPORT #1 - Report of details of all classes taken away from Frisco by Frisco students;
title1 'Location of courses taken by "Frisco" students in Fall 19 - Detailed';
title2 "(Frisco Student = &frisco_student)";
ods tagsets.excelxp options( embedded_titles='yes' AUTOFIT_HEIGHT='YES' 
				 sheet_interval='none' 
	             sheet_name="Details" suppress_bylines='no'
				 absolute_column_width='10,10,6,10,10,8,20,10,20,11,11,11' );
PROC PRINT DATA=WORK.NONFRISCO_COURSES NOOBS LABEL;
	FORMAT LOCATION $LOCATION.;
	LABEL LOCATION = 'Campus' 
			COURSE2 = 'Course Code'
			NAME = 'Student Name' 
			CLASS_MTG_TIME = 'Time of Day' 
			CLASS_MTG_PAT = 'Day of Week' 
			CLASS_FACILITY_ID = 'Classroom' 
			ACAD_PLAN = 'Program'
			EMPLID = 'ID'
			EMAIL_ADDRESS = 'E-Mail'
			CELL_PHONE_NMBR = 'Cell #'
			MAIN_PHONE_NMBR = 'Main #'
			PERM_PHONE_NMBR = 'Other #';
RUN;
TITLE;
ods tagsets.excelxp close;


* 22) CREATE DATASET OF STUDENTS AND DEGREE PLANS (DIFFERENT FROM FRISCO_STUDENTS BECAUSE OF ADDITION OF ACAD_PLAN);
* WORK.FRISCO_DEG = ALL CLASSES TAKEN BY ALL STUDENTS, KEEPING ONLY ID AND PLAN, SO CONTAINS DUPLICATES;
DATA FRISCO_DEG;
	SET FRISCO_COURSES;
	KEEP EMPLID2 ACAD_PLAN;
RUN;

* 23) REMOVE DUPLICATES FROM FRISCO_DEG;
* WORK.FRISCO_DEG = ALL "FRISCO" STUDENT ID'S WITH ACAD_PLAN;
PROC SORT DATA=FRISCO_DEG 
			NODUPKEY;
	BY EMPLID2;
RUN;

* 24) REPORT #2 - "FRISCO" Students, by degree plan;

Title1 'Frisco Students by Academic Program';
Title2 "(Frisco Student = &frisco_student)";
ods tagsets.excelxp file="C:\Users\jrk0200\UNT System\New College - Reports\&curdate.\ACAD_PLANS.xml" style=XLSANSPRINTER 
	options( embedded_titles='yes' AUTOFIT_HEIGHT='YES' 
			 skip_space='3,2,0,0,1' sheet_interval='none'
             sheet_name="TOTAL" suppress_bylines='no'
			 ABSOLUTE_COLUMN_WIDTH='16,10');

PROC FREQ DATA=FRISCO_DEG;
	TABLE ACAD_PLAN/NOCUM NOPERCENT NOROW NOCOL;
RUN; 

Title1 'Frisco Students by Academic Program (Guided Pathways)';
Title2 "(Frisco Student = &frisco_student)";

ods tagsets.excelxp options( embedded_titles='yes' AUTOFIT_HEIGHT='YES' 
			 skip_space='3,2,0,0,1' sheet_interval='none'
             sheet_name="GP Programs" suppress_bylines='no'
			 ABSOLUTE_COLUMN_WIDTH='16,10');

PROC FREQ DATA=FRISCO_DEG;
	TABLE ACAD_PLAN/NOCUM NOPERCENT NOROW NOCOL;
	where acad_plan = 'KINE-BS' 
		 or acad_plan = 'CEXM-BS'
		 or acad_plan = 'JOUR-BA'
		 or acad_plan = 'LSCM-BS'
		 or acad_plan = 'PSYC-BA'
		 or acad_plan = 'RESM-BS'
		 or acad_plan = 'BUIS-BBA'
		 or acad_plan = 'APAS-BAAS'
		 or acad_plan = 'INDE-BS'
		 or acad_plan = 'IGST-BS'
		 or acad_plan = 'CSIT-BA';
RUN; 

title;
ods tagsets.excelxp close;


* CREATING REPORT TEMPLATE; 

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


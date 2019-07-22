/*		GUIDED PATHWAYS PROGRAM - PART 1
		THIS PROGRAM CREATES 4 REPORTS AND THE DATASETS FOR THE MACRO PROGRAM
		1. NUMBER OF "FRISCO" STUDENTS BY ACADEMIC PROGRAM
		2. NUMBER OF "FRISCO" STUDENTS BY ACADEMIC PROGRAM, ONLY GUIDED PATHWAYS
		3. SUMMARY OF LOCATIONS OF COURSES TAKEN BY "FRISCO" STUDENTS
		4. STUDENT AND LOCATION DETAILS FOR ALL COURSES TAKEN BY "FRISCO" STUDENTS

	VARIABLES FOR ADJUSTMENT
		1. CURRENT SEMESTER SIMSTERM SOURCE DATA - STEP 2 (macro, simloc)
		2. ADD NECESSARY SEMESTERS TO STEPS 5 AND 6 (must be manual)
		3. CHANGE SEMESTER VAR IN SET STATEMENT - STEP 8 (macro, cursem)
		4. LOCATIONS CONSIDERED "FRISCO" IN IF STATEMENT - STEP 8 (must be manual)
		5. SET NUMBER OF CLASSES TO CONSIDER STUDENT "FRISCO" - STEP 12 (CURRENTLY >1)
		6. CHANGE SEMESTER VAR IN SET STATEMENT - STEP 16 (CONSIDER MACRO'ING VARIABLES)

*/
%LET cursem = UNT_79;		* CURRENT SEMESTER;
%LET simloc = 'S:\UIS\Shared\SAS Data Projects\DATA\SIMSTERM\s2019c_020119';	*LOCATION OF DESIRED SIMSTERM;

%let curdate = %sysfunc(today(),mmddyy7.);	* CURRENT DATE;
options dlcreatedir;

libname newdir "C:\Users\jrk0200\UNT System\New College - Reports\&curdate.";	*DIRECTORY PATH TO FRISCO REPORTS;

* 1) Set the LIBNAME path to the Data Warehouse; 
LIBNAME UNT "S:\UIS\Shared\SAS Data Projects\DATA\SIMSTERM";

* 2) IMPORT student data from SIMSTERM;
DATA SIMSTERM;
  SET &simloc;
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

* 6) Combine all enrollment into ALLCOURSES, NOW have all courses taken by all students in last 5 years;
* WORK.ALLCOURSES = COMBINATION OF ALL ENROLLMENT DATASETS SINCE FALL 2012, WITH ALL FIELDS;
DATA ALLCOURSES;
	SET UNT_60 UNT_61 UNT_62 UNT_63 UNT_64 UNT_65 UNT_66 UNT_67 UNT_68 UNT_69
      UNT_70 UNT_71 UNT_72 UNT_73 UNT_74 UNT_75 UNT_76 UNT_77 UNT_78 UNT_79;
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
RUN;

* 12) Create another new dataset to filter using the count VAR;
* WORK.FRISCO_MULT = ONLY THE CLASSES AFTER THE FIRST CLASS (PER STUDENT) - ADJUSTABLE;
DATA FRISCO_MULT;
	SET FRISCO_SPEC;
	IF count > 1;	* students taking more than one class;
RUN;

*13) Remove duplicates from FRISCO_MULT;
* WORK.FRISCO_MULT = ONLY THE FIRST COURSE FOR EACH STUDENT;
* WORK.FRISCO_STUD = THE REST OF THE COURSES;
PROC SORT DATA=FRISCO_MULT
			DUPOUT=FRISCO_STUD 
			NODUPKEY;
	BY EMPLID2;
RUN;

* 14) CREATE A LIST OF EMPLID'S FOR EACH FRISCO STUDENT;
* WORK.FRISCO_STUDENTS = 1 COLUMN OF EMPLID'S OF "FRISCO" STUDENTS;
DATA FRISCO_STUDENTS;
	SET FRISCO_MULT;
	KEEP EMPLID2;
RUN;

* 15) MERGE SIMSTERM DETAILS WITH LIST OF CURRENT FRISCO STUDENTS;
* WORK.FRISCO_SIMSTERM = SIMSTERM DATA OF "FRISCO" STUDENTS;
DATA FRISCO_SIMSTERM;
	MERGE SIMSTERM (IN=A) FRISCO_STUDENTS (IN=B);
	BY EMPLID2;
	IF A=1 & B=1;
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
title1 'Location of courses taken by "Frisco" students in Spring 19 - Summary';
title2 '(Frisco Students = Took 2 courses at [IP, HP, CHEC] in Spring 19, registered in GP program)';
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
title1 'Location of courses taken by "Frisco" students in Spring 19 - Detailed';
title2 '(Frisco Students = Took 2 courses at [IP, HP, CHEC] in Spring 19, registered in GP program)';
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
Title2 '(Frisco Students = Took 2 courses at [IP, HP, CHEC] in Spring 19)';
ods tagsets.excelxp file="C:\Users\jrk0200\UNT System\New College - Reports\&curdate.\ACAD_PLANS.xml" style=XLSANSPRINTER 
	options( embedded_titles='yes' AUTOFIT_HEIGHT='YES' 
			 skip_space='3,2,0,0,1' sheet_interval='none'
             sheet_name="TOTAL" suppress_bylines='no'
			 ABSOLUTE_COLUMN_WIDTH='16,10');

PROC FREQ DATA=FRISCO_DEG;
	TABLE ACAD_PLAN/NOCUM NOPERCENT NOROW NOCOL;
RUN; 

Title1 'Frisco Students by Academic Program';
Title2 '(Frisco Students = Took 2 courses at [IP, HP, CHEC] in Spring 19, enrolled in a Guided Pathway program)';

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

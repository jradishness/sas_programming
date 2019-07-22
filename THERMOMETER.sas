 ******************************************************************
**																**
**			Thermometer Program for Frisco Enrollment			**
**					At a Given Date in Time						**
**																**
**																**
**		Editted: 07/17/2019		By: Jared Kelly					**
******************************************************************
* Step 1 - Setup variables;
options dlcreatedir;
%let today = %sysfunc(today(),mmddyy7.);	* CURRENT DATE;
libname nroll 'C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\';			*Path to enrollment directory;
%let new_enroll=enrollement_dw_2019z_071719;	* enrollment file for test;
%let comp_enroll=enrollement_dw_2018z_census;	* comparison enrollment file - census;
%let semester='Spring 2019';
libname newdir "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment";	*DIRECTORY PATH TO FRISCO REPORTS;


********************* COMPARISON ENROLLMENT *********************************************;


DATA ENROLLMENT_COMP;		* import the enrollment records from the requested semester;
	SET nroll.&COMP_enroll;
	IF LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK') THEN FRISCO='YES';
	KEEP ADMIT_N EMPLID FRISCO OTHER LOCATION UNT_TAKEN;
	LABEL ADMIT_N='Admission Type' EMPLID='ID' UNT_TAKEN='Credit Hours' ;
RUN;

DATA FRISCO_COMP;			* create dataset of frisco enrollments;
	SET ENROLLMENT_COMP;
	WHERE FRISCO='YES';
	KEEP EMPLID FRISCO;		* end up with only 2 vars, emplid and Frisco;
RUN;
PROC SORT DATA=FRISCO_COMP NODUPKEY;		* sort by emplid and remove duplicates;
	BY EMPLID;
RUN;
DATA ELSEWHERE_COMP;			* create dataset of non-frisco enrollments;
	SET ENROLLMENT_COMP;
	WHERE FRISCO~='YES';
	OTHER='YES';
	KEEP EMPLID OTHER;		* end up with only 2 vars, emplid and Other;
RUN;
PROC SORT DATA=ELSEWHERE_COMP NODUPKEY;	* sort by emplid and remove duplicates;
	BY EMPLID;
RUN;

DATA NON_FRISCO_STUDENTS_C FRISCO_STUDENTS_C HYBRID_STUDENTS_C TROUBLESHOOTING_C;	* based on Other and Frisco, disperse obs to sets;
	MERGE FRISCO_COMP ELSEWHERE_COMP;
	BY EMPLID;
	IF FRISCO~='YES' AND OTHER='YES' THEN OUTPUT NON_FRISCO_STUDENTS_C;
	ELSE IF FRISCO='YES' AND OTHER~='YES' THEN OUTPUT FRISCO_STUDENTS_C;
	ELSE IF FRISCO='YES' AND OTHER='YES' THEN OUTPUT HYBRID_STUDENTS_C;
	ELSE OUTPUT TROUBLESHOOTING_C;		* This should always be empty, unless there is something wrong in the data;
RUN;

DATA NON_FRISCO_STUDENTS_C;	*create status field;
	SET NON_FRISCO_STUDENTS_C;
	LOC_STATUS="NON_FRISCO";
	KEEP EMPLID LOC_STATUS;
	LABEL LOC_STATUS='Location Type';
RUN;
DATA FRISCO_STUDENTS_C;		*create status field;
	SET FRISCO_STUDENTS_C;
	LOC_STATUS="FRISCO";
	KEEP EMPLID LOC_STATUS;
	LABEL LOC_STATUS='Location Type';
RUN;
DATA HYBRID_STUDENTS_C;		*create status field;
	SET HYBRID_STUDENTS_C;
	LOC_STATUS="HYBRID";
	KEEP EMPLID LOC_STATUS;
	LABEL LOC_STATUS='Location Type';
RUN;

DATA STUDENT_STATUS_COMP;		* create one set with all students of all status types;
	MERGE NON_FRISCO_STUDENTS_C FRISCO_STUDENTS_C HYBRID_STUDENTS_C;
	BY EMPLID;
RUN;

DATA TOTAL_STUDENTS_COMP;		* new dataset with EMPLID and ADMIT_N(student continuation status);
	SET ENROLLMENT_COMP;
	KEEP EMPLID ADMIT_N;
RUN;
PROC SORT DATA=TOTAL_STUDENTS_COMP NODUPKEY;	*remove duplicates and sort by emplid;
	BY EMPLID;
RUN;

DATA FINAL_STUDENTS_COMP;		*dataset of students (each student once) with ADMIT_N and LOC_STATUS;
	MERGE TOTAL_STUDENTS_COMP STUDENT_STATUS_COMP;
	BY EMPLID;
RUN;
PROC SORT DATA=FINAL_STUDENTS_COMP;	
	BY LOC_STATUS ADMIT_N;
RUN;

PROC SORT DATA=FINAL_STUDENTS_COMP OUT=STUD_SORTED_COMP;		*RE-SORT STUDENT DATASET TO MERGE WITH ENROLLMENTS; 
	BY EMPLID;
RUN;
DATA ENROLLMENTS_COMP;				*CREATE AN ENROLLMENTS DATABASE TO MERGE WITH STUDENTS;
	SET ENROLLMENT_COMP;
	ADMIT_M = ADMIT_N;
	DROP ADMIT_N FRISCO;
RUN;
PROC SORT DATA=ENROLLMENTS_COMP;		*SORT THE ENROLLMENTS DATABASE FOR MERGE;
	BY EMPLID;
RUN;
DATA STUD_ENROLL_COMP;			*ONE-TO-MANY-MERGE THE STUDENTS BACK TO ENROLLMENTS; 
	MERGE STUD_SORTED_COMP ENROLLMENTS_COMP;
	BY EMPLID;
RUN;


********************* CURRENT ENROLLMENT *********************************************;


DATA ENROLLMENT;		* import the enrollment records from the requested semester;
	SET nroll.&new_enroll;
	IF LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK') THEN FRISCO='YES';
	KEEP ADMIT_N EMPLID FRISCO OTHER LOCATION UNT_TAKEN;
	LABEL ADMIT_N='Admission Type' EMPLID='ID' UNT_TAKEN='Credit Hours' ;
RUN;

DATA FRISCO;			* create dataset of frisco enrollments;
	SET ENROLLMENT;
	WHERE FRISCO='YES';
	KEEP EMPLID FRISCO;		* end up with only 2 vars, emplid and Frisco;
RUN;
PROC SORT DATA=FRISCO NODUPKEY;		* sort by emplid and remove duplicates;
	BY EMPLID;
RUN;
DATA ELSEWHERE;			* create dataset of non-frisco enrollments;
	SET ENROLLMENT;
	WHERE FRISCO~='YES';
	OTHER='YES';
	KEEP EMPLID OTHER;		* end up with only 2 vars, emplid and Other;
RUN;
PROC SORT DATA=ELSEWHERE NODUPKEY;	* sort by emplid and remove duplicates;
	BY EMPLID;
RUN;

DATA NON_FRISCO_STUDENTS FRISCO_STUDENTS HYBRID_STUDENTS TROUBLESHOOTING;	* based on Other and Frisco, disperse obs to sets;
	MERGE FRISCO ELSEWHERE;
	BY EMPLID;
	IF FRISCO~='YES' AND OTHER='YES' THEN OUTPUT NON_FRISCO_STUDENTS;
	ELSE IF FRISCO='YES' AND OTHER~='YES' THEN OUTPUT FRISCO_STUDENTS;
	ELSE IF FRISCO='YES' AND OTHER='YES' THEN OUTPUT HYBRID_STUDENTS;
	ELSE OUTPUT TROUBLESHOOTING;		* This should always be empty, unless there is something wrong in the data;
RUN;

DATA NON_FRISCO_STUDENTS;	*create status field;
	SET NON_FRISCO_STUDENTS;
	LOC_STATUS="NON_FRISCO";
	KEEP EMPLID LOC_STATUS;
	LABEL LOC_STATUS='Location Type';
RUN;
DATA FRISCO_STUDENTS;		*create status field;
	SET FRISCO_STUDENTS;
	LOC_STATUS="FRISCO";
	KEEP EMPLID LOC_STATUS;
	LABEL LOC_STATUS='Location Type';
RUN;
DATA HYBRID_STUDENTS;		*create status field;
	SET HYBRID_STUDENTS;
	LOC_STATUS="HYBRID";
	KEEP EMPLID LOC_STATUS;
	LABEL LOC_STATUS='Location Type';
RUN;

DATA STUDENT_STATUS;		* create one set with all students of all status types;
	MERGE NON_FRISCO_STUDENTS FRISCO_STUDENTS HYBRID_STUDENTS;
	BY EMPLID;
RUN;

DATA TOTAL_STUDENTS;		* new dataset with EMPLID and ADMIT_N(student continuation status);
	SET ENROLLMENT;
	KEEP EMPLID ADMIT_N;
RUN;
PROC SORT DATA=TOTAL_STUDENTS NODUPKEY;	*remove duplicates and sort by emplid;
	BY EMPLID;
RUN;

DATA FINAL_STUDENTS;		*dataset of students (each student once) with ADMIT_N and LOC_STATUS;
	MERGE TOTAL_STUDENTS STUDENT_STATUS;
	BY EMPLID;
RUN;
PROC SORT DATA=FINAL_STUDENTS;	
	BY LOC_STATUS ADMIT_N;
RUN;

PROC SORT DATA=FINAL_STUDENTS OUT=STUD_SORTED;		*RE-SORT STUDENT DATASET TO MERGE WITH ENROLLMENTS; 
	BY EMPLID;
RUN;
DATA ENROLLMENTS;				*CREATE AN ENROLLMENTS DATABASE TO MERGE WITH STUDENTS;
	SET ENROLLMENT;
	ADMIT_M = ADMIT_N;
	DROP ADMIT_N FRISCO;
RUN;
PROC SORT DATA=ENROLLMENTS;		*SORT THE ENROLLMENTS DATABASE FOR MERGE;
	BY EMPLID;
RUN;
DATA STUD_ENROLL;			*ONE-TO-MANY-MERGE THE STUDENTS BACK TO ENROLLMENTS; 
	MERGE STUD_SORTED ENROLLMENTS;
	BY EMPLID;
RUN;





PROC FORMAT;			* FORMAT STATEMENT FOR ADMIT_N VALUES;
	VALUE ADMIT
	1='Continuing Student'
	2='First Time in College'
	3='Transfer'
	4='New Grad'
	6='Transient';
RUN;

*************************************************************

************* START OF REPORTING ***************************

*************************************************************

*** REPORT OF STUDENTS ;
title1 "Number of Students (Fall 2019, as of %sysfunc(today(),date11.))";	
footnote1 'Frisco=took only Frisco classes';
footnote2 'Non-Frisco=took no classes at Frisco';
footnote3 'Hybrid=took classes both at Frisco and not';

ods tagsets.excelxp file="C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\Reports\thermometer_&today..xml" style=XLSANSPRINTER 
	options( skip_space='1,0,0,0,1'embedded_titles='yes' AUTOFIT_HEIGHT='YES' embedded_footnotes='NO'
			 sheet_interval='none' TITLE_FOOTNOTE_WIDTH="8"
             sheet_name="Students" suppress_bylines='no');

PROC FREQ DATA=FINAL_STUDENTS;
	FORMAT ADMIT_N ADMIT.;
	TABLE LOC_STATUS*ADMIT_N/ nocol norow nopercent;
	LABEL ADMIT_N='2019, Current';
RUN;

ods tagsets.excelxp options( embedDED_titles='NO' embedDED_footnotes='YES');
PROC FREQ DATA=FINAL_STUDENTS_COMP;
	FORMAT ADMIT_N ADMIT.;
	TABLE LOC_STATUS*ADMIT_N/ nocol norow nopercent;
	LABEL ADMIT_N='2018, Census';
RUN;


*** REPORT OF ENROLLMENTS ;
title1 "Number of Enrollments (Fall 2019, as of %sysfunc(today(),date11.))";
ods tagsets.excelxp options( embedded_titles='yes' AUTOFIT_HEIGHT='YES' 
			 sheet_interval='none' embeDdED_footnotes='NO'
             sheet_name="Enrollments" suppress_bylines='YES');

PROC FREQ DATA=STUD_ENROLL;
	FORMAT ADMIT_N ADMIT.;
	TABLE LOC_STATUS*ADMIT_N/ outcum;
	LABEL ADMIT_N='2019, Current';
RUN;

ods tagsets.excelxp options( embedDED_titles='NO' embedDED_footnotes='YES');

PROC FREQ DATA=STUD_ENROLL_COMP;
	FORMAT ADMIT_N ADMIT.;
	TABLE LOC_STATUS*ADMIT_N/ nocol norow nopercent;
	LABEL ADMIT_N='2018, Census';
RUN;

*** REPORT OF ENROLLMENT CREDIT HOURS;
title1 "Number of Credit Hours Enrolled (Fall 2019, as of %sysfunc(today(),date11.))";
ods tagsets.excelxp options( embedded_titles='yes' AUTOFIT_HEIGHT='YES' embedded_footnotes='no'
			 sheet_interval='none' absolute_column_width='12,16,10'
             sheet_name="Credits" suppress_bylines='no');

PROC TABULATE DATA=STUD_ENROLL FORMAT=COMMA12.;
	FORMAT ADMIT_N ADMIT.;
	CLASS LOC_STATUS ADMIT_N;
	VAR UNT_TAKEN;
	TABLE LOC_STATUS*ADMIT_N, UNT_TAKEN;
	LABEL LOC_STATUS='2019, Current';
RUN;
ods tagsets.excelxp options( embedDED_titles='NO' embedDED_footnotes='YES');
PROC TABULATE DATA=STUD_ENROLL_COMP FORMAT=COMMA12.;
	FORMAT ADMIT_N ADMIT.;
	CLASS LOC_STATUS ADMIT_N;
	VAR UNT_TAKEN;
	TABLE LOC_STATUS*ADMIT_N, UNT_TAKEN;
	LABEL LOC_STATUS='2018, Census';

RUN;

title;
ods tagsets.excelxp close;


****** PROC TEMPLATES *********;
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

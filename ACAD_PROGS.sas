**********************************

A Program to query an enrollment
file for Frisco Majors.

*********************************;
DATA COLLIN_ENR;	* SET OF ALL COLLIN ENROLLMENTS FOR CURRENT SEMESTER;
	SET ENROLLMENT;
	IF LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK');
RUN;

DATA COLLIN;	* SET OF COLLIN STUDENTS;
	SET COLLIN_ENR;
	KEEP EMPLID COURSE;
RUN;
PROC SORT DATA=COLLIN;
	BY EMPLID ;
RUN;
PROC SORT DATA=SIMSTERM;
	BY EMPLID;
RUN;

DATA COLLIN_STUD;
	MERGE COLLIN (IN=A) SIMSTERM;
	BY EMPLID;
	IF A=1;
	KEEP EMPLID ACAD_PLAN COURSE;
RUN;

DATA COLLIN_PROGS;
	SET COLLIN_STUD;
	KEEP EMPLID ACAD_PLAN;
RUN;
PROC SORT DATA=COLLIN_PROGS NODUPKEY;
	BY EMPLID;
RUN;


Title1 'Frequency of Academic Program among Collin Students';
Title2 '(Collin Students = TAKING >= 1 course at [IP, HP, CHEC] in FALL 19)';
ods tagsets.excelxp file="C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\Reports\COLLIN_ACAD_PLANS_%sysfunc(today(),mmddyy6.)" style=XLSANSPRINTER 
	options( embedded_titles='yes' AUTOFIT_HEIGHT='YES' 
			 sheet_interval='none' TITLE_FOOTNOTE_WIDTH='8'
             sheet_name="TOTAL" suppress_bylines='no');
PROC FREQ DATA=COLLIN_PROGS ORDER=FREQ;
	TABLE ACAD_PLAN/NOCUM;
RUN;
Title1 'Collin Courses by Academic Program among Collin Students';
Title2 '(Collin Students = TAKING >= 1 course at [IP, HP, CHEC] in FALL 19)';
ODS TAGSETS.EXCELXP OPTIONS( embedded_titles='yes' AUTOFIT_HEIGHT='YES' 
			 sheet_interval='none' TITLE_FOOTNOTE_WIDTH='8'
             sheet_name="COURSES" suppress_bylines='no');
PROC FREQ DATA=COLLIN_STUD ORDER=FREQ;
	TABLE COURSE * ACAD_PLAN/nocol norow nopercent NOCUM;
RUN;
ods tagsets.excelxp close;



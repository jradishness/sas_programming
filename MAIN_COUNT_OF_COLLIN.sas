* FOR GATHERING STUDENTS;
DATA FRISCO_STUDENTS;
  SET ENROLLMENT;
  IF LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK');			* Value for campus we want considered;
  KEEP EMPLID;
RUN;

PROC SORT DATA=FRISCO_STUDENTS NODUPKEY;
	BY EMPLID;
RUN;

*****	FRISCO_STUDENTS	- SET OF EMPLIDS OF "FRISCO" STUDENTS	*****;

* GRAB ALL FRISCO_STUDENT ENROLLMENTS;
PROC SORT DATA=ENROLLMENT OUT=FRISCO;
	BY EMPLID;
RUN;

***** 	FRISCO - SET OF SORTED ENROLLMENTS	*****;

DATA FRISCO_MAIN;
	MERGE FRISCO_STUDENTS (IN=A) FRISCO;
	BY EMPLID;
	IF A=1;
	IF LOCATION IN ('MAIN');
	KEEP EMPLID;
RUN;

***** FRISCO_MAIN - SET OF EMPLIDS OF "FRISCO" STUDENTS (ONE OBS PER MAIN CAMPUS COURSE)	*****;

DATA MAIN_COUNT;
	SET FRISCO_MAIN;
	BY EMPLID;
	IF FIRST.EMPLID THEN COUNT=1;
	ELSE COUNT+1;
	IF LAST.EMPLID THEN OUTPUT;
	LABEL COUNT='Count of Denton Courses';
RUN;

***** MAIN_COUNT - SET OF EMPLIDS OF "FRISCO" STUDENTS TAKING CLASSES ON MAIN CAMPUS, WITH COUNT OF MAIN COURSES	*****;

ods tagsets.excelxp file="C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\reports\main_count_%sysfunc(today(),mmddyy6.).xml" style=XLSANSPRINTER
    options( embedded_titles='yes' AUTOFIT_HEIGHT='YES'
			 sheet_name="Count" suppress_bylines='no');

title1 'Count of Denton Courses';
title2 'Students with at least 1 Frisco course';
title3 'Spring Semester 2020';
title4 "As of %sysfunc(today(),date11.)";
PROC FREQ DATA=MAIN_COUNT;
	TABLES COUNT;
RUN;
title;
ods tagsets.excelxp close;

ODS PDF FILE = "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\reports\main_count_%sysfunc(today(),mmddyy6.).pdf";

title1 'Count of Denton Courses';
title2 'By Students taking at least 1 Frisco course';
title3 'Spring Semester 2020';
title4 "As of %sysfunc(today(),date11.)";
PROC FREQ DATA=MAIN_COUNT;
	TABLES COUNT;
RUN;
title;
ODS PDF close;

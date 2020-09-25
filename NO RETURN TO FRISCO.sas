******************************************
PROGRAM TO REPORT FREQUENCY OF STUDENT
TYPES ACROSS 2 SEMESTERS.

IN OTHER WORDS, FALL 2019 ACROSS THE Y 
AXIS, SPRING 2020 ACROSS THE X AXIS, WITH 
FREQUENCIES OF STUDENT TYPES (CHEC, CHEC+,
COLLIN, COLLIN+, ETC.) 
*****************************************;
*      STUDENT_TYPE(S20, ENROLLMENT) ;
*      STUDENT_TYPE(F19, "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019z_census") ;
DATA COLLIN_STUDENTS_F19;
	SET "C:\Users\vac0019\OneDrive - UNT System\SAS Data Projects\FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019z_census";
	WHERE LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK' );
	KEEP EMPLID;
RUN;
PROC SORT DATA=COLLIN_STUDENTS_F19 NODUPKEY;
	BY EMPLID;
RUN;
PROC SORT DATA="C:\Users\vac0019\OneDrive - UNT System\SAS Data Projects\FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019z_census" OUT=ENROLL_TEMP;
	BY EMPLID;
RUN;
DATA COL_STUD_ENROLL_F19;
	MERGE ENROLL_TEMP COLLIN_STUDENTS_F19(IN=A);
	BY EMPLID;
	IF A=1;
	KEEP EMPLID LOCATION;
RUN;
DATA FRISCO_F19;
	SET COL_STUD_ENROLL_F19;
	WHERE LOCATION = "FRSC";
	FRISCO = 1;
	KEEP EMPLID FRISCO;	
RUN;
PROC SORT DATA=FRISCO_F19 NODUPKEY;
	BY EMPLID;
RUN;
DATA MAIN_F19;
	SET COL_STUD_ENROLL_F19;
	WHERE LOCATION = "MAIN";
	MAIN = 1;
	KEEP EMPLID MAIN;	
RUN;
PROC SORT DATA=MAIN_F19 NODUPKEY;
	BY EMPLID;
RUN;
DATA AOP_F19;
	SET COL_STUD_ENROLL_F19;
	WHERE LOCATION = "Z-AOP";
	AOP = 1;
	KEEP EMPLID AOP;	
RUN;
PROC SORT DATA=AOP_F19 NODUPKEY;
	BY EMPLID;
RUN;
DATA CHEC_F19;
	SET COL_STUD_ENROLL_F19;
	WHERE LOCATION = "Z-CHEC";
	CHEC = 1;
	KEEP EMPLID CHEC;	
RUN;
PROC SORT DATA=CHEC_F19 NODUPKEY;
	BY EMPLID;
RUN;
DATA INET_F19;
	SET COL_STUD_ENROLL_F19;
	WHERE LOCATION = "Z-INET-TX";
	INET = 1;
	KEEP EMPLID INET;	
RUN;
PROC SORT DATA=INET_F19 NODUPKEY;
	BY EMPLID;
RUN;
DATA INSPK_F19;
	SET COL_STUD_ENROLL_F19;
	WHERE LOCATION = "Z-INSPK";
	INSPK = 1;
	KEEP EMPLID INSPK;	
RUN;
PROC SORT DATA=INSPK_F19 NODUPKEY;
	BY EMPLID;
RUN;
DATA COUNTS_F19;
	MERGE INSPK_F19 FRISCO_F19 CHEC_F19 MAIN_F19 AOP_F19 INET_F19;
	BY EMPLID;
RUN;
DATA COUNTS_F19;
	SET COUNTS_F19;
	IF INSPK=1 AND FRISCO="" AND CHEC="" AND MAIN="" AND INET="" THEN FALL_2019 = "IP ONLY";
	ELSE IF INSPK=1 AND FRISCO="" AND CHEC="" AND MAIN="" AND INET=1 THEN FALL_2019 = "IP+";
	ELSE IF INSPK="" AND FRISCO=1 AND CHEC="" AND MAIN="" AND INET="" THEN FALL_2019 = "HP ONLY";
	ELSE IF INSPK="" AND FRISCO=1 AND CHEC="" AND MAIN="" AND INET=1 THEN FALL_2019 = "HP+";
	ELSE IF INSPK="" AND FRISCO="" AND CHEC=1 AND MAIN="" AND INET="" THEN FALL_2019 = "CHEC";
	ELSE IF INSPK="" AND FRISCO="" AND CHEC=1 AND MAIN="" AND INET=1 THEN FALL_2019 = "CHEC+";
	ELSE IF INSPK=1 AND FRISCO=1 AND CHEC="" AND MAIN="" AND INET="" THEN FALL_2019 = "FRISCO";
	ELSE IF INSPK=1 AND FRISCO=1 AND CHEC="" AND MAIN="" AND INET=1 THEN FALL_2019 = "FRISCO+";
	ELSE IF (INSPK=1 OR FRISCO=1) AND CHEC=1 AND MAIN="" AND INET="" THEN FALL_2019 = "COLLIN";
	ELSE IF (INSPK=1 OR FRISCO=1) AND CHEC=1 AND MAIN="" AND INET=1 THEN FALL_2019 = "COLLIN+";
	ELSE IF MAIN=1 AND (INSPK=1 OR FRISCO=1 OR CHEC=1) THEN FALL_2019 = "MAIN";
	ELSE IF MAIN=1 THEN FALL_2019 = "MAIN ONLY";
	ELSE IF INET=1 THEN FALL_2019 = "INET ONLY";
	ELSE IF AOP=1 THEN FALL_2019="AOP";
	ELSE FALL_2019 = "NONE";
	KEEP EMPLID FALL_2019;
RUN; 
TITLE1 "FALL 2019";
PROC FREQ DATA=COUNTS_F19;
	TABLE FALL_2019;
RUN;

DATA FRISCO_ONLY;
SET COUNTS_F19;
IF FALL_2019 = "MAIN ON" THEN DELETE;
IF FALL_2019 = "INET ON" THEN DELETE;
RUN;





DATA FALL_SIMSTERM;
	SET "C:\Users\vac0019\OneDrive - UNT System\SAS Data Projects\FriscoEnrollment\Simsterm\s2019z_091819";
	*If admit_n = 3;
	*KEEP unt_taken_prgrss EMPLID FULLPART O_COUNTY_DESC;
RUN;

proc sort data=FRISCO_ONLY;
by emplid;
run;

proc sort data=fall_simsterm;
by emplid;
run;


data simsterm_one_frisco;
merge FRISCO_ONLY (in=a) fall_simsterm (in=b);
if a = 1 and b=1;
run;


DATA SIMS_COLLIN;
SET FALL_SIMSTERM;
IF O_COUNTY_DESC = "Collin";
RUN;
PROC SORT DATA=SIMS_COLLIN;
BY EMPLID;
RUN;

PROC SORT DATA=COUNTS_F19;
BY EMPLID;
RUN;

DATA FINAL_CTS;
	MERGE SIMS_COLLIN(IN=A) COUNTS_F19 (IN=B);
	BY EMPLID;
	IF A=1;
RUN;
DATA FINAL_CTS;
	SET FINAL_CTS;
	IF SPRING_2020 = "" THEN SPRING_2020 = "UNENROLLED";
RUN;

TITLE1 "Frequency of Student types the last two semesters.";
TITLE2 "FALL 2019 - CENSUS";
TITLE3;
TITLE4 'FULL-TIME STATUS FOR COLLIN COUNTY STUDENTS       ';
TITLE5 '=============================================================';

PROC FREQ DATA=FINAL_CTS ORDER=FREQ;
	TABLE FALL_2019*FULLPART/NOCUM NOROW NOCOL NOPERCENT;
RUN;


TITLE1 "Frequency of Student types the last two semesters.";
TITLE2 "FALL 2019 - CENSUS";
TITLE3; "Average Hours;"
TITLE4 'FULL-TIME STATUS FOR COLLIN COUNTY STUDENTS       ';
TITLE5 '=============================================================';
proc tabulate data=sims_collin;
class fullpart;
var unt_taken_prgrss;
table fullpart, unt_taken_prgrss*Mean n;
run;

TITLE1 "Frequency of Student types the last two semesters.";
TITLE2 "FALL 2019 - CENSUS";
TITLE3; "Admit Type;"
TITLE4 'COLLIN COUNTY STUDENTS       ';
TITLE5 '=============================================================';
proc freq data=simsterm_one_frisco;
table age*admit_n;
run;

title;
title "Freq Charts";
title2 "Admit Description by Group";
proc freq data=simsterm_one_frisco;
	table age*admit_n_desc/nocum nocol norow nopercent;
run;
title2 "College by Class Year";
proc freq data=simsterm_one_frisco;
	table group_descr*class_desc/nocum nocol norow nopercent;
run;
proc freq data=simsterm_one_frisco;
	table admit_n_desc*group_descr/ nocum nocol norow nopercent;
run;
title3 "Class by Age"; 
proc freq data=simsterm_one_frisco;
	table age*class_desc/nocum nocol norow nopercent;
run;


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
DATA COL_STUD_ENROLL_18Z;
	SET "C:\Users\vac0019\OneDrive - UNT System\SAS Data Projects\FriscoEnrollment\EnrollmentRecords\enrollement_dw_2018zag";
	WHERE LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK' );
	KEEP Emplid LOCATION;
RUN;

DATA COL_STUD_ENROLL_19C;
	SET "C:\Users\vac0019\OneDrive - UNT System\SAS Data Projects\FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019cag";
	WHERE LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK' );
	KEEP Emplid LOCATION;
RUN;
DATA COL_STUD_ENROLL_FY19;
	SET COL_STUD_ENROLL_18Z COL_STUD_ENROLL_19C;
	WHERE LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK' );
	KEEP Emplid LOCATION;
RUN;


PROC SORT DATA=COL_STUD_ENROLL_FY19 NODUPKEY;
	BY EMPLID;
RUN;

DATA ENROLL_TEMP_19Z;
SET "C:\Users\vac0019\OneDrive - UNT System\SAS Data Projects\FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019zag";
WHERE LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK' );
	KEEP EMPLID LOCATION;
	RUN;

DATA ENROLL_TEMP_20C;
SET "C:\Users\vac0019\OneDrive - UNT System\SAS Data Projects\FriscoEnrollment\EnrollmentRecords\enrollement_dw_2020C_CENSUS";
WHERE LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK' );
	KEEP EMPLID LOCATION;
	RUN;
DATA ENROLL_TEMP;
	SET ENROLL_TEMP_19Z ENROLL_TEMP_20C;
	*WHERE LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK' );
	KEEP Emplid LOCATION;
RUN;

PROC SORT DATA=ENROLL_TEMP NODUPKEY;
	BY EMPLID;
RUN;

DATA FALL2019Z_SIMSTERM;
	SET "C:\Users\vac0019\OneDrive - UNT System\SAS Data Projects\FriscoEnrollment\Simsterm\s2019ZAG";
	*If admit_n = 3;
	*KEEP unt_taken_prgrss EMPLID FULLPART O_COUNTY_DESC;
RUN;
DATA SPRING2020C_SIMSTERM;
	SET "C:\Users\vac0019\OneDrive - UNT System\SAS Data Projects\FriscoEnrollment\Simsterm\S2020C_CENSUS";
	*If admit_n = 3;
	*KEEP unt_taken_prgrss EMPLID FULLPART O_COUNTY_DESC;
RUN;
DATA FALL2018Z_SIMSTERM;
	SET "C:\Users\vac0019\OneDrive - UNT System\SAS Data Projects\FriscoEnrollment\Simsterm\s2018ZAG";	
	KEEP EMPLID NAME BIRTHDATE admit_n;
RUN;
DATA SPRING2019C_SIMSTERM;
	SET "C:\Users\vac0019\OneDrive - UNT System\SAS Data Projects\FriscoEnrollment\Simsterm\s2019CAG";	
	KEEP EMPLID NAME BIRTHDATE Admit_n;
RUN;

DATA FALL2018Z19C_SIMSTERM;
SET FALL2018Z_SIMSTERM SPRING2019C_SIMSTERM;
RUN;

PROC SORT DATA=FALL2018Z19C_SIMSTERM;
BY EMPLID;
RUN;

DATA ONE_1819_SIMSTERM;
 SET FALL2018Z19C_SIMSTERM;
 BY EMPLID;
 IF FIRST.EMPLID=1 THEN OUTPUT ONE_1819_SIMSTERM;
 RUN;

DATA FALL2019Z20C_SIMSTERM;
SET FALL2019Z_SIMSTERM SPRING2020C_SIMSTERM;
RUN;

PROC SORT DATA=FALL2019Z20C_SIMSTERM;
BY EMPLID;
RUN;

DATA ONE_1920_SIMSTERM;
 SET FALL2019Z20C_SIMSTERM;
 BY EMPLID;
 IF FIRST.EMPLID=1 THEN OUTPUT ONE_1920_SIMSTERM;
 RUN;

proc sort data=COL_STUD_ENROLL_FY19;
by emplid;
run;

proc sort data=ENROLL_TEMP;
by emplid;
run;


data FRISCO_NR_FY19;
merge COL_STUD_ENROLL_FY19 (in=a) ENROLL_TEMP (in=b);
BY EMPLID;
if a = 1 and b=0 then output FRISCO_NR_FY19;
run;

PROC SORT DATA=FRISCO_NR_FY19;
BY EMPLID;
RUN;

/*DATA ONE_NR_FY19;
  SET FRISCO_NR_FY19;
  BY EMPLID;
  IF FIRST.EMPLID =1 THEN OUTPUT ONE_NR_FY19;
  ELSE DELETE;
  RUN;
/*
PROC FREQ DATA=ONE_NR_FY19;
TABLE EMPLID;
RUN;
*/

PROC SORT DATA=ONE_1920_SIMSTERM;
BY EMPLID;
RUN;

PROC SORT DATA=FRISCO_NR_FY19;
BY EMPLID;
RUN;
*STUDENTS IN FRISCO FY19 BUT NOT RETURN FY20 TO FRISCO; 
DATA DENTON_ONLYFY20 NO_UNTFY20;
	MERGE ONE_1920_SIMSTERM (IN=A) FRISCO_NR_FY19 (IN=B);
	BY EMPLID;
	IF A=1 AND B=1 THEN OUTPUT DENTON_ONLYFY20;
	IF A=0 AND B=1 THEN OUTPUT NO_UNTFY20;
RUN;
PROC SORT DATA= ONE_1819_SIMSTERM;
BY EMPLID;
RUN;

DATA OUTPUT;
  MERGE NO_UNTFY20 (IN=A) ONE_1819_SIMSTERM (IN=B);
  BY EMPLID;
  IF A=1 AND B=1;
  KEEP EMPLID NAME BIRTHDATE;
  RUN;


DATA GRADFILE;
	SET "C:\Users\vac0019\OneDrive - UNT System\SAS Data Projects\FriscoEnrollment\Simsterm\GRADFILE_2019Z_ALL_CERTS";
	*If admit_n = 3;
	*KEEP unt_taken_prgrss EMPLID FULLPART O_COUNTY_DESC;
RUN;


PROC SORT DATA= GRADFILE;
BY EMPLID;
RUN;

DATA OUTPUT2;
  MERGE OUTPUT (IN=A) GRADFILE (IN=B);
  BY EMPLID;
  IF A=1 AND B=0;
  KEEP EMPLID NAME BIRTHDATE;
  RUN;













* TEST;

PROC SORT DATA = NO_UNTFY20;
BY EMPLID;
RUN;


DATA TEST;
	MERGE ONE_1920_SIMSTERM (IN=A) NO_UNTFY20 (IN=B);
	BY EMPLID;
	IF A=1 AND B=1 THEN OUTPUT TEST;
RUN;


PROC IMPORT OUT= WORK.MB_TABLE 
            DATAFILE= "C:\Users\vac0019\Desktop\MB TABLE2.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
DATA MB_TABLE2;
  SET MB_TABLE;
  ID=PUT(EMPLID,14.0);
  DROP EMPLID;
  RUN;
DATA MB_TABLE3;
  SET MB_TABLE2;
  EMPLID=SUBSTR(ID,7,8);
  DROP ID;
  RUN;





PROC SORT DATA = MB_TABLE3;
BY EMPLID;
RUN;


DATA TEST2;
	MERGE NO_UNTFY20 (IN=A) MB_TABLE3 (IN=B);
	BY EMPLID;
	IF A=1 AND B=1 THEN OUTPUT TEST2;
RUN;

DATA TEST3;
	MERGE DENTON_ONLYFY20 (IN=A) MB_TABLE3 (IN=B);
	BY EMPLID;
	IF A=1 AND B=1 THEN OUTPUT TEST3;
RUN;


DATA TEST4;
	MERGE ONE_1819_SIMSTERM (IN=A) MB_TABLE3 (IN=B);
	BY EMPLID;
	IF A=1 AND B=1 THEN OUTPUT TEST4;
RUN;


DATA TEST5;
	MERGE ONE_1920_SIMSTERM (IN=A) MB_TABLE3 (IN=B);
	BY EMPLID;
	IF A=1 AND B=1 THEN OUTPUT TEST5;
RUN;
DATA TEST6;
	MERGE COL_STUD_ENROLL_FY19 (IN=A) MB_TABLE3 (IN=B);
	BY EMPLID;
	IF A=1 AND B=1 THEN OUTPUT TEST6;
RUN;
PROC SORT DATA =enroll_temp;
BY EMPLID;
RUN;


DATA outputx;
	MERGE one_1920_simsterm (IN=A) enroll_temp (IN=B);
	BY EMPLID;
	IF A=1 AND B=1 THEN OUTPUT outputx;
RUN;

DATA TEST3;




proc freq data=outputx;
table admit_n;
run;



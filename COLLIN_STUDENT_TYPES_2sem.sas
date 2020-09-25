******************************************
PROGRAM TO REPORT FREQUENCY OF STUDENT
TYPES ACROSS 2 SEMESTERS.
BY JARED KELLY
LAST EDIT: 3/5/20

INPUT: TWO SETS OF ENROLLMENT
OUTPUT: FREQUENCY CHART OF STUDENT TYPES

EX.
FALL_2019	FREQ	CUMUL
MAIN		1993	1993
HP+ 		321		2314
HP ONLY		233		2547
ETC.....................

*****************************************;

********* CREATING STUDENT LISTS ****************;
%let SEMESTER1 = "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2019z_census"; 
%let SEMESTER2 = "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2020c_2census_dt";
DATA COLLIN_STUDENTS_F19;		*load the (Collin) enrollment from the first semester, removing all fields except emplid, return list of ids;
	SET &SEMESTER1;
	WHERE LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK');
	KEEP EMPLID;
RUN;
PROC SORT DATA=COLLIN_STUDENTS_F19 NODUPKEY;		* Remove duplicates to return true list of Collin students;
	BY EMPLID;
RUN;
DATA COLLIN_STUDENTS_S20;		* LOAD THE COLLIN ENROLLMENT FROM THE SECOND SEMESTER, REMOVING ALL BUT EMPLID, RETURN LIST OF STUDENT IDS;
	SET &SEMESTER2;
	WHERE LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK');
	KEEP EMPLID;
RUN;
PROC SORT DATA=COLLIN_STUDENTS_S20 NODUPKEY;		* Remove duplicates to return true list of Collin students;
	BY EMPLID;
RUN;
DATA COLLIN_STUDENTS_FY19;	*MERGE THE TWO STUDENT SETS INTO ONE;
	MERGE COLLIN_STUDENTS_F19 COLLIN_STUDENTS_S20;
	BY EMPLID;
RUN;
PROC SORT DATA=COLLIN_STUDENTS_FY19 NODUPKEY;		* Remove duplicates to return true list of Collin students;
	BY EMPLID;
RUN;

************** CAPTURING ENROLLMENT RELEVANT TO STUDENT LISTS **************************;
* These four steps recreate (and then sort) the enrollment reports we just finished filtering irrecognizable; 
PROC SORT DATA=&SEMESTER1 OUT=ENROLL_TEMP1; 
	BY EMPLID;		
RUN;
PROC SORT DATA=&SEMESTER2 OUT=ENROLL_TEMP2;
	BY EMPLID;
RUN;
DATA ENROLL_TEMP;
	SET ENROLL_TEMP1 ENROLL_TEMP2;
RUN;
PROC SORT DATA=ENROLL_TEMP;
	BY EMPLID;
RUN;

* Create a dataset with the intersection of enrollment and the Collin student list, 
	return an emplid and loc for each enrollment;
DATA COL_STUD_ENROLL_F19;			
	MERGE ENROLL_TEMP COLLIN_STUDENTS_FY19(IN=A);
	BY EMPLID;
	IF A=1;
	KEEP EMPLID LOCATION;
RUN;

************** CREATING STUDENT TYPES **************************;
* Create pseudo datasets for calculating student types based on where they enrolled;
DATA FRISCO_F19;		*Create dataset for all HP enrollments;
	SET COL_STUD_ENROLL_F19;
	WHERE LOCATION = "FRSC";
	FRISCO = 1;
	KEEP EMPLID FRISCO;
RUN;
PROC SORT DATA=FRISCO_F19 NODUPKEY;		* remove any duplicates (we don't need all the enrollments of a location, just 1 per id, so we know they qualify);
	BY EMPLID;
RUN;
DATA MAIN_F19;	*Create dataset for all main enrollments;
	SET COL_STUD_ENROLL_F19;
	WHERE LOCATION = "MAIN";
	MAIN = 1;
	KEEP EMPLID MAIN;
RUN;
PROC SORT DATA=MAIN_F19 NODUPKEY;		* remove any duplicates (we don't need all the enrollments of a location, just 1 per id, so we know they qualify);
	BY EMPLID;
RUN;
DATA AOP_F19;	*Create dataset for all AOP enrollments;
	SET COL_STUD_ENROLL_F19;
	WHERE LOCATION = "Z-AOP";
	AOP = 1;
	KEEP EMPLID AOP;
RUN;
PROC SORT DATA=AOP_F19 NODUPKEY;		* remove any duplicates (we don't need all the enrollments of a location, just 1 per id, so we know they qualify);
	BY EMPLID;
RUN;
DATA CHEC_F19;	*Create dataset for all CHEC enrollments;
	SET COL_STUD_ENROLL_F19;
	WHERE LOCATION = "Z-CHEC";
	CHEC = 1;
	KEEP EMPLID CHEC;
RUN;
PROC SORT DATA=CHEC_F19 NODUPKEY;		* remove any duplicates (we don't need all the enrollments of a location, just 1 per id, so we know they qualify);
	BY EMPLID;
RUN;
DATA INET_F19;	*Create dataset for all Internet enrollments;
	SET COL_STUD_ENROLL_F19;
	WHERE LOCATION = "Z-INET-TX";
	INET = 1;
	KEEP EMPLID INET;
RUN;
PROC SORT DATA=INET_F19 NODUPKEY;		* remove any duplicates (we don't need all the enrollments of a location, just 1 per id, so we know they qualify);
	BY EMPLID;
RUN;
DATA INSPK_F19;	*Create dataset for all IP enrollments;
	SET COL_STUD_ENROLL_F19;
	WHERE LOCATION = "Z-INSPK";
	INSPK = 1;
	KEEP EMPLID INSPK;
RUN;
PROC SORT DATA=INSPK_F19 NODUPKEY;		* remove any duplicates (we don't need all the enrollments of a location, just 1 per id, so we know they qualify);
	BY EMPLID;
RUN;

* Re-Merge Pseudo-datasets to have all variables in a single set;
DATA COUNTS_F19;		* Merge into a single dataset for classification;
	MERGE INSPK_F19 FRISCO_F19 CHEC_F19 MAIN_F19 AOP_F19 INET_F19;
	BY EMPLID;
RUN;

* based on all of the new variables, create a type variable (FALL_2019) for all relevant combinations;
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
	ELSE IF (INSPK=1 OR FRISCO=1 OR CHEC=1) AND MAIN=1 AND INET=1 THEN SPRING_2020 = "MAIN+";
	KEEP EMPLID FALL_2019;
RUN;

************** REPORTING **************************;
TITLE1 "Frequency of Collin Student types the last two semesters.";
TITLE2 "ALL STUDENTS IN THIS PROC CHART TOUCHED COLLIN";
PROC FREQ DATA=COUNTS_F19 ORDER=FREQ;
	TABLE FALL_2019/NOPERCENT;
RUN;

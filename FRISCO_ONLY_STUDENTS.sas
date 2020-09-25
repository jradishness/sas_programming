/* Final product: X axis=5 time points (3/16, 4/26, 6/6, 7/16, CENSUS)
					Y axis(LINE)=enrollment type (2020, 2019, GOAL)

*/

*** find frisco touch students;
data frisco_students;
	set enrollment;
	WHERE LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK');
	keep emplid;
RUN;
*remove duplicates;
proc sort data=frisco_students nodupkey;
	by emplid;
run;

*** find every other student*;
data other_students;
	set enrollment;
	WHERE LOCATION NOT IN ('FRSC', 'Z-CHEC', 'Z-INSPK', 'Z-INET-OS', 'Z-INET-TX');
	KEEP EMPLID;
RUN;
PROC SORT DATA=WORK.OTHER_STUDENTS NODUPKEY;
	BY EMPLID;
RUN;

*** CALCULATE FRISCO_ONLY;
DATA FRISCO_ONLY_STUDENTS;
	MERGE FRISCO_STUDENTS (IN=A) OTHER_STUDENTS (IN=B);
	BY EMPLID;
	IF A=1 AND B=0;
RUN;

*** GET STUDENT DATA;
DATA FRISCO_ONLY_STUDENT_DATA;
	MERGE FRISCO_ONLY_STUDENTS (IN=A) SIMSTERM;
	BY EMPLID;
	IF A=1;
RUN;



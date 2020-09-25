**************************************************
Program for counting the sections per term for a given course
*************************************************;


libname unt1 "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords";

%LET SUB = MGMT;		* easy-change Subject variable;
%LET CAT = 4660;		* easy-change Course Number variable;

DATA FY2019;
	SET UNT1.enrollement_dw_2019c_census UNT1.enrollement_dw_2018z_census UNT1.enrollement_dw_2019gim_census;	* Import relevant datasets;
RUN;
DATA TOTALFY2019;		* count once for total, count later for collin;
	SET FY2019;			* from total FY19 enrollment;
	where subject="&SUB" AND CATALOG_NBR="&CAT";		*filter by preset variables;
RUN;
PROC SORT DATA=TOTALFY2019 NODUPKEY;		*remove duplicate enrollments;
	BY STRM COURSE;
RUN;
TITLE "TOTAL &SUB &CAT";
PROC FREQ DATA=TOTALFY2019;		* report total sections by term;
	TABLE ACAD_TERM_DESC;
RUN;
DATA COLLINFY2019;	*count again for collin;
	SET FY2019;
	where subject="&SUB" AND CATALOG_NBR="&CAT" AND LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK');	*filter by preset variables and location;
	RUN;
PROC SORT DATA=COLLINFY2019 NODUPKEY;		*remove duplicate enrollments;
	BY STRM COURSE;
RUN;
TITLE "COLLIN &SUB &CAT";
PROC FREQ DATA=COLLINFY2019;		* report total sections by term;
	TABLE ACAD_TERM_DESC;
RUN;

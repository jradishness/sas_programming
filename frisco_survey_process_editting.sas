* Process the Frisco Student Survey;

libname untsim "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\Simsterm\";
libname surv "C:\Users\jrk0200\Desktop\Survey Data";

data filter;		*CREATE DATASET FROM HISTORIC SIMSTERM DATA;
	set simsterm
 	untsim.s2019z_091819
	untsim.dw_2019gimag_official
	untsim.dw_2019cag_official
	untsim.dw_2018zag_official
	untsim.dw_2018gimag_official
	untsim.dw_2018cag_official
	untsim.dw_2017zag_official
	untsim.dw_2017gimag_official
	untsim.dw_2017cag_official;
	keep emplid euid plan_descr acad_plan first_name last_name ACAD_GROUP GROUP_DESCR;
run;
proc sort data=filter nodupkey;		* REMOVE DUPLICATES FROM FILTER DATASET;
	by emplid;
run;

data survey_res;		* REFORMAT SURVEY DATA FOR PROCESSING;
	set surv.frisco_survey_processed;
	EMPLID2 = EMPLID;		* REFORMAT EMPLID TO MERGE;
	IF Q6_1 = 1 THEN HALL_PARK = 'HP';		* REFORMAT LOCATION VARS;
	IF Q6_2 = 1 THEN INSP_PARK = 'IP';
	IF Q6_3 = 1 THEN CHEC = 'CHEC';
	IF Q6_4 = 1 THEN ONLINE = 'OL';
	IF Q6_5 = 1 THEN MAIN = 'MAIN';
	LONG_SEM = Q10;						* REFORMAT QUESTION ABOUT CLASSLOAD;
	SUM_SEM = Q11;
	IF Q4_1_1 = 1 THEN PREF_MON = 'MORN';		* REFORMATTING DATE/TIME VAR;
	ELSE IF Q4_1_1 = 2 THEN PREF_MON = 'EAFT';
	ELSE IF Q4_1_1 = 3 THEN PREF_MON = 'LAFT';
	ELSE IF Q4_1_1 = 4 THEN PREF_MON = 'EVEN';
	ELSE PREF_MON = 'NO';
	IF Q4_1_2 = 1 THEN PREF_TUE = 'MORN';
	ELSE IF Q4_1_2 = 2 THEN PREF_TUE = 'EAFT';
	ELSE IF Q4_1_2 = 3 THEN PREF_TUE = 'LAFT';
	ELSE IF Q4_1_2 = 4 THEN PREF_TUE = 'EVEN';
	ELSE PREF_TUE = 'NO';
	IF Q4_1_3 = 1 THEN PREF_WED = 'MORN';
	ELSE IF Q4_1_3 = 2 THEN PREF_WED = 'EAFT';
	ELSE IF Q4_1_3 = 3 THEN PREF_WED = 'LAFT';
	ELSE IF Q4_1_3 = 4 THEN PREF_WED = 'EVEN';
	ELSE PREF_WED = 'NO';
	IF Q4_1_4 = 1 THEN PREF_THUR = 'MORN';
	ELSE IF Q4_1_4 = 2 THEN PREF_THUR = 'EAFT';
	ELSE IF Q4_1_4 = 3 THEN PREF_THUR = 'LAFT';
	ELSE IF Q4_1_4 = 4 THEN PREF_THUR = 'EVEN';
	ELSE PREF_THUR = 'NO';
	IF Q4_1_5 = 1 THEN PREF_FRI = 'MORN';
	ELSE IF Q4_1_5 = 2 THEN PREF_FRI = 'EAFT';
	ELSE IF Q4_1_5 = 3 THEN PREF_FRI = 'LAFT';
	ELSE IF Q4_1_5 = 4 THEN PREF_FRI = 'EVEN';
	ELSE PREF_FRI = 'NO';
	IF Q4_1_6 = 1 THEN PREF_SAT = 'MORN';
	ELSE IF Q4_1_6 = 2 THEN PREF_SAT = 'EAFT';
	ELSE IF Q4_1_6 = 3 THEN PREF_SAT = 'LAFT';
	ELSE IF Q4_1_6 = 4 THEN PREF_SAT = 'EVEN';
	ELSE PREF_SAT = 'NO';
	IF Q4_1_7 = 1 THEN PREF_SUN = 'MORN';
	ELSE IF Q4_1_7 = 2 THEN PREF_SUN = 'EAFT';
	ELSE IF Q4_1_7 = 3 THEN PREF_SUN = 'LAFT';
	ELSE IF Q4_1_7 = 4 THEN PREF_SUN = 'EVEN';
	ELSE PREF_SUN = 'NO';
	COURSE1 = CATX("-", UPCASE(Q3_1_1), Q3_1_2);	* REFORMAT COURSE VARS;
	COURSE1TYPE = PROPCASE(Q3_1_3);
	COURSE2 = CATX("-", UPCASE(Q3_2_1), Q3_2_2);
	COURSE2TYPE = PROPCASE(Q3_2_3);
	COURSE3 = CATX("-", UPCASE(Q3_3_1), Q3_3_2);
	COURSE3TYPE = PROPCASE(Q3_3_3);
	COURSE4 = CATX("-", UPCASE(Q3_4_1), Q3_4_2);
	COURSE4TYPE = PROPCASE(Q3_4_3);
	COURSE5 = CATX("-", UPCASE(Q3_5_1), Q3_5_2);
	COURSE5TYPE = PROPCASE(Q3_5_3);
	COURSE6 = CATX("-", UPCASE(Q3_6_1), Q3_6_2);
	COURSE6TYPE = PROPCASE(Q3_6_3);
	SURV_DATE_TIME = RECORDEDDATE;		* MOVE METADATA TO END;
	UNIQUE_ID = RESPONSEID;			* MOVE METADATA TO END;
	DROP DISTRIBUTIONCHANNEL DURATION__IN_SECONDS_ ENDDATE EXTERNALREFERENCE
	FINISHED IPADDRESS LOCATIONLATITUDE LOCATIONLONGITUDE PROGRESS EMPLID
	RecipientEmail RecipientFirstName RecipientLastName UserLanguage
	StartDate STATUS Q4_1_1 Q4_1_2 Q4_1_3 Q4_1_4 Q4_1_5 Q4_1_6 Q4_1_7 Q3_1_1
	Q3_1_2 Q3_2_2 Q3_2_1 Q3_3_2 Q3_3_1 Q3_4_2 Q3_4_1 Q3_5_2 Q3_5_1 Q3_1_3
	Q3_2_3 Q3_3_3 Q3_4_3 Q3_5_3 Q3_6_1 Q3_6_2 Q3_6_3 RECORDEDDATE RESPONSEID
	Q10 Q11 Q6_1 Q6_2 Q6_3 Q6_4 Q6_5 Q3_5_3___Parent_Topics Q3_5_3___Topics;
run;		* DROP THE USELESS STUFF;

/*
proc contents data=SURVEY_RES;		* CHECK ON CONTENTS (VARS) OF DATASET;
run;
*/
/*
PROC FREQ DATA=SURVEY_RES ORDER=FREQ;   * QUERY THE VARS OF A DATASET;
	TABLE EMPLID2;
RUN;
*/

PROC SORT DATA=SURVEY_RES;		* SORT SURVEY DATA FOR MERGE;
	BY EMPLID2;
RUN;
proc sort data=filter out=filtered;		*SORT SIMSTERM ARCHIVE FOR MERGE;
	by emplid;
run;

data filtered;		*REFORMAT FILTERED (EMPLID) FOR MERGE;
	set filtered;
	EMPLID2 = INPUT(EMPLID, 8.);
	drop EUID EMPLID;
run;

DATA SURVEY;		*MERGE SURVEY RESULTS WITH STUDENT DATA;
	MERGE FILTERED SURVEY_RES (IN=A);
	BY EMPLID2;
	IF A=1;
RUN;

DATA EIS_RES;
	SET SURVEY;
	WHERE LAST_NAME NE "";
RUN;

PROC SORT DATA=EIS_RES NODUPKEY;
	BY EMPLID2;
RUN;

PROC TRANSPOSE DATA=SURVEY OUT=COURSES_TRNSPSD;
	BY EMPLID2;
	VAR COURSE1 COURSE2 COURSE3 COURSE4 COURSE5 COURSE6;
RUN;

DATA COURSES_TRNSPSD_CLN;		* CLEAN UP THE TRANSPOSED DATA;
	SET COURSES_TRNSPSD;
	IF COL1 = '' THEN DELETE;
	ELSE IF UPCASE(COL1) = "NA-NA" THEN DELETE;
	ELSE IF UPCASE(COL1) = "N/A-N/A" THEN DELETE;
	ELSE IF UPCASE(COL1) = "---" THEN DELETE;
	ELSE IF UPCASE(COL1) = ".-." THEN DELETE;
	ELSE IF UPCASE(COL1) = "0-00" THEN DELETE;
	ELSE IF UPCASE(COL1) = "0-0" THEN DELETE;
	ELSE IF UPCASE(COL1) = "NA-000" THEN DELETE;
	ELSE IF UPCASE(COL1) = "H-Q" THEN DELETE;
	ELSE IF UPCASE(COL1) = "G-Q" THEN DELETE;
	ELSE IF UPCASE(COL1) = "DONT-1" THEN DELETE;
	ELSE IF UPCASE(COL1) = "NEED-1" THEN DELETE;
	ELSE IF UPCASE(COL1) = "MORE-1" THEN DELETE;
	ELSE IF UPCASE(COL1) = "N/A" THEN DELETE;
	ELSE IF UPCASE(COL1) = "-" THEN DELETE;
	KEEP EMPLID2 COL1;
RUN;

*prepare data for college count;
DATA SURVEY2;			* SURVEY2 is the results with emplids in simsterm;
	SET SURVEY;
	WHERE LAST_NAME NE "";
	LENGTH LOC_PREF $15.;
	IF (HALL_PARK = 'HP' OR INSP_PARK = 'IP') AND ONLINE = 'OL' AND CHEC NE 'CHEC' THEN LOC_PREF = 'UNT_FRISCO+';
	ELSE IF (HALL_PARK = 'HP' OR INSP_PARK = 'IP') AND CHEC = 'CHEC' AND ONLINE NE 'OL' THEN LOC_PREF = 'COLLIN';
	ELSE IF ((HALL_PARK = 'HP' OR INSP_PARK = 'IP') AND CHEC = 'CHEC') AND ONLINE = 'OL' THEN LOC_PREF = 'COLLIN+';
	ELSE IF (HALL_PARK = 'HP' OR INSP_PARK = 'IP' OR CHEC = 'CHEC') AND MAIN = 'MAIN' THEN LOC_PREF = 'INDIFFERENT';
	ELSE IF HALL_PARK = 'HP' OR INSP_PARK = 'IP' THEN LOC_PREF = 'UNT_FRISCO';
	ELSE IF HALL_PARK NE 'HP' AND INSP_PARK NE 'IP' AND CHEC = 'CHEC' AND MAIN NE 'MAIN' AND ONLINE NE 'OL' THEN LOC_PREF = 'CHEC';
	ELSE IF HALL_PARK NE 'HP' AND INSP_PARK NE 'IP' AND CHEC = 'CHEC' AND MAIN NE 'MAIN' AND ONLINE = 'OL' THEN LOC_PREF = 'CHEC+';
	ELSE IF HALL_PARK NE 'HP' AND INSP_PARK NE 'IP' AND CHEC NE 'CHEC' AND MAIN NE 'MAIN' AND ONLINE = 'OL' THEN LOC_PREF = 'ONLINE';
	ELSE IF HALL_PARK NE 'HP' AND INSP_PARK NE 'IP' AND CHEC NE 'CHEC' AND MAIN = 'MAIN' AND ONLINE NE 'OL' THEN LOC_PREF = 'DENTON';
	ELSE IF HALL_PARK NE 'HP' AND INSP_PARK NE 'IP' AND CHEC NE 'CHEC' AND MAIN = 'MAIN' AND ONLINE = 'OL' THEN LOC_PREF = 'DENTON+';
	ELSE LOC_PREF = "UNCONSIDERED";
RUN;

/*
Proc freq data=survey2;
	table loc_pref;
run;
*/

PROC SORT DATA=SURVEY2 OUT=SURVEY3;
	BY ACAD_PLAN;
RUN;

DATA SURVEY_SANS_COURSES;
	SET SURVEY2;
	DROP COURSE1 COURSE1TYPE COURSE2 COURSE2TYPE COURSE3 COURSE3TYPE COURSE4 COURSE4TYPE COURSE5 COURSE5TYPE COURSE6 COURSE6TYPE;
RUN; 
PROC SORT DATA=SURVEY_SANS_COURSES;
	BY EMPLID2;
RUN;
PROC SORT DATA=COURSES_TRNSPSD_CLN;
	BY EMPLID2;
RUN;

DATA SURVEY_TRNSPSD;
	MERGE COURSES_TRNSPSD_CLN SURVEY_SANS_COURSES;
	BY EMPLID2;
RUN;
/*DATA SURVEY3;*/
/*	SET SURVEY2;*/
/*	WHERE LOC_PREF = "UNCONSIDERED";*/
/*	KEEP LOC_PREF HALL_PARK INSP_PARK CHEC ONLINE MAIN;*/
/*RUN;*/


*HALL_PARK = 'HP';
*INSP_PARK = 'IP';
*CHEC = 'CHEC';
*ONLINE = 'OL';
*MAIN = 'MAIN';

title1 "Course Frequecy Results from Frisco Student Course Request Survey, Fall 2019";
ods tagsets.excelxp file="C:\Users\jrk0200\Desktop\Survey Data\SURVEY_%sysfunc(today(),mmddyy6.).xml" style=XLSANSPRINTER
    options( embedded_titles='yes' AUTOFIT_HEIGHT='YES' sheet_interval='none'
             sheet_name="Course_Freq" suppress_bylines='no'
			 ABSOLUTE_COLUMN_WIDTH='16,10');

PROC FREQ DATA=COURSES_TRNSPSD_CLN ORDER=FREQ;
	TABLE COL1 / nopercent nocum;
RUN;

title;
title1 "Respondent Count from Frisco Student Course Request Survey, Fall 2019";
ods tagsets.excelxp options( embedded_titles='yes' AUTOFIT_HEIGHT='YES' sheet_interval='none'
             sheet_name="CxL_Freq" suppress_bylines='no'
			 ABSOLUTE_COLUMN_WIDTH='26,10,10,10,10,10,10,10,10');

PROC FREQ DATA=SURVEY2 ORDER=FREQ;
	TABLE group_descr*loc_pref / nopercent nocum norow nocol;
RUN;


title;
title1 "Prefences of Respondents from Frisco Student Course Request Survey, Fall 2019";
ods tagsets.excelxp options( embedded_titles='no' AUTOFIT_HEIGHT='YES' sheet_interval='none'
             sheet_name="L&C_Freq" suppress_bylines='no'
			 ABSOLUTE_COLUMN_WIDTH='26,10');
title1 "Location Preferences of Respondents from Frisco Student Course Request Survey, Fall 2019";
PROC FREQ DATA=SURVEY2 ORDER=FREQ;
	TABLE loc_pref / nopercent nocum;
RUN;
title1 "College of Respondents from Frisco Student Course Request Survey, Fall 2019";
PROC FREQ DATA=SURVEY2 ORDER=FREQ;
	TABLE group_descr / nopercent nocum;
RUN;
title;
title1 "Major Degree Plan of Respondents from Frisco Student Course Request Survey, Fall 2019";
ods tagsets.excelxp options( embedded_titles='yes' AUTOFIT_HEIGHT='YES' sheet_interval='none'
             sheet_name="Prog_Freq" suppress_bylines='no'
			 ABSOLUTE_COLUMN_WIDTH='26,10');
PROC FREQ DATA=SURVEY3 ORDER=FREQ;
	TABLE ACAD_PLAN / nopercent nocum;
RUN;
title;
title1 "Major Degree Plan of Respondents from Frisco Student Course Request Survey (with self-identification), Fall 2019";
ods tagsets.excelxp options( embedded_titles='no' AUTOFIT_HEIGHT='YES' sheet_interval='none'
             sheet_name="Prog_Freq*" suppress_bylines='no'
			 ABSOLUTE_COLUMN_WIDTH='26,10');
PROC FREQ DATA=SURVEY3 ORDER=FREQ;
	BY ACAD_PLAN;
	TABLE Q2 / nopercent nocum;
RUN;
title;
title1 "Raw Data from Frisco Student Course Request Survey (with EIS data), Fall 2019";
ods tagsets.excelxp options( embedded_titles='no' AUTOFIT_HEIGHT='YES' sheet_interval='none'
             sheet_name="Raw_Data" suppress_bylines='no'
			 ABSOLUTE_COLUMN_WIDTH='10,20,9,10,10,10,10,10,10,10,10,10');
PROC PRINT DATA=SURVEY3 noobs;
RUN;
ods tagsets.excelxp close;

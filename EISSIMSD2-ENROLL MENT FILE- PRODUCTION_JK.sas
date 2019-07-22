%let curdate = %sysfunc(today(),mmddyy6.);	* CURRENT DATE;
%let fnamesave = "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\ENROLLEMENT_DW_2019Z_&curdate.";	* CURRENT SAVE DIRECTORY;


LIBNAME MYORALIB oracle user='meb0044' password='Prahacib$17' path='LSRDSPD'  SCHEMA=STRDSOWNER;
run;

/* 1CURRENT  2CENSUS_DT  2REVIEW  3OFFICIAL 0AFT_GRADE*/
/* 2REVIEW is period after census date and before official. Daily changes from clean-up can be seen*/


DATA SIMSTERM_ORIG;
  SET MYORALIB.NTSR_IR_STU_ENRL_ARCH;
  IF STRM='1198' AND DW_RUN_DESC='1CURRENT';
  RUN;

/**check to see if grades populate if running after grades file**;
proc freq data = simsterm_orig;
table crse_grade_off;
run;  */
**********************************;

DATA SIMSTERM_ORIG;
  SET SIMSTERM_ORIG;
  TOTAL_SCH=UNT_TAKEN*ENRL_TOT;
  COURSE = (TRIM(LEFT(SUBJECT))||'-'||(TRIM(LEFT(CATALOG_NBR)))||'-'||(TRIM(CLASS_SECTION)));
  COURSE2 = (TRIM(LEFT(SUBJECT))||'-'||(TRIM(LEFT(CATALOG_NBR))));
RUN;

DATA ENROLLMENT;
SET SIMSTERM_ORIG;
IF INSTITUTION NE 'DL773';
RUN;


/******FOR AFTER GRADES ONLY*******

  PROC FREQ DATA = SIMSTERM;
  TABLE STRM CRSE_GRADE_OFF; **THERE SHOULD BE GRADES AT EACH ROW, DOUBLE CHECK***;
  RUN;

data test;
set simsterm;
if CRSE_GRADE_OFF in (' ');
run;*/


DATA &fnamesave;      **for census format ...2010z_census**;
  SET ENROLLMENT;														**date format....090510**mmddyy6*******;
   	RUN;															** summer =  gim  : 
																**   _20th_day**;
																**UNT Courses only**;
																**for census format ...2010z_census**;
																**date format....090510*******;
																**2012gimag_w_dal**;


	****dallas data no longer avail***;
/*DATA 'S:\IRE\TRANSFER\DATA WAREHOUSE\ENROLLEMENT_DW_2015z_082515_w_dal';  **dallas no longer in file, spring 2015*;    
 SET SIMSTERM_ORIG;														
   	RUN;
*/




/*****EXPORTING FOR MANIPULATION IN EXCEL****
	PROC EXPORT DATA=WORK.SIMSTERM OUTFILE='S:\IRE\Ad Hoc\2017-18\Enrollment Management\1718-1082_Easley_Summer2018_051418.XLSX' DBMS=XLSX;
   SHEET=SUMMER18_051418;
RUN;

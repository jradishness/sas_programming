**********************************************************
**														**
**			Report of Denton Courses taken by 			**
**			Frisco "Touch" students						**
**														**
**			Tab 1: Courses taken in Denton				**
**			by # of courses taken in Denton				**
**														**
**														**
**			Updated:	4/28/20	jrk0200					**
**														**
**														**
**														**
*********************************************************;
* file source (ENROLLMENT);
%let enrollment = "S:\UIS\Shared\SAS Data Projects\enrollment_records\ENROLLEMENT_DW_2020z_%sysfunc(today(),mmddyy6.)";
%let input_fname = "C:\Users\jrk0200\UNT System\Special Projects Frisco Data Team - General\DAIR reports - with roster\4-27FriscoCHEC_Weekly_Summary_Summer_Fall.xlsx";

PROC IMPORT OUT= WORK.CASSIE 
            DATAFILE= &input_fname 
            DBMS=EXCEL REPLACE;
     RANGE="COLLIN_STUDENTS_FALL$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

data majority;
	set cassie;
	where collin_status='MAJORITY COLLIN';
	keep emplid;
run;
proc sort data=majority;
	by emplid;
run;
*** GET FRISCO STUDENT ENROLLMENT ***;
data enrollment;
	set &enrollment;
run;
data frisco_students; * CAPTURE FRISCO ENROLLMENT IDS; 
	set enrollment;
	where location IN ('FRSC', 'Z-CHEC', 'Z-INSPK');
	keep emplid;
run;
proc sort data=frisco_students nodupkey; *REMOVE DUPS TO HAVE A LIST OF FRISCO TOUCH STUDENTS;
	by emplid;
run;
proc sort data=enrollment out=enroll_sorted; *RE-ACCESS ENROLLMENT TO MERGE WITH FRISCO STUDENTS;
	by emplid;
run;
data frisco_stud_enrollment; * CAPTURE ALL ENROLLMENTS (AT ALL CAMPUSES) BY FRISCO STUDENTS;
	merge frisco_students(in=a) enroll_sorted;
	by emplid;
	if a=1;
run;

*** COUNT COURSES TAKEN ON MAIN CAMPUS BY FRISCO STUDENTS;
data frisco_stud_enroll_main; *CAPTURE MAIN ENROLLMENT BY FRISCO STUDENTS;
	set frisco_stud_enrollment;
	where location = "MAIN";
	MAIN_COUNT=1;
	keep emplid location MAIN_COUNT;
run;
proc sort data=frisco_stud_enroll_main; * SORT BY EMPLID FOR COUNTING;
	by emplid;
run;
data frisco_stud_count_main; * COUNT THE OBSERVATIONS (ENROLLMENTS) FOR MAIN;
	set frisco_stud_enroll_main;
	by emplid;
	if last.emplid;
	DENTON = _n_-sum(lag(_n_), 0);
	do _n_=1 to DENTON;
		set frisco_stud_enroll_main;
		frisco_stud_count_main=profile/count;
		output;
	end;
	keep EMPLID DENTON;
run;
proc sort data=frisco_stud_count_main nodupkey; *REMOVE DUPLICATES TO COUNT STUDENTS;
	by emplid;
run;
data frisco_denton_enroll_sorted;
	set enroll_sorted;
	where location = "MAIN";
run;

* Internet;
data frisco_stud_enroll_inet; *CAPTURE MAIN ENROLLMENT BY FRISCO STUDENTS;
	set frisco_stud_enrollment;
	where location IN ("Z-INET-OS","Z-INET-TX");
	INET_COUNT=1;
	keep emplid INET_COUNT;
run;
proc sort data=frisco_stud_enroll_inet; * SORT BY EMPLID FOR COUNTING;
	by emplid;
run;
data frisco_stud_count_inet; * COUNT THE OBSERVATIONS (ENROLLMENTS) FOR MAIN;
	set frisco_stud_enroll_inet;
	by emplid;
	if last.emplid;
	ONLINE = _n_-sum(lag(_n_), 0);
	do _n_=1 to ONLINE;
		set frisco_stud_enroll_inet;
		frisco_stud_count_inet=profile/count;
		output;
	end;
	keep EMPLID ONLINE;
run;
proc sort data=frisco_stud_count_inet nodupkey; *REMOVE DUPLICATES TO COUNT STUDENTS;
	by emplid;
run;
data frisco_inet_enroll_sorted;
	set enroll_sorted;
	where location IN ("Z-INET-OS","Z-INET-TX");
run;

data frisco_enroll_denton;
	merge frisco_stud_count_main (in=a) frisco_denton_enroll_sorted;
	by emplid;
	if a=1;
	COURSE3=catx(" - ", Course, crse_descr);
	LABEL COURSE3='Denton Course'
		  DENTON='Number of Denton Courses';
run;

data frisco_enroll_inet;
	merge frisco_stud_count_inet (in=a) frisco_denton_enroll_sorted;
	by emplid;
	if a=1;
	COURSE3=catx(" - ", Course, crse_descr);
	LABEL COURSE3='Online Course'
		  ONLINE='Number of Online Courses';
run;

data frisco_enroll_majority;
	merge majority (in=a) frisco_enroll_denton;
	by emplid;
	if a=1;
run;
*** REPORTING ***:

title1 "DENTON COURSES by Frisco Students - %sysfunc(today(),mmddyy10.)";
ods _all_ close;
ods tagsets.excelxp file="C:\Users\jrk0200\UNT System\Special Projects Frisco Data Team - General\SPFDT\DENTON_CT_OF_FRISCO_%sysfunc(today(), mmddyy6).xml" style=XLsansprinter;

ods tagsets.excelxp options(embed_titles_once='yes' autofit_height='yes' sheet_interval='none'
			 sheet_name='Touch Students' absolute_column_width='30,4,4,4,4,4,4,4,8');

proc freq data=frisco_enroll_Denton order=freq;
	table course3*denton/nocum nopercent norow nocol out=work.freq outcum;
run;

ods tagsets.excelxp options(embed_titles_once='yes' autofit_height='yes' sheet_interval='none'
			 sheet_name='Majority Students' absolute_column_width='30,4,4,4,4,4,4,4,8');

proc freq data=frisco_enroll_majority order=freq;
	table course3*denton/nocum nopercent norow nocol out=work.freq outcum;
run;

ods tagsets.excelxp options(embed_titles_once='yes' autofit_height='yes' sheet_interval='none'
			 sheet_name='Online Courses(Touch)' absolute_column_width='30,4,4,4,4,4,4,4,8');

proc freq data=frisco_enroll_inet order=freq;
	table course3*online/nocum nopercent norow nocol out=work.freq outcum;
run;

ods _all_ close;
ods listing;

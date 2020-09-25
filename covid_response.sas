**********************************************

Program to backtrace known close associates of
anyone affected by the COVID-19 outbreak.

Input: Emplid of affected
Output: Table of close associates with contact info


by Jared Kelly
Last edit: 3/12/20

***********************************************;
* Input Emplid of COVID affected student here;
%let affected = 11199620; *<<<<<<<<<<<<<<<<;

*Path to simsterm data (in case of change of machine used to run report);
%let simsterm = "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\Simsterm\s2020c_2census_dt";
*Path to enrollment data;
%let enrollment = "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\EnrollmentRecords\enrollement_dw_2020c_2census_dt";
*Path to report save file;
%let fname_save = "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\covid\&affected._covid.xml";

*capture enrollment data related to affected;
data affected_enroll;		
	set &enrollment.;
	where emplid = &affected.;
run;

* create list of courses taken by affected;
data affected_courses;		
	set affected_enroll;
	keep course;
run;

*sort affected_courses for merge;
proc sort data=affected_courses;	
	by course;
run;

*sort enrollment for merge;
proc sort data=&enrollment. out=sorted_enroll;      
	by course;
run;

*gather all enrollments for first-level associates of affected;
data first_level_enroll;		
	merge affected_courses(in=a) sorted_enroll;
	by course;
	if a = 1;
run;

*gather ids for first-level associates of affected;
data first_level_ids;
	set first_level_enroll;
	keep emplid;
run;

*merge simsterm with enrollment to report first-level;
data simsterm;
	set &simsterm.;
run;

*sort first_level_enroll for merge;
proc sort data=first_level_enroll;
	by emplid;
run;

*sort simsterm for merge;
proc sort data=simsterm;
	by emplid;
run;

*merge data with simsterm to report;
data first_level_enr_sim;
	merge first_level_enroll(in=a) simsterm;
	by emplid;
	if a=1;
	instr_sort_name = catx(", ", instr_last_name, instr_first_name);
	keep instr_sort_name course emplid instr_emplid sort_name class email_address cell_phone_nmbr main_phone_nmbr mail_address1 mail_city mail_state mail_postal;
run;
proc sort data=first_level_enr_sim;
	by sort_name;
run;

proc template;
 	define style styles.XLsansPrinter;
 	parent = styles.sansPrinter;

 	* Change attributes of the column headings;

 	style header from header /
 	font_size = 11pt
 	just = center
 	BACKGROUND=GREEN
 	vjust = bottom;
 	end;
run;

PROC FORMAT;
	VALUE LEVEL
	1='Freshman'
	2='Sophomore'
	3='Junior'
	4='Senior'
	5='Post-Bac'
	6='Masters'
	7='Doctoral';
RUN;

title1 "First-Level Interaction with student id: &affected.";
ods tagsets.excelxp file=&fname_save style=XLsansprinter
	options(embedded_titles='yes' autofit_height='yes' sheet_interval='none'
			sheet_name='lvl1' absolute_column_width='');
proc report data=first_level_enr_sim HEADLINE HEADSKIP;
	column ('Associate' emplid sort_name class email_address cell_phone_nmbr main_phone_nmbr mail_address1 mail_city mail_state mail_postal)
			('Course With Affected' course instr_sort_name instr_emplid);
	DEFINE emplid / DISPLAY 'Student ID';
	DEFINE sort_name / ORDER 'Name';
	DEFINE class / DISPLAY 'Level' FORMAT=LEVEL.;
	DEFINE email_address / DISPLAY 'Email';
	DEFINE cell_phone_nmbr / DISPLAY 'Cell';
	DEFINE main_phone_nmbr / DISPLAY "Other Phone";
	DEFINE mail_address1 / DISPLAY "Street Address";
	DEFINE mail_city / DISPLAY 'City';
	DEFINE mail_state / DISPLAY 'State';
	DEFINE mail_postal / DISPLAY 'Zip Code';
	DEFINE course / DISPLAY 'Course';
	DEFINE instr_sort_name / DISPLAY 'Instructor';
	DEFINE instr_emplid / DISPLAY 'Instructor ID';
run;
ods tagsets.excelxp close;
title;



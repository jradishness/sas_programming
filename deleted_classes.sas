*WHAT'S MISSING?;

%let week1=enroll.Enrollement_dw_2020z_042620;
%let week2=enroll.Enrollement_dw_2020z_050420;
%let simsterm="S:\UIS\Shared\sas_data_projects\simsterm_records\s2020z_042620";

data week1;
	set &week1.;
	WHERE LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK');
run;
proc sort data=week1;
	by course;
run;
data week1_courses;
	set week1;
	keep course;
run;
proc sort data=week1_courses nodupkey;
	by course;
run;
data week2;
	set &week2.;
	WHERE LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK');
	keep course;
run;
proc sort data=week2 nodupkey;
	by course;
run;
data deleted;
	merge week1_courses(in=a) week2(in=b);
	by course;
	if a=1 and b=0;
run;

data deleted_students;
	merge deleted (in=a) week1;
	by course;
	if a=1;
	keep emplid course;
run;
proc sort data=deleted_students;
	by emplid;
run;

data deleted_students_info;
	merge deleted_students (in=a) &simsterm.;
	by emplid;
	if a=1;
	keep emplid course name class_desc FULLPART acad_plan email_address;
run;

proc sort data=deleted_students_info;
	by emplid;
run;

*ods pdf file="C:\Users\jrk0200\UNT System\Special Projects Frisco Data Team - General\SPFDT\deleted_students_%sysfunc(today(),mmddyy6.).pdf";
ods pdf file="C:\Users\jrk0200\UNT System\Special Projects Frisco Data Team - General\SPFDT\deleted_students_050420.pdf";
title "Report of Courses Removed from Frisco";
proc print data=deleted;
run;
title "Report of Students Removed from Frisco Courses";
proc print data=deleted_students_info;
run;
ods pdf close;


data frisco_students;
	set C:\Users\vac0019\OneDrive - UNT System\SAS Data Projects\FriscoEnrollment\EnrollmentRecords\ENROLLEMENT_DW_2020C_110719;
	where location IN ('FRSC', 'Z-CHEC', 'Z-INSPK');
	keep emplid;
run;

data ENROLLED SORTED;
	set C:\Users\vac0019\OneDrive - UNT System\SAS Data Projects\FriscoEnrollment\EnrollmentRecords\ENROLLEMENT_DW_2020C_110719;
	*where location IN ('FRSC', 'Z-CHEC', 'Z-INSPK');
	keep emplid;
run;
proc sort data=frisco_students nodupkey;
	by emplid;
run;
proc sort data=enrollment out=enroll_sorted;
	by emplid;
run;
data frisco_stud_enrollment;
	merge frisco_students(in=a) enroll_sorted;
	by emplid;
	if a=1;
run;
data frisco_stud_enroll_main;
	set frisco_stud_enrollment;
	where location = "MAIN";
	MAIN_COUNT=1;
	keep emplid location MAIN_COUNT;
run;
proc sort data=frisco_stud_enroll_main;
	by emplid;
run;
data frisco_stud_count_main;
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
proc sort data=frisco_stud_count_main nodupkey;
	by emplid;
run;
data frisco_denton_enroll_sorted;
	set enroll_sorted;
	where location = "MAIN";
run;
data frisco_enroll_denton;
	merge frisco_stud_count_main (in=a) frisco_denton_enroll_sorted;
	by emplid;
	if a=1;
	COURSE3=catx(" - ", Course, crse_descr);
run;




title1 "DENTON COURSES by Frisco Students - %sysfunc(today(),mmddyy10.)";
ods _all_ close;
ods tagsets.excelxp file="C:\Users\vac0019\OneDrive - UNT System\SAS Data Projects\FriscoEnrollment\DENTON_CT_OF_FRISCO_%sysfunc(today(), mmddyy6).xml" style=XLsansprinter;

ods tagsets.excelxp options(embed_titles_once='yes' autofit_height='yes' sheet_interval='none' 
			 absolute_column_width='30,6,6,6,6,6,6,8');

proc freq data=frisco_enroll_Denton order=freq;
	table course3*denton/nocum nopercent norow nocol;
run;
ods _all_ close;
ods listing;
	

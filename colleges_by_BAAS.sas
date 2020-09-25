************************************************************************

Program to report percentages of schools in which BAAS Students are
taking enrollments.

Input: Simsterm and ENROLLMENT
Output: Proc Freq of Colleges with percentages

By: Jared Kelly
Creation Date: 6/21/20

***********************************************************************;

libname enroll "S:\UIS\Shared\sas_data_projects\enrollment_records";
libname simst "S:\UIS\Shared\sas_data_projects\simsterm_records";

*enroll.Enrollement_dw_2020z_%SYSFUNC(TODAY(), MMDDYY6.);
*simst.S2020Z_%SYSFUNC(TODAY(), MMDDYY6.);

data baas_ids;
  set simst.S2020Z_%SYSFUNC(TODAY(), MMDDYY6.);
  where acad_plan = "APAS-BAAS";
  keep emplid;
run;

proc sort data=baas_ids;
  by emplid;
run;

proc sort data=enroll.Enrollement_dw_2020z_%SYSFUNC(TODAY(), MMDDYY6.) out=enroll_sorted;
	by emplid;
run;
data baas_enrollment;
  merge baas_ids (in=a) enroll_sorted;
  by emplid;
  if a=1;
  drop acad_plan;
run;

ods pdf file="C:\Users\jrk0200\UNT System\Special Projects Frisco Data Team - General\SPFDT\dev\college_BAAS.pdf";
title1 "Count of Enrollments by College";
title2 "BAAS Students - Fall 2020 - As of June 21";
proc freq data=baas_enrollment order=freq;
  table A_GRP_descr / nocum;
run;
title;
ods pdf close;

*%let ENROLLMENT="S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020c_2census_dt"; 

*%let SIMSTERM="S:\UIS\Shared\SAS Data Projects\simsterm_records\s2020c_2census_dt";

%macro nationality(fnames, fnamee, term, dataname);
DATA ENROLLMENT;
	SET &fnamee.;
	WHERE LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK') OR SUBJECT IN ('BAAS');
RUN;
DATA SIMSTERM;
	SET &fnames.;
RUN;
PROC SORT DATA=SIMSTERM;
	BY EMPLID;
RUN;
PROC SORT DATA=ENROLLMENT;
	BY EMPLID;
RUN;
DATA &dataname.;
	MERGE ENROLLMENT (IN=A) SIMSTERM;
	BY EMPLID;
	IF A=1;
	TERM = &term.;
 	*KEEP CITIZENSHIP_COUNTRY TERM;
RUN;

%mend;

%nationality("S:\UIS\Shared\SAS Data Projects\simsterm_records\s2020z_%sysfunc(today(),mmddyy6.)", 
	"S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020z_%sysfunc(today(),mmddyy6.)",
	"Fall 2020", F20);
%nationality("S:\UIS\Shared\SAS Data Projects\simsterm_records\s2020c_2census_dt", 
	"S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020c_2census_dt",
	"Spring 20", S20);
%nationality("S:\UIS\Shared\SAS Data Projects\simsterm_records\s2019z_091819", 
	"S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2019z_official",
	"Fall 2019", F19);

data total;
	set f20 s20 f19;
run;

proc sort data=total out=students nodupkey;
	by term emplid;
run;

title1 "Nationalities Report";
title2 "(Includes BAAS)";
ods tagsets.excelxp file="C:\Users\jrk0200\UNT System\Special Projects Frisco Data Team - General\SPFDT\Nationalities_%sysfunc(today(), mmddyy6).xml" style=XLsansprinter;


ods tagsets.excelxp options(embedded_titles='yes' autofit_height='yes' sheet_interval='none'
						sheet_NAME='Enrollments Report' absolute_column_width='');

PROC FREQ DATA=TOTAL ORDER=FREQ;
	TABLE CITIZENSHIP_COUNTRY*TERM / nocum norow nocol;
RUN;


ods tagsets.excelxp options(embedded_titles='yes' autofit_height='yes' sheet_interval='none'
						sheet_NAME='Student Report' absolute_column_width='');

PROC FREQ DATA=students ORDER=FREQ;
	TABLE CITIZENSHIP_COUNTRY*TERM / nocum norow nocol;
RUN;

ods tagsets.excelxp options(embedded_titles='yes' autofit_height='yes' sheet_interval='none'
						sheet_NAME='SCH Report' absolute_column_width='');

proc tabulate data=total order=freq;
	class citizenship_country term;
	var unt_taken;
	table citizenship_country, term*unt_taken;
run;

ods tagsets.excelxp close;
title;

proc freq data=students;
	table instr_assign_seq;
run;


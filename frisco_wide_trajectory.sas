
*libname enroll "S:\UIS\Shared\sas_data_projects\enrollment_records";
libname enroll "S:\UIS\Shared\sas_data_projects\enrollment_records";
libname simst "S:\UIS\Shared\sas_data_projects\simsterm_records";

PROC FORMAT;
	VALUE $SEMESTER 'S2016Z'='a) Fall 2016'
					'S2017C'='b) Sping 2017'
					'S2017Z'='c) Fall 2017'	
					'S2018C'='d) Sping 2018'
					'S2018Z'='e) Fall 2018'
					'S2019C'='f) Sping 2019'	
					'2019Z'='g) Fall 2019'
					'2020C'='h) Sping 2020'
					'2020Z'='i) Fall 2020'	
					'2021C'='g) Sping 2021';
RUN;
*** Gather Frisco Enrollments;
%MACRO GRAB_FRISCO_ENROLL_SIMST(ENROLL, SIMSTERM, SEM);
	DATA FRISCO_ENROLL;		*PULL FRISCO ENROLLMENT;
		SET &ENROLL.;			
		WHERE LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK');
		TOUCH_&SEM. = 1;			*MACRO;
		DROP ACAD_PLAN;
	RUN;
	PROC SORT DATA=FRISCO_ENROLL;	* SORT FRISCO ENROLLMENT BY EMPLID;
		BY EMPLID;
	RUN;
	DATA FRISCO_IDS;			* GRAB ALL FRISCO IDS;
		SET FRISCO_ENROLL;			
		KEEP EMPLID TOUCH_&SEM.;
	RUN;
	PROC SORT DATA=FRISCO_IDS NODUPKEY;		* SORT FRISCO STUDENTS BY EMPLID;
		BY EMPLID;
	RUN;
	DATA OTHER_IDS;				* GRAB ALL IDS TAKING OFF-FRISCO;
		SET &ENROLL.;
		WHERE LOCATION NOT IN ('FRSC', 'Z-CHEC', 'Z-INSPK', 'Z-INET-OS', 'Z-INET-TX', 'Z-AOP');
		KEEP EMPLID;
	RUN;
	PROC SORT DATA=OTHER_IDS NODUPKEY;		* SORT OFF-FRISCO ENROLLMENTS BY EMPLID;
		BY EMPLID;
	RUN;
	DATA UNIQUE;						* CREATE JOIN OF FRISCO-UNIQUE STUDENTS;
		MERGE FRISCO_IDS (IN=A) OTHER_IDS (IN=B);
		BY EMPLID;
		IF A=1 AND B=0;
		UNIQUE_&SEM. = 1;									* MACRO;
		DROP TOUCH_&SEM.;									*MACRO;
	RUN;
	PROC SORT DATA=&SIMSTERM. OUT=SIMSTERM_SORTED;	* MACRO; * GRAB AND SORT SIMSTERM FOR STUDENT DATA;			* MACRO;
		BY EMPLID;
	RUN;
	DATA FRISCO_STUDENTS;
		MERGE FRISCO_IDS (IN=A) UNIQUE SIMSTERM_SORTED;
		BY EMPLID;
		IF A=1;
	RUN;
	DATA BIG_DATA_&SEM.;									* CREATE DATASET OF ALL FRISCO ENROLLMENTS AND SIMSTERM DATA;
		MERGE FRISCO_STUDENTS FRISCO_ENROLL;
		BY EMPLID;
	RUN;
	DATA LITTLE_DATA_&SEM.;				* CREATE SMALLER DATASET FROM LARGER WITH ONLY COUNTING VARS;
		SET BIG_DATA_&SEM.;
		KEEP EMPLID SEMESTER TOUCH_&SEM. UNIQUE_&SEM. ACAD_PLAN;
	RUN;
	PROC SORT DATA=LITTLE_DATA_&SEM. NODUPKEY;	* SORT SMALLER DATASET BY EMPLID AND REMOVE DUPES (STUDENT-LEVEL DETAILS);
		BY EMPLID;
	RUN;
	*DATA LITTLE_DATA_&SEM.;
	*	SET LITTLE_DATA_&SEM.;
		*WHERE ACAD_PLAN == &ACAD_PLAN.;		*VALUE FOR SUBSETTING???;
	*RUN;

%MEND;
****eXECUTION OF THE MACRO;
%GRAB_FRISCO_ENROLL_SIMST(ENROLL.Enrollement_dw_2020z_052120, SIMST.S2020Z_052120, F20);
%GRAB_FRISCO_ENROLL_SIMST(ENROLL.Enrollement_dw_2020c_2census_dt, SIMST.S2020c_2census_dt, S20);
%GRAB_FRISCO_ENROLL_SIMST(ENROLL.Enrollement_dw_2019z_census, SIMST.S2019z_official, F19);
%GRAB_FRISCO_ENROLL_SIMST(ENROLL.Enrollement_dw_2019c_census, SIMST.Dw_2019cag_official, S19);
%GRAB_FRISCO_ENROLL_SIMST(ENROLL.Enrollement_dw_2018z_census, SIMST.Dw_2018zag_official, F18);
%GRAB_FRISCO_ENROLL_SIMST(ENROLL.Enrollement_dw_2018c_census, SIMST.Dw_2018cag_official, S18);
%GRAB_FRISCO_ENROLL_SIMST(ENROLL.Enrollement_dw_2017z_census, SIMST.Dw_2017zag_official, F17);
%GRAB_FRISCO_ENROLL_SIMST(ENROLL.Enrollement_dw_2017c_census, SIMST.Dw_2017cag_official, S17);
%GRAB_FRISCO_ENROLL_SIMST(ENROLL.Enrollement_dw_2016z_census, SIMST.Dw_2016zag_official, F16);
%GRAB_FRISCO_ENROLL_SIMST(ENROLL.Enrollement_dw_2016c_census, SIMST.Dw_2016cag_official, S16);

**** START INNER LOOP FOR ACAD_PLAN????    *********;
%MACRO CALC_RETURNING(SEM1, SEM2);
	DATA RETURNING;
		MERGE LITTLE_DATA_&SEM1. (IN=A) LITTLE_DATA_&SEM2. (IN=B);
		BY EMPLID;
		IF A=1 AND B=1;
		RETAINED = 1;			* CONVERT MISSING TO INTEGER;
		RETAINED_&SEM2. = 1;
	RUN;
	DATA DATA_&SEM2.;
		MERGE LITTLE_DATA_&SEM2. RETURNING;
		BY EMPLID;
		DROP UNIQUE_&SEM1. TOUCH_&SEM1.;
	RUN;
%MEND;

*** MACRO EXECUTION TO CALCULATE THE RETAINED STUDENTS PER SEMESTER;
%CALC_RETURNING(S16, F16);
%CALC_RETURNING(F16, S17);
%CALC_RETURNING(S17, F17);
%CALC_RETURNING(F17, S18);
%CALC_RETURNING(S18, F18);
%CALC_RETURNING(F18, S19);
%CALC_RETURNING(S19, F19);
%CALC_RETURNING(F19, S20);
%CALC_RETURNING(S20, F20);


DATA FINAL_DATA;				* COMBINE ALL RETURNING COUNTS TO CREATE A COLUMN TO MERGE IN NEXT STEP;
	SET DATA_F16 DATA_S17 DATA_F17 DATA_S18 DATA_F18 DATA_S19 DATA_F19 DATA_S20 DATA_F20;
RUN;
PROC SORT DATA=FINAL_DATA;			* SORT DATA FOR FINAL MERGE;
	BY SEMESTER;
	RUN;

%MACRO calc_unique(sem);				* COUNT THE FRISCO-UNIQUE STUDENTS PER SEMESTER;
	PROC SORT DATA=data_&sem.;
		BY SEMESTER;
	RUN;
	data uni_&sem.;
		set data_&sem.;
		by semester;
		if first.semester then uni_ct = unique_&sem.;
		else uni_ct + unique_&sem.;
		if last.semester then output;
		keep semester uni_ct;
	run;
%MEND;

*** MACRO EXECUTION TO CALCULATE THE FRISCO-UNIQUE STUDENTS PER SEMESTER;
%calc_unique(f20);
%calc_unique(s20);
%calc_unique(f19);
%calc_unique(s19);
%calc_unique(f18);
%calc_unique(s18);
%calc_unique(f17);
%calc_unique(s17);
%calc_unique(f16);

data final_uni;						* COMBINE ALL UNIQUE COUNTS TO CREATE A COLUMN TO MERGE IN NEXT STEP;
	set uni_f16 uni_s17 uni_f17 uni_s18 uni_f18 uni_s19 uni_f19 uni_s20 uni_f20;
run; 
proc sort data=final_uni nodupkey;
	by semester;
run;

DATA TOTAL_COUNT;					* COUNT NUMBER OF TOTAL STUDENTS PER SEMESTER;
	SET FINAL_DATA;
	BY SEMESTER;
	IF FIRST.SEMESTER THEN COUNT = 1;
	ELSE COUNT + 1;
	IF LAST.SEMESTER THEN OUTPUT;
	KEEP SEMESTER COUNT;
RUN;
DATA RETAINED_COUNT;				* COUNT NUNBER OF RETAINED STUDENTS PERE SEMESTER;
	SET FINAL_DATA;
	BY SEMESTER;
	IF FIRST.SEMESTER THEN RET_CT = RETAINED;
	ELSE RET_CT + RETAINED;
	IF LAST.SEMESTER THEN OUTPUT;
	KEEP SEMESTER RET_CT;
RUN;

DATA FINAL_FINAL;		* ASSEMBLE FINAL DATASET;
	MERGE TOTAL_COUNT RETAINED_COUNT FINAL_UNI;
	BY SEMESTER;
	FORMAT SEMESTER SEMESTER.;
	where semester ~= "";			* IGNORE MISSING VALUES (STUDENTS WHO WEREN'T IN SIMSTERM;
	NEW_STUD = COUNT - RET_CT;		* CALCULATE NEW_STUD VAR FROM (COUNT-RETAINED VAR);
	NON_UNIQ = count - uni_ct; 		* CALCULATE NON_UNIQQUE VAR FROM (COUNT - UNIQUE VAR);
RUN;

proc sql;		* SORT FINAL DATASET BY FORMATTED VALUES;
    create table sql_final as
    select *
    from final_final
    order by put(semester, $SEMESTER.);
quit;

title1 "Frisco Trajectory Information";
ods tagsets.excelxp file="C:\Users\jrk0200\UNT System\Special Projects Frisco Data Team - General\SPFDT\dev\trajectory_table.xml" style=XLSANSPRINTER
    options( embedded_titles='yes' AUTOFIT_HEIGHT='YES'
			 skip_space='3,2,0,0,1' sheet_interval='none'
			 sheet_name="HP_IP_CHEC"
             suppress_bylines='no' absolute_column_width='9,7,7,8,7,7,8,7');

proc report data=sql_final;
	column semester ("Student Type" count uni_ct uni_per non_uniq) ("Retention" ret_ct ret_per new_stud);
	define semester / display 'Semester' format=$semester.;
	define count / analysis 'Touch';
	define non_uniq / analysis 'Non-Unique';
	define uni_ct / analysis 'Unique';
	define ret_ct / analysis 'Retained';
	define new_stud / analysis 'New/Xfer';
	define uni_per / computed 'Unique %' format=percent7.0;
	define ret_per / computed 'Retained %' format=percent7.0;
	COMPUTE uni_per;
		uni_per = uni_ct.sum/count.sum;
	ENDCOMP;
	COMPUTE ret_per;
		ret_per = ret_ct.sum/count.sum;
	ENDCOMP;
RBREAK AFTER /SUMMARIZE OL UL;
run;

ods tagsets.excelxp close;



PROC FREQ DATA=SIMSTERM_SORTED;
	TABLE ACAD_PLAN;
RUN;
/*
PROC FREQ DATA=LITTLE_DATA_S16;
	TABLE TOUCH_S16;
RUN;
DATA TEST;
	SET BIG_DATA_S16;
	WHERE EMPLID="10968583";
RUN;

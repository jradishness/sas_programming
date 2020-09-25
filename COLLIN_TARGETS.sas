***************************

Compare the non-enrolled targets with enrollment.

Question: How many students from the target list
have enrolled in courses?


***************************;

* Robert's IPT target list of non enrolled;


%let DAIR_DATA="S:\UIS\Shared\SAS Data Projects\enrollment_records\enrollement_dw_2020z_%sysfunc(today(),mmddyy6.)";
%LET SIMST = "S:\UIS\Shared\SAS Data Projects\simsterm_records\s2020z_%sysfunc(today(),mmddyy6.)";


*MACRO TO READ IN REPORTS FROM ROBERT'S IPT TARGETING ^%&*()*&^%*^^;
%MACRO IPT_IN(wk_id, in_fname);
	data M_WEEK&wk_id.;
	     %let _EFIERR_ = 0; * set the ERROR detection macro variable;
	     infile &in_fname delimiter = ','
	 MISSOVER DSD lrecl=32767 firstobs=2 ;
	        informat Current_Ongoing_Term best32. ;
	        informat FutureTerm_NotEnrolled best32. ;
	        informat EMPLID $32. ;
	        informat Name $25. ;
	        informat Last_Name $11. ;
	        informat First_Name $7. ;
	        informat Middle_Name $9. ;
	        informat Academic_Career $4. ;
	        informat ACAD_CLASSIFICATION $3. ;
	        informat Academic_Program best32. ;
	        informat Academic_Plan $9. ;
	        informat Academic_Plan_Description $25. ;
	        informat CAMPUS_EMAIL $30. ;
	        informat PREF_PHONE $12. ;
	        informat Service_Indicator_Cd $3. ;
	        informat Service_Ind_Reason_Code $5. ;
	        informat Description $27. ;
	        informat SERVICE_IMPACT_DESCR $1. ;
	        informat Student_City $11. ;
	        informat Student_ZIP_Code $10. ;
	        format Current_Ongoing_Term best12. ;
	        format FutureTerm_NotEnrolled best12. ;
	        format EMPLID $12. ;
	        format Name $25. ;
	        format Last_Name $11. ;
	        format First_Name $7. ;
	        format Middle_Name $9. ;
	        format Academic_Career $4. ;
	        format ACAD_CLASSIFICATION $3. ;
	        format Academic_Program best12. ;
	        format Academic_Plan $9. ;
	        format Academic_Plan_Description $25. ;
	        format CAMPUS_EMAIL $30. ;
	        format PREF_PHONE $12. ;
	        format Service_Indicator_Cd $3. ;
	        format Service_Ind_Reason_Code $5. ;
	        format Description $27. ;
	        format SERVICE_IMPACT_DESCR $1. ;
	        format Student_City $11. ;
	        format Student_ZIP_Code $10. ;
			format Week 2.;
	     input
	                 Current_Ongoing_Term
	                 FutureTerm_NotEnrolled
	                 EMPLID $
	                 Name $
	                 Last_Name $
	                 First_Name $
	                 Middle_Name $
	                 Academic_Career $
	                 ACAD_CLASSIFICATION $
	                 Academic_Program
	                 Academic_Plan $
	                 Academic_Plan_Description $
	                 CAMPUS_EMAIL $
	                 PREF_PHONE $
	                 Service_Indicator_Cd $
	                 Service_Ind_Reason_Code $
	                 Description $
	                 SERVICE_IMPACT_DESCR $
	                 Student_City $
	                 Student_ZIP_Code $
	     ;
		 if EMPLID ~= .;
	     if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
		week = &wk_id;
		 *keep name id last_name first_name middle_name;
	run;

	DATA WEEK&wk_id.;
		SET M_WEEK&wk_id.;
		DROP SERVICE_INDICATOR_CD SERVICE_IND_REASON_CODE DESCRIPTION SERVICE_IMPACT_DESCR ACADEMIC_PROGRAM;
	RUN;

	PROC SORT DATA = WEEK&WK_ID. NODUPKEY;
		BY EMPLID;
	RUN;

%MEND IPT_IN;


* MACRO EXECUTION STEP;		*EVERY WEEK - ADD NEW INVOCATION;
%IPT_IN(1, 'C:\Users\jrk0200\UNT System\Special Projects Frisco Data Team - General\Prev Student Reports\NotEnrolled-PrevFriscoStudent -3-31.csv');
%IPT_IN(2, 'C:\Users\jrk0200\UNT System\Special Projects Frisco Data Team - General\Prev Student Reports\NotEnrolled-PrevFriscoStudent -4-3.csv');
%IPT_IN(3, 'C:\Users\jrk0200\UNT System\Special Projects Frisco Data Team - General\Prev Student Reports\NotEnrolled-PrevFriscoStudent -4-10.csv');
%IPT_IN(4, 'C:\Users\jrk0200\UNT System\Special Projects Frisco Data Team - General\Prev Student Reports\NotEnrolled-PrevFriscoStudent -4-17.csv');

* STEPS TO CCOMBINE WEEKS WITHOUT DUPLICATES;      *EVERY WEEK - ADD NEW DATA STEP;
DATA REG_W1;
	MERGE WEEK1 WEEK2(IN=A);
	BY EMPLID;
	IF A = 0;
	DROPPED = 1;
RUN;
DATA REG_W2;
	MERGE WEEK2 WEEK3 (IN=A);
	BY EMPLID;
	IF A = 0;
	DROPPED = 2;
RUN;
DATA REG_W3;	* <- INCREMENT THIS LINE;
	MERGE WEEK3 WEEK4 (IN=A); * <- INCREMENT THIS LINE;
	BY EMPLID;
	IF A = 0;
	DROPPED = 3; * <- INCREMENT THIS LINE;
RUN;

DATA IPT;
	SET WEEK4 REG_W3 REG_W2 REG_W1;   *EVERY WEEK - UPDATE WITH NEW DATASET;
RUN;

*SORT IPT SET FOR MERGE;
PROC SORT DATA=IPT;
	BY EMPLID;
RUN;

*COLLECT DAIR ENROLLMENT;
DATA DAIR;
	SET &DAIR_DATA;
	KEEP EMPLID;
RUN;
*SORT ENROLLMENT FOR MERGE;
PROC SORT DATA=DAIR NODUPKEY;
	BY EMPLID;
RUN;
*LOAD SIMSTERM TO PROVIDE DEMOGRAPHICS;
DATA WORK.SIMSTERM;
	SET &SIMST;
RUN;
*SORT SIMSTERM FOR MERGE;
PROC SORT DATA=SIMSTERM;
	BY EMPLID;
RUN;
*ADD SIMSTERM TO IPT DATA;
DATA IPT;
	MERGE IPT (IN=A) SIMSTERM;
	BY EMPLID;
	IF A=1;
 RUN;
*COLLECT DAIR DATA SEPARATELY FROM IPT CALC;
DATA TARGETS_ENROLLED;
	MERGE IPT(IN=A) DAIR(IN=B);
	IF A=1 AND B=1;
	BY EMPLID;
RUN;



************ REPORTING *****************;

*ODS PDF FILE="";
PROC FREQ DATA=TARGETS_ENROLLED;
	TABLE ACADEMIC_PLAN_DESCRIPTION*WEEK / NOCUM NOPERCENT NOROW NOCOL;
RUN;

PROC FREQ DATA=TARGETS_ENROLLED;
	TABLE ACAD_CLASSIFICATION*WEEK / NOCUM NOPERCENT NOROW NOCOL;
RUN;

PROC FREQ DATA=TARGETS_ENROLLED;
	TABLE GROUP_DESCR*WEEK / NOCUM NOPERCENT NOROW NOCOL;
RUN;
*ODS PDF CLOSE;

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
%IPT_IN(1, 'C:\Users\ccy0016\UNT System\Special Projects Frisco Data Team - General\Prev Student Reports\NotEnrolled-PrevFriscoStudent-4-3.csv');
%IPT_IN(2, 'C:\Users\ccy0016\UNT System\Special Projects Frisco Data Team - General\Prev Student Reports\NotEnrolled-PrevFriscoStudent-4-10.csv');
%IPT_IN(3, 'C:\Users\ccy0016\UNT System\Special Projects Frisco Data Team - General\Prev Student Reports\NotEnrolled-PrevFriscoStudent-4-17.csv');
%IPT_IN(4, 'C:\Users\ccy0016\UNT System\Special Projects Frisco Data Team - General\Prev Student Reports\NotEnrolled-PrevFriscoStudent- 4.24.csv');
%IPT_IN(5, 'C:\Users\ccy0016\UNT System\Special Projects Frisco Data Team - General\Prev Student Reports\NotEnrolled-PrevFriscoStudent- 5.1.csv');
%IPT_IN(6, 'C:\Users\ccy0016\UNT System\Special Projects Frisco Data Team - General\Prev Student Reports\NotEnrolled-PrevFriscoStudent-5-8.csv');
%IPT_IN(7, 'C:\Users\ccy0016\UNT System\Special Projects Frisco Data Team - General\Prev Student Reports\NotEnrolled-PrevFriscoStudent-5-15.csv');
%IPT_IN(8, 'C:\Users\ccy0016\UNT System\Special Projects Frisco Data Team - General\Prev Student Reports\NotEnrolled-PrevFriscoStudent-5-22.csv');
%IPT_IN(9, 'C:\Users\ccy0016\UNT System\Special Projects Frisco Data Team - General\Prev Student Reports\NotEnrolled-PrevFriscoStudent-5-29.csv');
%IPT_IN(10,'C:\Users\ccy0016\UNT System\Special Projects Frisco Data Team - General\Prev Student Reports\NotEnrolled-PrevFriscoStudent-6-12.csv');

DATA RELEVANT;
	SET M_WEEK10 M_WEEK9 M_WEEK8 M_WEEK7 M_WEEK6 M_WEEK5 M_WEEK4 M_WEEK3 M_WEEK2 M_WEEK1;
	WHERE ACAD_CLASSIFICATION IN ("FR", "SO");
RUN;
PROC SORT DATA=RELEVANT NODUPKEY;
	BY EMPLID;
RUN;

ods pdf file="C:\Users\ccy0016\UNT System\Special Projects Frisco Data Team - General\SPFDT\not_enrolled_deegrees.pdf";
PROC FREQ DATA=RELEVANT order=freq;
	TABLE ACADEMIC_PLAN_DESCRIPTION/nocum nopercent;
RUN;
ods pdf close;

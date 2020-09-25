data WORK.WEEK3    ;
     %let _EFIERR_ = 0; * set the ERROR detection macro variable;
     infile 'C:\Users\jrk0200\Desktop\NotEnrolled_PrevFriscoStudent_4_3.csv' delimiter = ','
 MISSOVER DSD lrecl=32767 firstobs=2 ;
        informat Current_Ongoing_Term best32. ;
        informat FutureTerm_NotEnrolled best32. ;
        informat ID best32. ;
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
        format ID best12. ;
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
     input
                 Current_Ongoing_Term
                 FutureTerm_NotEnrolled
                 ID
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
     if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
	 keep name id last_name first_name middle_name;
run;


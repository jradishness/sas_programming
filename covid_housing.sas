
**************************************************
*Program to backtrace known close associates of
*anyone affected by the COVID-19 outbreak.
*
*Input: Emplid of affected
*Output: Tab 1: Table of residents on the same floor
*		Tab 2: Table of residents on the floor above/below
*
*by Jared Kelly
*Last edit: 3/19/20 - Finished all levels
*************************************************;
* Input Emplid of COVID affected student here;
%let affected = 11182158; *<<<<<<<<<<<<<<<<;

* LOCATION OF "Current_Residents_Table";
%let housing_import = "S:\UIS\Shared\SAS Data Projects\COVID\Current_Residents_Table Spring 2019.xlsx";
* LOCATION OF SIMSTERM;
%let simsterm = "S:\UIS\Shared\SAS Data Projects\simsterm_records\s2020c_2census_dt";

*******Import the student data from housing;
PROC IMPORT OUT= WORK.housing_IMP 
            DATAFILE= &housing_import. 
            DBMS=EXCEL REPLACE;
     RANGE="Current_Residents_Table"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

****** Process housing data for IR, creating new variables for room info;
DATA HOUSING;
	SET HOUSING_IMP;
	IF HALL_NAME IN ("Rawlins Hall", "Traditions Hall") THEN ROOM = SUBSTR(CK_BED_SPACE, 4);
	ELSE ROOM = SUBSTR(CK_BED_SPACE, 4);
	IF HALL_NAME IN ("Rawlins Hall", "Traditions Hall", "Victory Hall") THEN FLOOR = SUBSTR(CK_BED_SPACE, 4, 1);
	ELSE FLOOR = SUBSTR(CK_BED_SPACE, 4, 2);
	IF HALL_NAME IN ("Rawlins Hall", "Traditions Hall", "Victory Hall") THEN FLOOR_NUM = SUBSTR(FLOOR, 1);
	ELSE FLOOR_NUM = SUBSTR(FLOOR, 2);
	IF HALL_NAME IN ("Rawlins Hall", "Traditions Hall", "Victory Hall") THEN WING = "0";
	ELSE WING = SUBSTR(FLOOR, 1, 1);
	KEEP ix_Last_Name ix_First_Name AGE SEX HALL_NAME CK_BED_SPACE EMPLID ROOM FLOOR FLOOR_NUM WING;
RUN;

* CAPTURE HOUSING DATA OF AFFECTED STUDENT;
DATA AFFECT;
	SET HOUSING;
	WHERE EMPLID = "&affected.";
	CALL SYMPUT('up_number', LEFT(PUT(floor_num+1, $8.)));
	CALL SYMPUT('down_number', LEFT(PUT(floor_num-1, $8.)));
RUN;

*SORT AND NARROW HOUSING DATA BY HALL OF AFFECTED;
PROC SORT DATA=HOUSING OUT=SORT_HALL;
	BY HALL_NAME;
RUN;
DATA REL_ASSOC;
	MERGE AFFECT (IN=A) SORT_HALL;
	BY HALL_NAME;
	IF A=1;
RUN;

*SORT AND NARROW BY WING;
PROC SORT DATA=REL_ASSOC OUT=SORT_WING;
	BY WING;
RUN;
DATA REL_ASSOC2; 
	MERGE AFFECT (IN=A) SORT_WING;
	BY WING;
	IF A=1;
RUN;

* include simsterm to provide contact info...;
PROC SORT DATA=REL_ASSOC2;
	BY EMPLID;
RUN;
PROC SORT DATA=&SIMSTERM. OUT=SIM_SORT;
	BY EMPLID;
RUN;
DATA REL_ASSOC3;
	MERGE REL_ASSOC2(IN=A) SIM_SORT;
	BY EMPLID;
	IF A=1;
	KEEP ix_Last_Name ix_First_Name AGE SEX HALL_NAME CK_BED_SPACE EMPLID ROOM FLOOR FLOOR_NUM 
	WING SORT_NAME EMAIL_ADDRESS CELL_PHONE_NMBR MAIN_PHONE_NMBR PERM_PHONE_NMBR MAIL_ADDRESS1 
	MAIL_CITY MAIL_STATE MAIL_POSTAL; 
RUN;

*SORT AND NARROW BY FLOOR;
PROC SORT DATA=REL_ASSOC3 OUT=SORT_FLOOR;
	BY FLOOR_NUM;
RUN;
DATA REL_ASSOC4;
	MERGE AFFECT (IN=A) SORT_FLOOR;
	BY FLOOR_NUM;
	IF A=1;
RUN;

**********************CALCULATE SECOND LEVEL!!***********************;
DATA REL_ASSOC_UP; 
	SET SORT_FLOOR;
	WHERE FLOOR_NUM = "&up_number.";
RUN;
DATA REL_ASSOC_DOWN; 
	SET SORT_FLOOR;
	WHERE FLOOR_NUM = "&down_number.";
RUN;
DATA SECOND_LVL;
	SET REL_ASSOC_UP REL_ASSOC_DOWN;
RUN;
************************FINISH SECOND LEVEL**************************;

******* REPORT RESULTS TO USER;
title1 "Report of dorm residents related to the affected student(EMPLID: &affected.)";
ods tagsets.excelxp file="S:\UIS\Shared\SAS Data Projects\COVID\reports\housing\&affected._COVID_housing_%sysfunc(today(), mmddyy6).xml" style=XLsansprinter;
ODS TAGSETS.EXCELXP options(embedded_titles='yes' autofit_height='yes' sheet_interval='none'
			sheet_name='1st Level' absolute_column_width='20,8,7,7,15,10,22,20,15,7,8,15,15,15');
proc report data=REL_ASSOC4 HEADLINE MISSING;
	COLUMN ("Student" SORT_NAME EMPLID AGE SEX)
			("Hall" HALL_NAME CK_BED_SPACE)
			("Contact" EMAIL_ADDRESS MAIL_ADDRESS1 MAIL_CITY MAIL_STATE MAIL_POSTAL 
			CELL_PHONE_NMBR MAIN_PHONE_NMBR PERM_PHONE_NMBR);
	DEFINE SORT_NAME / ORDER 'Name';
	DEFINE EMPLID / DISPLAY 'EmplID';
	DEFINE AGE / DISPLAY 'Age';
	DEFINE SEX / DISPLAY 'Gender';
	DEFINE HALL_NAME / DISPLAY 'Hall';
	DEFINE CK_BED_SPACE / DISPLAY 'Bed Space';
	DEFINE EMAIL_ADDRESS / DISPLAY 'E-mail';
	DEFINE MAIL_ADDRESS1 / DISPLAY 'Street';
	DEFINE MAIL_CITY / DISPLAY 'City';
	DEFINE MAIL_STATE / DISPLAY 'State';
	DEFINE MAIL_POSTAL / DISPLAY 'Zip';
	DEFINE CELL_PHONE_NMBR / DISPLAY 'Cell';
	DEFINE MAIN_PHONE_NMBR / DISPLAY 'Phone#2';
	DEFINE PERM_PHONE_NMBR / DISPLAY 'Phone#3';
run;

ODS TAGSETS.EXCELXP options(embedded_titles='yes' autofit_height='yes' sheet_interval='none'
			sheet_name='2nd Level' absolute_column_width='20,8,7,7,15,10,22,20,15,7,8,15,15,15');
proc report data=SECOND_LVL HEADLINE MISSING;
	COLUMN ("Student" SORT_NAME EMPLID AGE SEX)
			("Hall" HALL_NAME CK_BED_SPACE)
			("Contact" EMAIL_ADDRESS MAIL_ADDRESS1 MAIL_CITY MAIL_STATE MAIL_POSTAL 
			CELL_PHONE_NMBR MAIN_PHONE_NMBR PERM_PHONE_NMBR);
	DEFINE SORT_NAME / DISPLAY 'Name';
	DEFINE EMPLID / DISPLAY 'EmplID';
	DEFINE AGE / DISPLAY 'Age';
	DEFINE SEX / DISPLAY 'Gender';
	DEFINE HALL_NAME / DISPLAY 'Hall';
	DEFINE CK_BED_SPACE / ORDER 'Bed Space';
	DEFINE EMAIL_ADDRESS / DISPLAY 'E-mail';
	DEFINE MAIL_ADDRESS1 / DISPLAY 'Street';
	DEFINE MAIL_CITY / DISPLAY 'City';
	DEFINE MAIL_STATE / DISPLAY 'State';
	DEFINE MAIL_POSTAL / DISPLAY 'Zip';
	DEFINE CELL_PHONE_NMBR / DISPLAY 'Cell';
	DEFINE MAIN_PHONE_NMBR / DISPLAY 'Phone#2';
	DEFINE PERM_PHONE_NMBR / DISPLAY 'Phone#3';
run;


ods tagsets.excelxp close;
title;


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

*****************************************************

Program to grab cross-tabulation of Spring 2020 - 
Fall 2020 Collin Touch-Majority-Unique-No from 
Cassie's DAIR Reports



*****************************************************;

*Macro to save filename;
%let input_fname = 'C:\Users\ccy0016\UNT System\Special Projects Frisco Data Team - General\DAIR reports - with roster\4-13FriscoCHEC_Weekly_Summary_Summer_Fall.xlsx';

PROC IMPORT OUT= WORK.CASSIE 
            DATAFILE= &input_fname 
            DBMS=EXCEL REPLACE;
     RANGE="COLLIN_STUDENTS_FALL$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

DATA CASSIE;
	SET CASSIE(RENAME=(COLLIN_STATUS=Fall SP20_COLLIN_STATUS=Spring));
	LABEL Fall="Fall 2020 Status"
		  Spring="Spring 2020 Status";
	KEEP Fall Spring;
RUN;

ods pdf file="desktop/test.pdf";
TITLE1 "Distribution of Collin Student Types";
title2 "FALL 2020 - SPRING 2020";

proc freq data=CASSIE;
 	tables Spring*Fall /plots=freqplot(groupby=row twoway=cluster) norow nocol nopercent nocum;
run;

ods pdf close;



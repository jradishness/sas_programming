*****************************************************

Program to grab cross-tabulation of Spring 2020 - 
Fall 2020 Collin Touch-Majority-Unique-No from 
Cassie's DAIR Reports



*****************************************************;

*Macro to save filename;
%let input_fname = 'C:\Users\jrk0200\UNT System\Special Projects Frisco Data Team - General\DAIR reports - with roster\FriscoCHEC_Weekly_Summary_Summer_Fall_5.4.2020.xlsx';

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

DATA CASSIE_CAT;
	SET CASSIE(RENAME=(COLLIN_STATUS=Fall SP20_COLLIN_STATUS=Spring));
	LABEL Fall="Fall 2020 Status"
		  Spring="Spring 2020 Status";
	KEEP Fall Spring;
RUN;

ods pdf file="desktop/test.pdf";
TITLE1 "Distribution of Collin Student Types";
title2 "FALL 2020 - SPRING 2020";

proc freq data=CASSIE_CAT;
 	tables Spring*Fall /plots=freqplot(groupby=row twoway=cluster) norow nocol nopercent nocum;
run;

ods pdf close;

proc template; *FRISCO STUDENT CATECORIES PIE CHART;
define statgraph cat_pie;  
begingraph;    
entrytitle "Frisco students by Category";  
layout region;      
piechart category=Fall / datalabellocation=outside;    
endlayout;  
endgraph; 
end; 
run; 
proc sgrender data=Cassie_CAT           
template=cat_pie;
run;

proc template; *FRISCO STUDENT Colleges PIE CHART;
define statgraph col_pie;  
  begingraph;    
	entrytitle "Frisco students by College";  
	  layout region;      
		piechart category=group_descr / datalabellocation=callout
otherslice=true othersliceopts=(type=maxslices maxslices=6 label="Other Colleges"); 
endlayout;  
endgraph; 
end; 
run; 

ods pdf file="C:\Users\jrk0200\test.pdf";
TITLE1 "Majority Collin and Collin Only";
proc sgrender data=Cassie template = col_pie;
	WHERE collin_status in ("COLLIN ONLY", "MAJORITY COLLIN");
run;
proc freq data=Cassie order=freq;
	table group_descr / nocum;
	WHERE collin_status in ("COLLIN ONLY", "MAJORITY COLLIN");
run;
title;

TITLE1 "Majority Collin";
proc sgrender data=Cassie template = col_pie;
	WHERE collin_status in ("MAJORITY COLLIN");
run;
proc freq data=Cassie order=freq;
	table group_descr / nocum;
	WHERE collin_status in ("MAJORITY COLLIN");
run;title;

TITLE1 "Collin Only";
proc sgrender data=Cassie template = col_pie;
	WHERE collin_status in ("COLLIN ONLY");
run;
proc freq data=Cassie order=freq;
	table group_descr / nocum;
	WHERE collin_status in ("COLLIN ONLY");
run;title;
ods pdf close;


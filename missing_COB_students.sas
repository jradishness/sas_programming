data fall_ids;
 	set enroll.Enrollement_dw_2020z_060920;
	* where location in ("Z-CHEC", "Z-INSPK", "FRSC");
	keep emplid;
run;
proc sort data=fall_ids nodupkey;
	by emplid;
run;
data spring_ids;
 	set enroll.Enrollement_dw_2020c_2census_dt;
	where location in ("Z-CHEC", "Z-INSPK", "FRSC");
	keep emplid;
run;
proc sort data=spring_ids nodupkey;
	by emplid;
run;

data relevant_ids;
	merge fall_ids (in=b) spring_ids (in=a);
	by emplid;
	if a=1 and b=0;
run;
data simst;
	set simst.S2020c_2census_dt;
	keep emplid name acad_group group_descr cell_phone_nmbr main_phone_nmbr perm_phone_nmbr mail_address1 
		mail_city mail_state mail_postal email_address;
run;
proc sort data=simst;
	by emplid;
run;
data relevant_data;
	merge relevant_ids (in=a) simst;
	by emplid;
	if a=1;
run;

ods html file="C:\Users\jrk0200\UNT System\Special Projects Frisco Data Team - General\SPFDT\dev\brcob_unreg.xls";
proc print data=relevant_data;
	where acad_group = "BUAD";
run;
ods html close;

proc freq data=relevant_data order=freq;
	table acad_group*group_descr/nopercent norow nocol nocum;
run;
proc

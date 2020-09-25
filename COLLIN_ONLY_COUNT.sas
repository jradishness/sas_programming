data enroll;
	set enrollment;
	if location in ('FRSC', 'Z-CHEC', 'Z-INSPK') then collin = 1;
	else etcetera=1;
	keep emplid collin etcetera;
run;

data enroll;
	set enroll;
	by EMPLID;
	if First.EMPLID then collin_tot = 0;
	collin_tot + collin;
	if First.EMPLID then etc_tot = 0;
	etc_tot + etcetera;
	IF LAST.EMPLID THEN OUTPUT;
	KEEP EMPLID collin_tot etc_tot;
run;

data frisco_enroll;
	set enrollment;
	where location in LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK');
	collin = 1;
	keep emplid collin;
run;

proc sort data=frisco_stud nodupkey;	
	by emplid;
run;

data else_enroll;
	set enrollment;
	where l in LOCATION IN ('FRSC', 'Z-CHEC', 'Z-INSPK');
	collin = 1;
	keep emplid collin;
run;




proc sort data=frisco_stud;
	by emplid;
run;

data frisco_stud;
	by emplid;
run;

	


/* to create the SAS dataset using 64 bit you must attach to the data warehouse (12_22_15)

	to attach to the data warehouse:
	click on 'tools' > 'new library'
	populate the template as follows:
	Name:   MYORALIB
	Engine:   ORACLE
	User:   your euid (ex. meb0044)
	Password:   your EIS password
	Path:   LSRDSPD
	Options:  SCHEMA=STRDSOWNER

/*if the above LIBNAME statement fails, notify UNT System IT Shared Services
if one of the analysts needs to connect to the LIBNAME to be able to run this program, Keitha or Ben Inn in 
 the RO must give access. It would be to Grant/Revoke Non-PS Roles,  DWGBSA prefix in LSPD. */

/* 1CURRENT   2CENSUS_DT  2REVIEW  3OFFICIAL  */
/* 2REVIEW is period after census date and before official. Daily changes from clean-up will be seen*/;
/*file1 below is for SAS EIS (ex. simsterm_2017z_official) and file2 is for SAS SIMSTERM (ex. s2017z*/;

LIBNAME MYORALIB oracle user='meb0044' password='Prahacib$17' path='LSRDSPD'  SCHEMA=STRDSOWNER;
run;
%let curdate = %sysfunc(today(),mmddyy6.);	* CURRENT DATE;

options symbolgen;

%macro create(term=1198, term2=2019Z, run=1CURRENT, file1=simsterm_s2019z_&curdate., file2=s2019z_&curdate.); ** on file1 official 20th_class_day;

LIBNAME IN1 "S:\UIS\Shared\SAS Data Projects\Simsterm\";
 
DATA SIMSTERM_ORIG;
SET MYORALIB.NTSR_IR_SIMSTERM_ARCH;
IF STRM ="&term" AND DW_RUN_DESC = "&run";
RUN;

********************RUN THIS SECTION TO CREATE BEFORE GRADE FILE***********************;
DATA SIMSTERM;
SET SIMSTERM_ORIG;
IF STRM="&term" THEN SEMESTER="S&term2";   /*<-- CHANGE FOR EACH SEMESTER*/ *Summer = GIM**;
RK105=NATIONAL_ID;
SORT_SSN=RK105;
SORT_EMPLID=INPUT(EMPLID,8.0);
RK100=SORT_NAME;
ETHNIC_2=ETHNIC_GROUP2;
RK111=SEX;
RK261=INPUT(LAST_SCH_ATTEND, 8.0);
RT315=MAJOR;
RA532=MAIL_ADDRESS1;
RA536=MAIL_CITY;
RA537=MAIL_STATE;
RA538=MAIL_POSTAL;
RT314=SCAN(ACAD_PLAN,2,'-');
IF ADMIT_N=2 OR ADMIT_N=3 OR ADMIT_N=4 THEN RK251 = "&term2";  *Z,C,GIM must be UPPERCASE*;
RUN;


**UNT ESTABLISHED AN ORDER OF PRECEDENCE FOR REPORTING STUDENTS WHO SELECTED MULITPLE RACES INTO A SINGLE RACE **;
**ONE_RACE IS THE RACE ACCORDING TO THE PRECEDENCE LIST**;

DATA SIMSTERM;		
SET SIMSTERM;
IF ETHNIC_CATEGORY = 1 AND NTSR_CB_INTL NE 'Y' THEN ONE_RACE = '3';
ELSE IF NTSR_CB_INTL = 'Y' THEN ONE_RACE = '6';
ELSE IF NTSR_CB_BLACK = 'Y' THEN ONE_RACE = '2';
ELSE IF NTSR_CB_AM_INDIAN = 'Y' THEN ONE_RACE = '5';
ELSE IF NTSR_CB_HAWAIIAN = 'Y' THEN ONE_RACE = '8';
ELSE IF NTSR_CB_ASIAN = 'Y' THEN ONE_RACE = '4';
ELSE IF NTSR_CB_WHITE = 'Y' THEN ONE_RACE = '1';
ELSE IF NTSR_CB_UNKNOWN = 'Y' THEN ONE_RACE = '7';
RUN;

DATA SIMSTERM;
SET SIMSTERM;
IF ONE_RACE = '6' THEN ONE_RACE_DESC = 'International';
IF ONE_RACE = '3' THEN ONE_RACE_DESC = 'Hispanic';
IF ONE_RACE = '2' THEN ONE_RACE_DESC = 'Black';
IF ONE_RACE = '5' THEN ONE_RACE_DESC = 'Am_Indian';
IF ONE_RACE = '8' THEN ONE_RACE_DESC = 'Hawaiian\ Pacific Isl';
IF ONE_RACE = '4' THEN ONE_RACE_DESC = 'Asian';
IF ONE_RACE = '1' THEN ONE_RACE_DESC = 'White';
IF ONE_RACE = '7' THEN ONE_RACE_DESC = 'Unknown';
RUN;

DATA SIMSTERM;
SET SIMSTERM;
IF IPEDS_ETHNICITY = '01' THEN IPEDS_DESC = 'Nonresident Alien';
ELSE IF IPEDS_ETHNICITY = '07' THEN IPEDS_DESC = 'Unknown';
ELSE IF IPEDS_ETHNICITY = '08' THEN IPEDS_DESC = 'Hispanic';
ELSE IF IPEDS_ETHNICITY = '09' THEN IPEDS_DESC = 'Am_Indian\ Alaskan';
ELSE IF IPEDS_ETHNICITY = '10' THEN IPEDS_DESC = 'Asian';
ELSE IF IPEDS_ETHNICITY = '11' THEN IPEDS_DESC = 'Black';
ELSE IF IPEDS_ETHNICITY = '12' THEN IPEDS_DESC = 'Hawaiian\ Pacific Isl';
ELSE IF IPEDS_ETHNICITY = '13' THEN IPEDS_DESC = 'White';
ELSE IF IPEDS_ETHNICITY = '14' THEN IPEDS_DESC = 'Two or more races';
RUN;


DATA SIMSTERM;					**CREATES VARIABLE TO CROSSWALK GACT FROM GRAD SCHOOL TO COLLEGE IN WHICH CERT IS EARNED**;
LENGTH ACAD_GROUP_GACT $5;
SET SIMSTERM;					**VERIFIED LIST WITH ROXANNE LITMAN IN GRAD SCH 8.16.10**;
IF ACAD_PLAN = 'GACT-6SIG' THEN ACAD_GROUP_GACT = 'BUAD';	 	*Six Sigma*;
ELSE IF ACAD_PLAN = 'GACT-AAIS' THEN ACAD_GROUP_GACT = 'BUAD';	*Accounting Information Systems*;
ELSE IF ACAD_PLAN = 'GACT-ABA' THEN ACAD_GROUP_GACT = 'SOCS';	*Applied Behavior Analysis*;
ELSE IF ACAD_PLAN = 'GACT-ADCT' THEN ACAD_GROUP_GACT = 'LIBR';	*Advanced Corporate Training*;
ELSE IF ACAD_PLAN = 'GACT-ADLE' THEN ACAD_GROUP_GACT = 'COE';	*Adult Learning and Education*;
ELSE IF ACAD_PLAN = 'GACT-ADOC' THEN ACAD_GROUP_GACT = 'COE';   *Adolescent Counseling*;
ELSE IF ACAD_PLAN = 'GACT-ADUC' THEN ACAD_GROUP_GACT = 'COE';   *Adult Counseling*;
ELSE IF ACAD_PLAN = 'GACT-AIAC' THEN ACAD_GROUP_GACT = 'BUAD';	*Internal Audit*;
ELSE IF ACAD_PLAN = 'GACT-AMLA' THEN ACAD_GROUP_GACT = 'LIBR';	*Advanced Management in Libraries and Information Agencies*;
ELSE IF ACAD_PLAN = 'GACT-ARCM' THEN ACAD_GROUP_GACT = 'LIBR';	*Archival Management*;
ELSE IF ACAD_PLAN = 'GACT-ARME' THEN ACAD_GROUP_GACT = 'SOVA';	*Art Museum Education*;
ELSE IF ACAD_PLAN = 'GACT-ARTL' THEN ACAD_GROUP_GACT = 'SOVA';	*Arts Leadership*;
ELSE IF ACAD_PLAN = 'GACT-AUTI' THEN ACAD_GROUP_GACT = 'COE';	*Autism Intervention*;
ELSE IF ACAD_PLAN = 'GACT-BEHS' THEN ACAD_GROUP_GACT = 'COE';	*Behavioral Specialist*;
ELSE IF ACAD_PLAN = 'GACT-BNTL' THEN ACAD_GROUP_GACT = 'BUAD';	*Business Intelligence*;
ELSE IF ACAD_PLAN = 'GACT-CAFC' THEN ACAD_GROUP_GACT = 'COE';	*Couple and Family Counseling*;
ELSE IF ACAD_PLAN = 'GACT-CCL' THEN ACAD_GROUP_GACT = 'COE';	*Community College Leadership*;
ELSE IF ACAD_PLAN = 'GACT-CCPT' THEN ACAD_GROUP_GACT = 'COE';	*Child Counseling/Play Therapy*;
ELSE IF ACAD_PLAN = 'GACT-CMMD' THEN ACAD_GROUP_GACT = 'COE';   *Tchng Chldrn w Mild/Mod Disabl*;
ELSE IF ACAD_PLAN = 'GACT-CMLG' THEN ACAD_GROUP_GACT = 'SOCS';	*Computational Linguistics*;
ELSE IF ACAD_PLAN = 'GACT-CMRT' THEN ACAD_GROUP_GACT = 'COE';	*Master Reading Teacher*;
ELSE IF ACAD_PLAN = 'GACT-CMWT' THEN ACAD_GROUP_GACT = 'COE';	*Master Writing Teacher*;
ELSE IF ACAD_PLAN = 'GACT-CORM' THEN ACAD_GROUP_GACT = 'SOCS';	*Correction Management*;
ELSE IF ACAD_PLAN = 'GACT-CPTG' THEN ACAD_GROUP_GACT = 'LIBR';	*Corporate Training*;
ELSE IF ACAD_PLAN = 'GACT-CSSA' THEN ACAD_GROUP_GACT = 'COENG';	*Campus Security and Secur Admn*;
ELSE IF ACAD_PLAN = 'GACT-DCDM' THEN ACAD_GROUP_GACT = 'LIBR'; 	*Digital Curation and Data Management*;
ELSE IF ACAD_PLAN = 'GACT-DCMT' THEN ACAD_GROUP_GACT = 'LIBR'; 	*Digital Content Management*;
ELSE IF ACAD_PLAN = 'GACT-ENER' THEN ACAD_GROUP_GACT = 'COENG';	*Energy*;
ELSE IF ACAD_PLAN = 'GACT-EVNT' THEN ACAD_GROUP_GACT = 'SMHM';	*Event Management*;
ELSE IF ACAD_PLAN = 'GACT-GATE' THEN ACAD_GROUP_GACT = 'COE';	*Gifted and Talented Education*;
ELSE IF ACAD_PLAN = 'GACT-GGIS' THEN ACAD_GROUP_GACT = 'CLASS';	*Geographic Information Systems*;
ELSE IF ACAD_PLAN = 'GACT-HMGT' THEN ACAD_GROUP_GACT = 'SMHM';	*Hospitality Management*;
ELSE IF ACAD_PLAN = 'GACT-HRMT' THEN ACAD_GROUP_GACT = 'BUAD';	*Human Resource Management*;
ELSE IF ACAD_PLAN = 'GACT-ITAD' THEN ACAD_GROUP_GACT = 'BUAD';	*Information Technology Administration*;
ELSE IF ACAD_PLAN = 'GACT-ITFN' THEN ACAD_GROUP_GACT = 'BUAD';	*Information Technology Fundamentals*;
ELSE IF ACAD_PLAN = 'GACT-ITSC' THEN ACAD_GROUP_GACT = 'BUAD';	*Information Technology Security*;
ELSE IF ACAD_PLAN = 'GACT-IVDC' THEN ACAD_GROUP_GACT = 'JOUR';	*Interactive and Virtual Dig Comm*;
ELSE IF ACAD_PLAN = 'GACT-LPDT' THEN ACAD_GROUP_GACT = 'LIBR';	*Leadership in Prof Dev & Tech*;*;
ELSE IF ACAD_PLAN = 'GACT-LSCM' THEN ACAD_GROUP_GACT = 'BUAD';	*Logistics and Supply Chain Management*;
ELSE IF ACAD_PLAN = 'GACT-LSMT' THEN ACAD_GROUP_GACT = 'BUAD';	*Leadership & Supervisory Management*;
ELSE IF ACAD_PLAN = 'GACT-MPCT' THEN ACAD_GROUP_GACT = 'COE';	*Alternative Certification in Special Education (AKA. IMPACT)*;
ELSE IF ACAD_PLAN = 'GACT-MRCH' THEN ACAD_GROUP_GACT = 'SMHM';	*Merchandising*;
ELSE IF ACAD_PLAN = 'GACT-NAJO' THEN ACAD_GROUP_GACT = 'JOUR';	*Narrative Journalism*;
ELSE IF ACAD_PLAN = 'GACT-PLCM' THEN ACAD_GROUP_GACT = 'SOCS';	*Police Management*;
ELSE IF ACAD_PLAN = 'GACT-PMGT' THEN ACAD_GROUP_GACT = 'SOCS';	*Police Management-former code*;
ELSE IF ACAD_PLAN = 'GACT-PRIN' THEN ACAD_GROUP_GACT = 'COE';	*Principal Certification*;
ELSE IF ACAD_PLAN = 'GACT-PTED' THEN ACAD_GROUP_GACT = 'COE';	*Parent Education*;
ELSE IF ACAD_PLAN = 'GACT-PUBR' THEN ACAD_GROUP_GACT = 'JOUR';	*Public Relations*;
ELSE IF ACAD_PLAN = 'GACT-RECM' THEN ACAD_GROUP_GACT = 'COE';	*Recreation Management*;
ELSE IF ACAD_PLAN = 'GACT-RECO' THEN ACAD_GROUP_GACT = 'SOCS';	*Rehabilitation Counseling*;
ELSE IF ACAD_PLAN = 'GACT-SEBD' THEN ACAD_GROUP_GACT = 'COE';	*Trans Spec Emot/Hehv Disorders*;
ELSE IF ACAD_PLAN = 'GACT-SECR' THEN ACAD_GROUP_GACT = 'COENG';	*Security Certificate*;
ELSE IF ACAD_PLAN = 'GACT-SECT' THEN ACAD_GROUP_GACT = 'COE';	*Secondary Teacher Certification*;
ELSE IF ACAD_PLAN = 'GACT-SPAG' THEN ACAD_GROUP_GACT = 'SOCS';	*Specialist in Aging*;	
ELSE IF ACAD_PLAN = 'GACT-STRY' THEN ACAD_GROUP_GACT = 'LIBR';	*Storytelling*;
ELSE IF ACAD_PLAN = 'GACT-TESL' THEN ACAD_GROUP_GACT = 'COI';	*Teaching English to Speakers of Other Languages*;
ELSE IF ACAD_PLAN = 'GACT-TLIS' THEN ACAD_GROUP_GACT = 'COE';	*Teaching & Learning Specialist for Inclusion Settings*;
ELSE IF ACAD_PLAN = 'GACT-TTWR' THEN ACAD_GROUP_GACT = 'CLASS';	*Teaching Technical Writing*;
ELSE IF ACAD_PLAN = 'GACT-VCRM' THEN ACAD_GROUP_GACT = 'SOCS';	*Volunteer and Community Resourse Management*;
ELSE IF ACAD_PLAN = 'GACT-YLIS' THEN ACAD_GROUP_GACT = 'LIBR';	*Youth Services in Library and Information Settings*;
ELSE ACAD_GROUP_GACT = ACAD_GROUP;
RUN;

**CREATE GACT_DESCR, PROVIDE DESC COLL NAME FOR THE GACTS IN THE RESPECTIVE COLLEGES;


DATA SIMSTERM;
LENGTH GACT_DESCR $30.;   **CREATES VARIABLE TO CROSSWALK GACT FROM GRAD SCHOOL TO COLLEGE IN WHICH CERT IS EARNED**;
SET SIMSTERM;					**VERIFIED LIST WITH ROXANNE LITMAN IN GRAD SCH 8.16.10**;
IF ACAD_PLAN = 'GACT-6SIG' THEN GACT_DESCR = 'College of Business'; 	*Six Sigma*;
ELSE IF ACAD_PLAN = 'GACT-AAIS' THEN GACT_DESCR = 'College of Business';	*Accounting Information Systems*;
ELSE IF ACAD_PLAN = 'GACT-ABA' THEN GACT_DESCR = 'College Health and Public Srv';	*Applied Behavior Analysis*;
ELSE IF ACAD_PLAN = 'GACT-ADCT' THEN GACT_DESCR = 'College of Information';	*Advanced Corporate Training*;
ELSE IF ACAD_PLAN = 'GACT-ADLE' THEN GACT_DESCR = 'College of Education';	*Adult Learning and Education*;
ELSE IF ACAD_PLAN = 'GACT-ADOC' THEN GACT_DESCR = 'College of Education';   *Adolescent Counseling*;
ELSE IF ACAD_PLAN = 'GACT-ADUC' THEN GACT_DESCR = 'College of Education';   *Adult Counseling*;
ELSE IF ACAD_PLAN = 'GACT-AIAC' THEN GACT_DESCR = 'College of Business';	*Internal Audit*;
ELSE IF ACAD_PLAN = 'GACT-AMLA' THEN GACT_DESCR = 'College of Information';	*Advanced Management in Libraries and Information Agencies*;
ELSE IF ACAD_PLAN = 'GACT-ARCM' THEN GACT_DESCR = 'College of Information';	*Archival Management*;
ELSE IF ACAD_PLAN = 'GACT-ARME' THEN GACT_DESCR = 'College of Visual Arts & Desig';	*Art Museum Education*;
ELSE IF ACAD_PLAN = 'GACT-ARTL' THEN GACT_DESCR = 'College of Visual Arts & Desig';	*Arts Leadership*;
ELSE IF ACAD_PLAN = 'GACT-AUTI' THEN GACT_DESCR = 'College of Education';	*Autism Intervention*;
ELSE IF ACAD_PLAN = 'GACT-BEHS' THEN GACT_DESCR = 'College of Education';	*Behavioral Specialist*;
ELSE IF ACAD_PLAN = 'GACT-BNTL' THEN GACT_DESCR = 'College of Business';	*Business Intelligence*;
ELSE IF ACAD_PLAN = 'GACT-CAFC' THEN GACT_DESCR = 'College of Education';	*Couple and Family Counseling*;
ELSE IF ACAD_PLAN = 'GACT-CCL' THEN GACT_DESCR = 'College of Education';	*Community College Leadership*;
ELSE IF ACAD_PLAN = 'GACT-CCPT' THEN GACT_DESCR = 'College of Education';	*Child Counseling/Play Therapy*;
ELSE IF ACAD_PLAN = 'GACT-CMMD' THEN GACT_DESCR = 'College of Education';   *Tchng Chldrn w Mild/Mod Disabl*;
ELSE IF ACAD_PLAN = 'GACT-CMLG' THEN GACT_DESCR = 'College Health and Public Srv';	*Computational Linguistics*;
ELSE IF ACAD_PLAN = 'GACT-CMRT' THEN GACT_DESCR = 'College of Education';	*Master Reading Teacher*;
ELSE IF ACAD_PLAN = 'GACT-CMWT' THEN GACT_DESCR = 'College of Education';	*Master Writing Teacher*;
ELSE IF ACAD_PLAN = 'GACT-CORM' THEN GACT_DESCR = 'College Health and Public Srv';	*Correction Management*;
ELSE IF ACAD_PLAN = 'GACT-CPTG' THEN GACT_DESCR = 'College of Information';	*Corporate Training*;
ELSE IF ACAD_PLAN = 'GACT-CSSA' THEN GACT_DESCR = 'College of Engineering';	*Campus Security and Secur Admn*;
ELSE IF ACAD_PLAN = 'GACT-DCDM' THEN GACT_DESCR = 'College of Information'; 	*Digital Curation and Data Management*;
ELSE IF ACAD_PLAN = 'GACT-DCMT' THEN GACT_DESCR = 'College of Information'; 	*Digital Content Management*;
ELSE IF ACAD_PLAN = 'GACT-ENER' THEN GACT_DESCR = 'College of Engineering';	 *Energy*;
ELSE IF ACAD_PLAN = 'GACT-EVNT' THEN GACT_DESCR = 'Merchndsng, Hosptlty & Tourism';	*Event Management*;
ELSE IF ACAD_PLAN = 'GACT-GATE' THEN GACT_DESCR = 'College of Education';	*Gifted and Talented Education*;
ELSE IF ACAD_PLAN = 'GACT-GGIS' THEN GACT_DESCR = 'College of Lib Arts and Soc Sc';	*Geographic Information Systems*;
ELSE IF ACAD_PLAN = 'GACT-HMGT' THEN GACT_DESCR =  'Merchndsng, Hosptlty & Tourism';	*Hospitality Management*;
ELSE IF ACAD_PLAN = 'GACT-HRMT' THEN GACT_DESCR = 'College of Business';	*Human Resource Management*;
ELSE IF ACAD_PLAN = 'GACT-ITAD' THEN GACT_DESCR = 'College of Business';	*Information Technology Administration*;
ELSE IF ACAD_PLAN = 'GACT-ITFN' THEN GACT_DESCR = 'College of Business';	*Information Technology Fundamentals*;
ELSE IF ACAD_PLAN = 'GACT-ITSC' THEN GACT_DESCR = 'College of Business';	*Information Technology Security*;
ELSE IF ACAD_PLAN = 'GACT-IVDC' THEN GACT_DESCR = 'Mayborn School of Journalism';	*Interactive and Virtual Dig Comm*;
ELSE IF ACAD_PLAN = 'GACT-LPDT' THEN GACT_DESCR = 'College of Information';	*Leadership in Prof Dev & Tech*;
ELSE IF ACAD_PLAN = 'GACT-LSCM' THEN GACT_DESCR = 'College of Business';	*Logistics and Supply Chain Management*;
ELSE IF ACAD_PLAN = 'GACT-LSMT' THEN GACT_DESCR = 'College of Business';	*Leadership & Supervisory Management*;
ELSE IF ACAD_PLAN = 'GACT-MPCT' THEN GACT_DESCR = 'College of Education';	*Alternative Certification in Special Education (AKA. IMPACT)*;
ELSE IF ACAD_PLAN = 'GACT-MRCH' THEN GACT_DESCR = 'Merchndsng, Hosptlty & Tourism';	*Merchandising*;
ELSE IF ACAD_PLAN = 'GACT-NAJO' THEN GACT_DESCR = 'Mayborn School of Journalism';	*Narrative Journalism*;
ELSE IF ACAD_PLAN = 'GACT-PLCM' THEN GACT_DESCR = 'College Health and Public Srv';	*Police Management*;
ELSE IF ACAD_PLAN = 'GACT-PMGT' THEN GACT_DESCR = 'College Health and Public Srv';	*Police Management-former code*;
ELSE IF ACAD_PLAN = 'GACT-PRIN' THEN GACT_DESCR = 'College of Education';	*Principal Certification*;
ELSE IF ACAD_PLAN = 'GACT-PTED' THEN GACT_DESCR = 'College of Education';	*Parent Education*;
ELSE IF ACAD_PLAN = 'GACT-PUBR' THEN GACT_DESCR = 'Mayborn School of Journalism';	*Public Relations*;
ELSE IF ACAD_PLAN = 'GACT-RECM' THEN GACT_DESCR = 'College of Education';	*Recreation Management*;
ELSE IF ACAD_PLAN = 'GACT-RECO' THEN GACT_DESCR = 'College Health and Public Srv';	*Rehabilitation Counseling*;
ELSE IF ACAD_PLAN = 'GACT-SEBD' THEN GACT_DESCR = 'College of Education';	*Trans Spec Emot/Hehv Disorders*;
ELSE IF ACAD_PLAN = 'GACT-SECR' THEN GACT_DESCR = 'College of Engineering';	*Security Certificate*;
ELSE IF ACAD_PLAN = 'GACT-SECT' THEN GACT_DESCR = 'College of Education';	*Secondary Teacher Certification*;
ELSE IF ACAD_PLAN = 'GACT-SPAG' THEN GACT_DESCR = 'College Health and Public Srv';	*Specialist in Aging*;	
ELSE IF ACAD_PLAN = 'GACT-STRY' THEN GACT_DESCR = 'College of Information';	*Storytelling*;
ELSE IF ACAD_PLAN = 'GACT-TESL' THEN GACT_DESCR = 'College of Information';	*Teaching English to Speakers of Other Languages*;
ELSE IF ACAD_PLAN = 'GACT-TLIS' THEN GACT_DESCR = 'College of Education';	*Teaching & Learning Specialist for Inclusion Settings*;
ELSE IF ACAD_PLAN = 'GACT-TTWR' THEN GACT_DESCR = 'College of Lib Arts and Soc Sc';	*Teaching Technical Writing*;
ELSE IF ACAD_PLAN = 'GACT-VCRM' THEN GACT_DESCR = 'College Health and Public Srv';	*Volunteer and Community Resourse Management*;
ELSE IF ACAD_PLAN = 'GACT-YLIS' THEN GACT_DESCR = 'College of Information';	*Youth Services in Library and Information Settings*;
ELSE GACT_DESCR = GROUP_DESCR;
RUN;

DATA NEWGACT;		**CHECKS FOR ANY NEW GACTs THAT SHOULD BE ADDED TO THE ABOVE LIST**;
SET SIMSTERM;
IF PROG_DESCR = 'Graduate Academic Certificate' & ACAD_PLAN NOT IN ('GACT-6SIG','GACT-AAIS','GACT-ABA','GACT-ADCT',
	'GACT-ADLE','GACT-ADOC','GACT-ADUC','GACT-AIAC','GACT-AMLA','GACT-ARCM','GACT-ARME','GACT-ARTL','GACT-AUTI','GACT-BEHS','GACT-BNTL',
	'GACT-CAFC','GACT-CCL','GACT-CCPT','GACT-CMMD','GACT-CMLG', 'GACT-CMRT','GACT-CMWT','GACT-CORM','GACT-CPTG','GACT-CSSA','GACT-DCDM','GACT-DCMT',
	'GACT-ENER','GACT-EVNT','GACT-GATE','GACT-GGIS','GACT-HMGT','GACT-HRMT','GACT-ITAD','GACT-ITFN','GACT-ITSC','GACT-IVDC',
    'GACT-LPDT','GACT-LSCM','GACT-LSMT','GACT-MPCT','GACT-MRCH','GACT-NAJO','GACT-PLCM','GACT-PMGT','GACT-PRIN','GACT-PTED', 'GACT-PUBR',
	'GACT-RECM','GACT-RECO','GACT-SEBD','GACT-SECR','GACT-SECT','GACT-SPAG','GACT-STRY','GACT-TESL',
	'GACT-TLIS','GACT-TTWR','GACT-VCRM','GACT-YLIS')
	THEN OUTPUT NEWGACT; 
RUN;

proc sql noprint;
select count(*) into: newgact
from work.newgact;
quit;

ods _all_ close;

%if &newgact~=0 %then %do;
%put "New Graduate Certificates Found - File Not Created - Go Back & Revise Code & Rerun";
ods html;
title 'New Graduate Certificates - File Not Created - Revise Code & Run Again (Use Information in Table Below)';

TITLE1 "************************************************************************";
TITLE2 "IF NO NEW GACTs ARE FOUND THIS REPORT WILL NOT PRINT";
TITLE3 "IF NEW GACTs ARE FOUND, ADD THEM TO BOTH OF THE ABOVE LISTS AND RERUN SIMSTERM";
PROC FREQ DATA = NEWGACT;  *IF ANY NEW GACTS ARE FOUND ADD TO LIST AND RERUN SIMSTERM**;
TABLE ACAD_PLAN;
RUN;
%end;

%else %do;
%put "No New Graduate Certificates---File Created";
ods html;
data _null_;
title;
file print;
put _page_;
put "No New Graduate Certificates - File Created";
run;

PROC SORT DATA = SIMSTERM;
BY EMPLID;
RUN;


****retain simsterm in preferred order of variables**;

DATA SIMSTERM;
RETAIN EMPLID NAME STRM SEMESTER /*term  */

                EUID SORT_SSN   /*  key id  */

				EFFECTIVE_TERM ACAD_TERM_DESC ACAD_TERM_YR/*  semester  */

                ACAD_CAREER CLASS CLASS_DESC  CLASS3  /*  classification  */

                ADMIT_N ADMIT_N_DESC  /*  admit status  */

                INSTATE EFC FULLPART TAMS HONORS HONORS_NEW STDNT_GROUP  /* population filters  */

                AGE BIRTHDATE SEX GENDER ETHNIC_CATEGORY ETHNIC_2  ETHNIC_GROUP /*  student phyical charateristics  */
                ETHNIC_GROUP2 ETHNIC_GROUP2_DESC ONE_RACE ONE_RACE_DESC IPEDS_DESC IPEDS_ETHNICITY  

				ACAD_GROUP ACAD_GROUP_GACT GROUP_DESCR GACT_DESCR PROG_DESCR  STU_ACAD_ORG_S_DESC  /*  academic affiliations  */
                STU_ACAD_ORG_L_DESC  MAJOR PLAN_DESCR 
                ACAD_PLAN ACAD_SUB_PLAN  CIP_CODE SORT_PROG ACAD_PLAN_TYPE

                TSI_COMPLETE TOT_TAKEN_PRGRSS UNT_TAKEN_PRGRSS TOTALSCH CUM_GPA CUR_GPA /*  UNT progress  */               

                RESID RESIDENCY PRSTATUS PRSTATUS_DESC  CITIZENSHIP_COUNTRY VISA_PERMIT_TYPE /*  residency status */
                O_COUNTRY O_COUNTRY_DESC O_STATE O_STATE_DESC O_COUNTY O_COUNTY_DESC O_DISTRICT

				COUNTRY COUNTRY_DESC STATE STATE_DESC SHORT_COUNTY  COUNTY_DESC COUNTY COUNTYX COUNTYZ  /*  locations  */
			    MSA_COUNTY_CODE MSA_COUNTY_DESC MSA_CODE MSA_DESC

				ADM_APPL_CTR RUN_DTTM REFRESH_DT DW_RUN_DESC EFF_STATUS STDNT_CAR_NBR  /*  CLUTTER  */
				STDNT_KEY2 STDNT_ENRL_STATUS GROUP_DESCR_HIST WITHDRAW_DATE WITHDRAW_REASON SESSION_CODE 
                 CLASS_RANK CLASS_SIZE CENSUS CENSUS_SAS ADMIT_TERM EXT_SUMM_TYPE EXT_CAREER
				 STDT_APRG STDT_APRG_PRIMARY SHORT_RES 

				NTSR_CB_ASIAN NTSR_CB_AM_INDIAN  NTSR_CB_BLACK  NTSR_CB_HAWAIIAN /* ethnicities  */
                NTSR_CB_INTL NTSR_CB_UNKNOWN  NTSR_CB_WHITE 

				ACAD_LEVEL_BOT ACAD_LEVEL_BOT_DESC  CLASS2 CLASS2_DESC FT_FRESHMAN/* auxilary classification  */
                ADMIT_TYPE ADMIT_TYPE_DESC 

				NAME_PREFIX FIRST_NAME LAST_NAME NAME_SUFFIX SORT_NAME SORT_EMPLID     /*  auxilary ID  */
                PRIOR_NATIONAL_ID NATIONAL_ID 

                RK105 RK100  RK111 RK251 RK261 RT314 RT315 RA532 RA536 RA537 RA538  /*  OLD SIMS */

			   	NTSR_INTER_IN NTSR_INTER_OUT LAST_SCH_ATTEND LAST_SCH_ATTEND_DESC    /*  other institutions */
                LAST_SCH_ATTEND_TYPE HSRANK HSRANK4 HSRANK5 HSRANK9 PERCENTILE

                TEST_ID DEC_ACTC ACT_COMP_SCORE ACT_ENGL_SCORE ACT_MATH_SCORE ACT_READ_SCORE  /*  test scores  */
				ACT_SCIRE_SCORE ACT_WRITING_SCORE  DEC_SATT DEC_SATM DEC_SATV SAT_ESSAY_SCORE SAT_TOTAL_SCORE SAT_MATH_SCORE
                SAT_VERB_SCORE  SAT_WRITING_SCORE GMAT_TTL GMAT_TOTAL_SCORE GMAT_MTH GMAT_QUAN_SCORE GMAT_VRB
				GMAT_VERB_SCORE GMAT_ANLY_SCORE GRE_TOTL GRE_QUAN GRE_QUAN_SCORE GRE_SQUAN_SCORE
                GRE_VERB GRE_VERB_SCORE GRE_SVERB_SCORE GRE_WRITING_SCORE GRE_ANLY_SCORE TOEFL_COMPC_SCORE TOEFL_COMPP_SCORE  

				EMAIL_ADDRESS CELL_PHONE_NMBR MAIN_PHONE_NMBR PERM_PHONE_NMBR MAIL_ADDRESS_TYPE MAIL_ADDRESS1  /* contact information */
                MAIL_ADDRESS2 MAIL_ADDRESS3 MAIL_ADDRESS4  MAIL_CITY MAIL_STATE MAIL_POSTAL

				GBSA_GTP_STATUS GBSA_GTP_STATUS_DESC GTP_START_TERM GTP_END_TERM;

SET SIMSTERM;
RUN;

DATA "C:\Users\jrk0200\UNT System\Clark, Allen - FriscoEnrollment\Simsterm\&file2";
SET SIMSTERM;
RUN;

%end;

%mend create;

%create();



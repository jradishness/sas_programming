# sas_programming
Repository of Programs developed for UNT UIS

All programs are stored either in the SAS DATA PROJECTS folder in the shared drive, 
or in the FRISCO GUIDED PATHS directory inside there.

### 1. FGP_CHECK_START - 
Program to load enrollments and datasets for students currently 
enrolled in >1 course in (IP, HP, CHEC), to be used with FGP_CHECK_MACRO program.
FGP_CHECK_START_DEV - Program copy for development.
Creates 2 Reports:
Report 1 - ACAD_PLANS - SAVED IN NEW COLLEGE SHAREPOINT - \Reports
Tab1 - Total count of Degree Plans for all filtered students.
Tab2 - Total count of Degree Plans (in Guided Pathway) for all filtered students.
Report 2 - FRSTUD_NONFRCOURSE_DATA - SAVED IN NEW COLLEGE SHAREPOINT - \Reports
Tab1 - Cross-tab of all courses and their locations, for all filtered students (with 
GP degree program).
Tab2 - Student/course details for each of the aforementioned enrollments.

### 2. FGP_CHECK_MACRO - 
Program to project backlogged classes for Guided Pathways.
FGP_CHECK_MACRO_DEV - Program copy for development.
Creates 2 Reports:
Report 1 - LEFTOVER - SAVED IN NEW COLLEGE SHAREPOINT - \Reports
Tabs - a tab for each program in the Guided Pathway, each showing how many students 
in the program currently lack each course in the program's GP.
Report 2 - LEFTOVER_TOTAL - SAVED IN NEW COLLEGE SHAREPOINT - \Reports
Tab1 - Total count of students for each needed course (crosses boundaries within GP).
Tab2 - Student/course details for each of the aforementioned needed enrollments.

### 3. THERMOMETER - 
Program to gather current enrollment and compare with 2018 Census 
enrollment. 
Report - THERMOMETER_(DATE) - SAVED IN VAC ONEDRIVE - FriscoEnrollment\Reports
Tab1 - Count of students by Admit Status and Location. 
Tab2 - Count of course enrollments by Admit Status and Location. 
Tab3 - Count of enrolled credit hours by Admit Status and Location.

### 4. ENROLL_SIMST_JK - 
Program to gather and save current enrollment and simsterm data.
SIMSTERM - LOADS INTO MEMORY, AND SAVES IN VAC ONEDRIVE - FriscoEnrollment\SIMSTERM
ENROLLMENT - LOADS INTO MEMORY, AND SAVES IN VAC ONEDRIVE - FriscoEnrollment\ENROLLMENT

### 5. COURSES IN FRISCO - 
CURRENT DAY 5-6-2019_JK - Program to generate enrollment 
report for Molly. Also generating a second report with a picture of the trajectory
graph.
Creates 2 Reports:
Report 1 - FALL_2019_(DATE) - SAVED IN VAC ONEDRIVE - FriscoEnrollment
Tab1 - Executive Report - Not yet built
Tab2 - College Report - Not yet built
Tab3 - Course Report - Enrollment Details for courses offered at Frisco (IP, HP, CHEC).
Tab4 - Trajectory - Historical Trend Comparison
Report 2 - TRAJECTORY - Not yet completed
Tab1 - Line Graph comparison of current Trajectory with last year.

### 6. MAIN_COUNT_OF_COLLIN - 
Program to report the number of students who have taken
1-6 courses on main campus, while also taking at least one course in Frisco.
REPORT - MAIN_COUNT_(DATE) - SAVED IN VAC ONEDRIVE - FriscoEnrollment\Reports

### 7. FRISCO_SENIORS - 
Program to report Frisco seniors for a project for Vincent Fisher.

### 8. EXCLTAGS.TPL - 
Template Program for the tagsets.excelxp ODS destination.



## UNUSED PROGRAMS

### SPLIT_STUDENTS - Program to divide SIMSTERM by level (Freshman, Sophomore, Junior,
Senior, Grad).

### JK_SHORTCUT - Program stub filled with useful commands and functions.

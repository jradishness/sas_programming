import csv
from datetime import date
today = date.today()
# open_file = "csv_to_python_121119.csv"  # SET MANUAL PATH
open_file = "csv_to_python_" + today.strftime("%m%d%y") + ".csv"  # SET PATH AUTOMATICALLY
save_file = open("frisco_course_html.txt", "w")


# G. Brint Ryan College of Business
print("""<ul class="accordion" data-accordion="">
 <li class="accordion-navigation">
    <a href="#panel1a">G. Brint Ryan College of   Business</a>
    <div id="panel1a" class="content">
<table cellspacing="0" cellpadding="0" width="100%">
  <tbody><tr>
    <th>Subject</th>
    <th>Catalog</th>
    <th>Section</th>
    <th>Career</th>
    <th>Description</th>
    <th>Room</th>
    <th>Start</th>
    <th>End</th>
    <th>Days</th>
    <th>Instructor</th>
    <th>Campus</th>
  </tr>""", file=save_file)

with open(open_file) as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        if row["College_School_Descr"] == "College of Business":
            print("  <tr>", file=save_file)
            print("    <td>" + str(row["Subject"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Catalog"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Section"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Career"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Course_Descr"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Facil_ID"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_Start"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_End"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Days_of_the_Week"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Name"]) + "</td>", file=save_file)
            print("    <td>" + str(row["CAMPUS2"]) + "</td>", file=save_file)
            print("  </tr>", file=save_file)

# College of Liberal Arts and Social Sciences
print("""</tbody></table>    </div>
  </li>
  <li class="accordion-navigation">
    <a href="#panel2a">College of Liberal Arts and   Social Sciences</a>
    <div id="panel2a" class="content">
<table cellspacing="0" cellpadding="0" width="100%">
  <tbody><tr>
    <th>Subject</th>
    <th>Catalog</th>
    <th>Section</th>
    <th>Career</th>
    <th>Description</th>
    <th>Room</th>
    <th>Start</th>
    <th>End</th>
    <th>Days</th>
    <th>Instructor</th>
    <th>Campus</th>
  </tr>""", file=save_file)

with open(open_file) as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        if row["College_School_Descr"] == "Col of Lib Arts & Social Sci":
            print("  <tr>", file=save_file)
            print("    <td>" + str(row["Subject"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Catalog"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Section"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Career"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Course_Descr"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Facil_ID"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_Start"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_End"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Days_of_the_Week"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Name"]) + "</td>", file=save_file)
            print("    <td>" + str(row["CAMPUS2"]) + "</td>", file=save_file)
            print("  </tr>", file=save_file)

# College of Education
print("""</tbody></table>    </div>
  </li>
  <li class="accordion-navigation">
    <a href="#panel4a">College of Education</a>
    <div id="panel4a" class="content">
<table cellspacing="0" cellpadding="0" width="100%">
  <tbody><tr>
    <th>Subject</th>
    <th>Catalog</th>
    <th>Section</th>
    <th>Career</th>
    <th>Description</th>
    <th>Room</th>
    <th>Start</th>
    <th>End</th>
    <th>Days</th>
    <th>Instructor</th>
    <th>Campus</th>
  </tr>""", file=save_file)

with open(open_file) as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        if row["College_School_Descr"] == "College of Education":
            print("  <tr>", file=save_file)
            print("    <td>" + str(row["Subject"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Catalog"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Section"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Career"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Course_Descr"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Facil_ID"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_Start"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_End"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Days_of_the_Week"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Name"]) + "</td>", file=save_file)
            print("    <td>" + str(row["CAMPUS2"]) + "</td>", file=save_file)
            print("  </tr>", file=save_file)

# College of Engineering
print("""</tbody></table>    </div>
  </li>
  <li class="accordion-navigation">
    <a href="#panel5a">College of Engineering</a>
    <div id="panel5a" class="content">
<table cellspacing="0" cellpadding="0" width="100%">
  <tbody><tr>
    <th>Subject</th>
    <th>Catalog</th>
    <th>Section</th>
    <th>Career</th>
    <th>Description</th>
    <th>Room</th>
    <th>Start</th>
    <th>End</th>
    <th>Days</th>
    <th>Instructor</th>
    <th>Campus</th>
  </tr>""", file=save_file)

with open(open_file) as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        if row["College_School_Descr"] == "College of Engineering":
            print("  <tr>", file=save_file)
            print("    <td>" + str(row["Subject"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Catalog"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Section"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Career"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Course_Descr"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Facil_ID"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_Start"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_End"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Days_of_the_Week"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Name"]) + "</td>", file=save_file)
            print("    <td>" + str(row["CAMPUS2"]) + "</td>", file=save_file)
            print("  </tr>", file=save_file)

# College of Science
print("""</tbody></table>    </div>
  </li>
  <li class="accordion-navigation">
    <a href="#panel6a">College of Science</a>
    <div id="panel6a" class="content">
<table cellspacing="0" cellpadding="0" width="100%">
  <tbody><tr>
    <th>Subject</th>
    <th>Catalog</th>
    <th>Section</th>
    <th>Career</th>
    <th>Description</th>
    <th>Room</th>
    <th>Start</th>
    <th>End</th>
    <th>Days</th>
    <th>Instructor</th>
    <th>Campus</th>
  </tr>""", file=save_file)

with open(open_file) as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        if row["College_School_Descr"] == "College of Science":
            print("  <tr>", file=save_file)
            print("    <td>" + str(row["Subject"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Catalog"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Section"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Career"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Course_Descr"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Facil_ID"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_Start"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_End"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Days_of_the_Week"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Name"]) + "</td>", file=save_file)
            print("    <td>" + str(row["CAMPUS2"]) + "</td>", file=save_file)
            print("  </tr>", file=save_file)

# Graduate School
print("""</tbody></table>    </div>
  </li>
  <li class="accordion-navigation">
    <a href="#panel7a">Graduate School</a>
    <div id="panel7a" class="content">
<table cellspacing="0" cellpadding="0" width="100%">
  <tbody><tr>
    <th>Subject</th>
    <th>Catalog</th>
    <th>Section</th>
    <th>Career</th>
    <th>Description</th>
    <th>Room</th>
    <th>Start</th>
    <th>End</th>
    <th>Days</th>
    <th>Instructor</th>
    <th>Campus</th>
  </tr>""", file=save_file)

with open(open_file) as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        if row["College_School_Descr"] == "Graduate School":
            print("  <tr>", file=save_file)
            print("    <td>" + str(row["Subject"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Catalog"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Section"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Career"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Course_Descr"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Facil_ID"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_Start"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_End"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Days_of_the_Week"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Name"]) + "</td>", file=save_file)
            print("    <td>" + str(row["CAMPUS2"]) + "</td>", file=save_file)
            print("  </tr>", file=save_file)

# # Mayborn School of Journalism
# print("""</tbody></table>    </div>
#   </li>
#   <li class="accordion-navigation">
#     <a href="#panel9a">Mayborn School of Journalism</a>
#     <div id="panel9a" class="content">
# <table cellspacing="0" cellpadding="0" width="100%">
#   <tbody><tr>
#     <th>Subject</th>
#     <th>Catalog</th>
#     <th>Section</th>
#     <th>Career</th>
#     <th>Description</th>
#     <th>Room</th>
#     <th>Start</th>
#     <th>End</th>
#     <th>Days</th>
#     <th>Instructor</th>
#     <th>Campus</th>
#   </tr>""", file=save_file)
#
# with open(open_file) as csv_file:
#     csv_reader = csv.DictReader(csv_file)
#     for row in csv_reader:
#         if row["College_School_Descr"] == "Mayborn School of Journalism":
#             print("  <tr>", file=save_file)
#             print("    <td>" + str(row["Subject"]) + "</td>", file=save_file)
#             print("    <td>" + str(row["Catalog"]) + "</td>", file=save_file)
#             print("    <td>" + str(row["Section"]) + "</td>", file=save_file)
#             print("    <td>" + str(row["Career"]) + "</td>", file=save_file)
#             print("    <td>" + str(row["Course_Descr"]) + "</td>", file=save_file)
#             print("    <td>" + str(row["Facil_ID"]) + "</td>", file=save_file)
#             print('    <td align="right">' + str(row["Mtg_Start"]) + "</td>", file=save_file)
#             print('    <td align="right">' + str(row["Mtg_End"]) + "</td>", file=save_file)
#             print("    <td>" + str(row["Days_of_the_Week"]) + "</td>", file=save_file)
#             print("    <td>" + str(row["Name"]) + "</td>", file=save_file)
#             print("    <td>" + str(row["CAMPUS2"]) + "</td>", file=save_file)
#             print("  </tr>", file=save_file)


# College of Information
print("""</tbody></table>    </div>
  </li>
  <li class="accordion-navigation">
    <a href="#panel9a">College of Information</a>
    <div id="panel9a" class="content">
<table cellspacing="0" cellpadding="0" width="100%">
  <tbody><tr>
    <th>Subject</th>
    <th>Catalog</th>
    <th>Section</th>
    <th>Career</th>
    <th>Description</th>
    <th>Room</th>
    <th>Start</th>
    <th>End</th>
    <th>Days</th>
    <th>Instructor</th>
    <th>Campus</th>
  </tr>""", file=save_file)

with open(open_file) as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        if row["College_School_Descr"] == "College of Information":
            print("  <tr>", file=save_file)
            print("    <td>" + str(row["Subject"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Catalog"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Section"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Career"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Course_Descr"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Facil_ID"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_Start"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_End"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Days_of_the_Week"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Name"]) + "</td>", file=save_file)
            print("    <td>" + str(row["CAMPUS2"]) + "</td>", file=save_file)
            print("  </tr>", file=save_file)

# New College
print("""</tbody></table>    </div>
  </li>
  <li class="accordion-navigation">
    <a href="#panel10a">New College</a>
    <div id="panel10a" class="content">
<table cellspacing="0" cellpadding="0" width="100%">
  <tbody><tr>
    <th>Subject</th>
    <th>Catalog</th>
    <th>Section</th>
    <th>Career</th>
    <th>Description</th>
    <th>Room</th>
    <th>Start</th>
    <th>End</th>
    <th>Days</th>
    <th>Instructor</th>
    <th>Campus</th>
  </tr>""", file=save_file)

with open(open_file) as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        if row["College_School_Descr"] == "New College":
            print("  <tr>", file=save_file)
            print("    <td>" + str(row["Subject"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Catalog"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Section"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Career"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Course_Descr"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Facil_ID"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_Start"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_End"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Days_of_the_Week"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Name"]) + "</td>", file=save_file)
            print("    <td>" + str(row["CAMPUS2"]) + "</td>", file=save_file)
            print("  </tr>", file=save_file)

# College of Merchandising, Hospitality and Tourism
print("""</tbody></table>    </div>
  </li>
  <li class="accordion-navigation">
    <a href="#panel11a">College of Merchandising, Hospitality and Tourism</a>
    <div id="panel11a" class="content">
<table cellspacing="0" cellpadding="0" width="100%">
  <tbody><tr>
    <th>Subject</th>
    <th>Catalog</th>
    <th>Section</th>
    <th>Career</th>
    <th>Description</th>
    <th>Room</th>
    <th>Start</th>
    <th>End</th>
    <th>Days</th>
    <th>Instructor</th>
    <th>Campus</th>
  </tr>""", file=save_file)

with open(open_file) as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        if row["College_School_Descr"] == "College of Mrch, Hosp, Tourism":
            print("  <tr>", file=save_file)
            print("    <td>" + str(row["Subject"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Catalog"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Section"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Career"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Course_Descr"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Facil_ID"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_Start"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_End"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Days_of_the_Week"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Name"]) + "</td>", file=save_file)
            print("    <td>" + str(row["CAMPUS2"]) + "</td>", file=save_file)
            print("  </tr>", file=save_file)

# College of Health and Public Service
print("""</tbody></table>    </div>
  </li>
  <li class="accordion-navigation">
    <a href="#panel12a">College of Health and Public Service</a>
    <div id="panel12a" class="content">
<table cellspacing="0" cellpadding="0" width="100%">
  <tbody><tr>
    <th>Subject</th>
    <th>Catalog</th>
    <th>Section</th>
    <th>Career</th>
    <th>Description</th>
    <th>Room</th>
    <th>Start</th>
    <th>End</th>
    <th>Days</th>
    <th>Instructor</th>
    <th>Campus</th>
  </tr>""", file=save_file)

with open(open_file) as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        if row["College_School_Descr"] == "Col of Health & Public Service":
            print("  <tr>", file=save_file)
            print("    <td>" + str(row["Subject"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Catalog"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Section"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Career"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Course_Descr"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Facil_ID"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_Start"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_End"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Days_of_the_Week"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Name"]) + "</td>", file=save_file)
            print("    <td>" + str(row["CAMPUS2"]) + "</td>", file=save_file)
            print("  </tr>", file=save_file)

# College of Visual Arts and Design
print("""</tbody></table>    </div>
  </li>
  <li class="accordion-navigation">
    <a href="#panel13a">College of Visual Arts and Design</a>
    <div id="panel13a" class="content">
<table cellspacing="0" cellpadding="0" width="100%">
  <tbody><tr>
    <th>Subject</th>
    <th>Catalog</th>
    <th>Section</th>
    <th>Career</th>
    <th>Description</th>
    <th>Room</th>
    <th>Start</th>
    <th>End</th>
    <th>Days</th>
    <th>Instructor</th>
    <th>Campus</th>
  </tr>""", file=save_file)

with open(open_file) as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        if row["College_School_Descr"] == "College of Visual Arts & Dsgn":
            print("  <tr>", file=save_file)
            print("    <td>" + str(row["Subject"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Catalog"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Section"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Career"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Course_Descr"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Facil_ID"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_Start"]) + "</td>", file=save_file)
            print('    <td align="right">' + str(row["Mtg_End"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Days_of_the_Week"]) + "</td>", file=save_file)
            print("    <td>" + str(row["Name"]) + "</td>", file=save_file)
            print("    <td>" + str(row["CAMPUS2"]) + "</td>", file=save_file)
            print("  </tr>", file=save_file)

print("""</tbody></table>    </div>
  </li>
</ul>""", file=save_file)






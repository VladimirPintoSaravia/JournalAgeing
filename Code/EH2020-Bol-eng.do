/*******************************************************************************
El Colegio de Mexico
Centro de Estudios Demograficos Urbanos y Ambientales - CEDUA
Title: Socioeconomic inequalities in health among Indigenous older adults in Bolivia in times of COVID-19

Objective:
 1) To determine the association between sociodemographic variables with self-reported COVID-19 symptoms.
 2) To investigate whether this relationship shows inequalities by ethnicity and age.

Dependent variable: People who self-reported symptoms of COVID-19
Independent variables: Employment type, Household living arrangements, Attained education, Age, Ethnicity
Control variables: gender, current status, residence area 

Database: Household Survey 2020. Representative of houses, households and their residing population at a national, urban and rural level. 

Analytical sample n=16 910

Date created:Jan/14/2022
Last modification: Apr/10/2022

License:	El Colegio de México
Ado(s):	chowtest

Database site: http://anda.ine.gob.bo/index.php/catalog/88
*******************************************************************************/

*The original database is on SPSS format.
*Note: replace the file path for yours.

*Once downloaded and unzipped, import into stata extension
import spss using "C:\Users\Vladimir Pinto\Documents\Base de datos\Bolivia\EH Bolivia\2020\EH2020_Persona.sav", clear

*Save as file
save "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Journal of population ageing\EH2020_Persona.dta"

*Use the file
use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Journal of population ageing\EH2020_Persona.dta"

************************************************
****************Bolivia 2020********************
************************************************
clear all
use "C:\Users\Vladimir Pinto\OneDrive - El Colegio de México A.C\Journal of population ageing\EH2020_Persona.dta", clear
set more off

*Adultos mayores en el hogar
by folio, sort: egen numadm = total(inrange(s01a_03,60,112))
label variable numadm "number of adult persons in the house"

*Crear variable de año
generate int year:YEAR = 2020
label variable year "year"


**# Bookmark #1
*********************************************************************
*******DEPENDENT VARIABLE: self-reported symptoms of COVID-19********
*********************************************************************

recode s02a_02 ///
	(1 = 1 "With symptoms") ///
	(2 = 0 "Without_symptoms") ///
	, gen (covid) label (covid)
label variable covid "self-reported symptoms of COVID-19"
tab covid, missing


*********************************************************************
********************INDEPENDENT VARIABLES****************************
*********************************************************************

**# Bookmark #2
***********Attained education
*Conversion of the variable aestudio to the variable education to standardize educational attainment.
recode aestudio ///
	(0/6 . = 1 "Grade") ///
	(7/11 = 2 "Some high school") ///
	(12 = 3 "High school graduate") ///
	(13/23 = 4 "College graduate") ///
	, gen (educacion) label (educacion)
label variable educacion "Attained education"

**# Bookmark #3
***********Ethnicity

***A) Ethnic affiliation - PE
tab s01a_08, mi

*Conversion of variable s01a_08 to ethnicity
*Original question: Como boliviana o boliviano ¿A que nación o pueblo indígena originario o campesino o afro boliviano pertenece?
*Translated question: As a Bolivian woman or man, to which nation or indigenous people do you belong? or peasant or Afro-Bolivian people do you belong to?

recode s01a_08 ///
	(1 = 1 "Belong") ///
	(2 = 0 "Does_not_belong_to") ///
	, gen (PE) label (PE)
label variable PE "Ethnic affiliation"
replace PE=. if PE == 3
tab PE, missing

***B) Spoken language - IH
*B.1) First languaje
tab s01a_06_1,mi
*Conversion of variable s01a_06_1 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 1°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 1°

recode s01a_06_1 ///
	(2 10/33 = 1 "Native language") ///
	(6 = 0 "Spanish") ///
	(41/996 = 3 "Other") ///
	, gen (IH_1) label (IH_1)
label variable IH_1 "Spoken language 1"
replace IH_1=. if IH_1 == 3
tab IH_1, missing

*B.2) Second languaje
tab s01a_06_2,mi
*Conversion of variable s01a_06_2 to Spoken language
*Original question: ¿Qué Idiomas habla, incluidos los de las naciones y pueblos indígena originarios? 2°
*Translated question: Which languages do you speak, including those of indigenous nations and native indigenous peoples? 2°

recode s01a_06_2 ///
	(1/4 7/34 39 = 1 "Native language") ///
	(6 = 0 "Spanish") ///
	(41/70 = 3 "Other") ///
	, gen (IH_2) label (IH_2)
label variable IH_2 "Spoken language 2"
replace IH_2=. if IH_2 == 3
tab IH_2, missing

*Construction of the spoken language variable
// .f = fill - Produces a vector with value other than missing.
gen IH = .f
replace IH = 0 if IH_1 == 0 | IH_2 == 0
replace IH = 1 if IH_1 == 1 | IH_2 == 1
replace IH = 2 if IH_1 == 0 & IH_2 == 1 | IH_1 == 1 & IH_2 == 0

label define IH ///
0 "Spanish" ///
1 "Native language without Spanish" ///
2 "Native language with Spanish"
label values IH IH
label variable IH "Spoken language"
tab IH, missing

***C) Mother tongue  - LM
tab s01a_07,mi
*Conversion of variable s01a_07 to Mother tongue 
*Original question: ¿Cuál es el idioma o lengua en el que aprendió a hablar en su niñez?
*Translated question: What is the first language you learned to speak as a child?

recode s01a_07 ///
	(2 4 7/33 = 1 "Native") ///
	(6 34/60  = 0 "Not_Native") ///
	, gen (LM) label (LM)
label variable LM "Mother tongue"
tab LM, missing

***Creating the Ethnic Linguistic Condition variable - CEL
// .f = fill - Produces a vector with value other than missing.
gen CEL = .f
replace CEL = 0 if PE == 0 & IH == 0 & LM == 0
replace CEL = 1 if PE == 0 & IH == 2 & LM == 0
replace CEL = 2 if PE == 0 & IH == 2 & LM == 1
replace CEL = 3 if PE == 0 & IH == 1 & LM == 1
replace CEL = 4 if PE == 1 & IH == 0 & LM == 0
replace CEL = 5 if PE == 1 & IH == 2 & LM == 0
replace CEL = 6 if PE == 1 & IH == 2 & LM == 1
replace CEL = 7 if PE == 1 & IH == 1 & LM == 1
tab CEL, missing

*Indigenous/non-indigenous cohort
recode CEL ///
	(0 1 = 1 "Ethnic status null") ///
	(2 3 = 2 "Cohort by linguistic status") ///
	(4 = 3 "Cohort by ethnicity") ///
	(5/7 = 4 "Full ethnic status") ///
	, gen (cohorte_cel) label (cohorte_cel)
label variable cohorte_cel "Cohorts by ethnic status"
tab cohorte_cel, missing

**# Bookmark #4
*Ethnicity: Indigenous/non-indigenous
recode cohorte_cel ///
	(1 .f = 0 "Non_indigenous") ///
	(2/4 = 1 "Indigenous") ///
	, gen (condic_etnica) label (condic_etnica)
label variable condic_etnica "Ethnicity"

**# Bookmark #5 
***********Employment type
*Conversion of variable cob_op to Employment type
recode cob_op ///
	(5/9 = 1 "Low-skilled worker") ///
	(0/4 = 2 "Managerial, administrative and professional and technical workers") ///
	(. = 3 "Do not work") ///
	, gen (ocupacion) label (ocupacion)
label variable ocupacion "Employment type"


**# Bookmark #6
***********Age
*Recode variable s01a_03 into edad
clonevar edad = s01a_03
destring (edad),replace

****Age groups
recode edad ///
	(30/44 = 0 "30-44") ///
	(45/59 = 1 "45-59") ///
	(60/100 = 2 "60+") ///
	, gen (edad_tres_grupos) label (edad_tres_grupos)
label variable edad_tres_grupos "Age groups"


*********************************************************************
********************CONTROL VARARIABLES******************************
*********************************************************************

**# Bookmark #7
***********Gender
*Recode variable s01a_02 into gender
tab s01a_02, mi

recode s01a_02 ///
	(2 = 1 "Mujer") ///
	(1 = 0 "Hombre") ///
	, gen (sex) label (sex)
label variable sex "Gender"
tab sex,mi

**# Bookmark #8
***********Current Employment status
*Recode variable s06a_01 into Current Employment status
recode s04a_01 ///
	(1 = 1 "Working") ///
	(2 = 0 "Not working") ///
	, gen (condicion_laboral) label (condicion_laboral)
label variable condicion_laboral "Current Employment status"
tab condicion_laboral,mi


**# Bookmark #9
***********Residence area 
*Recode variable area into urban
tab area, mi
recode area ///
	(1 = 1 "Urban") ///
	(2 = 0 "Rural") ///
	, gen (urban) label (urban)
label variable urban "urban-rural status"
tab urban,mi


**# Bookmark #10
***********Household living arrangements
*Living alone: A single person, who by definition is classified as the head of household.
*Couples with/without children: The head of household and his or her spouse, with or without children.
*Couples with/without relatives: Consisting of the nuclear or extended household plus other non-family members (other non-relatives).

*Conversion of s01a_05 variable to p_parentescor
sort folio
clonevar p_parentescor=s01a_05

*Create vectors with each family relationship
gen jefe = 1 if p_parentescor == 1
gen esp = 1 if p_parentescor == 2
gen hijo = 1 if p_parentescor == 3|p_parentescor == 4
gen yerno = 1 if p_parentescor == 5
gen hercuña = 1 if p_parentescor == 6
gen padres = 1 if p_parentescor == 7
gen otropar = 1 if p_parentescor == 10|p_parentescor == 8
gen nieto = 1 if p_parentescor == 9
gen otronopar = 1 if p_parentescor == 11
gen empl = 1 if p_parentescor == 12
gen emplpar = 1 if p_parentescor == 13

*Creates new vectors by grouping each family relationship
egen jefe_1 = total (jefe), by (folio)
egen esp_1 = total(esp), by (folio) 
egen hijo_1 = total (hijo), by (folio)
egen yerno_1 = total(yerno), by (folio)
egen nieto_1 = total(nieto), by (folio)
egen hercuña_1 = total(padres), by (folio)
egen padres_1 = total(padres), by (folio)
egen otropar_1 = total(otropar), by (folio)
egen empl_1 = total(empl), by (folio)
egen emplpar_1 = total(emplpar), by (folio)
egen otronopar_1 = total(otronopar), by (folio)

gen otropariente = yerno_1+ hercuña_1 + padres_1 + otropar_1
gen empleadapareja = empl_1 + emplpar_1

*A value is assigned for each family relationship for the calculation of the type of household arrangement.
gen jefe2 = 1 if jefe_1>0
replace jefe2 = 0 if jefe2==.

gen esp2 = 2 if esp_1>0
replace esp2 = 0 if esp2==.

gen hijo2 = 4 if hijo_1>0
replace hijo2 = 0 if hijo2==.

gen nieto2 = 8 if nieto_1>0
replace nieto2 = 0 if nieto2==.

gen otropariente2 = 16 if otropariente>0
replace otropariente2 = 0 if otropariente2==.

gen empleadapareja2 = 32 if empleadapareja>0
replace empleadapareja2 = 0 if empleadapareja2==.

gen otronopar2 = 64 if otronopar_1>0
replace otronopar2 = 0 if otronopar2==.

*The totreco variable is generated with the total of the values of the family relationship.
gen totreco = jefe2+esp2+hijo2+nieto2+otropariente2+empleadapareja2+otronopar2

*The totrecon variable is recoded with the family arrangements.
recode totreco ///
	(1 33= 1 "Living alone") ///
	(5 7 37 39 3 35= 2 "Couples with/without children") ///
	(9 13 15 41 43 45 47 11 19 21 23 51 53 55 17 25 27 29 31 49 57 59 61 63 65 67 69 71 73 75 77 79 81 83 85 87 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119= 3 "Couples with/without relatives") ///
	(0 = 4 "Other") ///
	, gen (tipo_hogar) label (tipo_hogar)
label variable tipo_hogar "Household living arrangements"


**# Bookmark #11
***********Servicios de salud
*The variable Health is created with the different care options
// .f = fill - Produces a vector with value other than missing.
gen salud = .f
*Because the COVID-19 pandemic, you went to:
replace salud = 1 if s02a_03a == 1 //Health funds
replace salud = 2 if s02a_03b == 1 //Public healthcare establishments
replace salud = 3 if s02a_03c == 1 //Private healthcare facilities
replace salud = 4 if s02a_03d == 1 //Your residence
replace salud = 5 if s02a_03e == 1 //Consultation with a traditional practitioner
replace salud = 6 if s02a_03f == 1 //Consultation with a private doctor at home
replace salud = 7 if s02a_03g == 1 //Over-the-counter pharmacy (self-medication)
tab salud, missing

*Recodes the variable Health with the health care groups.
recode salud ///
	(1 2 3 = 1 "Establecimientos de salud (Pub/priv)") ///
	(4 = 2 "Su domicilio") ///
	(5 6 = 3 "Consulta con médico particular/tradicional") ///
	(7 = 4 "Farmacia-Automedicación") ///
	(.f = 5 "Ninguno") ///
	, gen (servicio_salud) label (servicio_salud)
label variable servicio_salud "Servicio en el que se atendió Covid"
tab servicio_salud, missing


**# Bookmark #12
***Sample to the age group of interest: 30-98
mark univ if inrange(edad,30,98)

tab univ, mi
keep if univ

**# Bookmark #13
*********************************************************************
*********Selecting the database with the study variables*************
*********************************************************************

keep factor numadm year covid educacion condic_etnica ocupacion edad_tres_grupos sex urban tipo_hogar condicion_laboral

**# Bookmark #14
*********************************************************************
********************BIVARIATE ANALYSIS*******************************
*********************************************************************

**# Bookmark #15
***********Attained education
***Total
tab educacion, gen(educacion)
tab1 educacion1 educacion2 educacion3 educacion4, mi
*Appendix A
tab educacion covid [iw=factor] , row nofreq
tab educacion covid

***Ethnicity
*Appendix A
bysort condic_etnica: tab educacion covid [iw=factor] , row nofreq
bysort condic_etnica: tab educacion covid

***Age groups
*Appendix A
bysort edad_tres_grupos: tab educacion covid [iw=factor] , row nofreq
bysort edad_tres_grupos: tab educacion covid

**# Bookmark #16
***********Ethnicity
tab condic_etnica, gen(condic_etnica)
tab1 condic_etnica1 condic_etnica2, mi
*Appendix A
tab condic_etnica covid [iw=factor] , row nofreq
tab condic_etnica covid

***Age groups
*Appendix A
bysort edad_tres_grupos: tab condic_etnica covid [iw=factor] , row nofreq
bysort edad_tres_grupos: tab condic_etnica covid

**# Bookmark #17
***********Employment type
tab ocupacion, gen(ocupacion)
tab1 ocupacion1 ocupacion2 ocupacion3, mi
*Appendix A
tab ocupacion covid [iw=factor] , row nofreq
tab ocupacion covid

***Ethnicity
*Appendix A
bysort condic_etnica: tab ocupacion covid [iw=factor] , row nofreq
bysort condic_etnica: tab ocupacion covid

***Age groups
*Appendix A
bysort edad_tres_grupos: tab ocupacion covid [iw=factor] , row nofreq
bysort edad_tres_grupos: tab ocupacion covid

**# Bookmark #18
***********Current working status
tab condicion_laboral, gen(condicion_laboral)
tab1 condicion_laboral1 condicion_laboral2, mi
*Appendix A
tab condicion_laboral covid [iw=factor] , row nofreq
tab condicion_laboral covid

***Ethnicity
*Appendix A
bysort condic_etnica: tab condicion_laboral covid [iw=factor] , row nofreq
bysort condic_etnica: tab condicion_laboral covid

***Age groups
*Appendix A
bysort edad_tres_grupos: tab condicion_laboral covid [iw=factor] , row nofreq
bysort edad_tres_grupos: tab condicion_laboral covid

**# Bookmark #19
**************Age groups
tab edad_tres_grupos, gen(edad_tres_grupos)
tab1 edad_tres_grupos1 edad_tres_grupos2 edad_tres_grupos3, mi
*Appendix A
tab edad_tres_grupos covid [iw=factor] , row nofreq
tab edad_tres_grupos covid

***Ethnicity
*Appendix A
bysort condic_etnica: tab edad_tres_grupos covid [iw=factor] , row nofreq
bysort condic_etnica: tab edad_tres_grupos covid

**# Bookmark #20
***********Gender
tab sex, gen(sex)
tab1 sex1 sex2, mi
*Appendix A
tab sex covid [iw=factor] , row nofreq
tab sex covid

***Ethnicity
*Appendix A
bysort condic_etnica: tab sex covid [iw=factor] , row nofreq
bysort condic_etnica: tab sex covid

***Age groups
*Appendix A
bysort edad_tres_grupos: tab sex covid [iw=factor] , row nofreq
bysort edad_tres_grupos: tab sex covid


**# Bookmark #21
***********Residence area
tab urban, gen(urban)
tab1 urban1 urban2, mi
*Appendix A
tab urban covid [iw=factor] , row nofreq
tab urban covid

***Ethnicity
*Appendix A
bysort condic_etnica: tab urban covid [iw=factor] , row nofreq
bysort condic_etnica: tab urban covid

***Age groups
*Appendix A
bysort edad_tres_grupos: tab urban covid [iw=factor] , row nofreq
bysort edad_tres_grupos: tab urban covid

**# Bookmark #22
***********Household living arrangements
tab tipo_hogar, gen(tipo_hogar)
tab1 tipo_hogar1 tipo_hogar2 tipo_hogar3, mi
*Appendix A
tab tipo_hogar covid [iw=factor] , row nofreq
tab tipo_hogar covid

***Ethnicity
*Appendix A
bysort condic_etnica: tab tipo_hogar covid [iw=factor] , row nofreq
bysort condic_etnica: tab tipo_hogar covid

***Age groups
*Appendix A
bysort edad_tres_grupos: tab tipo_hogar covid [iw=factor] , row nofreq
bysort edad_tres_grupos: tab tipo_hogar covid

**# Bookmark #23
****Age groups Total
bysort edad_tres_grupos: tab covid [iw=factor]


**# Bookmark #24
*********************************************************************
**************************MODELING***********************************
********************BIVARIATE ANALYSIS*******************************
*********************************************************************

logit covid ocupacion1 ocupacion2, or
estat ic

logit covid tipo_hogar2 tipo_hogar3, or
estat ic

logit covid educacion2 educacion3 educacion4, or
estat ic

logit covid edad_tres_grupos1 edad_tres_grupos2, or
estat ic

logit covid condic_etnica2, or
estat ic

logit covid sex2, or
estat ic

logit covid condicion_laboral1, or
estat ic

logit covid urban2, or
estat ic

**# Bookmark #25

*********************************************************************
**************************MODEL 1************************************
*********************************************************************

logit covid ocupacion1 ocupacion2 /// 
	tipo_hogar1 tipo_hogar2 ///
	educacion1 educacion2 educacion3 ///
	edad_tres_grupos1 edad_tres_grupos2 ///
	sex1 ///
	condicion_laboral1 ///
	urban2, or
estat ic

/*
-----------------------------------------------------------------------------
       Model |          N   ll(null)  ll(model)      df        AIC        BIC
-------------+---------------------------------------------------------------
           . |     16,910  -7693.636  -7555.603      13   15137.21   15237.77
-----------------------------------------------------------------------------

*/

**# Bookmark #26
*********************************************************************
**************************MODEL 2************************************
*********************************************************************

logit covid ocupacion1 ocupacion2 /// 
	tipo_hogar1 tipo_hogar2 ///
	educacion1 educacion2 educacion3 ///
	condic_etnica2 ///
	sex1 ///
	condicion_laboral1 ///
	urban2, or
estat ic

/*
-----------------------------------------------------------------------------
       Model |          N   ll(null)  ll(model)      df        AIC        BIC
-------------+---------------------------------------------------------------
           . |     16,910  -7693.636   -7572.95      12    15169.9   15262.73
-----------------------------------------------------------------------------

*/

**# Bookmark #27
*********************************************************************
**************************MODEL 3************************************
*********************************************************************

logit covid ocupacion1 ocupacion2 /// 
	tipo_hogar1 tipo_hogar2 ///
	educacion1 educacion2 educacion3 ///
	edad_tres_grupos1 edad_tres_grupos2 ///
	condic_etnica2 ///
	sex1 ///
	condicion_laboral1 ///
	urban2, or
estat ic

/*
-----------------------------------------------------------------------------
       Model |          N   ll(null)  ll(model)      df        AIC        BIC
-------------+---------------------------------------------------------------
           . |     16,910  -7693.636  -7554.338      14   15136.68   15244.98
-----------------------------------------------------------------------------

*/

**# Bookmark #28
*********************************************************************
**************************MODEL 4************************************
*********************************************************************

***Establecer categorías de referencia
fvset base 3 ocupacion
fvset base 3 tipo_hogar
fvset base 4 educacion
fvset base 3 edad_tres_grupos
fvset base 2 sex
fvset base 2 condicion_laboral
fvset base 1 urban

***Modelo basal interactuado por condición étnica - Odds Ratio
logit covid i.ocupacion#condic_etnica /// 
	i.tipo_hogar#condic_etnica ///
	i.educacion#condic_etnica ///
	i.edad_tres_grupos#condic_etnica ///
	i.sex#condic_etnica ///
	i.condicion_laboral#condic_etnica ///
	i.urban#condic_etnica, or
estat ic

**# Bookmark #29
*********************************************************************
**************************CHOW TEST**********************************
*********************************************************************

*Install chowtest module
*Qunyong Wang, 2020. "CHOWTEST: Stata module to perform Chow test for structural break," Statistical Software Components S458875, Boston College Department of Economics.
*https://ideas.repec.org/c/boc/bocode/s458875.html

ssc install chowtest

********Chow test by ethnicity
chowtest covid ocupacion1 ocupacion2 /// 
	tipo_hogar1 tipo_hogar2 ///
	educacion1 educacion2 educacion3 ///
	edad_tres_grupos1 edad_tres_grupos2 ///
	condic_etnica2 ///
	sex1 ///
	condicion_laboral1 ///
	urban2, group(condic_etnica)

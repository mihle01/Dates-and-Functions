/* PART A*/
libname HW3 "/home/u60739998/BS 805/Class 3";

data lead_temp;
	set HW3.lead_f2022;
/*Question 1*/	
	array month {3} mthbld_A mthbld_B mthbld_C;
	array day {3} daybld_A daybld_B daybld_C;
	array date {3} datebld_A datebld_B datebld_C;
	
	do i=1 to 3;
		if month{i}=-1|month{i}=13 then month{i}=6;
		if day{i}=-1|day{i}=32 then day{i}=15;
		date{i} = MDY(month{i}, day{i}, 1990);	
		end;
	format datebld_A datebld_B datebld_C date_maxpblev dob mmddyy10.;
/* Question 2*/	
	max_pblev=max(pblev_a, pblev_b, pblev_c);
/*Question 3*/
	array pbl {3} pblev_a pblev_b pblev_c;
	do i=1 to 3;
		/*if max_pblev=pbl{i} then max_sample=i;
		if max_sample=i then date_maxpblev=date{i}; <- can simply turm these two lines into one line, see below*/
		if max_pblev=pbl{i} then date_maxpblev=date{i};
		end;
	*1=sample A, 2=sample B, 3=sample C;
/*Question 4*/	
	age_days=date_maxpblev-dob;
	age_years=round(age_days/365.35,.01);
/* Question 5*/	
	if 0<age_years<4 then agecat=1;
	else if 4<=age_years<8 then agecat=2;
	else if age_years =>8 then agecat=3;
	
	label date_maxpblev='Date of largest lead level' 
		  age_years='Age at largest lead level' 
		  max_pblev='Largest lead level';
run;

proc contents data=lead_temp; run;
/* Question 6 */
proc print data=lead_temp;
	var id dob date_maxpblev age_years agecat sex max_pblev;
run;
/* question 7 */
proc sort data=lead_temp;
	by sex;
run;

proc means data=lead_temp;
	var age_years;
	by sex;
run;

proc freq data=lead_temp;
	tables agecat;
	by sex;
run;

/*PART B*/
proc glm data=lead_temp;
	class agecat sex;
	model max_pblev=agecat sex agecat*sex;
run;
*check balance of design;
proc freq data=lead_temp;
	tables agecat*sex;
run;
*no significant interaction - refit ANOVA. unbalanced deisgn, use lsmeans;
proc glm data=lead_temp;
	class agecat sex;
	model max_pblev=agecat sex;
	lsmeans sex / stderr pdiff cl adjust=tukey ; *agecat was not significant, remove from lsmeans;
run;
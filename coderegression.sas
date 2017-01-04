%let path=/folders/myfolders/Mod_lin;
data modlin.data2;
	missing na;
	infile '/folders/myfolders/Mod_lin/imports-85.data' dsd truncover;
	input symboling
		  normalizedlosses
		  make :$
		  fueltype :$
		  aspiration :$
		  numdoors :$
		  bodystyle :$
		  drivewheels :$
		  enginelocation :$
		  wheelbase
		  length
		  width
		  height
		  curbweight
		  enginetype :$
		  numcylinders :$
		  enginesize 
		  fuelsystem :$
		  bore
		  stroke
		  compressionratio
		  horsepower
		  peakrpm
		  citympg
		  highwaympg
		  price;
	drop symboling normalizedlosses numdoors bodystyle drivewheels enginelocation numcylinders fuelsystem price enginetype citympg;
	
run;

data modlin.data(drop=highwaykml);
	set modlin.data2;
	highwaykml = highwaympg *0.425170068;
	highwaylkm100 = round(100/highwaykml,0.01);
	wheelbase=wheelbase*2.54;
	length=length*2.54;
	width=width*2.54;
	height=height*2.54;
	bore=bore*2.54;
	stroke=stroke*2.54;
	enginesize=round(enginesize*0.0163871,0.01);
	curbweight=round(curbweight*0.453592,0.01);
	if fueltype='diesel' then fueldummy=1;
	else if fueltype='gas' then fueldummy=-1;
	if aspiration='std' then aspirationdummy=-1;
	else if aspiration ='turbo' then aspirationdummy=1;
	aspixfuel = aspirationdummy*fueldummy;
	if cmiss(of _all_) =0;
run;

proc export data=modlin.data
	outfile = "&path/automobileclean.csv"
	dbms=csv replace;
run;

/*premiere régression pour vérifier les vif: on supprime curbweight enginesize */
ods tagsets.tablesonlylatex file="&path/premiereregression.tex" (notop nobot);
proc reg data=modlin.data;
	model highwaylkm100 = wheelbase length width height curbweight enginesize bore stroke
			 horsepower peakrpm  fueldummy aspirationdummy   /vif;
run;
ods tagsets.tablesonlylatex close;
/*verification via proc corr */

proc corr data=modlin.data outp=resultats nosimple;
var wheelbase length width height curbweight enginesize bore stroke
			 horsepower peakrpm;
run;

*print;
ods tagsets.tablesonlylatex file="&path/corr.tex" (notop nobot);
proc print data=resultats;
 format _numeric_ 5.2;
 run;
ods tagsets.tablesonlylatex close;

ods tagsets.tablesonlylatex file="&path/regsuppr.tex" (notop nobot);
proc reg data=modlin.data;
	model highwaylkm100 = wheelbase length width height bore stroke
			 horsepower peakrpm fueldummy aspirationdummy /vif;
run;
ods tagsets.tablesonlylatex close;

/*selection via critère de mallows*/
ods tagsets.tablesonlylatex file="&path/regmallows.tex" (notop nobot);
proc reg data=modlin.data;
	model highwaylkm100 = wheelbase length width height bore stroke horsepower
			  peakrpm fueldummy aspirationdummy /vif selection=cp best=5;
run;
ods tagsets.tablesonlylatex close;
/*selection via adj rsq */
ods tagsets.tablesonlylatex file="&path/regadjsqr.tex" (notop nobot);
proc reg data=modlin.data;
	model highwaylkm100 = wheelbase length width height bore stroke horsepower
			  peakrpm fueldummy aspirationdummy /vif selection=adjrsq best=5;
run;
ods tagsets.tablesonlylatex close;

/*selection via forward selection */
ods tagsets.tablesonlylatex file="&path/regforwarsel.tex" (notop nobot);
proc reg data=modlin.data;
	model highwaylkm100 = wheelbase length width height bore stroke horsepower
			  peakrpm fueldummy aspirationdummy /vif selection=forward sle=0.10;
run;
ods tagsets.tablesonlylatex close;

/*stepwise*/
ods tagsets.tablesonlylatex file="&path/regstepwisesel.tex" (notop nobot);
proc reg data=modlin.data;
	model highwaylkm100 = wheelbase length width height bore stroke horsepower
			  peakrpm fueldummy aspirationdummy /vif selection=stepwise sle=0.1 sls=0.15;
run;
ods tagsets.tablesonlylatex close;

/*selection via backward selection */

ods tagsets.tablesonlylatex file="&path/regbackwardsel.tex" (notop nobot);
proc reg data=modlin.data;
	model highwaylkm100 = wheelbase length width height bore stroke horsepower
			  peakrpm fueldummy aspirationdummy /vif selection=backward sls=0.15;
run;
ods tagsets.tablesonlylatex close;


ods tagsets.tablesonlylatex file="&path/lasso.tex" (notop nobot);
proc glmselect data=modlin.data plots=all;
	model highwaylkm100 = wheelbase length width height bore stroke horsepower
			  peakrpm fueldummy aspirationdummy / selection=lasso (stop=none choose=bic);
run;
ods tagsets.tablesonlylatex close;

/*modele final*/
ods tagsets.tablesonlylatex file="&path/regfinale.tex" (notop nobot);
proc reg data=modlin.data plots=all;
	model highwaylkm100 = wheelbase length width horsepower
			   fueldummy aspirationdummy aspixfuel / white dwprob r vif influence;
	output out=modlin.resulta2 residual=residu h=leverage student=resstu
rstudent=resstudel dffits=dfits cookd=Dcook P=predicted;
run;

ods tagsets.tablesonlylatex close;
/*modèle incluant les variables des constructeurs */
ods tagsets.tablesonlylatex file="&path/regfinalecorrige.tex" (notop nobot);
proc reg data=modlin.datab;
	model thighwaylkm100 = wheelbase length width horsepower
			   fueldummy aspirationdummy tmakealfa_rom tmakeaudi tmakebmw tmakechevrole
			   tmakedodge tmakehonda tmakeisuzu tmakejaguar tmakemazda tmakemercedes
			   tmakemercury tmakemitsubis tmakenissan tmakepeugot tmakeplymouth
			   tmakeporsche tmakesaab tmakesubaru tmaketoyota tmakevolkswag
			    / white dwprob;
			 
run;
ods tagsets.tablesonlylatex close;
/*box cox*/
proc transreg data=modlin.data;
	model Boxcox(highwaylkm100)=identity(wheelbase length width horsepower wheelbase length width horsepower
			   fueldummy aspirationdummy)
	class(make);
	output out=modlin.datab;
	run;
	quit;
proc contents data=modlin.datab;
run;
data modlin.datacb;
	set modlin.datab;
	drop tintercept--tmakevolkswag _type_ _name_ intercept;
run;
proc export data=modlin.datacb
	outfile = "&path/automobilecleanboxcox.csv"
	dbms=csv replace;
run;

/* a faire sur pc salle info
proc model data=modlin.data;
	parms wheelbase length width horsepower
			   fueldummy aspirationdummy;
	highwaylkm100 = wheelbase length width horsepower
			   fueldummy aspirationdummy;
	fit highwaylkm100 /white;
run;
*/
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
	if cmiss(of _all_) =0;
run;
proc export data=modlin.data
	outfile = "&path/automobileclean.csv"
	dbms=csv;
run;

proc reg data=modlin.data;
	model citympg = wheelbase length width height curbweight enginesize bore stroke
			compressionratio horsepower peakrpm price /vif;
run;

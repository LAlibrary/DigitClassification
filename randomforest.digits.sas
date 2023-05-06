proc import out = digits
datafile = "C:/Users/lynet/OneDrive/Desktop/optdigits.tra"
dbms = csv replace;
getnames = no;
run;
proc contents data=digits;
run;
proc print data=digits;
run;

/* SPLIT DATA INTO 80% TRAINING & 20% TESTING */
proc surveyselect data=digits rate=0.8 seed=716546
out=digits outall method=srs;
run;

/* BUILDING RANDOM FOREST MULTINOMIAL CLASSIFIER */ 
proc hpforest data=digits seed=776253
maxtrees=150 vars_to_try=8 trainfraction=0.7 maxdepth=10;
target var65/level=nominal;
input var1-var64/level=interval;
partition rolevar=selected(train='1');
save file='C:/Users/lynet/OneDrive/Desktop/DIRECTEDSTUDIES/random_forest.bin';
run;

/* COMPUTING PREDICTED VALUES FOR TESTING DATA */ 
data test;
set digits;
if(selected='0');
run;

proc hp4score data=test;
id var65;
score file='C:/Users/lynet/OneDrive/Desktop/DIRECTEDSTUDIES/random_forest.bin'
out=predicted;
run;

/* COMPUTING PREDICTION ACCURACY FOR TESTING DATA */
data predicted;
set predicted;
match=(var65=lowcase(I_var65));
run;
proc sql;
select sum(match)/count(*) as accuracy
from predicted;
quit;

/* WITH HANDWRITTEN DIGITS */
proc import out = hdigits
datafile = "C:/Users/lynet/OneDrive/Desktop/DIRECTEDSTUDIES/handwritten_digits.csv"
dbms = csv replace;
getnames = no;
run;
proc contents data= hdigits;
run;
proc print data=hdigits;
run;

proc hp4score data=hdigits;
id var65;
score file='C:/Users/lynet/OneDrive/Desktop/DIRECTEDSTUDIES/random_forest.bin'
out=hpredicted;
run;

/* COMPUTING PREDICTION ACCURACY FOR TESTING DATA */
data hpredicted;
set hpredicted;
match=(var65=lowcase(I_var65));
run;
proc sql;
select sum(match)/count(*) as accuracy
from hpredicted;
quit;




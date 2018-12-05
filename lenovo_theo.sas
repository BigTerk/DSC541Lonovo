******************************************************************************************************************
*	NAME: 	Lenovo Project
*	DATE CREATED:	1DEC2018
*	 FUNCTION(S):	
					1) Manipulate lenovo dataset to get number of parts per finished good
*					2) Generate dataset of 10000 fake orders
*					3) Create CIs for each item to determine minimum inventory needed to sustain __% of orders
******************************************************************************************************************;


** (1) Manipulate lenovo dataset to get number of parts per finished good ****************************************;
	proc import out=lenovo(drop=date plant)
		datafile="F:/DSC541/lenovo.csv" 
		dbms=CSV;
		getnames=yes;
	run;

	proc sort data=lenovo;
		by item_number FG; 
	run;
	
	
	data c1(rename=(quantity=q1)) c2(rename=(quantity=q2));
		set lenovo;
		if FG='209MH32' then output c1;
		if FG='209MH56' then output c2;
	run;

	data len1;
		merge c1(drop=FG in=a) c2(drop=FG in=b);
		by item_number;
		if q1=. then q1=0;
		if q2=. then q2=0;
	run;

	data shared; set len1(where=(q1^=0 and q2^=0)); run;
	*10 of 155 parts are shared;


** (2) Generate dataset of 10000 fake orders **********************************************************************;
	%let orders=10000;
	%let pord=70; *% of orders thata are personal orders;
	%let cord=30; *% of orders thata are commercial orders;
	%let lamb1=0.5; *Y1 poisson parameter;
	%let mu=50; *Y2 normal mean;
	%let sig=20; *Y2 normal variance;
	%let scale=.15; *value between 0 and 1 -- smaller value gives more lop-sided orders;

	data g; do order=1 to &orders; output; end; run;
	data g1;
	length ORDTYPE $12;
		set g;
		if order<=(&pord/100)*&orders then do;
			ORDTYPE='Personal';
			X=1+rand('POISSON',&lamb1);
		end;
		if order>(&pord/100)*&orders then do;
			ORDTYPE='Commercial';
			X=floor(1+rand('NORMAL',&mu,&sig));
			do while (X<=0);
				X=floor(1+rand('NORMAL',&mu,&sig));
			end;	
		end;
	run;

	** Plots **;
		proc univariate data=g1(where=(ORDTYPE='Personal')); histogram X /  midpoints=1 to 12 by 1; run;
		proc univariate data=g1(where=(ORDTYPE='Commercial')); histogram X /  midpoints=1 to 150 by 5; run;

	data g2;
		set g1;
		B=1+ranbin(1,1,.5);
		if B=2 then X1=min(rand('POISSON',1+&scale*X),floor(X/2));
		if B=1 then X2=min(rand('POISSON',1+&scale*X),floor(X/2));
		if X1=. then X1=X-X2;
		if X2=. then X2=X-X1;
	run;
	proc sql;
	  create table g3 as
	  select *  from g2 as a, len1 as b;
	quit;
	proc sort data=g3; by order item_number; run;

	data g4;
		retain order ordtype x b x1 x2 item_number shared q1 q2 qty;
		set g3;
		QTY=X1*Q1+X2*Q2;
		if Q1^=0 and Q2^=0 then shared='Yes';
		else shared='No';
	run;
	proc sort data=g4(keep=ord: item_number shared qty) out=anl; by item_number order; run;



** 3) Create CIs for number of computers in each order *******************************************************************;

	** Overall CIs **;
		%macro ci1(alpha,int,n);
			ods output BasicIntervals=a1(where=(Parameter='Mean'));
			proc univariate data=anl cibasic(alpha=&alpha);
				by item_number;
				var QTY;
			run;
			proc sort data=anl out=share nodupkey; by item_number shared; run;
			data CI_all&n(drop=varname parameter rename=(lowercl=LL&int uppercl=UL&int));
			retain item_number shared;
				merge a1 share(keep=item_number shared);
				by item_number;
			run;
			*145 records (since 10 parts are shared);
		%mend ci1;
		%ci1(alpha=.1,int=90,n=1);
		%ci1(alpha=.05,int=95,n=2);
		%ci1(alpha=.01,int=99,n=3);
		data ci_all(rename=(Estimate=Mean)); merge ci_all1 ci_all2 ci_all3; by item_number shared estimate; run; 

	** CIs by order type **;
		%macro ci2(alpha,int,n);
			ods output BasicIntervals=a1(where=(Parameter='Mean'));
			proc univariate data=anl cibasic(alpha=&alpha);
				class ordtype;
				by item_number;
				var QTY;
			run;
			proc sort data=anl out=share nodupkey; by item_number shared; run;
			data CI_ord&n(drop=varname parameter rename=(lowercl=LL&int uppercl=UL&int));
			retain item_number shared;
				merge a1 share(keep=item_number shared);
				by item_number;
			run;
			proc sort data=CI_ord&n; by item_number ordtype shared estimate; run;
			*290 records (145 items * 2 order types);
		%mend ci2;
		%ci2(alpha=.1,int=90,n=1);
		%ci2(alpha=.05,int=95,n=2);
		%ci2(alpha=.01,int=99,n=3);
		data ci_ord(rename=(Estimate=Mean)); merge ci_ord1 ci_ord2 ci_ord3; by item_number ordtype shared estimate; run; 

	** Combine into final dataset **;
		data final;
		retain item_number ordtype pct;
			set ci_all(in=a) ci_ord(in=b);
			if a then ordtype='Total';
			if ordtype='Personal' then pct="&pord.% of orders ";
			if ordtype='Commercial' then pct="&cord.% of orders ";
			if ordtype='Total' then pct="100% of orders";
		run;
		proc sort data=final; by item_number ordtype; run;

libname lenovo "F:/DSC541/";

data lenovo.lenovo; set len1; run;
data lenovo.orders; set g4; run;
data lenovo.analysis; set final; run;



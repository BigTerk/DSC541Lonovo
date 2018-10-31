*****************************************************
** Project: Lenovo 
** Date: 21OCT2018
** Author: CSowden
** SAS Program: Lenovo.sas
*****************************************************
** Additional Comments:
**
**
******************************************************;
proc datasets lib=work kill;
/* Generated Code (IMPORT) */
/* Source File: lenovo.csv */
/* Source Path:'F:\DSC541\lenovo.csv' */
/* Code generated on: 10/21/18, 3:15 PM */



***************************************************************************
**Bring in the data
***************************************************************************;
%web_drop_table(WORK.lenovo);


FILENAME REFFILE 'F:\DSC541\lenovo.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.lenovo;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.lenovo; RUN;


***************************************************************************
**Formatting date to dat9.
**random num
***************************************************************************;
data lenovo2;
	set lenovo;
	by plant;

	Date=datepart(date);
	 FG_new= rand('integer', 1, 5);**Random Number Generator;
	
	if quantity eq 2 then do;
		FGShared =rand('integer', 1, 5);**Random Number Generator;
	end;
	
	format date date9.;
run;

proc sort data=lenovo2;
	by fg_new;
run;
***************************************************************************
**MACRO to split Finished Goods into two different datasets
***************************************************************************;
%macro fg1 (var);

	data MH_32 MH_56;
	length FG $10.;
		set lenovo2;
		
			if &var eq '209MH32' then output MH_32;
			else if  &var  eq '209MH56' then output MH_56;	
	run;

%mend fg1;
%fg1(fg);
 

 
 %ds2csv (data=work.lenovo2, 
 					runmode=b, 
 					csvfile=F:\Lenovo\new_lenovo.csv);
 

-- COMP9311 19s1 Project 1 Check
--
-- MyMyUNSW Check

create or replace function
	proj1_table_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=tname and relkind='r';
	return (_check = 1);
end;
$$ language plpgsql;

create or replace function
	proj1_view_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_class
	where relname=tname and relkind='v';
	return (_check = 1);
end;
$$ language plpgsql;

create or replace function
	proj1_function_exists(tname text) returns boolean
as $$
declare
	_check integer := 0;
begin
	select count(*) into _check from pg_proc
	where proname=tname;
	return (_check > 0);
end;
$$ language plpgsql;

-- proj1_check_result:
-- * determines appropriate message, based on count of
--   excess and missing tuples in user output vs expected output

create or replace function
	proj1_check_result(nexcess integer, nmissing integer) returns text
as $$
begin
	if (nexcess = 0 and nmissing = 0) then
		return 'correct';
	elsif (nexcess > 0 and nmissing = 0) then
		return 'too many result tuples';
	elsif (nexcess = 0 and nmissing > 0) then
		return 'missing result tuples';
	elsif (nexcess > 0 and nmissing > 0) then
		return 'incorrect result tuples';
	end if;
end;
$$ language plpgsql;

-- proj1_check:
-- * compares output of user view/function against expected output
-- * returns string (text message) containing analysis of results

create or replace function
	proj1_check(_type text, _name text, _res text, _query text) returns text
as $$
declare
	nexcess integer;
	nmissing integer;
	excessQ text;
	missingQ text;
begin
	if (_type = 'view' and not proj1_view_exists(_name)) then
		return 'No '||_name||' view; did it load correctly?';
	elsif (_type = 'function' and not proj1_function_exists(_name)) then
		return 'No '||_name||' function; did it load correctly?';
	elsif (not proj1_table_exists(_res)) then
		return _res||': No expected results!';
	else
		excessQ := 'select count(*) '||
			   'from (('||_query||') except '||
			   '(select * from '||_res||')) as X';
		-- raise notice 'Q: %',excessQ;
		execute excessQ into nexcess;
		missingQ := 'select count(*) '||
			    'from ((select * from '||_res||') '||
			    'except ('||_query||')) as X';
		-- raise notice 'Q: %',missingQ;
		execute missingQ into nmissing;
		return proj1_check_result(nexcess,nmissing);
	end if;
	return '???';
end;
$$ language plpgsql;

-- proj1_rescheck:
-- * compares output of user function against expected result
-- * returns string (text message) containing analysis of results

create or replace function
	proj1_rescheck(_type text, _name text, _res text, _query text) returns text
as $$
declare
	_sql text;
	_chk boolean;
begin
	if (_type = 'function' and not proj1_function_exists(_name)) then
		return 'No '||_name||' function; did it load correctly?';
	elsif (_res is null) then
		_sql := 'select ('||_query||') is null';
		-- raise notice 'SQL: %',_sql;
		execute _sql into _chk;
		-- raise notice 'CHK: %',_chk;
	else
		_sql := 'select ('||_query||') = '||quote_literal(_res);
		-- raise notice 'SQL: %',_sql;
		execute _sql into _chk;
		-- raise notice 'CHK: %',_chk;
	end if;
	if (_chk) then
		return 'correct';
	else
		return 'incorrect result';
	end if;
end;
$$ language plpgsql;

-- check_all:
-- * run all of the checks and return a table of results

drop type if exists TestingResult cascade;
create type TestingResult as (test text, result text);

create or replace function
	check_all() returns setof TestingResult
as $$
declare
	i int;
	testQ text;
	result text;
	out TestingResult;
	tests text[] := array['q1', 'q2', 'q3', 'q4', 'q5','q6','q7','q8','q9','q10'];
begin
	for i in array_lower(tests,1) .. array_upper(tests,1)
	loop
		testQ := 'select check_'||tests[i]||'()';
		execute testQ into result;
		out := (tests[i],result);
		return next out;
	end loop;
	return;
end;
$$ language plpgsql;


--
-- Check functions for specific test-cases in Project 1
--

create or replace function check_q1() returns text
as $chk$
select proj1_check('view','q1','q1_expected',
                   $$select * from q1$$)
$chk$ language sql;

create or replace function check_q2() returns text
as $chk$
select proj1_check('view','q2','q2_expected',
                   $$select * from q2$$)
$chk$ language sql;

create or replace function check_q3() returns text
as $chk$
select proj1_check('view','q3','q3_expected',
                   $$select * from q3$$)
$chk$ language sql;

create or replace function check_q4() returns text
as $chk$
select proj1_check('view','q4','q4_expected',
                   $$select * from q4$$)
$chk$ language sql;

create or replace function check_q5() returns text
as $chk$
select proj1_check('view','q5','q5_expected',
                   $$select * from q5$$)
$chk$ language sql;

create or replace function check_q6() returns text
as $chk$
select proj1_check('view','q6','q6_expected',
                   $$select * from q6$$)
$chk$ language sql;

create or replace function check_q7() returns text
as $chk$
select proj1_check('view','q7','q7_expected',
                   $$select * from q7$$)
$chk$ language sql;

create or replace function check_q8() returns text
as $chk$
select proj1_check('view','q8','q8_expected',
                   $$select * from q8$$)
$chk$ language sql;

create or replace function check_q9() returns text
as $chk$
select proj1_check('view','q9','q9_expected',
                   $$select * from q9$$)
$chk$ language sql;

create or replace function check_q10() returns text
as $chk$
select proj1_check('view','q10','q10_expected',
                   $$select * from q10$$)
$chk$ language sql;


drop table if exists q1_expected;
create table q1_expected (
     unswid ShortString,
     longname LongName
);

drop table if exists q2_expected;
create table q2_expected (
	unswid integer,
	name LongName
);

drop table if exists q3_expected;
create table q3_expected (
	unswid integer,
	name LongName
);

drop table if exists q4_expected;
create table q4_expected (
	num_student integer
);

drop table if exists q5_expected;
create table q5_expected (
    code char(8),
	name MediumName,
	semester ShortName
);

drop table if exists q6_expected;
create table q6_expected (
    num bigint
);

drop table if exists q7_expected;
create table q7_expected (
    year courseyeartype,
    term ShortName,
    average_mark numeric(4,2)
);

drop table if exists q8_expected;
create table q8_expected (
    zid LongName,
    name LongName
);

drop table if exists q9_expected;
create table q9_expected (
	unswid integer,
    name longname
);

drop table if exists q10_expected;
create table q10_expected (
    unswid ShortString,
    longname longname,
    num integer,
    rank integer
);


COPY q1_expected (unswid, longname) FROM stdin;
K-B9-160	B9 160
K-C20-G6	MB-G6
K-C20-G7	MB-G7
K-C20-LG2	MB-LG2
K-C20-LG30	MB-LG30
K-D7-101	WC-101
K-E15-1042	QUAD-1042
K-E15-1045	QUAD-1045
K-E15-1046	QUAD-1046
K-E15-1047	QUAD-1047
K-E15-1048	QUAD-1048
K-E15-1049	QUAD-1049
K-E15-G022	QUAD-G022
K-E15-G025	QUAD-G025
K-E15-G026	QUAD-G026
K-E15-G027	QUAD-G027
K-E15-G031	QUAD-G031
K-E15-G032	QUAD-G032
K-E15-G034	QUAD-G034
K-E15-G035	QUAD-G035
K-E15-G040	QUAD-G040
K-E15-G041	QUAD-G041
K-E15-G042	QUAD-G042
K-E15-G044	QUAD-G044
K-E15-G045	QUAD-G045
K-E15-G046	QUAD-G046
K-E15-G047	QUAD-G047
K-E15-G048	QUAD-G048
K-E15-G052	QUAD-G052
K-E15-G053	QUAD-G053
K-E15-G054	QUAD-G054
K-E15-G055	QUAD-G055
K-E8-219	E8-219
K-F20-139	JG-139
K-F20-LG21	JG-LG21
K-F20-LG23	JG-LG23
K-G14-236	WEBSTER-236
K-G17-225	EE-225
K-H20-101	CE-101
K-H20-102	CE-102
K-H20-713	CE-713
K-H20-G1	CE-G1
K-H20-G6	CE-G6
K-H20-G8	CE-G8
K-J17-202	ME-202
K-J17-203	ME-203
K-J17-301	ME-301
K-J17-303	ME-303
K-J17-304	ME-304
K-J17-402	ME-402
K-J17-403	ME-403
K-J17-502	ME-502
K-J17-503	ME-503
K-K15-145A	OMB-145A
K-K15-149A	OMB-149A
K-K15-150	OMB-150
K-K15-228	OMB-228
K-K15-229	OMB-229
K-K15-231	OMB-231
K-K15-232	OMB-232
\.

COPY q2_expected (unswid, name) FROM stdin;
9026074	David Morgan
3138847	Benoit Julien
3128697	Zahid Riaz
3227548	Elaine Franco
3217878	Devorah Wainer
3149611	Edward Harbor
9854333	Denzil Fiebig
9995228	Peter Nichols
3210320	Suzanne Chan-Serafin
3307694	Ricardo Flores
3218828	Hugh Bainbridge
8545418	Judith Watson
6987539	Ian Wilkinson
3089715	Louis Wang
9213794	Tracy Wilcox
7676135	Trevor Stegman
3021175	Yue Wang
3178237	Sehne Avsar
3382677	Chen Qiu
3281877	Vasile Caprar
9155962	Noor-E-Alam Ahmed
9985688	Pradeep Ray
3266526	Simon Restubog
8837004	Tien Nguyen
3150458	Quan Gan
3228131	Ben Greiner
8831950	Diane Fieldes
8553813	Donna Wilcox
9643409	Suk-Joong Kim
6882728	Diane Enahoro
9466637	Betty Wong
8997961	Kenneth Ashwell
3344027	Jennifer Foster
3247239	Vincent Wong
3129186	Abu Shonchoy
8085382	Louise Zieme
9857057	Raymond Durham
9130234	Barbara Hendrischke
3389919	Denise Bunting
3115148	Andrew Jackson
8421419	Chung-Sok Suh
\.

COPY q3_expected (unswid, name) FROM stdin;
3107091	Grace Dobes
3027500	Aran Tidswell
3290708	Pamela Brassel
\.

COPY q4_expected (num_student) FROM stdin;
11122
\.


COPY q5_expected (
	code,
	name,
	semester
) FROM stdin;
MATH2011	Several Variable Calculus	Sem1 2010
GENM0703	Concept of Phys Fitness&Health	Summ 2006
MECH1300	Engineering Mechanics 1	Sem2 2003
SOLA9003	High Efficiency Si Solar Cells	Sem1 2011
INTA2171	Technology for Interior Arch 1	ASemM2007
PLAN3041	Planning Law & Administration	Sem1 2012
PHYS1231	Higher Physics 1B	Summ 2010
FINS1612	Capital Markets & Institution	Summ 2011
BIOS2021	Genetics	ASemA2007
IDES2161	Industrial Design Studio 2A	Sem1 2008
IDES2171	Computer Application Ind Desgn	Sem2 2008
GENT0420	Along the Silk Road	Summ 2008
ATAX0403	Taxation of Corporations	Sem1 2004
COMP9511	Human Computer Interaction	Sem2 2008
ZHSS1401	Politics 1A	Sem1 2005
ECON1101	Microeconomics 1	Sem2 2004
ARCH1172	Architectural Technologies 2	Sem2 2005
ARTS2458	Along the Silk Road	Summ 2013
GENS1004	Science and the Cinema	Summ 2007
MECH2102	Machine Design B	Sem2 2006
LAWS1052	Foundations of Law	Sem1 2003
HESC3532	Movement Rehabilitation	Sem2 2012
GSOE9840	Maintenance Engineering	Sem2 2011
FOOD2330	Quality Assurance and Control	Sem2 2009
DIPP1111	Intro to Leadership and PP	Summ 2013
ACCT5908	Auditing and Assurance Ser.	Summ 2012
PHYS1131	Higher Physics 1A	Sem1 2006
GENT0420	Along the Silk Road	Summ 2009
PHSL2502	Human Physiology B	Sem2 2010
ARTS1780	Concepts of Europe	Sem1 2009
ACCT1501	Accounting & Financial Mgt 1A	Sem2 2005
BIOS1101	Evolutionary & Functional Biol	Sem2 2003
\.

COPY q6_expected (num) FROM stdin;
223
\.

COPY q7_expected (
    year,
    term,
    average_mark
) FROM stdin;
2003	S1	78.22
2003	S2	72.88
2004	S1	82.33
2004	S2	67.62
2005	S1	81.83
2005	S2	69.90
2006	S1	71.29
2006	S2	77.31
2007	S1	70.08
2007	S2	76.05
2008	S1	67.94
2008	S2	68.73
2009	S1	73.20
2009	S2	64.13
2010	S1	67.47
2010	S2	76.23
2011	S1	68.10
2011	S2	70.85
2012	S1	63.74
2012	S2	74.56
\.

COPY q8_expected (
    zid,
    name
) FROM stdin;
z3255939	Rosanna Hogarth
z3256382	Viara Alexova
z3218103	Elaine Hon
z3253334	Sarah Sridharan
z3243616	Virginia Glanz
\.

COPY q9_expected (unswid, name) FROM stdin;
3230042	Fiona Ogden
3232152	Cosimo Mottey
\.


COPY q10_expected (unswid,longname,num,rank) FROM stdin;
K-J14-G5	Keith Burrows Theatre	102	1
K-D23-201	MathewsThA	99	2
K-E27-F	Biomedical Lecture Theatre F	48	3
K-F8-G04	Law Th G04	47	4
K-D23-304	MathewsThD	47	4
K-E19-104	Central Lecture Block Theatre 7	46	6
K-M15-G90	Myers Thtr	44	7
K-F8-G02	Law Th G02	40	8
K-E19-105	Central Lecture Block Theatre 8	34	9
K-E27-D	Biomedical Lecture Theatre D	33	10
K-E27-A	Biomedical Lecture Theatre A	33	10
K-E15-1027	Macauley Theatre	31	12
K-D23-203	MathewsThB	30	13
K-F8-G23	Law Theatre	29	14
K-E19-103	Central Lecture Block Theatre 6	28	15
K-G17-G25	Electrical Engineering G25	27	16
Z-32-LT07	LecThN07	26	17
K-D23-303	MathewsThC	24	18
K-E27-C	Biomedical Lecture Theatre C	22	19
K-G17-G24	Electrical Engineering G24	21	20
K-C24-G17	Sir John Clancy Auditorium	20	21
K-E27-B	Biomedical Lecture Theatre B	19	22
K-F23-303	Matthews Theatre C	18	23
K-D9-THTR	IoMyers Th	18	23
K-F13-G09	Science Th	16	25
K-E27-E	Biomedical Lecture Theatre E	16	25
Z-32-LT10	LecThN10	13	27
Z-32-LT05	LecThN05	9	28
K-F23-203	Matthews Theatre B	3	29
K-E19-G2	Central Lecture Block Theatre 1	0	30
K-G14-A	Webster Theatre A	0	30
K-G14-B	Webster Theatre B	0	30
K-G15-190	Webst ThA	0	30
K-G15-290	Webst ThB	0	30
K-E12-229	MellorTh	0	30
K-E12-227	NyholmTh	0	30
K-G17-LG1	Rex Vowels Theatre	0	30
K-G19-RT	Ritchie Th	0	30
K-E12-127	New South Global Theatre	0	30
K-K14-19	PhysicsTh	0	30
K-M15-1001	Myers Thtr	0	30
K-E12-125	SmithTh	0	30
Z-03-MTH	MilitaryTh	0	30
Z-30-LT04	LecThS04	0	30
Z-30-LT05	LecThS05	0	30
Z-32-LT04	LecThN04	0	30
Z-F9-THTR	ATSOCTh	0	30
K-E19-G6	Central Lecture Block Theatre 5	0	30
K-E19-G5	Central Lecture Block Theatre 4	0	30
K-F10-L1	Chemical Sciences Theatre	0	30
K-F23-201	Matthews Theatre A	0	30
K-F23-304	Matthews Theatre D	0	30
K-E19-G4	Central Lecture Block Theatre 3	0	30
K-E19-G3	Central Lecture Block Theatre 2	0	30
\.

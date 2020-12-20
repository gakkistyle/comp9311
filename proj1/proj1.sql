-- comp9311 19T3 Project 1
--
-- MyMyUNSW Solutions


-- Q1:
create or replace view Q1(unswid, longname)
as
--... SQL statements, possibly using other views/functions defined by you ...
select distinct r.unswid,r.longname
from Rooms.r,Room_facilities d,facilities f
where r.id = d.room and d.facility = f.id and f.description = 'Air-conditioned'
;

-- Q2:
create or replace view Q2(unswid,name)
as
--... SQL statements, possibly using other views/functions defined by you ...
select distinct psf.unswid,psf.name
from People psf,People ps,Students s,Staff sf,Course_enrolments ce,Courses c,Course_staff cs
where ps.name = 'Hemma Margareta' and psf.id = sf.id and ps.id = s.id and ce.student = s.id
     and sf.id = cs.staff and cs.course = c.id and ce.course = c.id
;

-- Q3:
create or replace view Q3(unswid, name)
as 
--... SQL statements, possibly using other views/functions defined by you ...
select distinct p.unswid,p.name
from People p,Students s,Course_enrolments ce1,Course_enrolments ce2,Courses c1,Courses c2,subjects sub1,subjects sub2
where s.type = 'intl' and p.id=s.id
     and ce1.mark >= 85 and ce2.mark >= 85
     and ce1.student = s.id and ce2.student = s.id
     and c1.id = ce1.course and c2.id = ce2.course
     and c1.semester = c2.semester 
     and c1.subject = sub.id and c2.subject = sub2.id
     and sub1.code = 'COMP9311' and sub2.code = 'COMP9024'
;

-- Q4:
create view calculate_averge_hd(av_num_hd)
as
select (count(grade)/count(student)) as av_num_hd
from Course_enrolments
where grade = 'HD' and student in (select distinct student from Course_enrolments where mark is not null)
;
create view student_hd(student,num_hd)
as
select distinct student,count(grade) as num_hd
from Course_enrolments
where grade = 'HD'
group by student
;

create or replace view Q4(num_student)
as
--... SQL statements, possibly using other views/functions defined by you ...
select count(student_hd.student) as num_student
from calculate_averge_hd,student_hd
where student_hd.num_hd > calculate_averge_hd.av_num_hd
;

--Q5:
create or replace view Q5(code, name, semester)
as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q6:
create or replace view Q6(num)
as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q7:
create or replace view Q7(year, term, average_mark)
as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q8: 
create or replace view Q8(zid, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q9:
create or replace view Q9(unswid, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q10:
create or replace view Q10(unswid, longname, num, rank)
as
--... SQL statements, possibly using other views/functions defined by you ...
;

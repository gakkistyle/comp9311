-- comp9311 19T3 Project 1
--
-- MyMyUNSW Solutions


-- Q1:
create or replace view Q1(unswid, longname)
as
--... SQL statements, possibly using other views/functions defined by you ...
select distinct r.unswid,r.longname
from Rooms r,Room_facilities d,facilities f
where r.id = d.room and d.facility = f.id and f.description = 'Air-conditioned'
;

-- Q2:
create or replace view Q2(unswid,name)
as
--... SQL statements, possibly using other views/functions defined by you ...
select distinct psf.unswid,psf.name
from People psf,People ps,Students s,Staff sf,Course_Enrolments ce,Courses c,Course_Staff cs
where ps.name = 'Hemma Margareta' and psf.id = sf.id and ps.id = s.id and ce.Student = s.id
      and sf.id = cs.staff and cs.course = c.id and ce.course = c.id
;

-- Q3:
create or replace view Q3(unswid, name)
as 
--... SQL statements, possibly using other views/functions defined by you ...
select distinct p.unswid,p.name
from People p,Students s,Course_enrolments ce1,Course_enrolments ce2,Courses c1,Courses c2,subjects sub1,subjects sub2
where s.stype = 'intl' and p.id=s.id 
      and ce1.mark >= 85 and ce2.mark >= 85
      and ce1.student = s.id and ce2.student = s.id 
      and c1.id = ce1.course and c2.id = ce2.course 
      and c1.semester = c2.semester 
      and c1.subject = sub1.id and c2.subject = sub2.id
      and sub1.code = 'COMP9311' and sub2.code = 'COMP9024'
;

-- Q4:
create view calculate_averge_hd(av_num_hd)
as
select (count(grade)/count(student)) as av_num_hd
from Course_Enrolments
where grade = 'HD' and student in (select distinct student from Course_Enrolments where mark is not null)
;

create view student_hd(student,num_hd)
as
select distinct student,count(grade) as num_hd
from Course_Enrolments
where grade = 'HD'
group by student
;

create or replace view Q4(num_student)
--... SQL statements, possibly using other views/functions defined by you ...
as
select count(student_hd.student) as num_student
from calculate_averge_hd,student_hd
where student_hd.num_hd > calculate_averge_hd.av_num_hd
;

--Q5:
create view max_mark(course,maxmark)
as
select Course_enrolments.course,max(mark) as maxmark
from Course_enrolments
where mark is not null 
group by Course_enrolments.course
having count(mark) >= 20
;

create view get_min(semester,minmark)
as
select semester,min(max_mark.maxmark) as minmark
from max_mark,courses
where courses.id = max_mark.course
group by semester
;

create view min_persemester(semester,subject)
as
select distinct get_min.semester, Courses.subject , max_mark.maxmark
from max_mark,Courses,get_min
where max_mark.course = Courses.id and Courses.semester = get_min.semester and maxmark = get_min.minmark
group by get_min.semester,Courses.subject,max_mark.maxmark
;

create or replace view Q5(code, name, semester)
as
--... SQL statements, possibly using other views/functions defined by you ...
select sub.code , sub.name, sem.name as semester
from subjects sub,semesters sem,min_persemester,courses c
where sem.id = min_persemester.semester and sub.id = c.subject and c.semester = min_persemester.semester
      and c.subject = min_persemester.subject
;

-- Q6:
create view stu_engineering(id)
as
select  distinct stu.id
from students stu,Course_enrolments ce,courses c,subjects sub,OrgUnits org
where stu.id = ce.student and ce.course = c.id and c.subject = sub.id and sub.OfferedBy = org.id 
        and org.longname = 'Faculty of Engineering' 
;
create view stu_no_engineering(id)
as
select distinct stu.id
from students stu
where stu.id in (select id from students except select id from stu_engineering)  and stu.stype = 'local'
;
create view stu_manage(id)
as 
select distinct stu.id
from students stu,program_enrolments pe,semesters sem,stream_enrolments se,streams str
where stu.id = pe.student and pe.semester = sem.id and sem.name = 'Sem1 2010' and se.partof = pe.id and se.stream=str.id
       and str.name = 'Management' and stu.stype = 'local'
;

create or replace view Q6(num)
as
--... SQL statements, possibly using other views/functions defined by you ...
select count(People.id) as num
from People,students
where People.id = students.id and students.id in ( select id from stu_no_engineering intersect select id from stu_manage)
;

-- Q7:
create or replace view Q7(year, term, average_mark)
as
--... SQL statements, possibly using other views/functions defined by you ...
select sem.year,sem.term,cast(AVG(mark) as numeric(4,2)) as average_mark
from Course_enrolments ce,courses c,subjects sub,semesters sem
where mark is not null and ce.course = c.id and c.subject = sub.id and sub.name = 'Database Systems'
       and c.semester = sem.id 
group by sem.year,sem.term
;

-- Q8: 

create view avail_sub(code,year,term)
as 
select sub.code,sem.year,sem.term
from subjects sub,courses c,semesters sem
where sub.code like 'COMP93%' and sub.id = c.subject and c.semester = sem.id
      and sem.year >= 2004 and sem.year <= 2013 and (sem.term = 'S1' or sem.term = 'S2')
group by sub.code,sem.year,sem.term
;
create view semester_create(year,term)
as
select distinct year,term
from semesters
where year >= 2004 and year <= 2013 and (term = 'S1' or term = 'S2')
;
create view find_code(code)
as
select distinct code
from avail_sub as1
where not exists(    (select * from semester_create)
                    except
                    (select year,term from avail_sub as2 where as1.code = as2.code)                   
                    )
;

create view stu_code(id,code)
as
select stu.id,sub.code
from students stu,course_enrolments ce,courses c,subjects sub
where stu.id = ce.student and ce.course = c.id and c.subject = sub.id and ce.mark <50 and ce is not null
group by stu.id,sub.code
;


create view find_fail_stu(id)
as
select distinct sc1.id
from stu_code sc1
where not exists (
       (select code from find_code)
       except
       (select distinct code from stu_code sc2 where sc1.id = sc2.id)
)
;

create or replace view Q8(zid, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
select concat('z',unswid) as zid,name
from People,find_fail_stu
where find_fail_stu.id = People.id
;

 --Q9:

 create view stu_two_condition(id)
 as
 select distinct stu.id
 from students stu,Course_enrolments ce,program_enrolments pe,semesters sem,programs pro,program_degrees pd,courses c
 where pd.abbrev = 'BSc' and pd.program = pro.id and pro.id = pe.program and pe.semester = sem.id and sem.name = 'Sem2 2010'
     and pe.student = stu.id and stu.id = ce.student and ce.mark >= 50 and  c.semester = pe.semester and pe.student=ce.student
 ;
create view stu_avg(id,program,avgmark)
as
select stc.id ,pro.name,avg(mark) as avgmark
from stu_two_condition stc,Course_Enrolments ce,courses c,semesters sem,programs pro,program_enrolments pe
where stc.id = ce.student and mark >= 50 and ce.course = c.id and sem.id = c.semester and sem.year<2011
      and stc.id = pe.student and pe.program = pro.id and c.semester = pe.semester and pe.student = ce.student
group by stc.id,pro.name
;
create view stu_third_condition(id)
as
select sa.id
from stu_avg sa
where sa.id not in (select sa.id from stu_avg sa where sa.avgmark < 80)
;
create view stu_pro(id,program)
as
select distinct stc.id,pro.name as program
from stu_third_condition stc,programs pro,program_enrolments pe
where stc.id = pe.student and pe.program = pro.id
;
create view stu_course(id,program,sumuoc,uoc)
as
select stu.id,stu.program,sum(sub.uoc) as sumuoc,pro.uoc
from stu_pro stu,courses c,course_enrolments ce,program_enrolments pe,programs pro,subjects sub,semesters sem
where stu.id = ce.student and ce.course = c.id and ce.mark>=50 and ce.student = pe.student and pe.semester = c.semester
     and pe.program = pro.id and pro.name = stu.program and sub.id = c.subject and c.semester = sem.id and sem.year<2011
group by stu.id,stu.program,pro.uoc
;

create view fin_stu(id)
as
select stu.id
from stu_course stu
where  stu.id  not in (select stu.id from stu_course stu,programs pro where pro.name = stu.program and stu.sumuoc<pro.uoc)
;
create or replace view Q9(unswid, name)
as
--... SQL statements, possibly using other views/functions defined by you ...
select unswid,name
from fin_stu fs,People
where fs.id = People.id
;

-- Q10:
create view room_description(id)
as
select r.id
from rooms r,room_types rt
where r.rtype = rt.id and rt.description = 'Lecture Theatre' 
;

create view class_room(room,course)
as
select rd.id as room,cla.course
from classes cla
right join room_description rd
on  rd.id = cla.room 
;
create view course_sem(id)
as
select  cou.id
from  courses cou,semesters sem
where cou.semester = sem.id and sem.name = 'Sem1 2011'
;

create view class_course(room,id)
as
select  cr.room,cs.id
from class_room cr 
left join course_sem  cs
on cr.course = cs.id
;
create view room_count(room,num)
as
select distinct room,count(id) as num
from class_course
group by room
;
create view room_rank(room,num,rank)
as
select  room,num,rank() over (order by num desc) rank
from room_count
group by room,num
;
create or replace view Q10(unswid, longname, num, rank)
as
select distinct unswid,longname,num,rank
from room_rank rr,Rooms r
where rr.room = r.id
--... SQL statements, possibly using other views/functions defined by you ...
;

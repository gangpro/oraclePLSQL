<PL/SQL 활용 및 응용>

# 0장. intro

## Program?
* 해야 할 일을 미리 기술해 놓은 것.
* 인간의 언어
###
    인간의 언어
    
        ↓ translate(사람)
    
    프로그래밍 언어 : C, Java, SQL, PL/SQL, HTML, ... 
    
        ↓ translate(소프트웨어)

      기계어

## PL/SQL
* PLSQL = https://en.wikipedia.org/wiki/PL/SQL
* SQL =  https://en.wikipedia.org/wiki/SQL#Procedural_extensions
* Pascal -> Ada -> PL/SQL
* SQL(Manipulating power) + 3GL(Processing power) = PL/SQL
* 구조
###
    Block Structured Language -> Anonymous block
                              -> Named block      : procedure, function, package, trigger, object, ...
###
    --Anonymous block
    declare     --옵션, declare 대신 
        선언부
    begin       --필수 키워드
        실행부
    exception   --옵션
        예외처리부
    end;        --필수 키워드
    /           --종결

###
    --Named block
    SOMETHING   --옵션
        선언부
    begin       --필수 키워드
        실행부
    exception   --옵션
        예외처리부
    end;        --필수 키워드
    /           --종결

* SQL 엔진 + PL/SQL 엔진
* function은 SQL에 포함시킬 수 있다는 점에서 procedure에 비해 유리한 점 있음





## Anonymous Block 예제들
--plsql을 사용하여 Hello World 출력
set serveroutput on     --화면 출력 기능 툴

begin
    dbms_output.put_line('Hello World!');   --오라클 서버에 요청해서 화면에 출력
end;
/


--
begin
    for i in 1..10 loop
        dbms_output.put_line(i||'번째, Hello World!');
    end loop;
end;
/


--begin 안에 select문, v_sal 변수를 넣기 위해 declare에 v_sal 변수 선언
declare
    v_sal number;
begin
    select sal into v_sal
    from emp
    where empno = 7788;
    
    dbms_output.put_line(v_sal);
end;
/
###





## Named Block 예제들
--plsql을 사용하여 Hello World 출력
create or replace procedure p1      --dbms()....을 p1에 저장
is
begin
    dbms_output.put_line('Hello World!');
end;
/

col object_name format a30

select object_name, object_type
from user_objects
where object_type in ('PROCEDURE', 'FUNCTION', 'PACKAGE')
order by 2, 1;

col name format a30
col text format a80

select name, text
from user_source;

execute p1




###
--p1
create or replace procedure p1(a number)
is
    v_sal number;
begin
    select sal into v_sal
    from emp
    where empno = a;
    
    dbms_output.put_line(v_sal);
end;
/

desc p1

exec p1(7788)   --7788사원의 월급이 리턴 = 3000

###
--p2
    create  or replace procedure p2(a number)
    is
    begin
      for i in 1..a loop
        dbms_output.put_line(i||'번째, Hello world!');
      end loop;
    end;
    /

    desc p2

    exec p2(100)
###
--p3
create or replace procedure p3(a number)
is
    v_sal number;
begin
    select sal into v_sal
    from emp
    where empno = a;
    
    dbms_output.put_line(v_sal);
end;
/

exec p3(7788)
exec p3(7900)




## 문제. 부서번호를 입력하면 평균급여를 리턴하는 프로시져를 생성할 것
set serveroutput on
select * from emp;

create or replace procedure emp_avg_sal(a number)   --헤더부분(변수(매개변수 데이터타입))
is
    v_avg_sal number;                               --선언부(변수명 데이터타입)
begin
    select avg(sal) into v_avg_sal
    from emp
    where deptno = a;
    
    dbms_output.put_line(round(v_avg_sal, 2));
end;
/

show errors

exec emp_avg_sal(10)
exec emp_avg_sal(30)


###
--emp_avg_sal 프로시져에 out 매개변수를 사용할 경우
--첫번째 문장
set serveroutput on     --세션이 종료 된 후 다시 시작하면 무조건 On 해야함.

create or replace procedure emp_avg_sal(a in number, b out number)      --a 들어오는 매개변수, b 나가는 매개변수 
is
begin
    select round(avg(sal), 2) into b
    from emp
    where deptno = a;
end;
/

show errors

--두번째 문장
create or replace procedure emp_sal_compare(a number)
is
    v_sal     emp.sal%type;
    v_deptno  emp.deptno%type;
    v_avg_sal number;
begin
    select sal, deptno into v_sal, v_deptno
    from emp
    where empno = a;
    
    emp_avg_sal(v_deptno, v_avg_sal);
    
    if v_sal > v_avg_sal then
        dbms_output.put_line('소속부서 평균 급여보다 급여 큼');
    elsif v_sal < v_avg_sal then
        dbms_output.put_line('소속부서 평균 급여보다 급여 적음');
    else
        dbms_output.put_line('소속부서 평균 급여보다 급여 같음');
    end if;
end;
/

--첫번째 문장과 두번째 문장을 활용
exec emp_sal_compare(7788)
exec emp_sal_compare(7900)





###
    --emp_avg_sal 프로시져를 함수로 변경할 경우
    drop procedure emp_avg_sal;

    create or replace function emp_avg_sal (p_deptno emp.deptno%type)
      return number
    is
      b number;
    begin                                       --함수는 begin과 end 안에 return이 필요 
      select round(avg(sal), 2) into b
      from emp
      where deptno = p_deptno;

      return b;
    end;
    /

    - function은 SQL에 포함시킬 수 있다는 점에서 
      procedure에 비해 유리한 점 있음
 
    select deptno, emp_avg_sal(deptno) avg_sal
    from dept;

    create or replace procedure emp_sal_compare(a number)
    is
      v_sal     emp.sal%type;
      v_deptno  emp.deptno%type;
    begin
      select sal, deptno into v_sal, v_deptno
      from emp
      where empno = a;

      if v_sal > emp_avg_sal(v_deptno) then
        dbms_output.put_line('소속 부서 평균 급여보다 급여 큼');
      elsif v_sal < emp_avg_sal(v_deptno) then
        dbms_output.put_line('소속 부서 평균 급여보다 급여 적음');
      else
        dbms_output.put_line('소속 부서 평균 급여보다 급여 같음');
      end if;
    end;
    /

    show errors

    exec emp_sal_compare(7788)
    exec emp_sal_compare(7900)










## 문제. 급여가 높은 사원의 사번을 출력하는 함수를 만드세요.
--함수
drop procedure emp_sal_compare;

create or replace function emp_sal_compare(p_first_empno emp.empno%type, p_second_empno emp.empno%type) --매개변수 앞에는 일반적으로 p_NAME
    return emp.empno%type
is
    v_first_sal emp.sal%type;
    v_second_sal emp.sal%type;
begin
    select sal into v_first_sal 
      from emp 
     where empno = p_first_empno;
     
    select sal into v_second_sal 
      from emp 
     where empno = p_second_empno;
    
    if v_first_sal > v_second_sal then
        return p_first_empno;
        
    elsif v_first_sal < v_second_sal then
        return p_second_empno;
        
    else
        return 0;
    end if;    
end;
/

show error


--함수 테스트용 조인 문장
select w.empno, e.empno
  from emp w, emp e
 where w.empno = 7788 and e.empno != w.empno;

select w.empno, e.empno, emp_sal_compare(w.empno, e.empno) as winner
  from emp w, emp e
 where w.empno = 7788 and e.empno != w.empno;

###
--cf. 함수없이 그냥 SQL로 해결하면 이렇습니다.

select w.empno, e.empno, case when w.sal > e.sal then w.empno 
                              when w.sal < e.sal then e.empno
                              else
                          end as winner
  from emp w, emp e
 where w.empno = 7788 and e.empno != w.empno;












## DML을 PL/SQL 프로그램 Unit을 이용해서 구현
drop table t1 purge;

create table t1
as
select empno, ename, sal, job
from emp
where 1 = 2;

create or replace procedure t1_insert_proc(a number, b varchar2, c number, d varchar2)
is
begin
    if c <= 1000 then
        dbms_output.put_line('입력 실패! 급여를 확인하세요');
    else
        insert into t1
        values(a, b, c, d);
    end if;    
end;
/

show errors     --오타 발생시 이유를 알 수 있음

exec t1_insert_proc(1000, 'Tom', 200, 'MANAGER');













--반복적으로 사용하는 select문을 파일에 저장 할 수 있다.
--장점은 편하지만 단점은 이 파일을 들고 다녀야 한다.
select empno, ename, sal
from emp
where deptno = 30;

ed s001.sql


또는















# 1장. 
desc dbms_output



    create or replace function tax(a number)
        return number
    is
        v_sal number := a;                    
        v_tax constant number := 0.013;  
    begin
        return v_sal * v_tax;
    end;
    /
    
    select empno, job, sal, tax(sal)
      from emp
     where job in('MANAGER', 'SALESMAN');
     
     
     
    set serveroutput on
    
    create or replace procedure p1(k number)
    is
        v_sal emp.sal%type;
    begin
        select sal into v_sal
        from emp
        where empno = k;
        
        dbms_output.put_line(k||' 사원의 급여는 '||v_sal||'입니다.');
    end;
    / 
    
    exec p1(7788)






        create or replace procedure p1(k number)
    is
        r emp%rowtype;    --emp%rowtype : 테이블 컬럼의 구조 그대로 데이터 타입을 갖는다.
    begin
        select * into r
          from emp
         where empno = k;
         
        dbms_output.put_line(r.empno);  --방식1
        dbms_output.put_line(r.ename);
        
        dbms_output.put_line(r.empno||' ' ||r.ename);   --방식2
    end;
    /
    
    exec p1(7788)






    create or replace procedure p1(a in jobs.job_id%type, b out jobs%rowtype)
    is
    begin
        select * into b
        from jobs
        where job_id = upper(a);
    end;
    /
    
    --아래 함수에서 위 프로시져 호출
    create or replace function f1(j in jobs.job_id%type)
        return jobs.job_title%type
    is
        r jobs%rowtype;
    begin
        p1(j, r);
        
        return r.job_title;
    end;
    /
    
    exec dbms_output.put_line('abc')
    exec dbms_output.put_line(f1('ad_pres'))
    exec dbms_output.put_line(f1('st_man'))




    drop table t1 purge;
    
    create table t1
    as
    select * from emp;


    create or replace procedure t1_set_ename(a t1.empno%type, b t1.ename%type)
    is
    begin
        update t1
        set ename = b
        where empno = a;
    end;
    /
    
    select * from t1;
    
    exec t1_set_ename(7369, 'QUEEN')
    
    select * from t1;


    create or replace function t1_get_ename(a t1.empno%type)
        return t1.ename%type
    is
        v_ename t1.ename%type;
    begin
        select ename into v_ename
        from t1
        where empno = a;
        
        return v_ename;
    end;
    /    
    
    select * from t1;
    exec dbms_output.put_line(t1_get_ename(7369))
    select * from t1;

## setter & getter를 package로 
    --패키지 변환
    create or replace package t1_pack
    is
        procedure t1_set_ename(a t1.empno%type, b t1.ename%type);
    
        function t1_get_ename(a t1.empno%type)
            return t1.ename%type;
    end;
    /
    
    create or replace package body t1_pack
    is
        procedure t1_set_ename(a t1.empno%type, b t1.ename%type)
        is
        begin
            update t1
               set ename = b
             where empno = a;
        end;  
    
        function t1_get_ename(a t1.empno%type)
            return t1.ename%type
        is 
            v_ename t1.ename%type;
        begin
            select ename into v_ename
              from t1
             where empno = a;
        
            return v_ename;
        end;
    end;
    /
    
    exec t1_pack.t1_set_ename(7369, 'PRINCE')
    select * from t1;
    exec dbms_output.put_line(t1_pack.t1_get_ename(7369))




    create or replace procedure p1(k number)
    is
        TYPE rt IS RECORD
        (a emp.ename%type, 
         b emp.job%type, 
         c emp.sal%type);     --필드명은 일반적으로 컬럼명으로 작성
        
        r rt;   --rt란 데이터 타입은 r변수를 따른다.
    begin
        select ename, job, sal into  r
          from emp
         where empno = k;
         
         dbms_output.put_line(r.a);
         dbms_output.put_line(r.b);
         dbms_output.put_line(r.c);
    end;
    /
    
    exec p1(7788)




    --조금더
    --바디가 없는 패키지로 만들면 활용성 증가
    create or replace package pack1
    is
        TYPE rt IS RECORD
        (a emp.ename%type, 
         b emp.job%type, 
         c emp.sal%type);
    end;
    /


    create or replace procedure p1(k number)
    is
        r pack1.rt;
    begin
        select ename, job, sal into  r
          from emp
         where empno = k;
         
         dbms_output.put_line(r.a);
         dbms_output.put_line(r.b);
         dbms_output.put_line(r.c);
    end;
    /


    exec p1(7788)









drFINAL QUERY 1 :


----> INSERT INTO stars (name) VALUES ('yo mismo');
----> INSERT INTO movies (title, director) VALUES ('123456789','yo mismo');
----> INSERT INTO genres_movies (title,director,genre) VALUES ('123456789','yo mismo','Comedy');
----> INSERT INTO genres_movies (title,director,genre) VALUES ('123456789','yo mismo','Drama');

SELECT * from movies where title in (SELECT title FROM (select * from genres_movies where genre = 'Drama' OR genre = 'Comedy') GROUP BY title HAVING COUNT(*)>1) ORDER BY title;

---> BORRAR
delete from genres_movies where title = '123456789'
delete from movies where title = '123456789';
delete from stars where name = 'yo mismo';

INSERT INTO users (nick,password,email,reg_date) VALUES ('zzzzzzzzz','patata','patata@patatamail.com','30-10-2000');
INSERT INTO profiles (nick,citizenid) VALUES ('zzzzzzzzz','ZZZZZZZZ12');
----------------->><><
select * from users where nick in(
select nick from profiles where citizenid in(
(select citizenid from profiles where nick in (select nick from (select nick from users where (MONTHS_BETWEEN(SYSDATE,reg_date)>=6))
NATURAL JOIN (select nick from users MINUS select nick from users NATURAL JOIN membership)))
 MINUS
select citizenid from contracts where citizenid in (select citizenid from profiles where nick in 
(select nick from (select nick from users where (MONTHS_BETWEEN(SYSDATE,reg_date)>=6)) NATURAL JOIN (select nick from users MINUS select nick from users NATURAL JOIN membership)))
)
);
---> BORRAR

-----------------------<><>

 SELECT director as FILMMASTER from 
	(select director,mov as movies,com as total_comments,com/mov as AVERAGE_COMMENTS_MOVIE from
		 ((select director,count(*) as mov from movies group by director) 
		 natural join
		 (SELECT DIRECTOR,count(*) as com FROM comments GROUP BY director HAVING COUNT(*)>0 )) order by AVERAGE_COMMENTS_MOVIE)
	 where AVERAGE_COMMENTS_MOVIE=
		(SELECT MAX(AVERAGE_COMMENTS_MOVIE) from 
			(select director,mov as movies,com as total_comments,com/mov as AVERAGE_COMMENTS_MOVIE from
				 ((select director,count(*) as mov from movies group by director) 
				 natural join 
				 (SELECT DIRECTOR,count(*) as com FROM comments GROUP BY director HAVING COUNT(*)>0 )) order by AVERAGE_COMMENTS_MOVIE));





-------------------------
select member, count(*) as total_prop from  proposals group by member order by total_prop;


select member as iden,
(select count(*) from comments where nick=member AND title in (select title from proposals where member=nick)) as commented ,
 count(*) as total, 
(select count(*) from comments where nick=member AND title in (select title from proposals where member=nick))/count(*) as perc 
from  proposals group by member order by perc desc;

create view CAPTAIN_ARAGNA as
select * from (select member as name,
    (select count(*) from comments where nick=member AND title in (select title from proposals where member=nick)) as commented_proposals ,
     count(*) as total_proposals,
    100-(((select count(*) from comments where nick=member AND title in (select title from proposals where member=nick))/count(*))*100) as percentage
 from  proposals group by member order by percentage desc) where percentage >0;

------------------><><
create view CAPTAIN_ARAGNA as
select * from (select member as name,
    100-(((select count(*) from comments where nick=member AND title in (select title from proposals where member=nick))/count(*))*100) as percentage
 from  proposals group by member order by percentage desc) where percentage >0;
----------------------------------><><


select * from (select member as name, (select club from membership where nick = name) as club, (select count(*) from comments where nick=(select nick from membership where club =) AND title in (select title from proposals where member=nick)) as commented_proposals , count(*) as total_proposals,
    100-(((select count(*) from comments where nick=member AND title in (select title from proposals where member=nick))/count(*))*100) as percentage
 from  proposals group by member order by percentage desc) where percentage >0;


select * from (select member as name, (select club from membership where nick = member), (select count(*) from comments where nick in (select nick from membership where club in (select club from membership where nick = member)) AND title in (select title from proposals where member=nick)) as commented_proposals , count(*) as total_proposals from  proposals group by member);


select * from (select member as name, (select club from membership where nick = member), (select count(*) from comments where title in (select title from proposals where member = member) and nick in (select nick from membership where club = (select club from membership where nick = member))) , count(*) as total_proposals from  proposals group by member) where rownum <= 10;

select count(*) from comments where club = (select club from membership where nick='cucho')  AND title in (select title from proposals where member = 'cucho')




select * from (select member as name, (select club from membership m1 where nick = p2.member), (select count(*) from comments c1 where title in (select title from proposals p1 where member = p2.member) and club = (select club from membership m3 where nick = p2.member))) as comme , count(*) as total_proposals from  proposals p2 group by member) where rownum <= 10;



------------------------------><><><
create view Leader as
select * from (
select member as name, 
(select club from membership m1 where nick = p2.member) as club, 
(select count(*) from comments c1 where title in (select title from proposals p1 where member = p2.member) and club = (select club from membership m3 where nick = p2.member))/count(*) as tot 
from  proposals p2 group by member order by tot desc) where rownum <= 10;

-------------><<<><



HISTORICAL






---------------><><><
  
CREATE OR REPLACE VIEW TH AS SELECT * FROM CLUBS WHERE END_DATE IS NOT NULL;
CREATE OR REPLACE VIEW TC AS SELECT * FROM CLUBS WHERE END_DATE IS NULL;

CREATE OR REPLACE VIEW THM AS SELECT * FROM MEMBERSHIP WHERE END_DATE IS NOT NULL;
CREATE OR REPLACE VIEW TCM AS SELECT * FROM MEMBERSHIP WHERE END_DATE IS NULL;

CREATE  OR REPLACE TRIGGER tr1
INSTEAD OF DELETE OR UPDATE ON tc
BEGIN
	IF DELETING THEN
		UPDATE clubs set END_DATE=SYSDATE WHERE name=:OLD.name;
	ELSE
		NULL;
	END IF;
END;


CREATE  OR REPLACE TRIGGER trm1
INSTEAD OF DELETE OR UPDATE ON tcm
BEGIN
	IF DELETING THEN
		UPDATE membership set END_DATE=SYSDATE WHERE nick=:OLD.nick and club = :OLD.club;
	ELSE
		NULL;
	END IF;
END;


CREATE  OR REPLACE TRIGGER tr2
INSTEAD OF INSERT OR UPDATE ON th
BEGIN	
	NULL;
END;

CREATE  OR REPLACE TRIGGER trm2
INSTEAD OF INSERT OR UPDATE ON thm
BEGIN	
	NULL;
END;


CREATE  OR REPLACE TRIGGER tr3
INSTEAD OF DELETE ON th
BEGIN	
	DELETE from candidates where club = :old.name;
	DELETE FROM membership WHERE club= :old.name;
	DELETE FROM clubs where name = :old.name;
END;

CREATE  OR REPLACE TRIGGER trm3
INSTEAD OF DELETE ON thm
BEGIN	
	DELETE FROM membership WHERE club= :old.club and nick = :old.nick;
END;



insert into users (nick, password , email, reg_date) 
VALUES ('davidryt','sfasdasfdadf', 'dsfsdnksdskndv', sysdate);

insert into tc (name, founder, cre_date, open) 
VALUES ('zzzzzzzzzz', 'davidryt' , SYSDATE, 'O');

insert into tcm (nick, club, type, req_date, inc_date) 
VALUES ('davidryt', 'zzzzzzzzzz', 'A', sysdate-10, sysdate);




----------------------------------------------------------------------------------------------
					TRIGGERS
----------------------------------------------------------------------------------------------





	rename comments to comments_tb;

	create view comments as select * from comments_tb;

	CREATE  OR REPLACE TRIGGER overwrite
	INSTEAD OF INSERT ON comments
	referencing new as new old as old
	FOR EACH ROW
	DECLARE	 varexist number;
	BEGIN
	select count(*) into varexist from comments where nick = :new.nick and title = :new.title;
	IF varexist != 0 THEN
			UPDATE comments set message = :new.message, msg_date = SYSDATE where comments.nick = :new.nick and comments.title = :new.title;
	ELSE

			insert into comments_tb (nick, title, director, club, msg_date, message) VALUES (:new.nick, :new.title, :new.director, :new.club, :new.msg_date, :new.message);
	END IF;
	END;


CREATE  OR REPLACE TRIGGER TheKingIsDead
FOR UPDATE ON clubs
COMPOUND TRIGGER
	 nombre VARCHAR2(60) := :new.name;
	 foundnull VARCHAR2(35) := :new.founder ;
	 nomembers number;
	 ff number;
AFTER EACH ROW IS
BEGIN
select count(*) into nomembers from membership where club = nombre;
IF foundnull is NULL THEN
	IF nomembers > 0 THEN
		DBMS_OUTPUT.PUT_LINE('FOUNDER NULL y hay miembro');
		insert into clubs_backup (name, founder, cre_date, end_date, slogan, open) VALUES (nombre, (select * from (select nick from membership where membership.club = nombre order by inc_date) where rownum = 1) , :new.cre_date, :new.end_date, :new.slogan, :new.open);
	ELSE
		DBMS_OUTPUT.PUT_LINE('FOUNDER NULL y NO HAY miembro');
		insert into clubs_backup (name, founder, cre_date, end_date, slogan, open) VALUES (nombre, NULL , :new.cre_date, :new.end_date, :new.slogan, :new.open);
	END IF;
ELSE
		DBMS_OUTPUT.PUT_LINE('FOUNDER NOT NULL');
		NULL;
END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS
BEGIN
DBMS_OUTPUT.PUT_LINE('SEGUNDO TRIG');
IF foundnull is NULL THEN
	IF nomembers > 0 THEN
		DBMS_OUTPUT.PUT_LINE('SEGUDO TRIG NULL IF');
		update clubs set founder = (select founder from clubs_backup) where name =nombre;
	ELSE
	select count(*) into ff from clubs_backup;
		IF ff = 1 then
		DBMS_OUTPUT.PUT_LINE('BORRANDO');
		update clubs set end_date = SYSDATE where name = nombre;
		ELSE
		DBMS_OUTPUT.PUT_LINE('terminando');
		END IF;
	END IF;
ELSE
	
	NULL;
END IF;
END AFTER STATEMENT;
END TheKingIsDead;



CREATE GLOBAL TEMPORARY TABLE clubs_backup (
name	   VARCHAR2(60),
founder  VARCHAR2(35),
cre_date DATE NOT NULL,
end_date DATE,
slogan	 VARCHAR2(100),
open     CHAR(1) DEFAULT 'O' NOT NULL
) ON COMMIT DELETE ROWS;


update clubs set founder = NULL  where name = 'Dude Guild'; 

update clubs set founder = 'davidryt' where name = 'Dude Guild'; 



select * from comments where nick = 'blt';

insert into comments (nick, title, director, club, msg_date, message) 
VALUES ('blt','The Illusionist','Neil Burger','The Donkey Guild',SYSDATE,'me quiero morir');

DELETE FROM comments where message = 'me quiero morir';

and :old.title = :new.title





CREATE  OR REPLACE TRIGGER Application
FOR INSERT ON candidates
COMPOUND TRIGGER

	 usnom  VARCHAR2(35) := :new.nick;
	 nombre VARCHAR2(60) := :new.club;
	 closed number;

AFTER EACH ROW IS
BEGIN
select count(*) into closed from clubs where name = nombre and open = 'O';
IF closed != 0 THEN
	
		DBMS_OUTPUT.PUT_LINE('club cerrado denegar');
		insert into candidates_temp (nick, club, req_date, type, req_msg ) values (usnom, nombre , :new.req_date, :new.type, :new.req_msg );
		NULL;

ELSE
	DBMS_OUTPUT.PUT_LINE('club abierto');
END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS
BEGIN
DBMS_OUTPUT.PUT_LINE('Segundo trigger');
IF closed != 0 THEN
	DBMS_OUTPUT.PUT_LINE('Segundo trigger BORRAR');
	update candidates set rej_date = sysdate, rej_msg = ('AUTO') where nick = usnom AND club = nombre;
ELSE
	DBMS_OUTPUT.PUT_LINE('Segundo trigger NADA');
END IF;
END AFTER STATEMENT;
END Application;


COMMIT;


CREATE GLOBAL TEMPORARY TABLE candidates_temp (
nick     VARCHAR2(35),
club     VARCHAR2(60),
member   VARCHAR2(35),
type     CHAR(1) NOT NULL,
req_date DATE NOT NULL,
req_msg  VARCHAR2(1500) NOT NULL,
rej_date DATE,
rej_msg  VARCHAR2(1500)
) ON COMMIT DELETE ROWS;








update candidates set rej_date= SYSDATE+1, rej_msg = 'AUTO' where nick = usnom and club = nombre; 

insert into candidates (nick, club, req_date, type, req_msg) values ('davidryt', 'The Club of Latin' , sysdate-1, 'A', 'no falles');

select nick,club into usnom,nombre from candidates c2 where c2.club = club and c2.nick = nick;




SEGUIR
--------------------------------------------
create role reg_usr;


create or replace view OpenPub as (select club, count(*) as MEMBERS,
(MONTHS_BETWEEN(SYSDATE,(select cre_date from clubs where name = membership.club))) as Active, 
((select count(*) from proposals where club = membership.club)/(MONTHS_BETWEEN(SYSDATE,(select cre_date from clubs where name = membership.club)))) as proposal_month, 
((select count(*) from comments where club = membership.club)/(select count(*) from proposals where club = membership.club)) as Mean
 from membership group by club );


create or replace view Anyone_goes as (select * from (select club, COUNT(*) as accepted
from membership where (type = 'A') group by club order by accepted desc) where rownum<6);



CREATE TABLE report (
club     VARCHAR2(60),
type     CHAR(1) NOT NULL,
req_date DATE NOT NULL,
inc_date DATE NOT NULL,
end_date DATE,
rej_date DATE)




create or replace view Report as (
select candidates.club as CLUB_NAME, membership.type AS TYPE,
CASE WHEN candidates.rej_date IS NOT NULL THEN 'Rejected' WHEN candidates.rej_date IS NULL THEN 'Pending' ELSE 'Accepted' END as STATUS,
inc_date as start_date, membership.end_date
FROM (
membership LEFT JOIN candidates
ON (
membership.club = candidates.club 
--and membership.nick = USER
)
)
);







 SELECT title, COUNT(*) AS rec FROM (select * from genres_movies where genre = 'Drama' OR genre = 'Comedy') GROUP BY title HAVING COUNT(*)>1 ORDER BY title;
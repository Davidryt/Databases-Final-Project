-- ----------------------------------------------------
-- -- Part III: Populate tables by querying old ones --
-- ----------------------------------------------------

INSERT INTO stars (
SELECT DISTINCT actor_1_name FROM fsdb.old_movies WHERE actor_1_name IS NOT NULL
UNION SELECT DISTINCT actor_2_name FROM fsdb.old_movies WHERE actor_2_name IS NOT NULL
UNION SELECT DISTINCT actor_3_name FROM fsdb.old_movies WHERE actor_3_name IS NOT NULL
UNION SELECT DISTINCT director_name FROM fsdb.old_movies );
-- 8354 rows

-- PROBLEM 1: film 'The Sting' appears twice, but with different stars 
-- SOLUTION: while uploading movies (without stars), SELECT DISTINCT; while uploading 'casts', insert all six
INSERT INTO movies (title, director, duration, year, country, language,color, aspect_ratio, 
            gross, budget, content_rating, faces_poster, imdb_score, imdb_link, num_critic, 
            voted_users, user_reviews, movie_likes, director_likes, cast_likes) 
SELECT DISTINCT movie_title,director_name,duration,TO_NUMBER(title_year),country, language, 
       CASE WHEN color='Black and White' THEN 'B' WHEN color='Color' THEN 'C' ELSE null END,
       TO_NUMBER(aspect_ratio,'99.99'),gross,budget,content_rating,facenumber_in_poster,
       TO_NUMBER(imdb_score,'9.9'),movie_imdb_link,num_critic_for_reviews,num_voted_users,
       num_user_for_reviews,movie_facebook_likes,director_facebook_likes,cast_total_facebook_likes 
FROM fsdb.old_movies;
-- 4814 rows

INSERT INTO casts (
SELECT DISTINCT actor_1_name,movie_title,director_name,actor_1_facebook_likes 
       FROM fsdb.old_movies WHERE actor_1_name IS NOT NULL
UNION SELECT DISTINCT actor_2_name,movie_title,director_name,actor_2_facebook_likes 
      FROM fsdb.old_movies WHERE actor_2_name IS NOT NULL
UNION SELECT DISTINCT actor_3_name,movie_title,director_name,actor_3_facebook_likes 
      FROM fsdb.old_movies WHERE actor_3_name IS NOT NULL);
-- 14409 rows

INSERT INTO genres (
SELECT DISTINCT genre1 FROM fsdb.old_movies WHERE genre1 IS NOT NULL
UNION SELECT DISTINCT genre2 FROM fsdb.old_movies WHERE genre2 IS NOT NULL
UNION SELECT DISTINCT genre3 FROM fsdb.old_movies WHERE genre3 IS NOT NULL
UNION SELECT DISTINCT genre4 FROM fsdb.old_movies WHERE genre4 IS NOT NULL
UNION SELECT DISTINCT genre5 FROM fsdb.old_movies WHERE genre5 IS NOT NULL);
-- 24 rows

INSERT INTO genres_movies (
SELECT DISTINCT movie_title,director_name,genre1 FROM fsdb.old_movies WHERE genre1 IS NOT NULL
UNION SELECT DISTINCT movie_title,director_name,genre2 FROM fsdb.old_movies WHERE genre2 IS NOT NULL
UNION SELECT DISTINCT movie_title,director_name,genre3 FROM fsdb.old_movies WHERE genre3 IS NOT NULL
UNION SELECT DISTINCT movie_title,director_name,genre4 FROM fsdb.old_movies WHERE genre4 IS NOT NULL
UNION SELECT DISTINCT movie_title,director_name,genre5 FROM fsdb.old_movies WHERE genre5 IS NOT NULL);
-- 13698 rows

INSERT INTO keywords (
SELECT DISTINCT movie_title,director_name,keyword1 FROM fsdb.old_movies WHERE keyword1 IS NOT NULL
UNION SELECT DISTINCT movie_title,director_name,keyword2 FROM fsdb.old_movies WHERE keyword2 IS NOT NULL
UNION SELECT DISTINCT movie_title,director_name,keyword3 FROM fsdb.old_movies WHERE keyword3 IS NOT NULL
UNION SELECT DISTINCT movie_title,director_name,keyword4 FROM fsdb.old_movies WHERE keyword4 IS NOT NULL
UNION SELECT DISTINCT movie_title,director_name,keyword5 FROM fsdb.old_movies WHERE keyword5 IS NOT NULL);
-- 23035 rows


INSERT INTO users (nick, password, email, reg_date) 
   SELECT nickname,passw,email,TO_DATE(ev_date||ev_hour,'YYYY-MM-DDHH24:MI') 
      FROM old_users JOIN (SELECT client nickname,ev_date,ev_hour FROM old_events WHERE etype='registration') USING(nickname);
-- 12345 rows


-- PROBLEM 2: user 'esperanza7' lacks of citizenID, while she has a profile 
-- SOLUTION:  skip it
-- PROBLEM 3: users 'carhuamaca3' and 'alfredo40' share the same citizenID ('82768894J')
-- SOLUTION:  skip them
INSERT INTO profiles (nick, name, surname, secsurname, citizenID, mobile, birthdate)
   SELECT nickname,name,surname,sec_surname,citizenID,TO_NUMBER(phoneN),TO_DATE(birthdate,'YYYY-MM-DD')
      FROM old_users 
      WHERE citizenID!='82768894J';
-- this condition checks citizenID is comparable (not null) and different from '82768894J'
-- 12064 rows (3 ill rows skipped)


INSERT INTO products 
   (SELECT DISTINCT contract_type 
       FROM old_users WHERE contract_type is not null);
-- 8 rows

INSERT INTO contracts (idcontract,citizenID,contract_type,startdate,enddate,address,town,ZIPcode,country)
   SELECT contractid,citizenID,contract_type,TO_DATE(startdate,'YYYY-MM-DD'),TO_DATE(enddate,'YYYY-MM-DD'),
          address,town,ZIPcode,country 
      FROM old_users WHERE contractID is not null;
-- 8002 rows

INSERT INTO viewings (title,director,client,vdate) 
   WITH watching AS (SELECT details1 title, details2 dir, client nick, 
                            TO_DATE(ev_date||ev_hour,'YYYY-MM-DDHH24:MI') vdate
                        FROM old_events WHERE etype='viewing')
   SELECT A.title,A.dir,C.IDcontract,A.vdate
      FROM watching A JOIN (SELECT nick,citizenID FROM profiles) B USING(nick) JOIN contracts C 
           ON(B.citizenID=C.citizenID AND A.vdate>=C.startdate AND (C.enddate IS NULL OR C.enddate>=A.vdate));
-- 30867 rows

INSERT INTO clubs (name,founder,cre_date,end_date,slogan,open) 
   SELECT club,A.client,TO_DATE(A.ev_date||A.ev_hour,'YYYY-MM-DDHH24:MI'),
          TO_DATE(B.ev_date||B.ev_hour,'YYYY-MM-DDHH24:MI'),A.subject,
          CASE WHEN details1='Open' THEN 'O' ELSE 'C' END
       FROM (SELECT * FROM old_events WHERE etype='foundation') A
           LEFT OUTER JOIN 
           (SELECT club,ev_date,ev_hour FROM old_events WHERE etype='ceasing') B
           USING(club);
-- 399 rows

INSERT INTO membership (nick,club,mentor,type,req_date,inc_date,end_date,req_msg,acc_msg)
   SELECT client,club,null,'F',TO_DATE(ev_date||ev_hour,'YYYY-MM-DDHH24:MI'),
          TO_DATE(ev_date||ev_hour,'YYYY-MM-DDHH24:MI')+1/86400,null,details1,subject
       FROM old_events WHERE etype='foundation';
-- 399 rows


INSERT INTO membership (nick,club,mentor,type,req_date,inc_date,end_date,req_msg,acc_msg)
   WITH 
     -- members from application: first mentor's answer (in case several mentors accept) 
        applies AS ( SELECT A.client nick,A.club club,B.client member,
                            TO_DATE(A.ev_date||A.ev_hour,'YYYY-MM-DDHH24:MI') adate,
                            TO_DATE(B.ev_date||B.ev_hour,'YYYY-MM-DDHH24:MI') rdate,
                            A.message amsg,B.message rmsg
                        FROM (SELECT * FROM old_events WHERE etype='application') A 
                             JOIN (SELECT * FROM old_events WHERE etype='acceptance') B 
                             ON (A.club=B.club AND A.client=B.subject) ),
     -- latest application of candidate (in case has issued several applications)
        welcm AS ( SELECT nick,club,rdate,max(adate) adate
                   FROM (Select nick,club,min(rdate) rdate FROM applies GROUP BY nick,club) C 
                        JOIN applies D USING (nick,club,rdate) 
                   GROUP BY (nick,club,rdate) ),
     -- members coming from application
        cand_A AS (SELECT nick, club,F.member mentor,'A' type, adate req_date,
                          rdate inc_date, null end_date, F.amsg req_msg, F.rmsg acc_msg
                      FROM welcm E JOIN applies F USING (nick,club,rdate,adate) ),
     -- members coming from invitation
        cand_I AS (SELECT B.client nick,A.club club,A.client mentor,'I' type,
                         TO_DATE(A.ev_date||A.ev_hour,'YYYY-MM-DDHH24:MI') req_date,
                         TO_DATE(B.ev_date||B.ev_hour,'YYYY-MM-DDHH24:MI') inc_date,
                         null end_date,A.message req_msg,B.message acc_msg
                     FROM (SELECT * FROM old_events WHERE etype='invitation') A 
                          JOIN (SELECT * FROM old_events WHERE etype='acceptance') B 
                          ON (A.club=B.club AND (A.client=B.subject OR A.club=B.subject) AND A.subject=B.client)),
        cand_ALL AS (SELECT * FROM cand_A UNION SELECT * FROM cand_I)
   SELECT nick,club,mentor,type,req_date,inc_date,end_date,req_msg,acc_msg 
      FROM cand_ALL ORDER BY inc_date;
-- 4897 rows

INSERT INTO candidates (nick,club,member,type,req_date,req_msg,rej_date,rej_msg)
   SELECT B.client,A.club,A.client,'I',TO_DATE(A.ev_date||A.ev_hour,'YYYY-MM-DDHH24:MI'),
          A.message,TO_DATE(B.ev_date||B.ev_hour,'YYYY-MM-DDHH24:MI'),B.message
      FROM (SELECT * FROM old_events WHERE etype='invitation') A 
           JOIN (SELECT * FROM old_events WHERE etype='rejection') B 
           ON (A.club=B.club AND (A.client=B.subject OR A.club=B.subject) AND A.subject=B.client);
-- 505 rows           

INSERT INTO candidates (nick,club,member,type,req_date,req_msg,rej_date,rej_msg)
   SELECT subject,club,client,'I',TO_DATE(ev_date||ev_hour,'YYYY-MM-DDHH24:MI'),message,null,null
      FROM old_events 
      WHERE etype='invitation'
           AND (subject,club) NOT IN (SELECT client,club from old_events where etype='rejection' or etype='acceptance');
-- 335 rows

-- PROBLEM 4: user 'maria59' is not a member of 'Club of the Harvest potato' and rejects an application for it
-- SOLUTION: skip it
INSERT INTO candidates (nick,club,member,type,req_date,req_msg,rej_date,rej_msg)
   SELECT A.client,A.club,B.client,'A',TO_DATE(A.ev_date||A.ev_hour,'YYYY-MM-DDHH24:MI'),
          A.subject,TO_DATE(B.ev_date||B.ev_hour,'YYYY-MM-DDHH24:MI'),B.message
      FROM (SELECT * FROM old_events WHERE etype='application') A 
           JOIN (SELECT * FROM old_events WHERE etype='rejection' and client!='maria59') B 
           ON (A.club=B.club AND A.client=B.subject);
-- 46 rows (1 ill row skipped)          

INSERT INTO candidates (nick,club,member,type,req_date,req_msg,rej_date,rej_msg)
   SELECT client,club,null,'A',TO_DATE(ev_date||ev_hour,'YYYY-MM-DDHH24:MI'),subject,null,null
      FROM old_events 
      WHERE etype='application'
           AND (client,club) NOT IN (SELECT subject,club from old_events where etype='rejection' or etype='acceptance');
-- 11 rows

-- PROBLEM 5: there is a non existing movie, titled 'Toi Story'
-- SOLUTION: skip it 
INSERT INTO proposals (title,director,club,member,prop_date,slogan,message) 
   SELECT details1,details2,club,client,TO_DATE(ev_date||ev_hour,'YYYY-MM-DDHH24:MI'),subject,message 
      FROM old_events WHERE etype='proposal' and details1!='Toi Story';
-- 15208 rows (1 ill row skipped)


-- PROBLEM 6: user 'bullon' from club "Eden's Guild" comments two films exactly at the same date+time 
-- SOLUTION: skip those comments, then insert them adding "rownum-1" seconds
INSERT INTO comments (club,nick,msg_date,title,director,subject,message,valoration) 
   SELECT club,client,TO_DATE(ev_date||ev_hour,'YYYY-MM-DDHH24:MI'),
          details1,details2,subject,message,TO_NUMBER(substr(etype,9))
      FROM (SELECT client,ev_date,ev_hour 
               FROM old_events WHERE etype LIKE 'opinion%'
               GROUP BY client,ev_date,ev_hour having count('s')=1) 
           JOIN old_events USING (client,ev_date,ev_hour)
       WHERE etype LIKE 'opinion%';
-- 121714 rows (skipped 2 ill rows)


INSERT INTO comments (club,nick,msg_date,title,director,subject,message,valoration) 
   SELECT club,client,TO_DATE(ev_date||ev_hour,'YYYY-MM-DDHH24:MI')+((rownum-1)/86400),
          details1,details2,subject,message,TO_NUMBER(substr(etype,9))
      FROM (SELECT client,ev_date,ev_hour 
               FROM old_events WHERE etype LIKE 'opinion%'
               GROUP BY client,ev_date,ev_hour having count('s')>1) 
           JOIN old_events USING (client,ev_date,ev_hour)
       WHERE etype LIKE 'opinion%';
-- 2 rows (2 ill rows healed)



COMMIT;


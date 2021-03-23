-- ----------------------------------------------------
-- ----------------------------------------------------
-- -- TABLES CREATION SCRIPT -- ASSIGNMENT SOLUTION ---
-- ----------------------------------------------------
-- ----------------------------------------------------
-- -- Course: File Structures and DataBases -----------
-- ----------------------------------------------------
-- -- (c) 2020 Javier Calle ---------------------------
-- ------ Carlos III University of Madrid -------------
-- ----------------------------------------------------
-- ----------------------------------------------------
-- -- Part I: Destroy (in case) existent tables -------
-- ----------------------------------------------------

DROP TABLE casts CASCADE CONSTRAINTS;
DROP TABLE genres_movies CASCADE CONSTRAINTS; 
DROP TABLE keywords CASCADE CONSTRAINTS; 
DROP TABLE viewings CASCADE CONSTRAINTS; 
DROP TABLE movies CASCADE CONSTRAINTS;
DROP TABLE stars CASCADE CONSTRAINTS;
DROP TABLE genres CASCADE CONSTRAINTS; 
DROP TABLE contracts CASCADE CONSTRAINTS; 
DROP TABLE products CASCADE CONSTRAINTS; 
DROP TABLE profiles CASCADE CONSTRAINTS; 
DROP TABLE comments CASCADE CONSTRAINTS; 
DROP TABLE proposals CASCADE CONSTRAINTS; 
DROP TABLE candidates CASCADE CONSTRAINTS; 
DROP TABLE membership CASCADE CONSTRAINTS; 
DROP TABLE clubs CASCADE CONSTRAINTS; 
DROP TABLE users CASCADE CONSTRAINTS; 



-- ----------------------------------------------------
-- -- Part II: Create all tables ----------------------
-- ----------------------------------------------------
CREATE TABLE genres (
genre	VARCHAR2(70),
CONSTRAINT PK_GENRES PRIMARY KEY (genre)
);

CREATE TABLE stars (
name	VARCHAR2(50),
CONSTRAINT PK_STARS PRIMARY KEY (name)
);

CREATE TABLE movies(
title             VARCHAR2(100),
director          VARCHAR2(50),
duration          NUMBER(3),
year              NUMBER(4),
country           VARCHAR2(25), 
language          VARCHAR2(20),
color             VARCHAR2(1),
aspect_ratio      NUMBER(4,2) , 
gross             NUMBER(10), 
budget            NUMBER(12),
content_rating    VARCHAR2(9),
faces_poster      NUMBER(6), 
imdb_score        NUMBER(2,1), 
imdb_link         VARCHAR2(60), 
num_critic        NUMBER(6), 
voted_users       NUMBER(7), 
user_reviews      NUMBER(6), 
movie_likes       NUMBER(6),
director_likes    NUMBER(6), 
cast_likes        NUMBER(6), 
CONSTRAINT MOVIES_PK PRIMARY KEY (title,director),
CONSTRAINT FK_movies_stars FOREIGN KEY (director) REFERENCES stars,
CONSTRAINT CK_MOVIES CHECK (COLOR IN ('B','C', null))
);

CREATE TABLE genres_movies (
title	 VARCHAR2(100),
director VARCHAR2(50),
genre	 VARCHAR2(70),
CONSTRAINT PK_GENRES_MOVIES PRIMARY KEY (title,director,genre),
CONSTRAINT FK_GENRES_MOVIES FOREIGN KEY (title,director) REFERENCES movies ON DELETE CASCADE,
CONSTRAINT FK_GENRES FOREIGN KEY (genre) REFERENCES genres 
);

CREATE TABLE keywords (
title	  VARCHAR2(100),
director  VARCHAR2(50),
keyword	  VARCHAR2(150),
CONSTRAINT PK_KEYWORDS PRIMARY KEY (title,director,keyword),
CONSTRAINT FK_KEYWORDS_MOVIES FOREIGN KEY (title,director) REFERENCES movies ON DELETE CASCADE
);

CREATE TABLE casts (
actor     VARCHAR2(50), 
title     VARCHAR2(100),
director  VARCHAR2(50),
likes     NUMBER(6), 
CONSTRAINT PK_CASTS PRIMARY KEY (actor, title, director),
CONSTRAINT FK1_CASTS_STARS  FOREIGN KEY (actor) REFERENCES stars ON DELETE CASCADE,
CONSTRAINT FK2_CASTS_MOVIES FOREIGN KEY (title,director) REFERENCES MOVIES ON DELETE CASCADE
);


CREATE TABLE users (
nick	    VARCHAR2(35),
password  VARCHAR2(20) NOT NULL,
email 	  VARCHAR2(60) NOT NULL,
reg_date  DATE NOT NULL,
CONSTRAINT PK_USERS PRIMARY KEY (nick),
CONSTRAINT UK_USERS UNIQUE (email)
);


CREATE TABLE profiles (
nick	      VARCHAR2(35),
name        VARCHAR2(35),
surname     VARCHAR2(35),
secsurname  VARCHAR2(35),
citizenID 	VARCHAR2(10) NOT NULL,
mobile   	  NUMBER(12),
birthdate   DATE,
CONSTRAINT PK_PROFILES PRIMARY KEY (nick),
CONSTRAINT UK_PROFILES UNIQUE (citizenID),
CONSTRAINT FK_PROFILES_USERS FOREIGN KEY (nick) REFERENCES users ON DELETE CASCADE
);

CREATE TABLE products (
name	VARCHAR2(50),
CONSTRAINT PK_PRODUCTS PRIMARY KEY (name)
);

CREATE TABLE contracts (
idcontract    VARCHAR2(20),
citizenID 	  VARCHAR2(10) NOT NULL,
contract_type VARCHAR2(50) NOT NULL,
startdate     DATE NOT NULL,
enddate       DATE,
address       VARCHAR2(100) NOT NULL,
town          VARCHAR2(100) NOT NULL,
ZIPcode       VARCHAR2(8) NOT NULL,
country       VARCHAR2(100) NOT NULL,
CONSTRAINT PK_CONTRACTS PRIMARY KEY (idcontract),
CONSTRAINT FK_CONTRACTS_PRODUCTS FOREIGN KEY (contract_type) REFERENCES products,
CONSTRAINT FK_CONTRACTS_PROFILES FOREIGN KEY (citizenID) REFERENCES profiles(citizenID), 
CONSTRAINT CK_CONTRACTS CHECK (enddate IS NULL OR enddate>startdate)
);

CREATE TABLE viewings (
title	   VARCHAR2(100),
director VARCHAR2(50),
client	 VARCHAR2(20),
vdate    DATE NOT NULL,
CONSTRAINT PK_VIEWINGS PRIMARY KEY (title,director,client),
CONSTRAINT FK_VIEWINGS_MOVIES  FOREIGN KEY (title,director) REFERENCES movies,
CONSTRAINT FK_VIEWINGS_CLIENTS FOREIGN KEY (client) REFERENCES contracts
);

CREATE TABLE clubs (
name	   VARCHAR2(60),
founder  VARCHAR2(35),
cre_date DATE NOT NULL,
end_date DATE,
slogan	 VARCHAR2(100),
open     CHAR(1) DEFAULT 'O' NOT NULL,
CONSTRAINT PK_CLUBS PRIMARY KEY (name),
CONSTRAINT FK_CLUBS_USER  FOREIGN KEY (founder) REFERENCES users ON DELETE SET NULL,
CONSTRAINT CK_CLUBS CHECK (open IN ('O','C'))
);

CREATE TABLE membership (
nick     VARCHAR2(35),
club     VARCHAR2(60),
mentor   VARCHAR2(35),
type     CHAR(1) NOT NULL,
req_date DATE NOT NULL,
inc_date DATE NOT NULL,
end_date DATE,
req_msg  VARCHAR2(100),
acc_msg VARCHAR2(1500),
CONSTRAINT PK_MEMBERSHIP PRIMARY KEY (nick,club),
CONSTRAINT FK_MEMBERSHIP_USERS FOREIGN KEY (nick) REFERENCES users ON DELETE CASCADE,
CONSTRAINT FK_MEMBERSHIP_CLUB FOREIGN KEY (club) REFERENCES clubs,
CONSTRAINT FK_MEMBERSHIP_MENTOR FOREIGN KEY (mentor,club) REFERENCES membership,
CONSTRAINT CK_MEMBERSHIP_TYPE CHECK (type IN ('A','I','F')),
CONSTRAINT CK_MEMBERSHIP_DATES CHECK (req_date<inc_date AND (end_date is null or inc_date<end_date))
);

CREATE TABLE candidates (
nick     VARCHAR2(35),
club     VARCHAR2(60),
member   VARCHAR2(35),
type     CHAR(1) NOT NULL,
req_date DATE NOT NULL,
req_msg  VARCHAR2(1500) NOT NULL,
rej_date DATE,
rej_msg  VARCHAR2(1500),
CONSTRAINT PK_DISMISSALS PRIMARY KEY (nick,club,req_date),
CONSTRAINT FK_DISMISSALS_USERS FOREIGN KEY (nick) REFERENCES users ON DELETE CASCADE,
CONSTRAINT FK_DISMISSALS_CLUB FOREIGN KEY (club) REFERENCES clubs,
CONSTRAINT FK_DISMISSALS_MENTOR FOREIGN KEY (member,club) REFERENCES membership,
CONSTRAINT CK_DISMISSALS_TYPE CHECK (type IN ('A','I')),
CONSTRAINT CK_DISMISSALS_DATES CHECK (rej_date is null or req_date<rej_date),
CONSTRAINT CK_DISMISSALS_PENDING CHECK (rej_date is not null or rej_msg is null)
);

CREATE TABLE proposals (
title	    VARCHAR2(100),
director  VARCHAR2(50),
club      VARCHAR2(60),
member	  VARCHAR2(35) NOT NULL,
prop_date DATE NOT NULL,
slogan    VARCHAR2(100),
message   VARCHAR2(1500),
CONSTRAINT PK_PROPOSALS PRIMARY KEY (title,director,club),
CONSTRAINT UK_PROPOSALS UNIQUE (club,member,prop_date),
CONSTRAINT FK_PROPOSALS_MOVIES  FOREIGN KEY (title,director) REFERENCES movies,
CONSTRAINT FK_PROPOSALS_MEMBER FOREIGN KEY (member,club) REFERENCES membership ON DELETE CASCADE
);

CREATE TABLE comments (
club       VARCHAR2(60) NOT NULL,
nick	     VARCHAR2(35),
msg_date   DATE,
title	     VARCHAR2(100) NOT NULL,
director   VARCHAR2(50) NOT NULL,
subject    VARCHAR2(100),
message    VARCHAR2(1500),
valoration NUMBER(2),
CONSTRAINT PK_COMMENTS PRIMARY KEY (nick,msg_date),
CONSTRAINT FK_COMMENTS_MEMBER FOREIGN KEY (nick,club) REFERENCES membership ON DELETE CASCADE,
CONSTRAINT FK_COMMENTS_MOVIES  FOREIGN KEY (title,director) REFERENCES movies,
CONSTRAINT CK_COMMENTS_VAL CHECK (valoration<11) 
);








-- ----------------------------------------------------
-- -- Annex: list of "mistakes" introduced         ----
-- ----------------------------------------------------
--
-- film "The Sting" appears twice, with different actors
--
--


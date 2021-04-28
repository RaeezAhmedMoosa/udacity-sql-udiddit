### udiddit

### Part I: Investigate the Existing Schema

/*
There are 2 existing tables in the project workspace:

1. bad_comments
2. bad_posts


The "bad_comments" table has the following x columns:

1.1 "id" SERIAL PRIMARY KEY
1.2 "username" VARCHAR(50)
1.3 "post_id" BIGINT
1.4 "text_content" TEXT


The "bad_posts" table has the following 8 columns:

2.1 "id" SERIAL PRIMARY KEY
2.2 "topic" VARCHAR(50)
2.3 "username" VARCHAR(50)
2.4 "title" VARCHAR(150)
2.5 "url" VARCHAR(4000) DEFAULT NULL
2.6 "text_content" TEXT DEFAULT NULL
2.7 "upvotes" TEXT
2.8 "downvotes" TEXT
*/

-- This is test query to explore the data contained in "bad_comments"
SELECT *
FROM bad_comments
LIMIT 50;


-- This is test query to explore the data contained in "bad_posts"
SELECT *
FROM bad_posts
LIMIT 50;


-- This query was used to check the format of the values listed under "topic"
SELECT DISTINCT topic
FROM bad_posts
LIMIT 100;


SELECT  DISTINCT username
FROM bad_posts;


/*
By looking at the "bad_comments" table, I can identify the following 3 entities:

• comments
• users
• posts


By looking at the "bad_posts" table, I can identify the following 5 entities:

• posts
• topics
• usernames
• votes
*/



### Part II: Create a New Schema for Udiddit


/*
For Part II, I need to create a new data schema for Udiddit. This will primarily
focus on using the SQL DDL (Database Definition Language).

The first thing I need to do is to fix the issues that were found in Part I of
the project.
*/


/*
The First Issue in Part I was the multiple entities issue. I need to create 5
separate tables for the following entities:

1. users
2. topics
3. posts
4. comments
5. votes

*/

### Users

/*
According to Guideline 1(a), the "users" table must have the following rules:

1.1 usernames must be unique
1.2 usernames have a maximum length of 25 characters
1.3 usernames can't be empty
*/

-- This works as intended in terms of DDL
CREATE TABLE "users" (
  "id" SERIAL,
  "username" VARCHAR(25) NOT NULL,
  CONSTRAINT "users_pk" PRIMARY KEY ("id"),
  CONSTRAINT "unique_usernames" UNIQUE ("username"),
  CONSTRAINT "no_empty_usernames"
  CHECK (LENGTH(TRIM("username")) > 0)
);


/*
Below are the test DML queries that were used to test and verify that the Udiddit
business rules were working.
*/

-- This is normal insertion of a proper username
INSERT INTO "users" ("username")
  VALUES ('raeez_moosa');


  -- Test DML for adding multiple users at once [SUCCESS]
  INSERT INTO "users" ("username")
    VALUES ('nabilaC'),
           ('SockoElBocco'),
           ('Gabibi');


-- This is an insertion of a username that is blank
INSERT INTO "users" ("username")
  VALUES ('');


-- This is another insertion of a blank username
INSERT INTO "users" ("username")
  VALUES ('');


-- This an insertion of a username that exceeds the maximum character length
INSERT INTO "users" ("username")
  VALUES ('012345678901234567890123456789');



### Topics

/*
According to Guideline 1(b), the "topics" table must have the following rules:

2.1 topic names must be unique
2.2 topic name has a maximum character length of 30 characters
2.3 topic name can't be empty
2.4 topics can have an optional description of a maximum of 500 characters
*/

-- This works as intended for DDL purposes
CREATE TABLE "topics" (
  "id" SERIAL,
  "name" VARCHAR(30) NOT NULL,
  "description" TEXT,
  CONSTRAINT "topics_pk" PRIMARY KEY ("id"),
  CONSTRAINT "unique_topic_names" UNIQUE ("name"),
  CONSTRAINT "no_empty_topic_names"
  CHECK (LENGTH(TRIM("name")) > 0),
  CONSTRAINT "description_limit"
  CHECK (LENGTH("description") <= 500)
);

/*
Below are the test DML queries that were used to test and verify that the Udiddit
business rules were working.
*/

-- This is a simple test DML adding a topic with no description
INSERT INTO "topics" ("name")
  VALUES ('newcastleunited');


  -- Test DML for inserting multiple topics at once
INSERT INTO "topics" ("name")
    VALUES ('cats'),
           ('eldoglen'),
           ('canada');

/*
This is a test DML which adds a topic and a description. It worked properly when
executed, but the description output didn't look right, as the formatting was
exactly identical to how it was inputted in the DML

Also, I may have found a solution to the grammatical inconsistency regarding the
case-sensitivity of the topic names in the original data set. I am using the
LOWER function to ensure that any upper case characters are converted into lower
case characters when being inserted into the new "topics" table.

Another note, the ESCAPE command for SQL when you need to include a single
quotation mark within a string is "'" (the single quotation mark). So for this
DML it cannot be ('...Sony's...') or ('...Sony\'s...'). The correct syntax is
('...Sony''s...'). You basically need to use 2 single quotation marks.
*/
INSERT INTO "topics" ("name", "description")
  VALUES (LOWER('PSP'), 'A subdiddit for all things Playstation Portable, the red-headed and oft-forgotten handheld console from our overlords at Sony. Hacked too soon, and now there''s no store available');


-- This is a simple test DML adding a topic with a short description
INSERT INTO "topics" ("name", "description")
  VALUES ('psvita', 'A subdiddit for all things PS Vita');


-- This is a test DML which attempts to add a blank topic
INSERT INTO "topics" ("name")
  VALUES ('');


  -- This is another test DML which attempts to add a blank topic
  INSERT INTO "topics" ("name")
    VALUES ('                           ');


-- This a test DML adding a topic and a long description
INSERT INTO "topics" ("name", "description")
  VALUES ('asoiaf', 'This is a subdiddit for fans of the Song of Ice and Fire series. While GRR Martin is taking his sweet, sweet time finishing the "Winds of Winter", we can all hang out here and wonder how more than a decade has passed since the last proper ASOIAF book.');




### Posts

/*
According to Guideline 1(c), the "posts" table must have the following rules:

3.1 title must have a maximum character length of 100 characters
3.2 title cannot be empty
3.3 posts can contain URLs or text content but NOT both
3.4 if a topic is deleted, then all the posts asssociated witht that topic should
    be deleted as well
3.5 if a user, who created the post, is deleted then their post should remain
    but it will become dissociated with that user
*/

/*
The "posts" table should have the following columns:

3.1 "id" SERIAL
3.2 "topic_id" INTEGER
3.3 "user_id" INTEGER
3.4 "title" VARCHAR(100)
3.5 "url" VARCHAR(2048)
3.6 "text_content" TEXT
*/


/*
This is the DDL which creates a "posts" tabe which complies with the first 2 rules
set out in Guideline 1(c). It works as intended.
*/
CREATE TABLE "posts" (
  "id" SERIAL,
  "topic_id" INTEGER,
  "user_id" INTEGER,
  "title" VARCHAR(100),
  "url" VARCHAR(2048),
  "text_content" TEXT,
  CONSTRAINT "posts_pk" PRIMARY KEY ("id"),
  CONSTRAINT "topics_id_fk" FOREIGN KEY ("topic_id")
  REFERENCES "topics",
  CONSTRAINT "users_id_fk" FOREIGN KEY ("user_id")
  REFERENCES "users",
  CHECK (LENGTH(TRIM("title")) > 0),
  CHECK (LENGTH("text_content") <= 40000)
);


/*
This is the DDL for the "posts" table which attempts to implement the next 2
rules set out in Guideline 1(c) relating to the deletion of referenced data
*/
CREATE TABLE "posts" (
  "id" SERIAL,
  "topic_id" INTEGER,
  "user_id" INTEGER,
  "title" VARCHAR(100),
  "url" VARCHAR(2048),
  "text_content" TEXT,
  CONSTRAINT "posts_pk" PRIMARY KEY ("id"),
  CONSTRAINT "topics_id_fk" FOREIGN KEY ("topic_id")
  REFERENCES "topics" ON DELETE CASCADE,
  CONSTRAINT "users_id_fk" FOREIGN KEY ("user_id")
  REFERENCES "users" ON DELETE SET NULL,
  CHECK (LENGTH(TRIM("title")) > 0),
  CHECK (LENGTH("text_content") <= 40000)
);


/*
This is the DDL for the "posts" table which attempts to implement the rule which
restricts a user from posting both a "url" and "text_content" at the same time.
Note that this seems to be the final version of the "posts" table.
*/
CREATE TABLE "posts" (
  "id" SERIAL,
  "topic_id" INTEGER,
  "user_id" INTEGER,
  "title" VARCHAR(100),
  "url" VARCHAR(2048),
  "text_content" TEXT,
  CONSTRAINT "posts_pk" PRIMARY KEY ("id"),
  CONSTRAINT "topics_id_fk" FOREIGN KEY ("topic_id")
  REFERENCES "topics" ON DELETE CASCADE,
  CONSTRAINT "users_id_fk" FOREIGN KEY ("user_id")
  REFERENCES "users" ON DELETE SET NULL,
  CONSTRAINT "no_empty_titles"
  CHECK (LENGTH(TRIM("title")) > 0),
  CONSTRAINT "post_content_restriction"
  CHECK (("url" IS NOT NULL AND "text_content" IS NULL) OR
        ("url" IS NULL AND "text_content" IS NOT NULL)),
  CHECK (LENGTH("text_content") <= 40000)
);


-- This is test DML to verify that the "posts" table functions properly [SUCCESS]
INSERT INTO "posts" ("topic_id", "user_id", "title", "text_content")
  VALUES (
    10, 1, 'When will the "Winds of Winter" be released?',
    'Like everyone on this subdiddit, I am eagerly awaiting the release of the "Winds of Winter", it''s been over 6 years since I first read "A Game of Thrones" for the first time. I now have read all the books in the series twice. When do you think our suffering will end?'
  );

--
INSERT INTO "posts" ("topic_id", "user_id", "title", "url")
  VALUES (
    10, 1, 'When will the "A Hope for Spring" be released?',
    'https://asoiaf.westeros.org/'
  );


-- Another test DML for data insertion in the "posts" table [SUCCESS]
INSERT INTO "posts" ("topic_id", "user_id", "title", "text_content")
  VALUES (
    3, 1, 'Which games do you wish were developed and released for the Vita?',
    'Like many of my fellow udidditors, I had a PSP before I moved over to the Vita. The PSP had quite a robust library, when compared to the Vita. I really wish we could have had a "GTA: San Andreas Stories" and dedicated "God of War" and "Metal Gear Solid" games, which were not ports of the series'' PSP games.'
  );


--
INSERT INTO "posts" ("topic_id", "user_id", "title", "text_content")
  VALUES (
    13, 4, 'Who is the ruler of Eldoglen?', 'It is I, Gabibi.'
  );

/*
This is a DQL which was used to test whether or not the different tables could
be successfully joined together without any issues. On testing, this produced
the expected result.
*/
SELECT "u"."username",
       "t"."name",
       "p"."title"
FROM "users" "u"
JOIN "posts" "p"
ON "u"."id" = "p"."user_id"
JOIN "topics" "t"
ON "t"."id" = "p"."topic_id";


-- Remember that the GB clause is inserted BEFORE the OB clause
SELECT "t"."name",
       COUNT(*) AS "post_count"
FROM "users" "u"
JOIN "posts" "p"
ON "u"."id" = "p"."user_id"
JOIN "topics" "t"
ON "t"."id" = "p"."topic_id"
GROUP BY 1
ORDER BY 2 DESC;


-- This DML tests the first rule of Guideline 1(c) [SUCCESS]
INSERT INTO "posts" ("topic_id", "user_id", "title", "text_content")
  VALUES (
    1, 1, 'pppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp',
    'title max character test'
  );


-- This DML tests the second rule of Guideline 1(c) [SUCCESS]
INSERT INTO "posts" ("topic_id", "user_id", "title", "text_content")
  VALUES (
    3, 1, '', 'no empty title test - 1 blank space'
  );


-- This DML tests the third rule of Guideline 1(c) [SUCCESS]
INSERT INTO "posts" ("topic_id", "user_id", "title", "url", "text_content")
  VALUES (
    1, 1, 'A good place to keep updated with Newcastle United',
    'https://www.reddit.com/r/NUFC/',
    'user can''t post both a URL and a text post test'
  );


-- This DML tests the fourth rule of Guideline 1(c) [SUCCESS]
DELETE FROM "topics"
  WHERE "name" = 'asoiaf';


-- This DML tests the fifth rule of Guideline 1(c) [SUCCESS]
DELETE FROM "users"
  WHERE "username" = 'raeez_moosa';




### Comments

/*
*/

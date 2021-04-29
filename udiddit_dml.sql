### udiddit

### Migrate the Provided Data

/*
I will be expected to use DML and DQL queries to migrate the given data from the
existing data schema ("bad_comments" & "bad_posts") into the 5 new tables. I will
use INSERT...SELECT queries to migrate the data.

Here are the Migration guidelines:

1. topic "description" can be empty
2. migrate all comments from "bad_comments" as top level comments
3. use the REGEXP_SPLIT_TO_TABLE function to separate all the votes in the
   "bad_posts" table
4. ensure to migrate the users from both existing tables
5. the order of migration matters!
6. test the migration queries by first running SELECT queries to fine-tune them
   to verify that the correct data is being targeted
7. The data is vast in number, so the DML queries may take up to 15 seconds to run
*/

TRUNCATE TABLE "users" CASCADE;

TRUNCATE TABLE "topics" CASCADE;

TRUNCATE TABLE "posts" CASCADE;

TRUNCATE TABLE "comments" CASCADE;

INSERT INTO "users" ("username")
  VALUES ('Gabibi'),
         ('MrSocko'),
         ('Snowballer');


--
### Users

/*
This is the Test DQL section for data concerning users
*/

-- This DQL returns the count of unique usernames in the "bad_posts" table
SELECT COUNT(DISTINCT "username") AS bp_usernames
FROM "bad_posts";
-- There's 100 unique usernames in "bad_posts"


-- This DQL returns the count of unique usernames in the "bad_comments" table
SELECT COUNT(DISTINCT "username") AS bc_usernames
FROM "bad_comments";
-- There's 9984 unique usernames in "bad_comments"


SELECT COUNT("username") AS bc_usernames
FROM "bad_comments";


-- This is a DQL using a UNION to append "usernames" from different tables
SELECT DISTINCT "username"
FROM "bad_posts"

UNION

SELECT DISTINCT "username"
FROM "bad_comments"

LIMIT 200;


--
SELECT DISTINCT REPLACE("username", '.', '_')
FROM "bad_posts"

UNION

SELECT DISTINCT REPLACE("username", '.', '_')
FROM "bad_comments"

LIMIT 200;



/*
This is the test DML section for data concerning users and "usernames"
*/

-- This is the DML which migrates the "usernames" to the new "users" table
INSERT INTO "users" ("username")
  SELECT DISTINCT "username"
  FROM "bad_posts"

  UNION

  SELECT DISTINCT "username"
  FROM "bad_comments";


-- This is test DQL to check if the DML above was successful
SELECT *
FROM "users"
LIMIT 200;



### Topics

/*
This is the Test DQL section for data concerning topics
*/
SELECT DISTINCT "topic"
FROM "bad_posts";
-- there's 89 topics

/*
This DQL replaces any topics which contain the '-' character with the '_' characte
*/
SELECT DISTINCT REPLACE("topic", '-', '_')
FROM "bad_posts";

/*
This DQL uses an Inline Subquery to iterate further on the above DQL and replaces
the '_' with a blank space '' character to harmonise the data a bit more
*/
SELECT REPLACE ("topic_name", '_', '')
FROM (
  SELECT DISTINCT REPLACE("topic", '-', '_') AS topic_name
  FROM "bad_posts"
) sub1;


/*
This is the test DML section for data concerning topics and "name"
*/

/*
This DML uses the DQL containing an Inline subquery to migrate the topic data
from "bad_posts" into the new "topics" table, specifically the "name" column
*/
INSERT INTO "topics" ("name")
  SELECT REPLACE ("topic_name", '_', '')
  FROM (
    SELECT DISTINCT REPLACE("topic", '-', '_') AS topic_name
    FROM "bad_posts"
  ) sub1;


-- This is test DQL to check if the DML above was successful
SELECT *
FROM "topics"
ORDER BY "name";



### Posts

/*
This is the Test DQL section for data concerning users
*/

SELECT *
FROM "bad_posts"
LIMIT 10;

/*
This test DQL attempts to use the previous DML migrated data to return a table
which incorporates the PRIMARY KEY values for the "usernames" and "topics" table
(which is the "id" column for both tables) within the returned table.
*/
SELECT "t"."id",
       "u"."id",
       "bp"."title",
       "bp"."url",
       "bp"."text_content"
FROM "bad_posts" "bp"
JOIN "topics" "t"
ON "t"."name" = "bp"."topic"
JOIN "users" "u"
ON "u"."username" = "bp"."username"
LIMIT 100;

### udiddit

### Part III: Migrate the Provided Data

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


-- Confirmed COUNT of 100 unique usernames
SELECT COUNT(*)
FROM (
  SELECT DISTINCT "username"
  FROM "bad_posts"
) sub1;

-- Confirmed COUNT of 9984 unique usernames
SELECT COUNT(*)
FROM (
  SELECT DISTINCT "username"
  FROM "bad_comments"
) sub2;


SELECT DISTINCT REGEXP_SPLIT_TO_TABLE("upvotes", ',')
FROM "bad_posts"
LIMIT 25;

SELECT COUNT(*)
FROM (
  SELECT DISTINCT REGEXP_SPLIT_TO_TABLE("upvotes", ',')
  FROM "bad_posts"
) sub1;
-- Confirmed COUNT of 1100 unique usernames


SELECT DISTINCT REGEXP_SPLIT_TO_TABLE("downvotes", ',')
FROM "bad_posts"
LIMIT 25;

SELECT COUNT(*)
FROM (
  SELECT DISTINCT REGEXP_SPLIT_TO_TABLE("downvotes", ',')
  FROM "bad_posts"
) sub1;
-- Confirmed COUNT of 1100 unique usernames


/*
I need to redo this as I didn't get the usernames that were only found within
the "upvotes" and "downvotes" column in the "bad_comments" table
*/
SELECT DISTINCT "username",
FROM "bad_posts"

UNION

SELECT DISTINCT "username"
FROM "bad_comments"

UNION

SELECT DISTINCT REGEXP_SPLIT_TO_TABLE("upvotes", ',')
FROM "bad_posts"

UNION

SELECT DISTINCT REGEXP_SPLIT_TO_TABLE("downvotes", ',')
FROM "bad_posts"


-- I think this is the correct DQL for this part of the project
SELECT COUNT(DISTINCT "username")
FROM (
  SELECT DISTINCT "username"
  FROM "bad_posts"

  UNION

  SELECT DISTINCT "username"
  FROM "bad_comments"

  UNION

  SELECT DISTINCT REGEXP_SPLIT_TO_TABLE("upvotes", ',') AS username
  FROM "bad_posts"

  UNION

  SELECT DISTINCT REGEXP_SPLIT_TO_TABLE("downvotes", ',') AS username
  FROM "bad_posts"
) sub1;

SELECT DISTINCT "username"
FROM "bad_posts"

UNION

SELECT DISTINCT "username"
FROM "bad_comments"

UNION

SELECT DISTINCT REGEXP_SPLIT_TO_TABLE("upvotes", ',') AS username
FROM "bad_posts"

UNION

SELECT DISTINCT REGEXP_SPLIT_TO_TABLE("downvotes", ',') AS username
FROM "bad_posts";

LIMIT 1000;


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

/*
This is the correct DML for the migration of usernames from all the columns
("username", "username", "upvotes" and "downvotes") from both tables
*/

-- Correct DML for username migration
INSERT INTO "users" ("username")
  SELECT DISTINCT "username"
  FROM "bad_posts"

  UNION

  SELECT DISTINCT "username"
  FROM "bad_comments"

  UNION

  SELECT DISTINCT REGEXP_SPLIT_TO_TABLE("upvotes", ',') AS username
  FROM "bad_posts"

  UNION

  SELECT DISTINCT REGEXP_SPLIT_TO_TABLE("downvotes", ',') AS username
  FROM "bad_posts";
-- 11 077 rows
--
SELECT COUNT("username")
FROM "users";

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
-- Successful


-- This is similar to the above query, but uses 'daisy-chaining' instead
SELECT DISTINCT REPLACE(REPLACE("topic", '-', '_'), '_', '')
FROM "bad_posts";

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
-- Successful

-- Use this DML for the final version
INSERT INTO "topics" ("name")
  SELECT DISTINCT REPLACE(REPLACE("topic", '-', '_'), '_', '')
  FROM "bad_posts";
-- 89 rows


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
-- Successful


-- This new test DQL attempts to sync with the business rule
SELECT "t"."id",
       "u"."id",
       LEFT("bp"."title", 100),
       LEFT("bp"."url", 2048),
       LEFT("bp"."text_content", 40000)
FROM "bad_posts" "bp"
JOIN "topics" "t"
ON "t"."name" = "bp"."topic"
JOIN "users" "u"
ON "u"."username" = "bp"."username"
LIMIT 100;
-- Successful


/*
This is the test DML section for data concerning topics and "name". I had an
issue in the first attempt at migrating the data. The issue was that for one or
more of the "title" values from the "bad_posts" table, the character length for
one or more of these values exceeded 100 characters.

The new table "posts" has a (n) LIMIT on the data type (VARCHAR) for the "title"
of 100 characters. To resolve this issue, I used the LEFT function to extract all
the relevant for a maximum value of their stated LIMIT/CONSTRAINT.
*/
INSERT INTO "posts" ("topic_id", "user_id", "title", "url", "text_content")
  SELECT "t"."id",
        "u"."id",
        LEFT("bp"."title", 100),
        LEFT("bp"."url", 2048),
        LEFT("bp"."text_content", 40000)
        FROM "bad_posts" "bp"
        JOIN "topics" "t"
        ON "t"."name" = "bp"."topic"
        JOIN "users" "u"
        ON "u"."username" = "bp"."username";
-- Successful 39 369 rows

-- Another DML attempt to insert the data
INSERT INTO "posts" ("id", "topic_id", "user_id", "title", "url", "text_content")
  SELECT "bp"."id",
        "t"."id",
        "u"."id",
        LEFT("bp"."title", 100),
        "bp"."url",
        "bp"."text_content"
        FROM "bad_posts" "bp"
        LEFT JOIN "topics" "t"
        ON "t"."name" = "bp"."topic"
        JOIN "users" "u"
        ON "u"."username" = "bp"."username";
-- 50 000 rows inserted! This is the correct one



### Comments

/*
This is the Test DQL section for data concerning users
*/

/*
This test DQL is returning a table which mirrors the structure of the new table
"comments". It also attempts to perform JOINs in order to  return the correct
columns and values to be used in the related DML query.
*/
SELECT "u"."id" AS user_id,
       "p". "id" AS post_id,
       "bc"."text_content"
FROM "bad_comments" "bc"
JOIN "users" "u"
ON "u"."username" = "bc"."username"
JOIN "posts" "p"
ON "p"."id" = "bc"."post_id"
LIMIT 10;
-- Successful


/*
This is the test DML section for data concerning the "comments" table.
*/

INSERT INTO "comments" ("user_id", "post_id", "text_content")
  SELECT "u"."id" AS user_id,
        "p". "id" AS post_id,
        "bc"."text_content"
        FROM "bad_comments" "bc"
        JOIN "users" "u"
  ON "u"."username" = "bc"."username"
  JOIN "posts" "p"
  ON "p"."id" = "bc"."post_id";
-- Successful



### Votes

/*
This is the Test DQL section for data concerning votes
*/


-- Test DQL for viewing the upvotes structure
SELECT "id",
      "upvotes"
FROM "bad_posts"
LIMIT 10;


-- Test DQL for viewing the downvotes structure
SELECT "id",
      "downvotes"
FROM "bad_posts"
LIMIT 10;


SELECT "id",
       "upvotes",
       "downvotes"
FROM "bad_posts"
WHERE "id" = 1;

/*
The test DQL below use the REGEXP_SPLIT_TO_TABLE function to split up all the
values within the "upvotes" column and return in separate rows.
*/
SELECT "id",
       REGEXP_SPLIT_TO_TABLE("upvotes", ',')
FROM "bad_posts"
LIMIT 10;

/*
The test DQL below use the REGEXP_SPLIT_TO_TABLE function to split up all the
values within the "downvotes" column and return in separate rows.
*/
SELECT "id",
       REGEXP_SPLIT_TO_TABLE("downvotes", ',')
FROM "bad_posts"
LIMIT 10;


SELECT DISTINCT REGEXP_SPLIT_TO_TABLE("upvotes", ',')
FROM "bad_posts"

UNION

SELECT DISTINCT REGEXP_SPLIT_TO_TABLE("downvotes", ',')
FROM "bad_posts"

LIMIT 100;


SELECT COUNT(*)
FROM (
  SELECT DISTINCT REGEXP_SPLIT_TO_TABLE("upvotes", ',')
  FROM "bad_posts"

  UNION

  SELECT DISTINCT REGEXP_SPLIT_TO_TABLE("downvotes", ',')
  FROM "bad_posts"
) sub2;


SELECT DISTINCT "id",
       REGEXP_SPLIT_TO_TABLE("upvotes", ',')
FROM "bad_posts";


SELECT "id",
       REGEXP_SPLIT_TO_TABLE("upvotes", ',')
FROM "bad_posts";


/*
This is the test DQL which attempts to create a table which will be used in the
DML to migrate all the upvotes to the new "votes" table.

The Inline subquery returns a table which has the columns "id" which refers to
the id of the post that was made. The "upvotes" column contained a range of
usernames that upvoted that post, with each username separate by a comma. This
was an obvious violation of First Normal Form.

The Inline subquery splits up all these usernames into separate columns sorted
according to the post "id" value.

The Outer Query leverages the Inline subquery by extracting the "id" value, but
it takes the "id" value from the "users" table and it adds an integer (1) to
each row, which represents a numerical value for an upvote.
*/
SELECT sub1."id" AS post_id,
       "u"."id" AS user_id,
       1 AS vote
FROM (
  SELECT "id",
         REGEXP_SPLIT_TO_TABLE("upvotes", ',') AS upvoters
  FROM "bad_posts"
) sub1
JOIN "users" "u"
ON "u"."username" = sub1."upvoters";


SELECT sub1."id" AS post_id,
       "u"."id" AS user_id,
       -1 AS vote
FROM (
  SELECT "id",
         REGEXP_SPLIT_TO_TABLE("downvotes", ',') AS downvoters
  FROM "bad_posts"
) sub1
JOIN "users" "u"
ON "u"."username" = sub1."downvoters";

/*
This is the test DML section for data concerning the "comments" table.
*/

/*
There's an issue with this DML. Apparently post_id 42235 is not found in the
new table "posts", so it was most likely excluded in the posts migration as it
violated one of the rules.

Somehow, I managed to solve this issue. I was performing an INNER JOIN in the
DML inserting data for the "posts" table, resulting in only 39 369 rows being
migrated. This was a problem as the original table had 50 000 rows. I somehow
managed to excluded around 10 000 rows. This was due to the INNER JOIN and the
fact that I modified the values of the "name" column in the "topics" table.

I fixed this by performing a LEFT JOIN on the "bad_posts" table to ensure that
all 50 000 "id" values were migrated. With this, the DML queries below now
work without throwing an error for both "upvotes" and "downvotes".
*/
INSERT INTO "votes" ("post_id", "user_id", "vote")
  SELECT sub1."id" AS post_id,
        "u"."id" AS user_id,
        1 AS vote
        FROM (
          SELECT "id",
          REGEXP_SPLIT_TO_TABLE("upvotes", ',') AS upvoters
          FROM "bad_posts"
        ) sub1
        JOIN "users" "u"
        ON "u"."username" = sub1."upvoters";
-- Worked


-- DML for the migration of the "downvotes" data
INSERT INTO "votes" ("post_id", "user_id", "vote")
  SELECT sub1."id" AS post_id,
        "u"."id" AS user_id,
        -1 AS vote
        FROM (
          SELECT "id",
          REGEXP_SPLIT_TO_TABLE("downvotes", ',') AS downvoters
          FROM "bad_posts"
        ) sub1
        JOIN "users" "u"
        ON "u"."username" = sub1."downvoters";
-- Worked

-- Test DQL which checks to see if the DMLs above worked correctly
SELECT *
FROM "votes"
ORDER BY "post_id", "vote" DESC
LIMIT 50;

-- Test DQL to count the number of votes cast per post id
SELECT "post_id",
       COUNT("vote") AS vote_count
FROM "votes"
GROUP BY 1
ORDER BY 1;

-- Test DQL to get the sum of the upvotes + (-downvotes)
SELECT "post_id",
       SUM("vote") AS vote_sum
FROM "votes"
GROUP BY 1
ORDER BY 1;

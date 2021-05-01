### udiddit

### Part II: udiddit Web Analytics

/*
Guideline 2(a) – List all users who haven’t logged in during the last year
*/

-- Test DDL
ALTER TABLE "users"
  ADD COLUMN "login_date" TIMESTAMP;

-- Test Index for "login_date"
CREATE INDEX "login_date_index"
    ON "users" ("login_date");

-- Test DQL
SELECT "id",
       "username",
       "login_date"
FROM "users"
WHERE "login_date" <= '2020-04-30'; -- sample date, please change accordingly



/*
Guideline 2(b) – List all users who haven’t created any posts
*/

-- Test DQL which returns the post count per user id
EXPLAIN ANALYZE
SELECT "user_id",
       COUNT("id")
FROM "posts"
GROUP BY 1
ORDER BY 2;

EXPLAIN ANALYZE
SELECT "user_id",
       "id"
FROM "posts";
ORDER BY 1;

-- Test DQL which returns the post count per username
SELECT "u"."username",
       COUNT("p"."id") AS post_count
FROM "users" "u"
LEFT JOIN "posts" "p"
ON "u"."id" = "p"."user_id"
GROUP BY 1
ORDER BY 2;


-- Test INDEX on the user_id column in posts
CREATE INDEX "user_id__index"
  ON "posts" ( "user_id");


-- DQL which filters out the data to focus on users with 0 posts
WITH user_post_count AS (
  SELECT "u"."username" AS username,
         COUNT("p"."id") AS post_count
  FROM "users" "u"
  LEFT JOIN "posts" "p"
  ON "u"."id" = "p"."user_id"
  GROUP BY 1
)
SELECT "username",
       "post_count"
FROM "user_post_count"
WHERE "post_count" = 0
ORDER BY 1; -- Arranges the usernames in alphabetical order


/*
Guideline 2(d) – List all topics that don't have any posts
*/

-- DDL for the INDEX on the "topic_id" column in the"posts" table
CREATE INDEX "topic_id_index"
  ON "posts" ("topic_id");


/*
Guideline 2(h) – Find all the posts that link to a specific URL.
*/

CREATE INDEX "url_index"
  ON "posts" ("url");
--


/*
Guideline 2(l) – List all the top-level comments for a given post.
*/

CREATE INDEX "post_id_index"
  ON "comments" ("post_id");
--

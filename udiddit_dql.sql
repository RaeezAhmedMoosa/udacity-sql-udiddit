### udiddit

### Part II: udiddit Web Analytics

/*
Guideline 2(a) – List all users who haven’t logged in during the last year
*/

-- Test DDL
ALTER TABLE "users"
  ADD COLUMN "login_date" TIMESTAMP;

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
SELECT "user_id",
       COUNT("id")
FROM "posts"
GROUP BY 1
ORDER BY 2;


-- Test DQL which returns the post count per username
SELECT "u"."username",
       COUNT("p"."id") AS post_count
FROM "users" "u"
LEFT JOIN "posts" "p"
ON "u"."id" = "p"."user_id"
GROUP BY 1
ORDER BY 2;


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

### Udiddit

### Part III: Migrate the Provided Data


### Users

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


### Topics

INSERT INTO "topics" ("name")
  SELECT DISTINCT "topic"
  FROM "bad_posts";
-- 89 rows


### Posts

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
-- 50 000  rows


### Comments

INSERT INTO "comments" ("user_id", "post_id", "text_content")
  SELECT "u"."id" AS user_id,
        "p". "id" AS post_id,
        "bc"."text_content"
        FROM "bad_comments" "bc"
        JOIN "users" "u"
  ON "u"."username" = "bc"."username"
  JOIN "posts" "p"
  ON "p"."id" = "bc"."post_id";
-- 100 000 rows


### Upvotes

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
-- 249 799 rows


### Downvotes

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
-- 249 911 rows

### Udiddit

### Part II: Create a New Schema for Udiddit


### Users

CREATE TABLE "users" (
  "id" SERIAL,
  "username" VARCHAR(25) NOT NULL,
  CONSTRAINT "users_pk" PRIMARY KEY ("id"),
  CONSTRAINT "unique_usernames" UNIQUE ("username"),
  CONSTRAINT "no_empty_usernames"
  CHECK (LENGTH(TRIM("username")) > 0)
);


### Topics

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


### Posts

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


### Comments

CREATE TABLE "comments" (
  "id" SERIAL,
  "user_id" INTEGER,
  "post_id" INTEGER,
  "comment_id" INTEGER,
  "text_content" TEXT,
  CONSTRAINT "comments_pk" PRIMARY KEY ("id"),
  CONSTRAINT "username_fk" FOREIGN KEY ("user_id")
  REFERENCES "users" ON DELETE SET NULL,
  CONSTRAINT "posts_fk" FOREIGN KEY ("post_id")
  REFERENCES "posts" ON DELETE CASCADE,
  CONSTRAINT "comment_thread_fk" FOREIGN KEY ("comment_id")
  REFERENCES "comments" ("id") ON DELETE CASCADE,
  CONSTRAINT "no_empty_comments"
  CHECK (LENGTH(TRIM("text_content")) > 0),
  CONSTRAINT "max_comment_character_length"
  CHECK (LENGTH("text_content") <= 10000),
  CONSTRAINT "no_double_comments"
  CHECK (("post_id" IS NULL AND "comment_id" IS NOT NULL) OR
        ("post_id" IS NOT NULL AND "comment_id" IS NULL))
);


### Votes

CREATE TABLE "votes" (
  "post_id" INTEGER REFERENCES "posts" ON DELETE CASCADE,
  "user_id" INTEGER REFERENCES "users" ON DELETE SET NULL,
  "vote" INTEGER NOT NULL,
  CONSTRAINT "user_voting_rule"
  UNIQUE ("user_id", "post_id"),
  CONSTRAINT "up_down_votes"
  CHECK ("vote" = 1 OR "vote" = -1)
);



### Indexes

-- Guideline 2(a) – List all users who haven’t logged in during the last year
ALTER TABLE "users"
  ADD COLUMN "login_date" TIMESTAMP;

CREATE INDEX "login_date_index"
    ON "users" ("login_date");
--


-- Guideline 2(b) – List all users who haven’t created any posts
CREATE INDEX "user_id__index"
  ON "posts" ( "user_id");
--


-- Guideline 2(d) – List all topics that don’t have any posts
CREATE INDEX "topic_id_index"
  ON "posts" ("topic_id");
--


/*
Guideline 2(h) – Find all posts that link to a specific URL, for moderation purposes
*/
CREATE INDEX "url_index"
  ON "posts" ("url");
--


-- Guideline 2(i) – List all the top-level comments for a given post
CREATE INDEX "post_id_index"
  ON "comments" ("post_id");
--


-- Guideline 2(k) – List the latest 20 comments made by a user
CREATE INDEX "user_id_index"
  ON "comments" ("user_id");
--


/*
Guideline 2(l) – List the vote sum for each post
*/
SELECT "post_id",
       SUM("vote") AS vote_sum
FROM "votes"
GROUP BY 1
ORDER BY 1;

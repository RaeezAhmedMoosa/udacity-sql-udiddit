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


SELECT COUNT(DISTINCT username)
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
• upvotes
• downvotes
*/

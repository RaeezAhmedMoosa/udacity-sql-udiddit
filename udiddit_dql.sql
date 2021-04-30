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

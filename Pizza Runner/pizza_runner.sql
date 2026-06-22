CREATE SCHEMA pizza_runner;
SET SEARCH_PATH TO pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

SELECT * FROM customer_orders;

-- Clean distance column to remove unit (km) and set NULL Values
SELECT distance,
REPLACE(distance, 'km', '') as distance_value
FROM runner_orders
WHERE distance IS NOT NULL;

UPDATE runner_orders
SET distance = REPLACE(distance, 'km', '')
WHERE distance IS NOT NULL;

UPDATE runner_orders
SET distance = NULL
WHERE distance = 'null';

-- Rename Column distance
ALTER TABLE runner_orders RENAME COLUMN distance TO distance_in_km;

-- Change type of column distance_in_km to Integer
ALTER TABLE runner_orders
ALTER COLUMN distance_in_km TYPE DECIMAL(4, 2) USING distance_in_km::DECIMAL;

-- Clean duration column 
SELECT * FROM runner_orders;

SELECT * FROM runner_orders
WHERE duration = 'null';

UPDATE runner_orders
SET duration = NULL
WHERE duration = 'null';

SELECT duration,
REGEXP_REPLACE(duration, '[^0-9.]', '', 'g') as new_duration
FROM runner_orders;

UPDATE runner_orders
SET duration = REGEXP_REPLACE(duration, '[^0-9.]', '', 'g')
WHERE duration IS NOT NULL;

ALTER TABLE runner_orders RENAME COLUMN duration to duration_in_minutes;
ALTER TABLE runner_orders 
ALTER COLUMN duration_in_minutes TYPE INTEGER USING duration_in_minutes::INTEGER;

-- Clean Cancellation Column
UPDATE runner_orders
SET cancellation = NULL
WHERE cancellation = '' 
	OR cancellation = 'null';
	
SELECT * FROM runner_orders;

-- A. Pizza Metrics
SELECT * FROM customer_orders;

-- How many pizzas were ordered?
SELECT COUNT(*) FROM customer_orders;

-- How many unique customer orders were made?
SELECT COUNT(*)
FROM (
	SELECT customer_id, COUNT(*) 
	FROM customer_orders
	GROUP BY customer_id
);

-- How many successful orders were delivered by each runner?
SELECT runner_id, COUNT(*) FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;

-- How many of each type of pizza was delivered?
SELECT pizza_name, COUNT(*)
FROM (
	SELECT ro.order_id, co.pizza_id, pn.pizza_name
	FROM runner_orders ro
	JOIN customer_orders co ON ro.order_id = co.order_id
	JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
	WHERE ro.cancellation IS NULL
)
GROUP BY pizza_name;

-- How many Vegetarian and Meatlovers were ordered by each customer?
SELECT co.customer_id, pn.pizza_name, COUNT(*) as total_ordered
	FROM customer_orders co
	JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
	GROUP BY co.customer_id, pn.pizza_name;

-- What was the maximum number of pizzas delivered in a single order?
SELECT order_id, COUNT(*)
FROM (
	SELECT ro.order_id, co.pizza_id, pn.pizza_name
	FROM runner_orders ro
	JOIN customer_orders co ON ro.order_id = co.order_id
	JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
)
GROUP BY order_id
ORDER BY COUNT(*) DESC
LIMIT 1;
	
-- For each customer, how many delivered pizzas had at least 1 
-- change and how many had no changes?
SELECT customer_id,
SUM(CASE WHEN exclusions = 'None' AND extras = 'None' THEN 1 ELSE 0 END)
	AS nonchanged_pizzas_count,
SUM(CASE WHEN exclusions NOT IN ('None') OR extras NOT IN ('None') THEN 1 ELSE 0 END)
	AS changed_pizzas_count
FROM customer_orders co
JOIN (SELECT * FROM runner_orders WHERE cancellation IS NULL) AS ro
	ON co.order_id = ro.order_id
GROUP BY (co.customer_id);

-- How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(*)
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE
	ro.cancellation IS NULL
	AND (co.exclusions != 'None')
	AND(co.extras != 'None');

-- What was the total volume of pizzas ordered for each hour of the day?
SELECT EXTRACT(HOUR FROM order_time), COUNT(*)
FROM customer_orders
GROUP BY EXTRACT(HOUR FROM order_time)
ORDER BY COUNT(*) DESC;

-- What was the volume of orders for each day of the week?
SELECT TO_CHAR(order_time, 'FMDAY'), COUNT(*)
FROM customer_orders
GROUP BY TO_CHAR(order_time, 'FMDAY')
ORDER BY COUNT(*) DESC;


		-- B. Runner and Customer Experience
-- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT 
    -- 1. Calculate the start of each custom 1-week bucket
    '2021-01-01'::date + ((registration_date - '2021-01-01'::date) / 7) * 7 AS week_start,
    -- 2. Count the runners in that bucket
    COUNT(*) AS runner_count
FROM runners
WHERE registration_date >= '2021-01-01'
GROUP BY week_start
ORDER BY week_start ASC;

-- What was the average time in minutes it took for each runner to arrive at 
-- the Pizza Runner HQ to pickup the order?
SELECT * FROM runner_orders;
SELECT * FROM customer_orders;

SELECT ROUND(AVG(minutes_difference)) AS average_time_in_minutes
FROM (
	SELECT ro.runner_id,
		EXTRACT(EPOCH FROM (ro.pickup_time::TIMESTAMP - co.order_time::TIMESTAMP)) / 60 AS minutes_difference
	FROM customer_orders co
	JOIN runner_orders ro ON co.order_id = ro.order_id
	WHERE ro.pickup_time::DATE IS NOT NULL OR  co.order_time::DATE IS NOT NULL
);
-- Is there any relationship between the number of pizzas 
-- and how long the order takes to prepare?
-- Yes, there is a relationship between the number of pizzas and how 
-- long the order takes to prepare.
WITH order_summary AS (
    SELECT co.order_id,
        COUNT(co.pizza_id) AS pizza_count,
        EXTRACT(EPOCH FROM (ro.pickup_time::timestamp - co.order_time::timestamp)) / 60 AS prep_minutes
    FROM customer_orders co
    JOIN runner_orders ro ON co.order_id = ro.order_id
    WHERE ro.pickup_time IS NOT NULL
    GROUP BY co.order_id, ro.pickup_time, co.order_time
)
SELECT 
    ROUND(CORR(prep_minutes, pizza_count)::numeric, 4) AS correlation_coefficient
FROM order_summary;

-- What was the average distance travelled for each customer?
SELECT co.customer_id, ROUND(AVG(ro.distance_in_km),2) AS average_distance
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.distance_in_km IS NOT NULL
GROUP BY co.customer_id;

-- What was the difference between the longest and shortest delivery times for all orders?
SELECT * FROM runner_orders;
SELECT * FROM customer_orders;

ALTER TABLE runner_orders
ALTER COLUMN duration_in_minutes TYPE INTEGER USING duration_in_minutes::INTEGER;

SELECT MAX(duration_in_minutes) - MIN(duration_in_minutes) AS difference
FROM runner_orders;

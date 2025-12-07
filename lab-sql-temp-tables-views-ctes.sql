--Step 1: Create a View (customer_rental_summary)
CREATE OR REPLACE VIEW customer_rental_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM
    customer c
JOIN
    rental r ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id, customer_name, c.email;

-- You can test the view:
-- SELECT * FROM customer_rental_summary LIMIT 5;
--Step 2: Create a Temporary Table (customer_payment_summary)
CREATE TEMPORARY TABLE customer_payment_summary (
    customer_id SMALLINT UNSIGNED NOT NULL,
    total_paid DECIMAL(5, 2) NOT NULL
);

INSERT INTO customer_payment_summary (customer_id, total_paid)
SELECT
    crs.customer_id,
    SUM(p.amount) AS total_paid
FROM
    customer_rental_summary crs  -- Joins the View from Step 1
JOIN
    payment p ON crs.customer_id = p.customer_id
GROUP BY
    crs.customer_id;

-- You can test the temporary table:
-- SELECT * FROM customer_payment_summary LIMIT 5;
--Step 3: Create a CTE and the Final Report
WITH customer_summary_cte AS (
    SELECT
        crs.customer_name,
        crs.email,
        crs.rental_count,
        cps.total_paid
    FROM
        customer_rental_summary crs  -- View
    JOIN
        customer_payment_summary cps ON crs.customer_id = cps.customer_id -- Temporary Table
)
SELECT
    customer_name,
    email,
    rental_count,
    total_paid,
    -- Calculate the derived column
    ROUND(total_paid / rental_count, 2) AS average_payment_per_rental
FROM
    customer_summary_cte
ORDER BY
    customer_name;

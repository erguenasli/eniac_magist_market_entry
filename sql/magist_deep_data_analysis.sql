/* =========================================================================================
   PROJECT: ENIAC MARKET ENTRY FEASIBILITY ASSESSMENT (MAGIST BRAZIL)
   AUTHOR: Team Electricity
   PURPOSE: Comprehensive exploratory data analysis (EDA), catalog identification, 
            price-tier taxonomy, seller revenue benchmarking, regional logistics analysis,
            and data exports for Tableau visualization.
   DATABASE: MySQL (magist)
   ========================================================================================= */

USE magist;

-- =========================================================================================
-- 1. PLATFORM SCALE & USER GROWTH
-- =========================================================================================

-- 1.1 Is Magist having user growth?
-- Evaluates monthly active customer acquisition across the platform lifecycle.
SELECT 
    YEAR(order_purchase_timestamp) AS yr,
    MONTH(order_purchase_timestamp) AS mth,
    COUNT(customer_id) AS num_cstmrs
FROM orders
GROUP BY yr, mth
ORDER BY yr ASC, mth ASC;

-- 1.2 Monthly Platform Revenue & Customer Growth Trends (2017 - 2018)
-- Feeds: monthly_revenue_and_customer_trends.csv & Presentation Slide 11
SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y %M') AS month_year,
    COUNT(o.customer_id) AS num_cstmrs,
    ROUND(SUM(oi.price), 0) AS mthly_revenue
FROM orders AS o
JOIN order_items AS oi USING (order_id)
WHERE YEAR(o.order_purchase_timestamp) != 2016 -- Excludes sparse 2016 launch data
GROUP BY month_year
ORDER BY month_year ASC;


-- =========================================================================================
-- 2. TECH PRODUCT CATALOG & OVERALL VOLUME
-- =========================================================================================

/* 
What categories of tech products does Magist have? 
The 10 categories aligning closest to ENIAC's consumer electronics catalog:
- computers_accessories (peripherals, adapters, cables, sleeves)
- computers, pc_gamer
- tablets_printing_image (tablets, portable printers, digitizers)
- telephony (smartphones, mobile cases, chargers, screen protectors)
- fixed_telephony (telecom hardware)
- electronics (general consumer electronics)
- audio (headphones, portable speakers, earbuds)
- cine_photo (cameras, lenses, photo accessories)
- consoles_games (gaming consoles and controllers)
*/

SELECT *
FROM product_category_name_translation
WHERE product_category_name_english IN (
    'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
    'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
    'consoles_games'
);

/* 
How many products of these tech categories have been sold?
What percentage does that represent from the overall number of products sold?
What is the average price of individual items vs the average tech order basket?
*/
SELECT 
    COUNT(o.product_id) AS num_tech_pr,
    ROUND(100 * COUNT(o.product_id) / (SELECT COUNT(*) FROM order_items), 0) AS percentage_sales,
    ROUND(AVG(o.price), 2) AS avg_item_price,
    (
        SELECT ROUND(AVG(order_tech_total), 2)
        FROM (
            SELECT oi.order_id, SUM(oi.price) AS order_tech_total
            FROM order_items AS oi
            JOIN products AS p USING (product_id)
            JOIN product_category_name_translation AS pcnt USING (product_category_name)
            WHERE pcnt.product_category_name_english IN (
                'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
                'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
                'consoles_games'
            )
            GROUP BY oi.order_id
        ) AS order_totals
    ) AS avg_tech_order_price
FROM products AS p
JOIN order_items AS o USING (product_id)
JOIN product_category_name_translation AS pcnt USING (product_category_name)
WHERE pcnt.product_category_name_english IN (
    'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
    'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
    'consoles_games'
);


-- =========================================================================================
-- 3. PRICE RANGE SEGMENTATION, FREIGHT & SELLER INCOME
-- =========================================================================================

/* 
Analysis of Sales, Revenue, Freight Cost of Tech Products & Avg. Monthly Income of Tech Sellers by Price Range 
Feeds: tech_pricing_freight_and_seller_income.csv & Presentation Slides 3, 7, 10
*/
SELECT 
    CASE
        WHEN o.price > 1000 THEN 'ultra-premium tech'
        WHEN o.price > 500  THEN 'premium hardware'
        WHEN o.price > 150  THEN 'mid-range tech'
        WHEN o.price > 50   THEN 'standard accessories'
        ELSE 'budget essentials'
    END AS price_tier,
    COUNT(o.product_id) AS num_products,
    ROUND(COUNT(o.product_id) / (
        SELECT COUNT(*)
        FROM order_items AS o
        JOIN products AS p USING (product_id)
        JOIN product_category_name_translation USING (product_category_name)
        WHERE product_category_name_english IN (
            'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
            'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
            'consoles_games'
        )
    ), 2) AS percent_tech_sales,
    ROUND(SUM(o.price) / 1000, 0) AS revenue_in_K,
    ROUND(AVG(o.freight_value), 2) AS avg_freight_cost,
    ROUND(MIN(o.freight_value), 2) AS min_freight_cost,
    ROUND(MAX(o.freight_value), 2) AS max_freight_cost,
    ROUND((SUM(o.price) / COUNT(DISTINCT o.seller_id)) / 25, 2) AS avg_mnthly_income_tech_sellers
FROM product_category_name_translation
JOIN products AS p USING (product_category_name)
JOIN order_items AS o USING (product_id)
WHERE product_category_name_english IN (
    'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
    'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
    'consoles_games'
)
GROUP BY price_tier
ORDER BY num_products DESC;

-- Statistical Validation: Tech Item Price Median vs Mean
-- Demonstrates that >= 50% of all tech items sold are priced below € 50 (Median: € 49.50)
SELECT 
    ROUND(AVG(price), 2) AS mean_tech_price,
    (
        SELECT ROUND(oi.price, 2)
        FROM order_items oi
        JOIN products p USING (product_id)
        JOIN product_category_name_translation t USING (product_category_name)
        WHERE t.product_category_name_english IN (
            'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
            'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
            'consoles_games'
        )
        ORDER BY oi.price ASC
        LIMIT 1 OFFSET 8635
    ) AS median_tech_price
FROM order_items oi
JOIN products p USING (product_id)
JOIN product_category_name_translation t USING (product_category_name)
WHERE t.product_category_name_english IN (
    'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
    'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
    'consoles_games'
);

-- =========================================================================================
-- 4. SELLER COMMUNITY & MONETARY BENCHMARKING
-- =========================================================================================

-- How many months of data are included in the magist database? (Baseline: 25 months)
SELECT 
    COUNT(DISTINCT DATE_FORMAT(order_purchase_timestamp, '%Y-%m')) AS total_months
FROM orders;

-- How many sellers vs tech sellers are there (percentage share)?
SELECT 
    (SELECT COUNT(s.seller_id) FROM sellers AS s) AS all_sellers,
    COUNT(DISTINCT s.seller_id) AS tech_sellers,
    ROUND(100 * (COUNT(DISTINCT s.seller_id) / (SELECT COUNT(seller_id) AS all_sellers FROM sellers)), 1) AS percent_tech_sellers
FROM sellers AS s
JOIN order_items AS oi USING (seller_id)
JOIN products AS p USING (product_id)
JOIN product_category_name_translation AS pcnt USING (product_category_name)
WHERE pcnt.product_category_name_english IN (
    'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
    'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
    'consoles_games'
);

-- What is the total amount earned by all sellers vs tech sellers?
SELECT
    ROUND((SELECT SUM(price) FROM order_items) / 1000000, 2) AS revenue_all_sellers_in_M,
    ROUND(SUM(oi.price) / 1000000, 2) AS revenue_tech_sellers_in_M,
    ROUND(100 * (SUM(oi.price) / (SELECT SUM(price) FROM order_items)), 2) AS tech_revenue_share_pct
FROM order_items AS oi
JOIN products AS p USING (product_id)
JOIN product_category_name_translation AS pcnt USING (product_category_name)
WHERE pcnt.product_category_name_english IN (
    'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
    'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
    'consoles_games'
);

-- What is the average monthly income of all sellers vs tech sellers?
SELECT
    ROUND(((SELECT SUM(price) FROM order_items) / (SELECT COUNT(*) FROM sellers)) / 25, 2) AS avg_mnthly_income_all_sellers,
    ROUND((SUM(price) / COUNT(DISTINCT seller_id)) / 25, 2) AS avg_mnthly_income_tech_sellers
FROM order_items
JOIN products USING (product_id)
JOIN product_category_name_translation AS pcnt USING (product_category_name)
WHERE pcnt.product_category_name_english IN (
    'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
    'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
    'consoles_games'
);


-- =========================================================================================
-- 5. LOGISTICS & DELIVERY TIME BENCHMARKS
-- =========================================================================================

-- What is the average time between order placement and delivery (All Categories: 13 Days)?
SELECT 
    ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 0) AS avg_delivery
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;
    
-- What is the average delivery time for tech categories specifically (13 Days)?
SELECT 
    ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 0) AS avg_delivery
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_id IN (
      SELECT order_id
      FROM order_items
      JOIN products USING (product_id)
      JOIN product_category_name_translation AS pcnt USING (product_category_name)
      WHERE pcnt.product_category_name_english IN (
          'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
          'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
          'consoles_games'
      )
  );

-- What is the average promised delivery timeframe (estimated ETA window = 25 days)?
SELECT 
    ROUND(AVG(DATEDIFF(order_estimated_delivery_date, order_purchase_timestamp)), 0) AS avg_estimated_delivery_days
FROM orders
JOIN order_items USING (order_id)
JOIN products USING (product_id)
JOIN product_category_name_translation AS pcnt USING (product_category_name)
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND pcnt.product_category_name_english IN (
      'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
      'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
      'consoles_games'
  );

-- Order volume distribution per order status (fulfillment completion rate)
SELECT 
    order_status,
    COUNT(order_id) AS num_of_orders,
    ROUND(100 * COUNT(order_id) / (SELECT COUNT(*) FROM orders), 2) AS percent_of_total
FROM orders
GROUP BY order_status
ORDER BY num_of_orders DESC;

-- Ratio of on-time/early orders vs delayed orders
SELECT 
    CASE
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN 'delayed'
        ELSE 'on time/early'
    END AS delivery_status,
    COUNT(*) AS total_orders,
    ROUND(100 * COUNT(*) / (
        SELECT COUNT(*) 
        FROM orders 
        WHERE order_status = 'delivered' 
          AND order_delivered_customer_date IS NOT NULL
    ), 1) AS pct_orders
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;

-- Average delay duration for late tech orders (when an order misses its ETA)
SELECT 
    COUNT(*) AS total_delayed_orders,
    MIN(DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)) AS min_days_late,
    ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)), 0) AS avg_days_late,
    MAX(DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)) AS max_days_late
FROM orders
JOIN order_items USING (order_id)
JOIN products USING (product_id)
JOIN product_category_name_translation AS pcnt USING (product_category_name)
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0
  AND pcnt.product_category_name_english IN (
      'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
      'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
      'consoles_games'
  );

/* Freight-to-Price Ratio & Total Spend by Tech Category
   (Proves the disproportionate shipping cost burden on lower-priced accessories) */
SELECT 
    t.product_category_name_english,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(AVG(oi.price), 2) AS avg_product_price,
    ROUND(AVG(oi.freight_value), 2) AS avg_freight_cost,
    ROUND(AVG(oi.freight_value) / AVG(oi.price) * 100, 2) AS freight_to_price_ratio_pct,
    ROUND(AVG(oi.price + oi.freight_value), 2) AS avg_total_customer_spend
FROM order_items oi
JOIN products p USING (product_id)
JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
WHERE t.product_category_name_english IN (
    'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
    'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
    'consoles_games'
)
GROUP BY t.product_category_name_english
ORDER BY freight_to_price_ratio_pct DESC;


-- =========================================================================================
-- 6. ROOT-CAUSE ANALYSIS OF SHIPPING DELAYS
-- =========================================================================================

-- Delay rate and average days late broken down by individual tech category
SELECT 
    pcnt.product_category_name_english AS category,
    COUNT(DISTINCT o.order_id) AS total_delivered_orders,
    COUNT(DISTINCT CASE 
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) > 0 
        THEN o.order_id END) AS delayed_orders,
    ROUND(100 * COUNT(DISTINCT CASE 
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) > 0 
        THEN o.order_id END) / COUNT(DISTINCT o.order_id), 1) AS percent_delayed,
    ROUND(AVG(CASE 
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) > 0 
        THEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) END), 0) AS avg_days_late
FROM orders AS o
JOIN order_items AS oi USING (order_id)
JOIN products AS p USING (product_id)
JOIN product_category_name_translation AS pcnt USING (product_category_name)
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND pcnt.product_category_name_english IN (
      'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
      'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
      'consoles_games'
  )
GROUP BY category
ORDER BY percent_delayed DESC;

-- Delay correlation: item weight, freight charges, seller dispatch time, and carrier transit time
SELECT 
    CASE 
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) > 0 THEN 'Delayed'
        ELSE 'On Time'
    END AS delivery_status,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(AVG(p.product_weight_g), 0) AS avg_weight_grams,
    ROUND(AVG(oi.freight_value), 2) AS avg_freight_cost,
    ROUND(AVG(DATEDIFF(o.order_delivered_carrier_date, o.order_purchase_timestamp)), 0) AS avg_days_seller_dispatch,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_delivered_carrier_date)), 0) AS avg_days_carrier_transit
FROM orders AS o
JOIN order_items AS oi USING (order_id)
JOIN products AS p USING (product_id)
JOIN product_category_name_translation AS pcnt USING (product_category_name)
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_delivered_carrier_date IS NOT NULL
  AND pcnt.product_category_name_english IN (
      'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
      'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
      'consoles_games'
  )
GROUP BY delivery_status;


-- =========================================================================================
-- 7. GEOGRAPHIC ANALYSES & REGIONAL LOGISTICS
-- =========================================================================================

-- Where are tech sellers located? (Postal prefix grouping)
SELECT 
    CASE LEFT(LPAD(s.seller_zip_code_prefix, 5, '0'), 1)
        WHEN '0' THEN '0xxxx: Greater São Paulo'
        WHEN '1' THEN '1xxxx: São Paulo State (Interior/Coast)'
        WHEN '2' THEN '2xxxx: Rio de Janeiro & Espírito Santo'
        WHEN '3' THEN '3xxxx: Minas Gerais'
        WHEN '4' THEN '4xxxx: Bahia & Sergipe'
        WHEN '5' THEN '5xxxx: Northeast (PE, AL, PB, RN)'
        WHEN '6' THEN '6xxxx: North & Upper NE (CE, PI, MA, PA, AM)'
        WHEN '7' THEN '7xxxx: Central-West & DF (Brasília, GO, MT, MS)'
        WHEN '8' THEN '8xxxx: South (Paraná & Santa Catarina)'
        WHEN '9' THEN '9xxxx: South (Rio Grande do Sul)'
        ELSE 'Other'
    END AS postal_region,
    COUNT(DISTINCT s.seller_id) AS num_of_tech_sellers,
    COUNT(oi.order_item_id) AS total_tech_items_sold
FROM sellers AS s
JOIN order_items AS oi USING (seller_id)
JOIN products AS p USING (product_id)
JOIN product_category_name_translation AS pcnt USING (product_category_name)
WHERE pcnt.product_category_name_english IN (
    'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
    'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
    'consoles_games'
)
GROUP BY postal_region
ORDER BY num_of_tech_sellers DESC;

-- Geographical analysis: Intrastate vs Interstate shipping performance
-- Compares delivery transit days, delay rates, and review scores when orders cross state borders.
SELECT 
    CASE
        -- Both in São Paulo state (covers the vast majority of local shipments)
        WHEN LEFT(LPAD(c.customer_zip_code_prefix, 5, '0'), 1) IN ('0', '1') 
         AND LEFT(LPAD(s.seller_zip_code_prefix, 5, '0'), 1) IN ('0', '1') THEN 'same state/intrastate'
        -- Both share the same broader postal zone
        WHEN LEFT(c.customer_zip_code_prefix, 1) = LEFT(s.seller_zip_code_prefix, 1) THEN 'same state/intrastate'
        ELSE 'cross state/interstate'
    END AS shipping_scope,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 1) AS avg_delivery_days,
    ROUND(100 * COUNT(DISTINCT CASE 
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) > 0 
        THEN o.order_id 
    END) / COUNT(DISTINCT o.order_id), 0) AS percent_delayed,
    ROUND(AVG(CASE 
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) > 0 
        THEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) 
    END), 0) AS avg_days_late,
    ROUND(AVG(review_score), 2) AS avg_review
FROM orders AS o
JOIN order_reviews USING (order_id)
JOIN customers AS c USING (customer_id)
JOIN order_items AS oi USING (order_id)
JOIN sellers AS s USING (seller_id)
JOIN products AS p USING (product_id)
JOIN product_category_name_translation AS pcnt USING (product_category_name)
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND pcnt.product_category_name_english IN (
      'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
      'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
      'consoles_games'
  )
GROUP BY shipping_scope;

-- [Query A - Macro Level Data Aggregation]:
-- Where are customers located, and how do macro-postal zones perform?
-- Used for high-level regional benchmarking across the 10 macro-postal zones.
SELECT 
    CASE LEFT(LPAD(c.customer_zip_code_prefix, 5, '0'), 1)
        WHEN '0' THEN '0xxxx: Greater São Paulo'
        WHEN '1' THEN '1xxxx: São Paulo State (Interior/Coast)'
        WHEN '2' THEN '2xxxx: Rio de Janeiro & Espírito Santo'
        WHEN '3' THEN '3xxxx: Minas Gerais'
        WHEN '4' THEN '4xxxx: Bahia & Sergipe'
        WHEN '5' THEN '5xxxx: Northeast (PE, AL, PB, RN)'
        WHEN '6' THEN '6xxxx: North & Upper NE (CE, PI, MA, PA, AM)'
        WHEN '7' THEN '7xxxx: Central-West & DF (Brasília, GO, MT, MS)'
        WHEN '8' THEN '8xxxx: South (Paraná & Santa Catarina)'
        WHEN '9' THEN '9xxxx: South (Rio Grande do Sul)'
        ELSE 'Other'
    END AS postal_region,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 1) AS avg_delivery_days,
    ROUND(100 * COUNT(DISTINCT CASE 
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) > 0 
        THEN o.order_id 
    END) / COUNT(DISTINCT o.order_id), 0) AS percent_delayed,
    ROUND(AVG(CASE 
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) > 0 
        THEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) 
    END), 0) AS avg_days_late,
    ROUND(AVG(review_score), 2) AS avg_review
FROM orders AS o
JOIN order_reviews USING (order_id)
JOIN customers AS c USING (customer_id)
JOIN order_items AS oi USING (order_id)
JOIN products AS p USING (product_id)
JOIN product_category_name_translation AS pcnt USING (product_category_name)
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND pcnt.product_category_name_english IN (
      'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
      'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
      'consoles_games'
  )
GROUP BY postal_region;

-- [Query B - Tableau Map Data Source Export]:
-- Exactly matches Query A above, but brings in 'g.state AS customer_state' via a LEFT JOIN on 'geo'.
-- Feeds: regional_delivery_and_logistics_by_state.csv & Presentation Slides 4, 12
SELECT 
    g.state AS customer_state,
    CASE LEFT(LPAD(c.customer_zip_code_prefix, 5, '0'), 1)
        WHEN '0' THEN '0xxxx: Greater São Paulo'
        WHEN '1' THEN '1xxxx: São Paulo State (Interior/Coast)'
        WHEN '2' THEN '2xxxx: Rio de Janeiro & Espírito Santo'
        WHEN '3' THEN '3xxxx: Minas Gerais'
        WHEN '4' THEN '4xxxx: Bahia & Sergipe'
        WHEN '5' THEN '5xxxx: Northeast (PE, AL, PB, RN)'
        WHEN '6' THEN '6xxxx: North & Upper NE (CE, PI, MA, PA, AM)'
        WHEN '7' THEN '7xxxx: Central-West & DF (Brasília, GO, MT, MS)'
        WHEN '8' THEN '8xxxx: South (Paraná & Santa Catarina)'
        WHEN '9' THEN '9xxxx: South (Rio Grande do Sul)'
        ELSE 'Other'
    END AS postal_region,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 1) AS avg_delivery_days,
    ROUND(100 * COUNT(DISTINCT CASE 
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) > 0 
        THEN o.order_id 
    END) / COUNT(DISTINCT o.order_id), 0) AS percent_delayed,
    ROUND(AVG(CASE 
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) > 0 
        THEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) 
    END), 0) AS avg_days_late,
    ROUND(AVG(review_score), 2) AS avg_review
FROM orders AS o
JOIN order_reviews USING (order_id)
JOIN customers AS c USING (customer_id)
JOIN order_items AS oi USING (order_id)
JOIN products AS p USING (product_id)
JOIN product_category_name_translation AS pcnt USING (product_category_name)
LEFT JOIN geo AS g ON c.customer_zip_code_prefix = g.zip_code_prefix
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND pcnt.product_category_name_english IN (
      'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
      'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
      'consoles_games'
  )
GROUP BY 
    postal_region,
    customer_state
ORDER BY avg_delivery_days ASC;


-- =========================================================================================
-- 8. CUSTOMER REVIEWS & FEEDBACK COVERAGE
-- =========================================================================================

-- How many orders have reviews?
-- Validates review response rate across tech orders (> 99% review coverage).
SELECT 
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT ore.order_id) AS orders_with_at_least_one_review,
    COUNT(DISTINCT o.order_id) - COUNT(DISTINCT ore.order_id) AS orders_without_review,
    ROUND(100 * COUNT(DISTINCT ore.order_id) / COUNT(DISTINCT o.order_id), 2) AS percent_orders_reviewed
FROM orders AS o
LEFT JOIN order_reviews AS ore 
    ON o.order_id = ore.order_id 
   AND ore.review_score IS NOT NULL
LEFT JOIN order_items AS oi
    ON o.order_id = oi.order_id
LEFT JOIN products AS p
    USING (product_id)
LEFT JOIN product_category_name_translation AS pcnt
    USING (product_category_name)
WHERE pcnt.product_category_name_english IN (
    'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
    'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
    'consoles_games'
);

/* Text Mining & NLP Classification of Customer Review Complaints (Review Score <= 2)
   Feeds: customer_complaints_breakdown.csv & Presentation Slide 9 */
SELECT
    CASE
        WHEN LOWER(r.review_comment_message) REGEXP 'demor|atras|demou|entrega|prazo|chegou' 
          OR LOWER(r.review_comment_title) REGEXP 'demor|atras|demou|entrega|prazo|chegou'
            THEN 'Delivery Delay / Shipping Issues'
        WHEN LOWER(r.review_comment_message) REGEXP 'quebr|estrag|defeito|danific|funciona|pessim'
          OR LOWER(r.review_comment_title) REGEXP 'quebr|estrag|defeito|danific|funciona|pessim'
            THEN 'Product Quality / Defect'
        WHEN LOWER(r.review_comment_message) REGEXP 'errad|diferent|trocad|falta|veio'
          OR LOWER(r.review_comment_title) REGEXP 'errad|diferent|trocad|falta|veio'
            THEN 'Wrong or Missing Item'
        WHEN r.review_comment_message IS NULL OR TRIM(r.review_comment_message) = '' 
            THEN 'No Written Comment'
        ELSE 'Other Complaint'
    END AS complaint_category,
    COUNT(DISTINCT r.review_id) AS total_complaints,
    ROUND(100 * COUNT(DISTINCT r.review_id) / SUM(COUNT(DISTINCT r.review_id)) OVER(), 2) AS percent_of_complaints
FROM order_reviews r
JOIN order_items i ON r.order_id = i.order_id
JOIN products p ON i.product_id = p.product_id
JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
WHERE r.review_score <= 2
  AND t.product_category_name_english IN (
      'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
      'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
      'consoles_games'
  )
GROUP BY complaint_category
ORDER BY total_complaints DESC;

/* Customer Sentiment Impact: Review Score Cliff by Delivery SLA Performance
   Feeds: delivery_status_review_impact.csv & Presentation Slide 8 */
SELECT 
    CASE 
        WHEN o.order_delivered_customer_date IS NULL THEN 'Not Delivered'
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Delayed'
        ELSE 'On Time'
    END AS delivery_status,
    COUNT(DISTINCT r.review_id) AS total_reviews,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    ROUND(100 * COUNT(DISTINCT r.review_id) / SUM(COUNT(DISTINCT r.review_id)) OVER(), 2) AS percent_of_reviews
FROM order_reviews r
JOIN orders o ON r.order_id = o.order_id
JOIN order_items i ON o.order_id = i.order_id
JOIN products p ON i.product_id = p.product_id
JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
WHERE t.product_category_name_english IN (
    'computers_accessories', 'computers', 'pc_gamer', 'tablets_printing_image',
    'telephony', 'fixed_telephony', 'electronics', 'audio', 'cine_photo', 
    'consoles_games'
)
GROUP BY delivery_status
ORDER BY avg_review_score ASC;
-- ============================================
-- Amazon Last Mile Delivery Analysis
-- Author: Keerthi
-- Dataset: Amazon Delivery Dataset (43,648 rows)
-- ============================================

-- ============================================
-- PROJECT QUESTION: Is Preparation Time or Transit Time the bigger driver of late deliveries?
-- ============================================

SELECT 
    Late_Delivery_Flag,
    ROUND(AVG(Preparation_Time), 2) AS Avg_Preparation_Time,
    ROUND(AVG(Transit_Time), 2) AS Avg_Transit_Time
FROM deliveries
GROUP BY Late_Delivery_Flag;

-- FINDING: Transit time is the primary driver. Late deliveries 
-- Preparation time remains consistent at ~10 mins regardless.

-- ============================================
-- Q1: Which zones have highest average transit time?
-- ============================================

SELECT 
    Area,
    ROUND(AVG(Transit_Time), 2) AS Avg_Transit_Time
FROM deliveries
GROUP BY Area
ORDER BY Avg_Transit_Time DESC;

-- FINDING: Semi-Urban highest at 238 mins, 2x higher than 

-- ============================================
-- Q2: Do lower rated agents take longer to deliver?
-- Which segments need intervention?
-- ============================================

-- Agent Rating Buckets
SELECT 
    CASE 
        WHEN Agent_Rating > 4.5 THEN 'High Rating'
        WHEN Agent_Rating > 3.5 THEN 'Medium Rating'
        ELSE 'Low Rating'
    END AS Rating_Segment,
    ROUND(AVG(Transit_Time), 2) AS Avg_Transit_Time
FROM deliveries
GROUP BY Rating_Segment;

-- FINDING: Low rated agents average 174 mins vs 115 mins 
-- for high rated — 50% difference. Rating correlates strongly with delivery speed.

-- Agent Age Segments
SELECT 
    CASE 
        WHEN Agent_Age < 25 THEN 'Junior'
        WHEN Agent_Age <= 35 THEN 'Mid'
        ELSE 'Senior'
    END AS Agent_Segment,
    ROUND(AVG(Transit_Time), 2) AS Avg_Transit_Time
FROM deliveries
GROUP BY Agent_Segment;

-- FINDING: Senior agents (35+) average 140 mins vs 109 mins for juniors
-- Digital literacy training and pre-planned routes recommended for senior agents.

-- ============================================
-- Q3: Which time slots have worst delivery performance? Do peak hours explain delays?
-- ============================================

SELECT 
    CASE 
        WHEN Order_Time >= '21:00:00' OR Order_Time < '06:00:00' THEN 'Night'
        WHEN Order_Time > '17:00:00' THEN 'Evening'
        WHEN Order_Time > '12:00:00' THEN 'Afternoon'
        ELSE 'Morning'
    END AS Time_Slot,
    ROUND(AVG(Transit_Time), 2) AS Avg_Transit_Time
FROM deliveries
GROUP BY Time_Slot
ORDER BY Avg_Transit_Time DESC;

-- FINDING: Evening (5-9PM) worst at 139 mins vs Morning 
-- best at 102 mins. Peak traffic and concurrent order volume drive evening delays.

-- Weather and Traffic Impact
SELECT 
    Weather,
    Traffic,
    ROUND(AVG(Transit_Time), 2) AS Avg_Transit_Time
FROM deliveries
GROUP BY Weather, Traffic
ORDER BY Avg_Transit_Time DESC;

-- FINDING: Traffic Jam is dominant factor regardless of weather. Jam combinations occupy all top positions. 

-- ============================================
-- Q4: Which areas are consistently underperforming?
-- ============================================

SELECT 
    Area,
    COUNT(CASE WHEN Late_Delivery_Flag = 'Late' THEN 1 END) AS Late_Deliveries,
    COUNT(*) AS Total_Deliveries,
    ROUND(COUNT(CASE WHEN Late_Delivery_Flag = 'Late' THEN 1 END) * 100.0 / COUNT(*), 2) AS Late_Percentage
FROM deliveries
GROUP BY Area
ORDER BY Late_Percentage DESC;
-- FINDING: Semi-Urban shows 0 late deliveries NOT due to good performance but because it structurally has no Low 
-- traffic conditions. Requires separate benchmark.

-- Semi-Urban Traffic Verification
SELECT 
    Traffic,
    Weather,
    COUNT(*) AS Order_Count
FROM deliveries
WHERE Area = 'Semi-Urban'
GROUP BY Traffic, Weather
ORDER BY Order_Count DESC;
-- FINDING: Confirms Semi-Urban has zero Low traffic orders. 90%+ orders occur under Jam or High traffic conditions.

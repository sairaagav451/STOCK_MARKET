Create database stock;
use stock;

-- =====================================================
-- 1. CREATE TABLES (Stock Market Database)
-- =====================================================

DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS sector_performance;
DROP TABLE IF EXISTS ipo;
DROP TABLE IF EXISTS analyst_ratings;
DROP TABLE IF EXISTS stock_splits;
DROP TABLE IF EXISTS market_data;
DROP TABLE IF EXISTS portfolio_holdings;
DROP TABLE IF EXISTS portfolios;
DROP TABLE IF EXISTS watchlist;
DROP TABLE IF EXISTS dividends;
DROP TABLE IF EXISTS trades;
DROP TABLE IF EXISTS stocks;
DROP TABLE IF EXISTS brokers;
DROP TABLE IF EXISTS companies;
DROP TABLE IF EXISTS investors;

CREATE TABLE investors (
    investor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    join_date DATE NOT NULL
);

CREATE TABLE companies (
    company_id INT AUTO_INCREMENT PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    sector VARCHAR(50),
    industry VARCHAR(50),
    listing_date DATE
);

CREATE TABLE brokers (
    broker_id INT AUTO_INCREMENT PRIMARY KEY,
    broker_name VARCHAR(100) NOT NULL,
    headquarters VARCHAR(50),
    commission_rate DECIMAL(5,4)
);

CREATE TABLE stocks (
    stock_id INT AUTO_INCREMENT PRIMARY KEY,
    company_id INT,
    stock_symbol VARCHAR(10) UNIQUE NOT NULL,
    market_cap DECIMAL(15,2),
    outstanding_shares BIGINT,
    FOREIGN KEY (company_id) REFERENCES companies(company_id)
);

CREATE TABLE portfolios (
    portfolio_id INT AUTO_INCREMENT PRIMARY KEY,
    investor_id INT UNIQUE,
    total_value DECIMAL(15,2),
    created_date DATE NOT NULL,
    FOREIGN KEY (investor_id) REFERENCES investors(investor_id)
);

CREATE TABLE trades (
    trade_id INT AUTO_INCREMENT PRIMARY KEY,
    investor_id INT,
    stock_id INT,
    broker_id INT,
    trade_type VARCHAR(4) CHECK (trade_type IN ('BUY','SELL')),
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    trade_date DATE NOT NULL,
    settlement_date DATE,
    FOREIGN KEY (investor_id) REFERENCES investors(investor_id),
    FOREIGN KEY (stock_id) REFERENCES stocks(stock_id),
    FOREIGN KEY (broker_id) REFERENCES brokers(broker_id)
);

CREATE TABLE dividends (
    dividend_id INT AUTO_INCREMENT PRIMARY KEY,
    company_id INT,
    ex_date DATE NOT NULL,
    pay_date DATE,
    amount_per_share DECIMAL(8,4),
    FOREIGN KEY (company_id) REFERENCES companies(company_id)
);

CREATE TABLE watchlist (
    watchlist_id INT AUTO_INCREMENT PRIMARY KEY,
    investor_id INT,
    stock_id INT,
    added_date DATE NOT NULL,
    UNIQUE KEY (investor_id, stock_id),
    FOREIGN KEY (investor_id) REFERENCES investors(investor_id),
    FOREIGN KEY (stock_id) REFERENCES stocks(stock_id)
);

CREATE TABLE portfolio_holdings (
    holding_id INT AUTO_INCREMENT PRIMARY KEY,
    portfolio_id INT,
    stock_id INT,
    quantity INT NOT NULL,
    avg_buy_price DECIMAL(10,2),
    UNIQUE KEY (portfolio_id, stock_id),
    FOREIGN KEY (portfolio_id) REFERENCES portfolios(portfolio_id),
    FOREIGN KEY (stock_id) REFERENCES stocks(stock_id)
);

CREATE TABLE market_data (
    market_data_id INT AUTO_INCREMENT PRIMARY KEY,
    stock_id INT,
    trade_date DATE NOT NULL,
    open_price DECIMAL(10,2),
    high_price DECIMAL(10,2),
    low_price DECIMAL(10,2),
    close_price DECIMAL(10,2),
    volume BIGINT,
    UNIQUE KEY (stock_id, trade_date),
    FOREIGN KEY (stock_id) REFERENCES stocks(stock_id)
);

CREATE TABLE stock_splits (
    split_id INT AUTO_INCREMENT PRIMARY KEY,
    stock_id INT,
    split_ratio DECIMAL(8,4),
    effective_date DATE NOT NULL,
    FOREIGN KEY (stock_id) REFERENCES stocks(stock_id)
);

CREATE TABLE analyst_ratings (
    rating_id INT AUTO_INCREMENT PRIMARY KEY,
    stock_id INT,
    analyst_firm VARCHAR(100),
    rating VARCHAR(20),
    target_price DECIMAL(10,2),
    rating_date DATE,
    FOREIGN KEY (stock_id) REFERENCES stocks(stock_id)
);

CREATE TABLE ipo (
    ipo_id INT AUTO_INCREMENT PRIMARY KEY,
    company_id INT,
    ipo_price DECIMAL(10,2),
    listing_date DATE NOT NULL,
    shares_offered BIGINT,
    FOREIGN KEY (company_id) REFERENCES companies(company_id)
);

CREATE TABLE sector_performance (
    performance_id INT AUTO_INCREMENT PRIMARY KEY,
    sector VARCHAR(50),
    year INT,
    quarter INT CHECK (quarter BETWEEN 1 AND 4),
    avg_return DECIMAL(8,5)
);

CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    investor_id INT,
    trade_id INT,
    transaction_date DATE NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    transaction_type VARCHAR(20),
    FOREIGN KEY (investor_id) REFERENCES investors(investor_id),
    FOREIGN KEY (trade_id) REFERENCES trades(trade_id)
);

-- =====================================================
-- 2. INSERT DATA (100 rows per table)
-- =====================================================

-- Create a temporary numbers table (1..100)
CREATE TEMPORARY TABLE numbers (n INT PRIMARY KEY);

INSERT INTO numbers (n)
SELECT a.n * 10 + b.n + 1
FROM 
    (SELECT 0 AS n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
     UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a
CROSS JOIN
    (SELECT 0 AS n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
     UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) b
ORDER BY 1
LIMIT 100;

-- Disable foreign key checks to avoid dependency errors
SET FOREIGN_KEY_CHECKS = 0;

-- 1. Investors
INSERT INTO investors (name, city, email, join_date)
SELECT 
    CONCAT('Investor_', n),
    ELT(FLOOR(1 + RAND()*7), 'Mumbai','Delhi','Bangalore','Chennai','Hyderabad','Pune','Kolkata'),
    CONCAT('user', n, '@example.com'),
    CURDATE() - INTERVAL FLOOR(RAND()*3650) DAY
FROM numbers;

-- 2. Companies
INSERT INTO companies (company_name, sector, industry, listing_date)
SELECT 
    CONCAT('Company_', n),
    ELT(FLOOR(1 + RAND()*7), 'Tech','Finance','Healthcare','Energy','Retail','Automobile','Real Estate'),
    CONCAT('Industry_', FLOOR(1 + RAND()*10)),
    CURDATE() - INTERVAL FLOOR(RAND()*5000) DAY
FROM numbers;

-- 3. Brokers
INSERT INTO brokers (broker_name, headquarters, commission_rate)
SELECT 
    CONCAT('Broker_', n),
    ELT(FLOOR(1 + RAND()*5), 'Mumbai','Delhi','New York','London','Singapore'),
    ROUND(RAND() * 0.005, 4)
FROM numbers;

-- 4. Stocks (depends on companies)
INSERT INTO stocks (company_id, stock_symbol, market_cap, outstanding_shares)
SELECT 
    FLOOR(1 + RAND()*100),
    UPPER(SUBSTRING(MD5(RAND()), 1, 4)),
    ROUND(RAND() * 1e9, 2),
    FLOOR(RAND() * 1e8)
FROM numbers;

-- 5. Portfolios (depends on investors)
INSERT INTO portfolios (investor_id, total_value, created_date)
SELECT 
    n,   -- one portfolio per investor
    ROUND(RAND() * 500000, 2),
    CURDATE() - INTERVAL FLOOR(RAND()*1000) DAY
FROM numbers;

-- 6. Trades (depends on investors, stocks, brokers)
INSERT INTO trades (investor_id, stock_id, broker_id, trade_type, quantity, price, trade_date, settlement_date)
SELECT 
    FLOOR(1 + RAND()*100),
    FLOOR(1 + RAND()*100),
    FLOOR(1 + RAND()*100),
    IF(RAND() > 0.5, 'BUY', 'SELL'),
    FLOOR(1 + RAND()*1000),
    ROUND(RAND()*5000 + 10, 2),
    CURDATE() - INTERVAL FLOOR(RAND()*1000) DAY,
    CURDATE() - INTERVAL FLOOR(RAND()*990) DAY
FROM numbers;

-- 7. Dividends (depends on companies)
INSERT INTO dividends (company_id, ex_date, pay_date, amount_per_share)
SELECT 
    FLOOR(1 + RAND()*100),
    CURDATE() - INTERVAL FLOOR(RAND()*500) DAY,
    CURDATE() - INTERVAL FLOOR(RAND()*400) DAY,
    ROUND(RAND()*5, 2)
FROM numbers;

INSERT IGNORE INTO watchlist (investor_id, stock_id, added_date)
SELECT 
    investor_id,
    stock_id,
    CURDATE() - INTERVAL FLOOR(RAND() * 300) DAY AS added_date
FROM (
    SELECT 
        FLOOR(1 + RAND() * 100) AS investor_id,
        FLOOR(1 + RAND() * 100) AS stock_id
    FROM numbers
    GROUP BY investor_id, stock_id   -- alias works inside the subquery
    LIMIT 100
) AS pairs;

INSERT IGNORE INTO portfolio_holdings (portfolio_id, stock_id, quantity, avg_buy_price)
SELECT 
    portfolio_id,
    stock_id,
    FLOOR(1 + RAND() * 5000) AS quantity,
    ROUND(RAND() * 1000 + 10, 2) AS avg_buy_price
FROM (
    SELECT 
        FLOOR(1 + RAND() * 100) AS portfolio_id,
        FLOOR(1 + RAND() * 100) AS stock_id
    FROM numbers
    GROUP BY portfolio_id, stock_id   -- removes duplicate pairs inside the generated set
    LIMIT 200                         -- adjust to how many rows you want
) AS distinct_pairs;


-- 10. Market Data (depends on stocks)
INSERT INTO market_data (stock_id, trade_date, open_price, high_price, low_price, close_price, volume)
SELECT 
    FLOOR(1 + RAND()*100),
    CURDATE() - INTERVAL FLOOR(RAND()*365) DAY,
    ROUND(RAND()*500 + 10, 2),
    ROUND(RAND()*550 + 10, 2),
    ROUND(RAND()*480 + 10, 2),
    ROUND(RAND()*510 + 10, 2),
    FLOOR(RAND()*1e7)
FROM numbers;

-- 11. Stock Splits (depends on stocks)
INSERT INTO stock_splits (stock_id, split_ratio, effective_date)
SELECT 
    FLOOR(1 + RAND()*100),
    ROUND(RAND()*3 + 1, 2),
    CURDATE() - INTERVAL FLOOR(RAND()*800) DAY
FROM numbers;

-- 12. Analyst Ratings (depends on stocks)
INSERT INTO analyst_ratings (stock_id, analyst_firm, rating, target_price, rating_date)
SELECT 
    FLOOR(1 + RAND()*100),
    ELT(FLOOR(1 + RAND()*5), 'Morgan Stanley','Goldman Sachs','JP Morgan','Citi','Bank of America'),
    ELT(FLOOR(1 + RAND()*5), 'Buy','Hold','Sell','Strong Buy','Underweight'),
    ROUND(RAND()*800 + 20, 2),
    CURDATE() - INTERVAL FLOOR(RAND()*200) DAY
FROM numbers;

-- 13. IPO (depends on companies)
INSERT INTO ipo (company_id, ipo_price, listing_date, shares_offered)
SELECT 
    FLOOR(1 + RAND()*100),
    ROUND(RAND()*500 + 10, 2),
    CURDATE() - INTERVAL FLOOR(RAND()*3000) DAY,
    FLOOR(RAND()*1e7)
FROM numbers;

-- 14. Sector Performance (independent)
INSERT INTO sector_performance (sector, year, quarter, avg_return)
SELECT 
    ELT(FLOOR(1 + RAND()*7), 'Tech','Finance','Healthcare','Energy','Retail','Automobile','Real Estate'),
    2020 + FLOOR(RAND()*4),
    FLOOR(1 + RAND()*4),
    ROUND(RAND()*0.2 - 0.1, 5)
FROM numbers;

-- 15. Transactions (depends on investors, trades)
INSERT INTO transactions (investor_id, trade_id, transaction_date, amount, transaction_type)
SELECT 
    FLOOR(1 + RAND()*100),
    FLOOR(1 + RAND()*100),
    CURDATE() - INTERVAL FLOOR(RAND()*365) DAY,
    ROUND(RAND()*50000 + 100, 2),
    IF(RAND() > 0.5, 'DEBIT', 'CREDIT')
FROM numbers;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Drop the temporary numbers table (optional)
DROP TEMPORARY TABLE numbers;

-- =====================================================
-- 3. TASK QUERIES (30 questions)
-- =====================================================

-- 1. Display all trade details with investor name, stock symbol, broker name
SELECT 
    i.name AS investor_name,
    s.stock_symbol,
    b.broker_name,
    t.trade_type,
    t.quantity,
    t.price,
    t.trade_date
FROM trades t
JOIN investors i ON t.investor_id = i.investor_id
JOIN stocks s ON t.stock_id = s.stock_id
JOIN brokers b ON t.broker_id = b.broker_id;

-- 2. Brokers handling the maximum number of trades
SELECT b.broker_name, COUNT(*) AS trade_count
FROM trades t
JOIN brokers b ON t.broker_id = b.broker_id
GROUP BY b.broker_id
ORDER BY trade_count DESC
LIMIT 1;

-- 3. Top 3 investors with most trades
SELECT i.name, COUNT(*) AS trade_count
FROM trades t
JOIN investors i ON t.investor_id = i.investor_id
GROUP BY i.investor_id
ORDER BY trade_count DESC
LIMIT 3;

-- 4. Monthly trade count (last 12 months)
SELECT 
    DATE_FORMAT(trade_date, '%Y-%m') AS month,
    COUNT(*) AS total_trades
FROM trades
WHERE trade_date >= CURDATE() - INTERVAL 12 MONTH
GROUP BY DATE_FORMAT(trade_date, '%Y-%m')
ORDER BY month;

-- 5. Investors whose all trades are profitable (total sell > total buy)
SELECT investor_id
FROM trades
GROUP BY investor_id
HAVING SUM(CASE WHEN trade_type = 'SELL' THEN quantity * price ELSE 0 END) >
       SUM(CASE WHEN trade_type = 'BUY'  THEN quantity * price ELSE 0 END);

-- 6. Trades not assigned to any broker (broker_id is NULL) – will be empty if all assigned
SELECT * FROM trades WHERE broker_id IS NULL;

-- 7. Sector with maximum total trading volume
SELECT c.sector, SUM(t.quantity * t.price) AS total_volume
FROM trades t
JOIN stocks s ON t.stock_id = s.stock_id
JOIN companies c ON s.company_id = c.company_id
GROUP BY c.sector
ORDER BY total_volume DESC
LIMIT 1;

SELECT 
    i.name,
    AVG(CASE WHEN t.trade_type = 'SELL' 
             THEN t.price * t.quantity 
             ELSE -t.price * t.quantity 
        END) AS avg_net_value_per_trade
FROM trades t
JOIN investors i ON t.investor_id = i.investor_id
GROUP BY i.investor_id, i.name;

-- 9. Sector with highest resolution rate (positive stocks)
SELECT c.sector, COUNT(DISTINCT s.stock_id) AS positive_stocks
FROM market_data md
JOIN stocks s ON md.stock_id = s.stock_id
JOIN companies c ON s.company_id = c.company_id
WHERE md.close_price > md.open_price
GROUP BY c.sector
ORDER BY positive_stocks DESC
LIMIT 1;

-- 10. Brokers who processed more trades than average
WITH broker_trades AS (
    SELECT broker_id, COUNT(*) AS trade_count
    FROM trades
    GROUP BY broker_id
)
SELECT b.broker_name, bt.trade_count
FROM broker_trades bt
JOIN brokers b ON bt.broker_id = b.broker_id
WHERE bt.trade_count > (SELECT AVG(trade_count) FROM broker_trades);

-- 11. Most common stock symbol traded
SELECT s.stock_symbol, COUNT(*) AS trade_frequency
FROM trades t
JOIN stocks s ON t.stock_id = s.stock_id
GROUP BY s.stock_symbol
ORDER BY trade_frequency DESC
LIMIT 1;

-- 12. Trades settled within 2 days (T+2)
SELECT *
FROM trades
WHERE DATEDIFF(settlement_date, trade_date) <= 2;

-- 13. Broker with maximum pending (unsettled) trades
SELECT b.broker_name, COUNT(*) AS pending_trades
FROM trades t
JOIN brokers b ON t.broker_id = b.broker_id
WHERE t.settlement_date > CURDATE()
GROUP BY b.broker_id
ORDER BY pending_trades DESC
LIMIT 1;

-- 14. Top 3 sectors by number of unique investors trading
SELECT c.sector, COUNT(DISTINCT t.investor_id) AS unique_investors
FROM trades t
JOIN stocks s ON t.stock_id = s.stock_id
JOIN companies c ON s.company_id = c.company_id
GROUP BY c.sector
ORDER BY unique_investors DESC
LIMIT 3;

-- 15. Sectors contributing more than 30% of total trade value
WITH sector_trade_value AS (
    SELECT c.sector, SUM(t.quantity * t.price) AS sector_value
    FROM trades t
    JOIN stocks s ON t.stock_id = s.stock_id
    JOIN companies c ON s.company_id = c.company_id
    GROUP BY c.sector
),
total_value AS (
    SELECT SUM(sector_value) AS all_value FROM sector_trade_value
)
SELECT sector, sector_value, 
       (sector_value / all_value) * 100 AS percentage
FROM sector_trade_value, total_value
WHERE (sector_value / all_value) > 0.3;

-- 16. Longest unresolved (not yet settled) trade
SELECT *
FROM trades
WHERE settlement_date > CURDATE()
ORDER BY DATEDIFF(settlement_date, trade_date) DESC
LIMIT 1;

-- 17. Detect duplicate watchlist entries (should be none)
SELECT investor_id, stock_id, COUNT(*)
FROM watchlist
GROUP BY investor_id, stock_id
HAVING COUNT(*) > 1;

-- 18. Available stocks not in any portfolio
SELECT s.stock_symbol
FROM stocks s
LEFT JOIN portfolio_holdings ph ON s.stock_id = ph.stock_id
WHERE ph.stock_id IS NULL;

-- 19. Total revenue (turnover) per stock
SELECT s.stock_symbol, SUM(t.quantity * t.price) AS total_turnover
FROM trades t
JOIN stocks s ON t.stock_id = s.stock_id
GROUP BY s.stock_symbol;

-- 20. Top booked (most traded) stock
SELECT s.stock_symbol, COUNT(*) AS trade_count
FROM trades t
JOIN stocks s ON t.stock_id = s.stock_id
GROUP BY s.stock_symbol
ORDER BY trade_count DESC
LIMIT 1;

-- 21. Cancel booking: delete pending trades older than 30 days
DELETE FROM trades
WHERE settlement_date IS NULL 
  AND trade_date < CURDATE() - INTERVAL 30 DAY;

-- 22. Simulate lock: show stocks selected in last 5 minutes (conceptual)
SELECT stock_id, MAX(trade_date) AS last_trade
FROM trades
WHERE trade_date > NOW() - INTERVAL 5 MINUTE
GROUP BY stock_id;

-- 23. Trending stock (highest 7‑day volume increase)
WITH weekly_volume AS (
    SELECT stock_id, 
           SUM(volume) AS total_volume,
           DATE_FORMAT(trade_date, '%Y-%u') AS week
    FROM market_data
    GROUP BY stock_id, DATE_FORMAT(trade_date, '%Y-%u')
),
growth AS (
    SELECT stock_id, 
           total_volume - LAG(total_volume) OVER (PARTITION BY stock_id ORDER BY week) AS volume_growth
    FROM weekly_volume
)
SELECT s.stock_symbol, MAX(volume_growth) AS peak_growth
FROM growth g
JOIN stocks s ON g.stock_id = s.stock_id
GROUP BY s.stock_symbol
ORDER BY peak_growth DESC
LIMIT 1;

-- 24. Filter stocks by sector, price range, market cap
SELECT s.stock_symbol, c.sector, md.close_price, s.market_cap
FROM stocks s
JOIN companies c ON s.company_id = c.company_id
JOIN market_data md ON s.stock_id = md.stock_id
WHERE c.sector = 'Tech'
  AND md.close_price BETWEEN 100 AND 500
  AND s.market_cap > 1e9;

-- 25. Investors who paid more than 40000 in total fees
SELECT i.name, SUM(t.quantity * t.price * b.commission_rate) AS total_fees
FROM trades t
JOIN investors i ON t.investor_id = i.investor_id
JOIN brokers b ON t.broker_id = b.broker_id
GROUP BY i.investor_id
HAVING SUM(t.quantity * t.price * b.commission_rate) > 40000;

-- 26. Investor name with stock company they traded (distinct)
SELECT DISTINCT i.name, c.company_name
FROM trades t
JOIN investors i ON t.investor_id = i.investor_id
JOIN stocks s ON t.stock_id = s.stock_id
JOIN companies c ON s.company_id = c.company_id;

-- 27. Total amount paid (DEBIT) by each investor
SELECT investor_id, SUM(amount) AS total_paid
FROM transactions
WHERE transaction_type = 'DEBIT'
GROUP BY investor_id;

-- 28. Investor, stock, invested amount, current value, balance
WITH latest_price AS (
    SELECT stock_id, close_price
    FROM market_data
    WHERE (stock_id, trade_date) IN (
        SELECT stock_id, MAX(trade_date) FROM market_data GROUP BY stock_id
    )
)
SELECT i.name, s.stock_symbol, 
       ph.quantity * ph.avg_buy_price AS invested,
       ph.quantity * lp.close_price AS current_value,
       (ph.quantity * lp.close_price) - (ph.quantity * ph.avg_buy_price) AS balance
FROM portfolio_holdings ph
JOIN portfolios p ON ph.portfolio_id = p.portfolio_id
JOIN investors i ON p.investor_id = i.investor_id
JOIN stocks s ON ph.stock_id = s.stock_id
JOIN latest_price lp ON s.stock_id = lp.stock_id;

-- 29. All investors even if they never traded (LEFT JOIN)
SELECT i.name, COUNT(t.trade_id) AS trade_count
FROM investors i
LEFT JOIN trades t ON i.investor_id = t.investor_id
GROUP BY i.investor_id;

-- 30. Sector‑wise total revenue (sum of trade value)
SELECT c.sector, SUM(t.quantity * t.price) AS total_revenue
FROM trades t
JOIN stocks s ON t.stock_id = s.stock_id
JOIN companies c ON s.company_id = c.company_id
GROUP BY c.sector;
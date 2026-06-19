# 📊 Stock Market Database – SQL Portfolio Project

## 📌 Overview
This repository contains a complete **MySQL project** that models a **stock market trading ecosystem**.  
It includes:
- **15 normalized tables** covering investors, companies, stocks, brokers, trades, portfolios, dividends, watchlists, analyst ratings, IPOs, market data, and more.
- **100 synthetic rows** per table (generated with pure SQL – no external scripts).
- **30 analytical tasks** (queries) that answer real‑world business questions – from top traders and trending stocks to sector performance and portfolio valuation.

This project demonstrates **proficiency in SQL** – from schema design and data insertion to complex joins, aggregations, window functions, and CTEs.  
It is **100% self‑contained** and runs on **MySQL 5.7+** (or MariaDB 10.2+).

---

## 🧰 Technologies
- **Database**: MySQL (tested on 8.0, compatible with 5.7+)
- **Language**: SQL (DDL, DML, DQL)
- **Tools**: MySQL Workbench, command‑line client, or any SQL executor

---

## 📁 Database Schema (15 Tables)

The schema follows a star‑like design with clear foreign‑key relationships:

| Table               | Description |
|---------------------|-------------|
| `investors`         | Individual traders / users |
| `companies`         | Publicly traded companies |
| `stocks`            | Stock symbols linked to companies |
| `brokers`           | Brokerage firms with commission rates |
| `portfolios`        | One portfolio per investor |
| `trades`            | Buy/sell transactions (with trade & settlement dates) |
| `dividends`         | Dividend payments per company |
| `watchlist`         | Stocks followed by investors |
| `portfolio_holdings`| Current holdings (quantity & average buy price) |
| `market_data`       | Daily OHLC (Open, High, Low, Close) and volume |
| `stock_splits`      | Split history |
| `analyst_ratings`   | Ratings and target prices from analyst firms |
| `ipo`               | IPO details of companies |
| `sector_performance`| Quarterly sector returns |
| `transactions`      | Cash journal entries (debit/credit) |

---

## 🚀 Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/stock-market-sql.git
cd stock-market-sql

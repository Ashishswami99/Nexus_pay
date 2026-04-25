# Nexus Pay 💳

### Tech Stack:
![SQL](https://img.shields.io/badge/SQL-003B57?style=for-the-badge&logo=postgresql&logoColor=white)
![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)

![MySQL](https://img.shields.io/badge/Database-MySQL-blue?style=for-the-badge&logo=mysql)
![SQL](https://img.shields.io/badge/Language-SQL-orange?style=for-the-badge&logo=databricks)
![PowerBI](https://img.shields.io/badge/Analytics-Power%20BI-yellow?style=for-the-badge&logo=powerbi)
![Git](https://img.shields.io/badge/Version%20Control-Git-red?style=for-the-badge&logo=git)
![Status](https://img.shields.io/badge/Status-Active-green?style=for-the-badge)

> A fully structured relational database for a modern digital payment platform — supporting wallets, UPI transactions, fraud detection, merchant payments, loans, cashback, and customer support. Built with SQL and designed for Power BI analytics and reporting.

---

## 📌 Table of Contents

- [About the Project](#-about-the-project)
- [Power BI Analytics](#-power-bi-analytics)
- [Database Schema](#-database-schema)
- [Tables Overview](#-tables-overview)
- [Key Features](#-key-features)
- [Getting Started](#-getting-started)
- [Sample Data](#-sample-data)
- [Tech Stack](#-tech-stack)
- [Author](#-author)

---

## 📖 About the Project

**NexusPay** is a digital payment system database designed to handle real-world financial operations. It models the complete backend data layer of a UPI-based payment application similar to PhonePe, Google Pay, or Paytm.

The database is built using **SQL (MySQL)** and structured to support **Power BI dashboards** for business intelligence and financial analytics.

The database covers:
- User registration and KYC verification
- Digital wallet management with UPI handles
- Bank account linking
- Merchant payments across categories
- Transaction processing with status tracking
- Fraud detection and risk scoring
- Services like loans, cashback, coupons, and autopay
- Customer support tickets and user reviews

---

## 📊 Power BI Analytics

This database is designed to connect directly with **Microsoft Power BI** for visual reporting and business intelligence.

### 📈 Suggested Power BI Dashboards

| Dashboard | Key Metrics |
|-----------|-------------|
| **Transaction Overview** | Total transactions, success rate, failed payments |
| **Revenue Report** | Total fees collected, net amount processed |
| **User Analytics** | New users, KYC status, active vs suspended accounts |
| **Fraud Detection Report** | Flagged transactions, risk scores, blocked users |
| **Merchant Performance** | Top merchants, category-wise payments |
| **Wallet & Balance Report** | Total wallet balance, UPI usage statistics |
| **Support Ticket Analysis** | Open vs resolved tickets, average rating |
| **Cashback & Offers Report** | Cashback distributed, coupons used, autopay trends |

### 🔗 How to Connect Power BI to This Database

1. Open **Power BI Desktop**
2. Click **Get Data → MySQL Database**
3. Enter your **Server** and **Database name** (`nexuspay`)
4. Select the tables you need
5. Click **Load** and start building dashboards! ✅

---

## 🗂️ Database Schema

```
nexuspay
│
├── Users                    → Registered users with KYC & login details
├── Wallets                  → Digital wallets with UPI handles & balance
├── BankAccounts             → Linked bank accounts with IFSC codes
├── Merchants                → Merchant profiles by category
├── Transactions             → Core transaction records (send/receive/bill)
├── TransactionHistory       → Audit log of transaction status changes
├── FraudDetection           → Fraud rules, risk scoring & actions
├── Services                 → Loans, cashback, coupons, autopay
└── SupportTickets__Reviews  → Customer support tickets & app reviews
```

---

## 📋 Tables Overview

### 👤 Users
Stores registered user details including contact information, hashed PINs, account status, and KYC verification status.

| Column | Type | Description |
|--------|------|-------------|
| user_id | INT (PK) | Unique user identifier |
| full_name | VARCHAR | User's full name |
| phone | VARCHAR | Unique mobile number |
| email | VARCHAR | Unique email address |
| login_pin_hash | VARCHAR | Hashed login PIN |
| transaction_pin_hash | VARCHAR | Hashed transaction PIN |
| account_status | ENUM | active / inactive / suspended |
| kyc_status | ENUM | verified / pending / rejected |

---

### 👛 Wallets
Each user has one digital wallet linked to their account with a unique UPI handle.

| Column | Type | Description |
|--------|------|-------------|
| user_wallet_id | INT (PK) | Unique wallet ID |
| user_id | INT (FK) | Linked user |
| balance | DECIMAL | Current wallet balance |
| upi_handle | VARCHAR | Unique UPI ID |
| is_active | BOOLEAN | Wallet active status |

---

### 🏦 BankAccounts
Users can link multiple bank accounts. One can be marked as primary.

| Column | Type | Description |
|--------|------|-------------|
| bank_id | INT (PK) | Unique bank account ID |
| bank_name | VARCHAR | Name of the bank |
| account_number | VARCHAR | Bank account number |
| ifsc_code | VARCHAR | IFSC code for transfers |
| is_primary | BOOLEAN | Primary account flag |

---

### 🏪 Merchants
Merchant profiles categorized by business type (food, telecom, healthcare, etc.)

| Column | Type | Description |
|--------|------|-------------|
| merchant_id | INT (PK) | Unique merchant ID |
| merchant_name | VARCHAR | Business name |
| category | VARCHAR | Business category |
| user_id | INT (FK) | Linked user account |

---

### 💸 Transactions *(Core Table)*
The heart of the system — records every financial transaction.

| Column | Type | Description |
|--------|------|-------------|
| txn_id | INT (PK) | Unique transaction ID |
| txn_ref | VARCHAR | Unique transaction reference |
| txn_type | ENUM | send / request / bill_pay / cashback |
| amount | DECIMAL | Transaction amount |
| fee | DECIMAL | Platform fee |
| net_amount | DECIMAL | Auto-calculated (amount - fee) |
| status | ENUM | processing / success / failed |

---

### 📜 TransactionHistory
Audit trail that tracks every status change in a transaction lifecycle.

---

### 🚨 FraudDetection
Monitors transactions for suspicious activity using rules based on amount, velocity, location, and device.

| Column | Type | Description |
|--------|------|-------------|
| rule_type | ENUM | amount / velocity / location / device |
| risk_score | INT | Calculated risk score |
| action_taken | ENUM | flag / block / verify |
| fraud_status | ENUM | flagged / confirmed / cleared |

---

### 🎁 Services
Flexible table handling multiple service types in one place:
- **Coupons** — promo codes with discount percentages
- **Cashback** — cashback amounts on transactions
- **Loans** — loan amounts with interest rates
- **Autopay** — recurring payments with frequency & due dates
- **Discounts** — merchant-specific discount offers

---

### 🎫 SupportTickets & Reviews
Combined table for customer support tickets and user feedback/ratings.

| Column | Type | Description |
|--------|------|-------------|
| issue_type | VARCHAR | Type of issue reported |
| status | ENUM | open / in_progress / resolved |
| rating | INT | User rating (1–5) |
| feedback_text | TEXT | Written review |

---

## ✨ Key Features

- ✅ **Full Relational Design** — All tables connected via foreign keys
- ✅ **UPI Support** — Unique UPI handle per wallet
- ✅ **Auto-Calculated Fields** — `net_amount` generated automatically
- ✅ **KYC System** — User verification workflow built-in
- ✅ **Fraud Detection** — Risk scoring with rule-based flagging
- ✅ **Transaction Audit Log** — Full history of status changes
- ✅ **Multi-Service Support** — Loans, cashback, coupons, autopay in one table
- ✅ **Support System** — Tickets + reviews combined
- ✅ **Sample Data Included** — 50 users, merchants, transactions & more
- ✅ **Power BI Ready** — Structured for direct dashboard integration

---

## 🚀 Getting Started

### Prerequisites
- MySQL 8.0 or higher
- MySQL Workbench / phpMyAdmin / DBeaver (any SQL client)
- Power BI Desktop *(for analytics & dashboards)*

### Installation

**Step 1 — Clone the repository:**
```bash
git clone https://github.com/Ashishswami99/Nexus_pay.git
```

**Step 2 — Open your MySQL client and run the SQL file:**
```bash
mysql -u root -p < "Nexus pay.sql"
```

**Or import manually:**
1. Open MySQL Workbench
2. Go to **Server → Data Import**
3. Select `Nexus pay.sql`
4. Click **Start Import**

**Step 3 — Verify the database:**
```sql
USE nexuspay;
SHOW TABLES;
```

**Step 4 — Connect to Power BI:**
1. Open Power BI Desktop
2. Click **Get Data → MySQL Database**
3. Connect to `nexuspay`
4. Build your dashboards!

---

## 📊 Sample Data

The database comes pre-loaded with realistic sample data:

| Table | Records |
|-------|---------|
| Users | 50 |
| Wallets | 50 |
| BankAccounts | 50+ |
| Merchants | 50 |
| Transactions | 50 |
| Services | 50 |
| SupportTickets & Reviews | 50 |

---

## 🛠️ Tech Stack

| Technology | Usage |
|-----------|-------|
| **MySQL** | Primary database engine |
| **SQL** | Schema design, data manipulation & querying |
| **Power BI** | Data analytics, dashboards & visual reporting |
| **Git** | Version control |
| **GitHub** | Code hosting & collaboration |

---

## 👨‍💻 Author

**Ashish Swami**

*Data Analytics &  Science | SQL | Power BI | Python | Tableau | Deloitte*

[![GitHub](https://img.shields.io/badge/GitHub-Ashishswami99-black?style=flat&logo=github)](https://github.com/Ashishswami99)

---




# 🚗 Auto Supply Chain Risk Analytics

> End-to-end supply chain analytics project analyzing delivery performance and quality risk across 300 automobile suppliers using Python, SQL Server and Power BI. Features a weighted supplier risk scoring model built on 900K+ records from NHTSA vehicle complaints and logistics data.

---

## 📌 Table of Contents
- [Project Overview](#project-overview)
- [Business Problem](#business-problem)
- [Dashboard Preview](#dashboard-preview)
- [Dataset](#dataset)
- [Project Architecture](#project-architecture)
- [Supplier Risk Scoring Model](#supplier-risk-scoring-model)
- [Key Findings](#key-findings)
- [Tools & Technologies](#tools--technologies)
- [Project Structure](#project-structure)
- [How to Run](#how-to-run)
- [SQL Analysis Queries](#sql-analysis-queries)
- [Author](#author)

---

## 📖 Project Overview

This project simulates a real-world automobile OEM (Original Equipment Manufacturer) supply chain analytics workflow. It combines two large datasets — NHTSA vehicle complaint records and logistics order data — to build a supplier risk scoring model that helps procurement teams identify which suppliers to prioritize for audit.

The project covers the full analyst workflow:
- Raw data ingestion and cleaning in Python
- Feature engineering and risk score calculation
- Structured storage in SQL Server
- SQL-based analysis across 6 business questions
- Interactive Power BI dashboard for stakeholder reporting

---

## 💼 Business Problem

An automobile OEM sources components from 300+ suppliers across 8 countries. The procurement team has no structured way to identify which suppliers are most likely to cause production delays or quality failures.

**Key questions this project answers:**
1. Which suppliers have the worst on-time delivery performance?
2. Which component categories experience the most delays?
3. Which suppliers carry the highest combined delivery and quality risk?
4. Is delivery performance improving or worsening over time?
5. Which shipping modes are most reliable?
6. Which countries have the highest supplier risk concentration?

---

## 📊 Dashboard Preview

> 📂 **[View Full Interactive Dashboard](https://drive.google.com/file/d/1Nq6HUuBHpMj4bzZjjiM650qlRasFYvNp/view?usp=sharing)**

### Page 1 — Executive Summary
![Executive Summary](<img width="1119" height="629" alt="image" src="https://github.com/user-attachments/assets/20b6e27a-7cd9-4af5-a6b4-4186adbe502d" />
)

### Page 2 — Supplier Scorecard
![Supplier Scorecard](<img width="958" height="544" alt="image" src="https://github.com/user-attachments/assets/3307ff38-c44c-4f92-bbca-b517dd8a86b8" />
)

### Page 3 — Delay & Logistics Analysis
![Delay & Logistics](<img width="962" height="542" alt="image" src="https://github.com/user-attachments/assets/68a6c0d3-4d46-473f-a78c-e130df8318e0" />
)

### Page 4 — Risk & Defects Analysis
![Risk & Defects](<img width="964" height="536" alt="image" src="https://github.com/user-attachments/assets/bbf1a25a-1ca9-4959-9e77-9bdfe927f030" />
)

---

## 📦 Dataset

| Dataset | Source | Size | Purpose |
|---------|--------|------|---------|
| NHTSA Vehicle Complaints | [nhtsa.gov](https://www.nhtsa.gov) | 746,257 rows | Component quality & defect risk |
| DataCo Supply Chain | [Kaggle](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis) | 160,351 rows | Delivery & logistics performance |
| Supplier Master | Generated via Python | 300 rows | Supplier metadata (name, country, tier) |

**Total records analysed: ~907,000**

> **Note on data:** The DataCo dataset is a general retail supply chain dataset. Product categories were mapped to automobile component categories (Engine, Brakes, Electrical System etc.) to align with NHTSA complaint data. This is a valid analytical assumption — logistics performance patterns transfer across supply chain contexts, and NHTSA data provides the domain-specific quality signal.

---

## 🏗️ Project Architecture

```
Raw Data Sources
│
├── FLAT_CMPL.txt (NHTSA)          ──► Python Cleaning & Feature Engineering
└── DataCoSupplyChainDataset.csv   ──►        │
                                              │
                                    ┌─────────▼──────────┐
                                    │  3 Clean CSV Files │
                                    │  - orders_clean    │
                                    │  - defects_clean   │
                                    │  - supplier_risk   │
                                    └─────────┬──────────┘
                                              │
                                    ┌─────────▼──────────┐
                                    │   SQL Server DB    │
                                    │  auto_supply_chain │
                                    └─────────┬──────────┘
                                              │
                                    ┌─────────▼──────────┐
                                    │   Power BI         │
                                    │   Dashboard        │
                                    └────────────────────┘
```

---

## 🎯 Supplier Risk Scoring Model

Each of the 300 suppliers is scored on 3 dimensions, each normalised to a 0–100 scale using MinMaxScaler:

| Dimension       | Metric                                                  | Source        | Weight  |
|-----------------|---------------------------------------------------------|---------------|---------|
| Delivery Speed  | Average delay days                                      | DataCo orders | **40%** |
| Delay Frequency | % of orders that were late                              | DataCo orders | **35%** |
| Quality Risk    | NHTSA complaint volume in supplier's component category | NHTSA data    | **25%** |

**Formula:**
```
Risk Score = (0.40 × Delay Score) + (0.35 × Delay Rate Score) + (0.25 × Defect Score)
```

**Risk Categories:**
| Score Range | Category       |
|-------------|----------------|
| ≥ 70        | 🔴 High Risk   |
| 40 – 69     | 🟡 Medium Risk |
| < 40        | 🟢 Low Risk    |

---

## 📈 Key Findings

### Delivery Performance
- **57.2%** of all orders experienced late delivery — delays are systemic across all component categories, not isolated to specific suppliers
- **Vehicle Speed Control** components had the highest delay rate at **58.5%**
- Delay rate remained consistently between **56–58%** across all months from 2015–2017, indicating a structural logistics problem rather than a seasonal one

### Supplier Risk
- **29 out of 300 suppliers** were classified as High Risk
- **AIR BAGS suppliers** dominated the top 2 highest risk positions due to both high delivery delays and the highest NHTSA complaint volumes (97,146 complaints)
- **Tier 1 suppliers** (who directly feed the assembly line) appeared in the High Risk list — a critical finding given their direct production impact

### Shipping Mode
- **First Class shipping had a 100% late delivery rate** — every single First Class shipment was delayed
- **Standard Class was the most reliable** at only 39.7% delay rate despite being the slowest and cheapest option — the OEM may be overpaying for premium shipping that performs worse

### Geographic Risk
- **China had the highest average supplier risk score (56.6)** despite having only 36 suppliers
- **India had the lowest average risk (51.5)** despite having the most suppliers (92) — Indian suppliers showed better relative reliability
- **Germany** surprisingly ranked 3rd highest in risk score (54.7)

### Defects & Quality
- **ENGINE components** had the highest total NHTSA complaints (136,136) from 2015 onwards
- **Chrysler (FCA US, LLC)** appeared most frequently in the top complained manufacturers across multiple component categories — indicating systemic quality issues
- Defect complaints peaked around **2015–2016** and showed a general declining trend through 2022

---

## 🛠️ Tools & Technologies

| Tool                      | Purpose                                                     |
|------ --------------------|-------------------------------------------------------------|
| **Python**                | Data ingestion, cleaning, feature engineering, risk scoring |
| **Pandas**                | Data manipulation and transformation                        |
| **Scikit-learn**          | MinMaxScaler for metric normalisation                       |
| **SQL Server (Express)**  | Structured data storage and analysis                        |
| **SSMS**                  | SQL query development and database management               |
| **Power BI**              | Interactive dashboard and data visualisation                |
| **Jupyter Notebook**      | Development environment                                     |

---

## 📁 Project Structure

```
auto-supply-chain-risk-analytics/
│
├── automobile_supply_chain_analytics.ipynb   # Complete Python pipeline
├── analysis_queries.sql                       # 6 SQL analysis queries
├── README.md                                  # This file
│
└── screenshots/
    ├── page1_executive_summary.png
    ├── page2_supplier_scorecard.png
    ├── page3_delay_logistics.png
    └── page4_risk_defects.png
```

> **Note:** Raw data files (FLAT_CMPL.txt, DataCoSupplyChainDataset.csv) and output CSVs are not included due to file size. Download links are provided in the Dataset section above. The Power BI .pbix file is hosted externally due to GitHub's 25MB file size limit — access it via the dashboard link at the top of this README.

---

## ▶️ How to Run

### Prerequisites
- Python 3.8+
- Libraries: `pandas`, `numpy`, `scikit-learn`
- SQL Server Express + SSMS
- Power BI Desktop

### Step 1 — Download Raw Data
- Download `FLAT_CMPL.txt` from [nhtsa.gov](https://www.nhtsa.gov/complaints) (Flat Files section)
- Download `DataCoSupplyChainDataset.csv` from [Kaggle](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis)
- Place both files in the same folder as the notebook

### Step 2 — Run Python Notebook
```bash
jupyter notebook automobile_supply_chain_analytics.ipynb
```
Run all cells top to bottom. This generates 3 clean CSV files:
- `supplier_risk_scores.csv`
- `orders_clean.csv`
- `defects_clean.csv`

### Step 3 — Set Up SQL Server
```sql
CREATE DATABASE auto_supply_chain;
```
Import the 3 CSV files using SSMS Table Data Import Wizard into the `auto_supply_chain` database.

### Step 4 — Run SQL Queries
Open `analysis_queries.sql` in SSMS and run each query against the `auto_supply_chain` database.

### Step 5 — View Dashboard
Download the Power BI file from the [dashboard link](https://drive.google.com/file/d/1Nq6HUuBHpMj4bzZjjiM650qlRasFYvNp/view?usp=sharing) and open in Power BI Desktop. Reconnect data source to your local SQL Server instance.

---

## 🗄️ SQL Analysis Queries

Six analytical queries are included in `analysis_queries.sql`:

| Query | Business Question                        |
|-------|------------------------------------------|
| 1     | On-Time Delivery Rate by Supplier        |
| 2     | Average Delay Days by Component Category |
| 3     | Top 10 Highest Risk Suppliers            |
| 4     | Monthly Order Volume and Delay Trend     |
| 5     | Delay Rate by Shipping Mode              |
| 6     | Supplier Risk Summary by Country         |

---

## 👤 Author

**Avinash Jha**  

---

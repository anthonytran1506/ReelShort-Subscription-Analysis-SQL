# 🎬 ReelShort Subscription Analysis (2020)

**Prepared by:** Nguyen Khanh Toan (Anthony) Tran

**Platform:** [ReelShort](https://reelshort.com) — Mobile-first short-form video streaming

**Reporting Period:** Full year 2020 until 30/04/2021

**Scope:** Subscription performance, churn behavior, upgrade paths, customer lifecycle

---

## 📖 Project Summary

This project delivers a **comprehensive subscription analysis** for ReelShort, a short-form video streaming platform. Using SQL-based analytics, we investigated user behavior, plan transitions, churn patterns, and revenue recognition strategies to support business growth and **data-driven decision-making**.

### 🔍 Goals:

* Uncover patterns in **user acquisition**, **trial conversion**, and **retention**
* Understand **upgrade/downgrade** behaviors and long-term engagement
* Estimate **revenue** through a simulated payment model
* Recommend churn-reducing strategies via data-backed insights

---

## 📊 Data Insights Summary

### 📅 Key User Behavior Stats:

| Metric                                  | Insight                                                |
| --------------------------------------- | ------------------------------------------------------ |
| **Top Signup Month**                    | March 2020                                             |
| **Churn Rate**                          | \~30% total; **9.2%** churned immediately post-trial   |
| **Trial Conversion**                    | Only **2.2%** of users remained on Trial plan          |
| **Average Time to Annual Plan Upgrade** | \~105 days                                             |
| **Most Popular Plan**                   | 🥇 Pro Monthly (37.7%), followed by Pro Annual (34.1%) |

### 📌 Subscription Plan Preferences:

* **Pro Monthly (37.7%)** – Most common choice, highlighting desire for flexibility and premium content
* **Pro Annual (34.1%)** – Indicates long-term value realization and commitment
* **Basic Monthly (25.9%)** – Attracts cautious, price-sensitive users
* **Trial Plan (2.2%)** – Rarely retained, suggesting effective trial-to-paid conversion tactics

---

## 📈 Core Metrics & Frameworks

### 💡 Key Performance Indicators:

* **Monthly Active Users (MAU)** – Monitor engagement trends
* **Monthly Recurring Revenue (MRR)** – Evaluate revenue over time
* **Churn Rate** – Detect drop-offs and retention challenges
* **Customer Lifetime Value (CLV)** – Estimate long-term profitability
* **Trial-to-Paid Conversion Rate** – Gauge onboarding and value perception

### 🔎 Behavioral Pathways to Track:

| Pathway                   | Description                                                               |
| ------------------------- | ------------------------------------------------------------------------- |
| **Trial to Subscription** | Analyze login frequency, content accessed, and trial length               |
| **Plan Upgrade Trends**   | Track how users move between Basic, Pro Monthly, and Pro Annual           |
| **Pre-Churn Signals**     | Identify early warning signs such as reduced activity or feature drop-off |

---

## 💳 Revenue Modeling: Simulated Payment Table

To simulate real-world billing and revenue, a **synthetic payment model** was built with:

* 📆 **Consistent billing cycles**
* ⏫ **Pro-rated upgrades**
* 🔁 **Deferred annual upgrades**
* ❌ **No payment after churn**

This approach allows more accurate estimation of **MRR and revenue fluctuations**.

---

## 🧠 Strategic Recommendations

### 🛠️ Product & Pricing

* Promote value of **Pro Annual** with bundled benefits and visible savings
* Use **countdown prompts** near trial expiry to encourage conversion
* Test **student/regional discounts** to increase inclusivity

### 📤 Re-engagement & Retention

* Trigger **personalized nudges** based on inactivity or downgraded usage
* Use **behavioral data** to segment high-risk churn customers
* Send **post-trial follow-up emails** with limited-time offers

### 💬 Exit Survey Framework

| Question                        | Purpose                                           |
| ------------------------------- | ------------------------------------------------- |
| Why did you cancel?             | Classify churn reasons: cost, content, UX, etc.   |
| What could we have done better? | Collect qualitative insight                       |
| Would you return? (1–10 scale)  | Measure goodwill & future re-engagement potential |

---

## 🧰 Tools & Technologies

| Tool                                 | Usage                                             |
| ------------------------------------ | ------------------------------------------------- |
| **SQL**                              | Data extraction, filtering, grouping, aggregation |
| **Simulated Payments Engine**        | Modeled realistic billing flow                    |
| **SWOT Analysis**                    | Assessed strategic levers to reduce churn         |
| **Data Visualization** *(Not shown)* | For internal charts and metric dashboards         |

---

## 🧾 Sample SQL Snippet (Conceptual)

```sql
-- How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
SELECT COUNT (*) AS churn_after_trial, ROUND(COUNT(*)::numeric/1000, 2) AS churn_after_trial_percentage
FROM (
SELECT customer_id
FROM subscriptions
GROUP BY customer_id
HAVING COUNT(DISTINCT plan_id) = 2
  		AND COUNT( DISTINCT CASE WHEN plan_id IN (0, 4) THEN plan_id END) = 2
) as sub;

```

---

## 🚀 Outcome & Impact

The analysis highlights **clear business opportunities**:

* Reduce churn with smarter UX and targeted messaging
* Grow revenue by converting monthly users to annual plans
* Enhance product-market fit by identifying key value drivers

📌 These findings help **ReelShort**:

* Make evidence-based product decisions
* Understand user behavior deeply
* Design retention and monetization strategies effectively


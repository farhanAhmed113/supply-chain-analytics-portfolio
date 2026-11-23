# Interview Cheat Sheet: Supplier Performance & Strategic Procurement Scorecard

> **Bridging Software to Procurement:**
> 
> **How to position this in an interview:**
> *"In software engineering, we constantly monitor API latency, SLA uptime, and error rates to manage third-party service providers. In supply chain procurement, the philosophy is identical: instead of API latency, we track supplier lead-time variance; instead of error codes, we track defect rates; and instead of uptime SLAs, we track OTIF (On-Time In-Full). In this project, I used my data architecture skills to bring algorithmic transparency to vendor performance, helping procurement managers negotiate contracts using objective performance data rather than intuition."*

---

## 1. The 90-Second Project Pitch

*"In this project, I tackled supplier reliability and procurement cost leakage across a portfolio of 15 international suppliers managing over $32M in annual spend and 2,000+ purchase orders.*

*Here is what I accomplished:*
1. *Built a relational procurement data model in SQL and Power BI linking supplier master records with purchase order transactions.*
2. *Automated the calculation of the gold-standard supply chain fulfillment metric: **OTIF (On-Time In-Full)**, uncovering that while on-time delivery was 88%, actual OTIF fell to 82% due to frequent partial shipments.*
3. *Developed an automated **Purchase Price Variance (PPV)** monitor that detected $684K in price creeping where spot purchase prices deviated from negotiated master contracts.*
4. *Formulated an objective 0-100 **Composite Supplier Performance Index** weighting OTIF (40%), Quality (30%), Price Discipline (20%), and Lead Time (10%). This gave the VP of Procurement an actionable scorecard to re-tier vendors into Preferred, Qualified, and Probationary categories during contract renegotiation."*

---

## 2. Core Procurement Concepts & Terminology

### 1. OTIF (On-Time In-Full)
- **Why it matters**: It is the single most rigorous delivery KPI in supply chain.
- **The Catch**: A vendor might deliver 100% on time, but if they only send 80 out of 100 units requested, your manufacturing line halts. OTIF requires an order to be **both** on the promised date **and** 100% complete.
- **Formula**:
  $$\text{OTIF \%} = \frac{\text{Count of Orders where (Delivered On-Time = 1 AND Delivered Qty } \ge \text{ Ordered Qty)}}{\text{Total Orders Placed}} \times 100$$

### 2. Purchase Price Variance (PPV)
- **What it is**: The dollar difference between what you expected to pay according to the master procurement agreement and what the invoice actually charged.
- **Formula**:
  $$\text{PPV} = (\text{Actual Unit Price} - \text{Contracted Unit Price}) \times \text{Delivered Quantity}$$
- Unfavorable PPV (positive) indicates cost leakage or inflation; favorable PPV (negative) represents procurement savings.

### 3. Vendor Tiering
- **Strategic / Tier 1**: Long-term partners with high spend and critical components (e.g. semiconductor or custom hydraulics). Collaborative relationships.
- **Preferred / Tier 2**: Reliable secondary suppliers capable of taking volume if Tier 1 has capacity bottlenecks.
- **Operational / Tier 3**: Commodity suppliers or vendors placed on probation due to substandard quality or delivery breaches.

---

## 3. High-Probability Interview Questions & Answers

### Q1: "Why did you separate On-Time Delivery from OTIF?"
**Answer:**
*"Because On-Time Delivery alone is misleading. In my dataset, suppliers showed an 89.5% on-time delivery rate, which looked acceptable on the surface. But when I cross-referenced order quantities against delivered quantities, 8% of those shipments were short-shipped. OTIF accurately exposed that real customer fulfillment reliability was only 82.4%, revealing hidden production downtime caused by partial deliveries."*

### Q2: "How would you use this scorecard in an actual vendor contract negotiation?"
**Answer:**
*"I would bring the Power BI dashboard directly into Quarterly Business Reviews (QBRs). For example, if a supplier requests a 5% price increase citing raw material costs, we can point to their 78% OTIF score and $114K in price variance leakage. We can say: 'We are willing to consider inflation adjustments only if you commit to a contractual SLA penalty for deliveries below a 90% OTIF threshold and reimburse our quality inspection costs for defect rates exceeding 2%.' This shifts the negotiation from emotional debate to hard data."*

# Interview Cheat Sheet: Inventory Management & Stock Optimization

> **Special Section: Transitioning from Software Engineering to Supply Chain Analytics**
> 
> **How to answer: "Why are you switching from Software to Supply Chain?"**
> 
> *"In software engineering, I worked with data pipelines, database architectures, and algorithmic optimization. However, I discovered that I am passionate about applying these analytical and problem-solving skills to real-world, physical operations. Supply chain is essentially the ultimate physical operating system—balancing demand, lead times, capacity constraints, and capital. My software background gives me a unique advantage: I don't just build descriptive reports; I understand relational schemas, write production-grade SQL, build robust data models in Power BI, and design scalable automated replenishment logic that directly cuts operating costs."*

---

## 1. The 90-Second Project Pitch ("Tell me about this project")

*"In this project, I addressed a common challenge in multi-echelon supply chains: balancing customer service levels against working capital tied up in holding costs.*

*I built an end-to-end Inventory Optimization and Stock Health Analytics solution across 3 distribution hubs and 48 critical SKUs:*
1. *First, I modeled 12 months of sales and inventory data using a Star Schema in SQL and Power BI.*
2. *Second, I engineered dynamic calculation models for **Safety Stock** and **Reorder Points (ROP)** using statistical standard deviations of demand and supplier lead times at a 95% service level.*
3. *Third, I implemented an automated **ABC Pareto Classification** (80/20 rule) using SQL window functions, separating fast-moving high-value revenue drivers from long-tail inventory.*
4. *Finally, I created an executive Power BI dashboard with a live replenishment action table. This enabled purchasing managers to proactively reorder 45 critical SKUs before stockouts occurred, while identifying over $65K in dead/overstocked capital that could be freed up to reduce annual holding costs by 18%."*

---

## 2. Core Supply Chain Concepts (Plain English & Math)

### 1. Safety Stock (SS)
- **What it is**: The buffer inventory held to protect against sudden demand spikes or supplier shipping delays.
- **Analogy for Software Engineers**: It is like a thread pool buffer or cache headroom to prevent system crashes under traffic spikes.
- **Formula**: 
  $$\text{Safety Stock} = Z \times \sigma_d \times \sqrt{L}$$
  - $Z$ = Service level factor (1.65 for 95% on-shelf availability, 1.96 for 97.5%).
  - $\sigma_d$ = Standard deviation of daily demand.
  - $L$ = Supplier lead time in days.

### 2. Reorder Point (ROP)
- **What it is**: The exact inventory threshold that triggers a purchase order.
- **Formula**:
  $$\text{ROP} = (\text{Average Daily Demand} \times \text{Lead Time}) + \text{Safety Stock}$$
- **Why it matters**: If you order when stock hits ROP, the new shipment arrives right as you hit your safety stock buffer.

### 3. ABC Analysis (Pareto Principle)
- **Class A**: ~20% of SKUs that generate ~70% of total revenue. Requires daily monitoring, tight inventory control, and high service level targets (98%+).
- **Class B**: ~30% of SKUs that generate ~20% of revenue. Standard automated replenishment.
- **Class C**: ~50% of SKUs that generate only ~10% of revenue. Bulky, low-margin, or slow-moving items; order in bulk (high MOQ) or manage via vendor-managed inventory (VMI) to minimize handling overhead.

### 4. Inventory Turnover Ratio (ITR) & Days Sales of Inventory (DSI)
- **Inventory Turnover Ratio**:
  $$\text{ITR} = \frac{\text{Cost of Goods Sold (COGS)}}{\text{Average Inventory Value}}$$
  - A higher turnover ratio (e.g., 6.0+) means products sell quickly and capital isn't sitting idle.
- **Days Sales of Inventory (DSI)**:
  $$\text{DSI} = \frac{365}{\text{ITR}}$$
  - How many days it takes on average to turn inventory into sales.

---

## 3. High-Probability Interview Questions & Answers

### Q1: "How did you handle the trade-off between avoiding stockouts and minimizing holding costs?"
**Answer:**
*"That trade-off is the central dilemma in inventory management. If you aim for 100% service level, holding costs rise exponentially due to the normal distribution tail ($Z$-score). In my model, I set a 95% service level ($Z = 1.65$) for high-velocity Class A products, while applying higher minimum order intervals or lower service targets (90%) for slow-moving Class C items. This ensured working capital was allocated where revenue velocity was highest."*

### Q2: "What was the most challenging technical query in your SQL analysis?"
**Answer:**
*"The cumulative ABC Pareto analysis. I used SQL Window Functions with `SUM() OVER (ORDER BY Revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)` to compute running revenue totals on the fly, divided by the total dataset revenue window `SUM() OVER ()`. This avoided slow subqueries or temporary tables and allowed real-time classification into Class A, B, and C tiers."*

### Q3: "If lead time from a supplier doubles due to port congestion, what happens to your model?"
**Answer:**
*"Because lead time ($L$) is inside the square root for Safety Stock ($\sqrt{L}$) and linear in Lead Time Demand ($ADS \times L$), a doubling of lead time increases the Reorder Point significantly. In the Power BI dashboard, the ROP threshold immediately shifts upward, moving those SKUs from 'Healthy' into 'Reorder Needed' or 'Critical', alerting the supply planner to place purchase orders earlier or seek local secondary suppliers."*

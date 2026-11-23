# Interview Cheat Sheet: Logistics & Freight Shipment Tracking

> **Bridging Software to Logistics & Transportation:**
> 
> **How to position this in an interview:**
> *"In software engineering, distributed systems rely on network packet routing, latency tracking, retry mechanisms, and SLA monitoring. Physical logistics functions the exact same way: shipments are the packets, freight carriers (FedEx, DHL, Maersk) are the network routing protocols, and transit lanes are the transmission channels. I brought that same systems engineering mindset to logistics: monitoring transit latency, isolating lane bottlenecks, performing root-cause analysis on delays, and optimizing freight spend."*

---

## 1. The 90-Second Project Pitch

*"In this project, I addressed transportation volatility and carrier SLA breaches across a multi-modal freight network covering 4,000+ dispatches, 12 major transit corridors, and $10.8M in freight spend.*

*Here is what I accomplished:*
1. *Constructed a Star Schema tracking shipments across road FTL (Full Truckload), road LTL (Less-Than-Truckload), air expedited, and ocean/intermodal modes.*
2. *Analyzed carrier compliance against contracted **On-Time Delivery (OTD)** SLAs, revealing that ground carriers missed their contracted 91% OTD SLA by an average of 4.2% on long-haul transit routes (>1,000 miles).*
3. *Performed a **Root-Cause Pareto Analysis** across 500+ delay incidents, discovering that 52% of all late shipments originated from port/customs congestion and severe weather bottlenecks, rather than carrier driver performance.*
4. *Delivered an executive Power BI dashboard with lane-level heatmaps and **Cost-per-Ton-Mile** metrics, uncovering that emergency expedited freight spending consumed $1.4M in avoidable premiums due to upstream warehouse order release delays."*

---

## 2. Core Logistics Terminology & Key Math

### 1. On-Time Delivery (OTD %)
- **Formula**:
  $$\text{OTD \%} = \frac{\text{Shipments Delivered On or Before Estimated Date}}{\text{Total Shipments Dispatched}} \times 100$$
- Evaluates freight carrier SLA compliance.

### 2. Ton-Mile Economics
- **Definition**: A standard freight measurement unit representing one ton (1,000 kg / 2,000 lbs) moved one mile.
- **Formula**:
  $$\text{Cost per Ton-Mile} = \frac{\text{Total Freight Cost}}{\sum (\text{Weight in Tons} \times \text{Distance in Miles})}$$
- **Why it matters**: It allows fair cost comparisons across wildly different transport modes: Air freight is high cost per ton-mile ($3-$5/ton-mile); Intermodal/Rail is low cost ($0.50-$1.00/ton-mile).

### 3. FTL vs. LTL
- **FTL (Full Truckload)**: The entire 53ft semi-trailer is booked for one shipper. Faster, direct from origin to destination with no intermediate stops.
- **LTL (Less-Than-Truckload)**: Multiple shippers share the same trailer through a hub-and-spoke terminal network. Cheaper for smaller pallet shipments (under 10,000 lbs), but higher risk of terminal handling delays.

---

## 3. High-Probability Interview Questions & Answers

### Q1: "How did you identify which routes were true operational bottlenecks?"
**Answer:**
*"In SQL and Power BI, I calculated both the delay frequency (% of dispatches delayed) and average delay severity (days late per delayed shipment). For example, the Los Angeles Port to Chicago lane (Route RT-107, 2,015 miles) had an average delay of 1.4 days per delayed load, driven by intermodal railyard congestion. By isolating this lane, logistics planners were able to shift critical time-sensitive shipments to expedited team-driver FTL, bypassing rail transfer delays."*

### Q2: "What was the most surprising insight from your delay root-cause analysis?"
**Answer:**
*"Many internal stakeholders initially blamed carrier drivers for missed deliveries. However, when I classified the delay reasons, 'Driver & Labor Shortage' accounted for only 20% of delays. The majority (52%) was driven by port/customs congestion at international entry ports and severe weather incidents along the Midwest corridor. This shifted management's strategy from penalizing carriers to building dynamic transit buffers during winter storm seasons and diversifying import ports away from congested single terminals."*

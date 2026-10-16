# Brazilian E-Commerce Market Entry Feasibility Study
## Strategic Assessment & Logistics Risk Analysis of Magist for ENIAC
**Author:** Team Electricity (Data Analytics & BI Strategy Consulting)<br>
**Deliverables:** [Executive Presentation (PDF)](presentation/market_entry_strategy.pdf) | [Executive Briefing Memo (PDF)](docs/market_entry_feasibility_assessment_magist.pdf) | [Master SQL Script](sql/magist_deep_data_analysis.sql) | [Tableau Workbooks](tableau/)

---

## 1. Executive Summary & Strategic Verdict

ENIAC, a European retailer specializing in premium consumer electronics and Apple-compatible hardware (average order value **€710**), evaluated an international marketplace expansion into Brazil via the **Magist** e-commerce platform.

```
                     STRATEGIC BOARD VERDICT: NO-GO ON FLAGSHIP HARDWARE (> €500)
┌──────────────────────────────────────┬──────────────────────────────────────┬──────────────────────────────────────┐
│        Return on Investment          │           Brand Reputation           │        Customer Satisfaction         │
├──────────────────────────────────────┼──────────────────────────────────────┼──────────────────────────────────────┤
│ • Avg Order Price: €124 vs €710      │ • Delivery lead times reach 27 days  │ • Reviews collapse: 4.13 → 1.70★     │
│ • Flagship Tech: < 23 units/mo nat'l │ • Uncontrolled postal courier transit│ • Average 10-day delay when late     │
│ • Regulatory & setup costs exceed GM │ • High freight theft / escort costs  │ • Logistics failure hurts brand trust│
└──────────────────────────────────────┴──────────────────────────────────────┴──────────────────────────────────────┘
                  VIABLE ALTERNATIVE: Phased Accessories Pilot (€50–€150) in São Paulo Corridor
```

### Strategic Board Recommendation: **NO-GO on Flagship Hardware**
- **Massive Basket Value Disconnect (AOV Gap):** Magist operates as an everyday commodity marketplace. Its tech category average order value sits at **~€124**, compared to ENIAC’s **€710** European benchmark.
- **Extreme Volume Skew Toward Budget Accessories:** Products priced above €500 accounted for only **565 total units sold across 25 months** — representing just **3.3% of tech sales** and fewer than **23 sales per month nationwide** across all 490+ sellers combined. In contrast, **83.6% of all tech units sold** fall into Budget Essentials (≤ €50) and Standard Accessories (€51 – €150).
- **Statistical Price Median (€49.50 vs €110 Mean):** A statistical percentile query reveals that the **median price of a tech product sold on Magist is €49.50**. Over half of all platform tech purchases cost less than €50, confirming the market is anchored in cheap cables, cases, and adapters rather than high-ticket computing hardware.
- **Fulfillment Friction & SLA Violations:** Nationwide deliveries average **13 days** and stretch up to **27 days** in the Northern and Northeastern territories. While Magist sets a generous estimated delivery date (ETA) buffer of **25 days**, orders that breach this window arrive an additional **10 days late on average** (total customer wait time of 5 to 6 weeks).
- **Severe Review Decay:** Deliveries completed on time maintain an average rating of **4.13 stars**. When an order is delayed, review scores crash to **2.58 stars**, falling to **1.70 stars** for undelivered shipments. Late deliveries account for **25.5% of all analyzed customer complaints**.

---

## 2. Core Business Benchmarks & Platform Realities

| Strategic Metric | Magist Platform Data (Reality) | ENIAC Commercial Requirement | Executive Verdict |
| :--- | :--- | :--- | :--- |
| **Gross Marketplace Volume** | €13.59M Total GMV (€1.90M Tech; ~14% share) | High-velocity tech volume | ❌ High platform concentration on non-tech commodities |
| **Tech Average Order Price** | ~€124 per tech order | €710 (ENIAC catalog baseline) | ❌ Mismatch in target demographic purchasing power |
| **Median Tech Product Price** | **€49.50** (Mean: €110.16) | Premium device spend | ❌ 50%+ of catalog volume sits below €50 |
| **Flagship Hardware Demand** | 567 units sold in 2 years (> €500) | Rapid hardware deployment | ❌ Under 23 units/month across all Brazil sellers |
| **Active Tech Sellers** | 493 sellers (15.9% of 3,095 sellers) | Scaled enterprise retail partners | ❌ Sellers average only ~€150/month in revenue |
| **Delivery Transit Duration** | 13 days nat'l avg (8–10d Southeast; 27d North) | 2–4 business days SLA | ❌ Deep regional infrastructure divide |
| **Promised Delivery ETA** | 25 days average buffer | Competitive fulfillment promise | ⚠️ Excessive delivery padding masks courier latency |
| **Delay Latency (When Late)** | +10 days additional transit past 25-day ETA | Strict SLA breach guarantees | ❌ Total customer wait reaches 5–6 weeks |
| **Customer Review Decay** | 4.13★ (On Time) → 2.58★ (Delayed) → 1.70★ (Lost) | Premium brand perception ≥ 4.5★ | ❌ Direct brand equity destruction from logistics failures |

---

## 3. Product Catalog Segmentation & Unit Economics

Products across the 10 ENIAC-relevant tech categories (`computers_accessories`, `computers`, `pc_gamer`, `tablets_printing_image`, `telephony`, `fixed_telephony`, `electronics`, `audio`, `cine_photo`, `consoles_games`) were modeled across 5 price tiers:

| Price Tier | Category Definition & Typical Hardware | Units Sold | Share % | Revenue (€) | Avg Freight | Min Freight | Max Freight | Tech Seller Income |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Ultra-Premium Tech** | MacBooks, iPhone Pro Max, Gaming PCs, Cameras (> €1,000) | 208 | 1.2% | €321,010 | €41.70 | €0.21 | €193.21 | €321.01 / mo |
| **Premium Hardware** | Base iPhones, iPads, 4K Monitors, Ultrabooks (€501–€1,000) | 359 | 2.1% | €253,718 | €37.92 | €11.34 | €157.27 | €142.94 / mo |
| **Mid-Range Tech** | AirPods Pro, Smartwatches, Thunderbolt Docks (€151–€500) | 2,303 | 13.3% | €552,218 | €21.44 | €0.37 | €127.82 | €103.22 / mo |
| **Standard Accessories** | Wireless charging stations, webcams, Apple Pencils (€51–€150) | 5,504 | 31.9% | €539,129 | €18.93 | €0.09 | €121.22 | €73.60 / mo |
| **Budget Essentials** | USB cables, basic phone cases, adapters (≤ €50) | 8,897 | 51.5% | €236,500 | €14.83 | €0.01 | €112.43 | €35.97 / mo |

*Key Takeaway: Products under €500 accounted for €1.33M in tech revenue across 25 months. Hardware above €500 generated just €575K across two full years — a market depth too shallow to support corporate entity setup.*

---

## 4. Brazilian Logistics Architecture & Regulatory Risk Analysis

### The Postal Carrier Mandate vs. Private Couriers
- **Correios Universal Coverage Mandate:** Under Brazilian federal regulations, Correios (Empresa Brasileira de Correios e Telégrafos) is the only logistics operator legally obligated to provide universal postal service across all 5,500+ municipalities.
- **The "Last-Mile Handoff":** Private express carriers (DHL Express, FedEx, Loggi, Jadlog) maintain owned delivery infrastructure primarily within the **South and Southeast "Golden Triangle" (São Paulo, Rio de Janeiro, Belo Horizonte, Curitiba, Porto Alegre)**, representing over 70% of national e-commerce spend. When private carriers accept parcels bound for interior or Northern states, they routinely fly freight to regional hubs and hand the package off to Correios for final-mile fulfillment. Private courier surcharges to remote areas inflate delivery costs without mitigating transit volatility.
- **Cargo Security (*Gerenciamento de Risco*):** Shipments of electronics valued over €500 transported by road freight require dedicated armed security escorts and specialized transit insurance under local risk-management protocols due to interstate cargo theft risks. This cost structure makes nationwide delivery of high-ticket electronics via standard parcel networks financially unviable.

### Macroeconomic & Market Dynamics (2017–2018)
- **Protective Import Tariffs:** Brazil levies substantial import tariffs (Imposto de Importação), IPI, and state-level ICMS taxes on consumer electronics. Imported flagships (such as the iPhone X) historically retailed between 5,000 and 7,000 BRL ($1,500+ USD) — nearly double global retail benchmarks — heavily favoring domestic assemblers with local tax exemptions (e.g. Samsung holding 42% volume share).
- **Macroeconomic Contraction:** An 11-day national truckers' strike in mid-2018 severed highway supply chains, and political uncertainty surrounding the September 2018 presidential elections caused domestic retail sales to contract by 1.3% month-over-month, suppressing consumer appetite for large discretionary tech purchases.

---

## 5. Visual Architecture (Tableau)

Visualizations are organized across two workbooks:

### [Workbook 1: Platform KPIs & Geographic Distribution](tableau/magist_tableau_workbook_part_1.twbx)
- **Average Delivery Days per State (Choropleth Map):** Displays the geographic delivery divide, scaling from 8–10 days in São Paulo to 27 days in Roraima and Amapá.
- **Tech Units Sold per Price Tier:** Visualizes the contrast between unit volume (83.6% under €150) and revenue yield across the 5 price tiers.
- **Regional Order Concentration:** Highlights that over 42,000 marketplace orders originate in São Paulo and the Southeast hub.
- **Monthly Revenue Growth Trends (2017–2018):** Tracks platform revenue growth, seasonality, and the 2018 macroeconomic plateau.

### [Workbook 2: Sentiment, Delivery SLAs & Customer Complaints](tableau/magist_tableau_workbook_part_2.twbx)
- **Impact of Delivery Delays on Reviews:** Categorizes shipments into *On Time* (4.13★), *Delayed* (2.58★) and *Not Delivered* (1.70★).
- **Customer Complaint Taxonomy:** Evaluates 2,401 negative customer review tickets via MySQL regex text mining, identifying delivery delays as the largest single identifiable driver (25.5% / 613 tickets).
- **Average Tech Seller Monthly Income:** Compares overall seller earnings against tech earnings across each defined price tier.

---

## 6. SQL Data Pipeline & Analytical Queries

The full analysis is documented in [`sql/magist_deep_data_analysis.sql`](sql/magist_deep_data_analysis.sql). Key queries include:
1. **Catalog & Revenue Share Identification:** Filters the 10 ENIAC-relevant tech categories, measuring sales percentages and calculating individual item vs. full basket order values.
2. **5-Tier Pricing Taxonomy & Freight Economics:** Segments units into defined price bands, calculating unit counts, revenue contribution, minimum/maximum/average freight charges and monthly seller earnings.
3. **Statistical Median Validation:** Evaluates the €49.50 median price cutoff to confirm catalog skew.
4. **Logistics & Geographic SLA Evaluation:** Measures interstate vs. intrastate lead times, average delay days and freight-to-price ratios by category.
5. **Customer Feedback Text Mining:** Applies `REGEXP` pattern matching across Portuguese review text to categorize complaints into delivery issues, defective products, wrong items or missing comments.
6. **State-Level Polygon Mapping Data Export:** Executes a multi-table join with `geo` to generate official 2-letter Brazilian state codes (`customer_state`) and macro-postal clusters for Tableau polygon mapping.

---

## 7. Strategic Recommendations & Alternative Phased Pilot

1. **Enforce Immediate Hardware No-Go:** Reject nationwide distribution of high-end consumer hardware (> €500) via Magist. The low absolute demand volume (< 23 sales/month nationwide) cannot justify Brazilian subsidiary formation, customs clearance and mandatory armed transport escorts.
2. **Execute Phased Accessories Pilot (€50–€150):** If leadership seeks entry into Latin America, initiate a targeted pilot restricted exclusively to **São Paulo State (postal prefixes 0xxxx and 1xxxx)**.
    * Focus on mid-range accessories: Apple-compatible charging stations, multi-port hubs, quality webcams and specialized styluses.
    * Maintain average transit times under 8–9 days within São Paulo to protect brand equity and preserve review ratings above 4.1 stars.
    * Utilize regional fulfillment partners in São Paulo to eliminate the risk of rural last-mile handoffs and cargo security surcharges.

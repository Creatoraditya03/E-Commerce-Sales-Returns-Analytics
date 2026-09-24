# E-Commerce-Sales-Returns-Analytics
E-commerce sales and returns analytics using SQL (JOINs, window functions, CTEs) and Power BI, built on a 6-table relational database.

### Database Structure
6 related tables modeling a realistic e-commerce backend:
`categories`, `customers`, `products`, `orders`, `order_items`, `returns` — connected via primary/foreign key relationships.

### Key SQL Techniques
Multi-table JOINs across the full schema.
Window functions (`RANK()`, `PARTITION BY`) to rank top products overall and within each category.
CTEs combined with `LAG()` to analyze revenue trends across customer signup cohorts.
Aggregate functions and `LEFT JOIN`s to calculate return rates and profit lost to returns, at both the product and category level.

### Key Findings
Overall profit margin sits at ~25%, with Food & Beverages and Toys as the top revenue-generating categories.
Return rate and revenue lost to returns vary meaningfully by category, highlighting which product lines carry the highest refund risk.
Identified the specific products with the highest return volume, offering a more actionable target than category-level trends alone.

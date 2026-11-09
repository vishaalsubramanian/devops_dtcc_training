

**Problem:** 



Order ORD0049 has "unknown" in Unit\_Price, so the column is not fully numeric.

Solution: Use pd.to\_numeric(errors="coerce") to mark it as missing and verify the price from the order record. "unknown" cannot be taken as the highest price.



**Observation:** 



The highest valid unit price is 999 for "Introduction to Data Science". The IQR check finds no numerical price outliers, so no prices need to be removed.




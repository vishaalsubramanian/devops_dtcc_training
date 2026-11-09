**Problem 1:** 



The original file has 2 repeated orders, an extra-space city/status entry, and 1 missing customer name.



**Solution:** 



Remove repeated Order\_ID records, standardize City and Delivery\_Status, and label the unknown customer name as "Unknown".





**Problem 2:** 



One Unit\_Price is "unknown" (ORD0049), and one Order\_Date is "not-a-date" (ORD0062). Other values are missing, including discount, shipping, rating, and cancelled orders' ship dates.



**Solution:** 



Use pd.to\_numeric(errors="coerce") and pd.to\_datetime(errors="coerce"); keep unverifiable values blank for review rather than inventing prices, dates, or amounts.





**Observation:** 



No numerical unit-price outliers are found using IQR. Export the 84 unique orders to bookbazaar\_orders\_2026\_cleaned.csv; unresolved missing values remain blank in the output.




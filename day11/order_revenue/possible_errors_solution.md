**Problem 1:** 



Duplicate orders can double-count revenue, and " chennai " and "Chennai" appear as different city names.



**Solution:** 



Drop repeated Order\_ID values and standardize City using str.strip().str.title() before grouping.





**Problem 2:** 



ORD0049 has an unknown price, so its revenue cannot be calculated. Cancelled, returned, and still-shipped orders should not be counted as completed sales.



**Solution:** 



Convert Unit\_Price with pd.to\_numeric(errors="coerce"), check missing revenues, and use delivered orders only. The calculation Quantity \* Unit\_Price is GROSS item revenue, before discounts and excluding shipping. Verify the missing price before treating totals as final.




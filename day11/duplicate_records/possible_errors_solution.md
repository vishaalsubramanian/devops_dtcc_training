**Problem:** 



ORD0010 and ORD0056 each occur twice, resulting in 2 extra records. This can inflate revenue and order counts.



**Solution:** 



Compare the repeated records, then use drop\_duplicates(subset="Order\_ID", keep="first"). The record count changes from 86 to 84.


**Problem 1:** 



There are 6 missing cells in 

Customer\_Name (1), Discount\_Percent (1), Shipping\_Cost (1), Ship\_Date (2), and Rating (1).



**Solution:** 



Use df.isnull().sum() to identify them. Fill the missing customer name with "Unknown" until verified.







**Problem 2:** 



Discount and shipping values are unknown; the two missing ship dates belong to cancelled orders.



**Solution:** 



Check the original order records before filling financial amounts. Leave cancelled orders' ship dates blank because they were not shipped. Leave the missing rating blank until available.




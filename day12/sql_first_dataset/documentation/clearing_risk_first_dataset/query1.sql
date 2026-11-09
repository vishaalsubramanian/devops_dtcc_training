-- Query 1: Detect duplicated trade identifiers and blank collateral records and missing settlement dates

select
    count(*) as raw_rows,
    count(distinct trade_id) as unique_trade_ids,
    count(*) - count(distinct trade_id) as duplicate_trade_rows,
    count(case when collateral_posted_usd is null then 1 end) AS missing_collateral_rows,
    count(case when actual_settlement_date is null then 1 end) AS missing_actual_settlement_dates
from clearing_risk_dataset;

-- Query 3: Exposure, trade value and unresolved settlement rate grouped by asset class.

select
    asset_class,
    count(*) as trade_count,
    round(sum(gross_trade_value_usd), 2) as total_gross_trade_value_usd,
    round(sum(net_exposure_usd), 2) as total_net_exposure_usd,
    count(case when settlement_status in ('Pending', 'Failed') then 1 end) as pending_or_failed_count,
    round(100.0 * count(case when settlement_status in ('Pending', 'Failed') then 1 end)
          / nullif(count(*), 0), 2) as pending_or_failed_pct,
    round(avg(risk_score), 2) as avg_risk_score
from dbo.clearing_risk_clean
group by asset_class
order by total_net_exposure_usd desc;

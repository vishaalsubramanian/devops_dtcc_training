-- Query 5:  To identify pending/failed high-risk trades exceeding the asset-class average
select top (10)
    a.trade_id, 
    a.asset_class, 
    a.clearing_member, 
    a.settlement_status,
    a.risk_score,
    round((select avg(1.0 * b.risk_score)
           from clearing_risk_clean as b
           where b.asset_class = a.asset_class), 2) as asset_avg_risk_score,
    a.net_exposure_usd
from clearing_risk_clean as a
where a.settlement_status in ('Pending', 'Failed')
  and a.risk_score > (
      select avg(1.0 * b.risk_score)
      from clearing_risk_clean as b
      where b.asset_class = a.asset_class
  )
order by 
    a.risk_score desc, 
    a.net_exposure_usd desc;
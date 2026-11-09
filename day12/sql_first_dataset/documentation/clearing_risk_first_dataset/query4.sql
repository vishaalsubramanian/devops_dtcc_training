-- Query 4: Identify each member's asset-class linked concentration

with member_totals as (
    select 
        clearing_member,
        sum(net_exposure_usd) as member_total_exposure_usd
    from clearing_risk_clean
    group by clearing_member
)
select top (10)
    t.clearing_member, 
    t.asset_class,
    count(*) as trade_count,
    round(sum(t.net_exposure_usd), 2) as asset_exposure_usd,
    round(m.member_total_exposure_usd, 2) as member_total_exposure_usd,
    round(100.0 * sum(t.net_exposure_usd) 
          / nullif(m.member_total_exposure_usd, 0), 2) as pct_of_member_exposure
from clearing_risk_clean as t
inner join member_totals as m
    on t.clearing_member = m.clearing_member
group by 
    t.clearing_member, 
    t.asset_class, 
    m.member_total_exposure_usd
order by 
    asset_exposure_usd desc;
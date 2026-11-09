-- Query 2: High Priority Pending/Failed Trades using filter, sort and top sql commands

select top 10
    trade_id, 
    clearing_member, 
    counterparty, 
    settlement_status, 
    asset_class,
    risk_score,
    net_exposure_usd, 
    collateral_posted_usd,
    round(
        case 
            when (net_exposure_usd - coalesce(collateral_posted_usd, 0)) > 0 
            then (net_exposure_usd - coalesce(collateral_posted_usd, 0))
            else 0 
        end, 2
    ) as indicative_collateral_gap_usd
from clearing_risk_clean
where settlement_status in ('Pending', 'Failed')
  and (risk_score >= 60 OR coalesce(collateral_posted_usd, 0) < net_exposure_usd)
order by 
    risk_score desc, 
    indicative_collateral_gap_usd desc, 
    trade_id;

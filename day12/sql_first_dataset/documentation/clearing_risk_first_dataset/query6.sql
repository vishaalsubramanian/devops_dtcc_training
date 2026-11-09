-- Query 6: Most frequent settlement exceptions and their severity.

select
    exception_reason,
    count(*) as affected_trades,
    sum(case when settlement_status = 'Failed' then 1 else 0 end) as failed_trades,
    sum(CASE WHEN settlement_status = 'Pending' then 1 else 0 end) as pending_trades,
    sum(CASE WHEN settlement_status = 'Settled Late' then 1 else 0 end) as late_trades,
    round(avg(risk_score), 2) as avg_risk_score,
    round(sum(net_exposure_usd), 2) as total_exposure_usd
from clearing_risk_clean
where exception_reason is not null
group by exception_reason
having count(*) >= 5
order by failed_trades desc, affected_trades desc;
-- Query 7: Weekly settlement backlog trends

with weekly_summary as (
    select
        cast(dateadd(week, datediff(week, 0, trade_date), 0) as date) as week_start,
        count(*) as total_trades,
        sum(case when settlement_status in ('Pending', 'Failed') then 1 else 0 end) as pending_or_failed_trades,
        round(sum(net_exposure_usd), 2) as total_exposure_usd
    from clearing_risk_clean
    group by cast(dateadd(week, datediff(week, 0, trade_date), 0) as date)
), weekly_trend as (
    select 
        week_start,
        total_trades,
        pending_or_failed_trades,
        total_exposure_usd,
        lag(pending_or_failed_trades) over (order by week_start) as previous_week_pending_or_failed
    from weekly_summary
)
select
    week_start,
    total_trades,
    pending_or_failed_trades,
    previous_week_pending_or_failed,
    pending_or_failed_trades - previous_week_pending_or_failed as change_vs_previous_week,
    total_exposure_usd
from weekly_trend
order by week_start;
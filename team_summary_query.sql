/*

 This query shown team performance per season,
 include percentage of winning, ranking, average goals,

 This query  I use to initialize my data analysis of this dataset.
 In another files I will change this query for my report propose

 */
with home_team_stats as (
    select
        m.league_id,
        m.season,
        m.home_team_api_id,
        sum(case
            when m.home_team_goal > m.away_team_goal then 1 else 0
            end) as home_match_win_count,
        avg(m.home_team_goal) as home_avg_goal,
        sum(case when m.home_team_goal > m.away_team_goal then 3
            when m.home_team_goal = m.away_team_goal then 1
            else 0 end) as home_points,
        sum(m.home_team_goal),
        count(*) as home_matches_count

    from main.Match m
    group by m.league_id, m.season, m.home_team_api_id
), away_team_stats as (
    select
        m.league_id,
        m.season,
        m.away_team_api_id,
        sum(case
            when m.home_team_goal < m.away_team_goal then 1 else 0
            end) as away_match_win_count,
        avg(m.away_team_goal) as away_avg_goal,
        sum(case
            when m.home_team_goal < m.away_team_goal then 3
            when m.home_team_goal = m.away_team_goal then 1
            else 0
            end) as away_points,
        count(*) as away_matches_count

    from main.Match m
    group by m.league_id, m.season, m.away_team_api_id
)
select
    t.team_api_id,
    l.name as league_name,
    hts.season,
    t.team_long_name,
    (hts.home_points + ats.away_points) as season_points,
    rank() over (
        partition by hts.season, l.name
        order by hts.home_points + ats.away_points desc) season_end_place,
    hts.home_points,
    (hts.home_match_win_count * 1.0 / hts.home_matches_count) * 100 as home_winning_percentage,
    hts.home_avg_goal,
    ats.away_points,
    (ats.away_match_win_count * 1.0 / ats.away_matches_count) * 100 as away_winning_percentage,
    ats.away_avg_goal

from home_team_stats hts
inner join away_team_stats ats
    on ats.away_team_api_id = hts.home_team_api_id and ats.season = hts.season
left join main.Team t
    on t.team_api_id = hts.home_team_api_id
left join main.League l
    on l.id = hts.league_id;







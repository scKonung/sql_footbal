/*

 This queries create tables, which ca nbe used to analyze
 team performance in all seasons and in all leagues,
 which are exiting in the dataset.

 In this tables you can find information such as
 winning percentage, total goals, average goal for
 home, away and both matches, which is required to
 analyze result of clubs.

 */
create table Team_Season_Home_Statistics as
    select
        m.league_id,
        m.season,
        m.home_team_api_id,
        sum(case
            when m.home_team_goal > m.away_team_goal then 1 else 0
            end) * 1.0 / count(*) * 100 as home_winning_percentage,
        avg(m.home_team_goal) as home_avg_goal,
        sum(case when m.home_team_goal > m.away_team_goal then 3
            when m.home_team_goal = m.away_team_goal then 1
            else 0 end) as home_points,
        sum(m.home_team_goal) as home_total_goals
    from main.Match m
    group by m.league_id, m.season, m.home_team_api_id;


create table Team_Season_Away_Statistics as
    select
        m.league_id,
        m.season,
        m.away_team_api_id,
        sum(case
            when m.home_team_goal < m.away_team_goal then 1 else 0
            end) * 1.0 /count(*) * 100 as away_winning_percentage,
        avg(m.away_team_goal) as away_avg_goal,
        sum(case
            when m.home_team_goal < m.away_team_goal then 3
            when m.home_team_goal = m.away_team_goal then 1
            else 0
            end) as away_season_points,
        sum(m.away_team_goal) as away_total_goals
    from main.Match m
    group by m.league_id, m.season, m.away_team_api_id;

create table Team_Season_Summary_Statistic as
    select
    hts.league_id,
    hts.season,
    hts.home_team_api_id,
    (hts.home_season_points + ats.away_season_points) as summary__points,
    rank() over (
        partition by hts.season, hts.home_team_api_id
        order by hts.home_season_points + ats.away_season_points desc) end_place,
    hts.home_season_total_goals + ats.away_season_total_goals as total_goals,
    (hts.home_avg_goal + ats.away_avg_goal) / 2 as avg_goals,
    (hts.home_winning_percentage + ats.away_winning_percentage) / 2 as winning_percentage
    from main.Team_Home_Statistics hts
    inner join main.Team_Away_Statistics ats
        on ats.away_team_api_id = hts.home_team_api_id
               and ats.season = hts.season;





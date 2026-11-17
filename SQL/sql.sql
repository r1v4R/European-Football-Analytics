CREATE VIEW team_season_summary AS
SELECT
    League,
    Season,
    Team,

    COUNT(*) AS Played,

    SUM(Result = 'Win') AS Wins,
    SUM(Result = 'Draw') AS Draws,
    SUM(Result = 'Loss') AS Losses,

    SUM(GoalsScored) AS GoalsFor,
    SUM(GoalsConceded) AS GoalsAgainst,
    SUM(GoalDifference) AS GoalDifference,
    SUM(Points) AS Points,

    ROUND(AVG(Points), 2) AS PointsPerGame,

    ROUND(
        SUM(Result = 'Win') / COUNT(*) * 100,
        2
    ) AS WinPercentage,

    ROUND(AVG(GoalsScored), 2) AS GoalsPerGame,
    ROUND(AVG(GoalsConceded), 2) AS GoalsConcededPerGame,

    ROUND(AVG(Shots), 2) AS ShotsPerGame,
    ROUND(AVG(ShotsOnTarget), 2) AS ShotsOnTargetPerGame,

    ROUND(
        SUM(ShotsOnTarget) / NULLIF(SUM(Shots), 0) * 100,
        2
    ) AS ShotAccuracy,

    ROUND(
        SUM(GoalsScored) / NULLIF(SUM(Shots), 0) * 100,
        2
    ) AS ShotConversion,

    ROUND(
        SUM(GoalsScored) / NULLIF(SUM(ShotsOnTarget), 0) * 100,
        2
    ) AS OnTargetConversion,

    ROUND(
        AVG(CASE WHEN Venue = 'Home' THEN Points END),
        2
    ) AS HomePPG,

    ROUND(
        AVG(CASE WHEN Venue = 'Away' THEN Points END),
        2
    ) AS AwayPPG,

    ROUND(
        AVG(CASE WHEN Venue = 'Home' THEN Points END)
        -
        AVG(CASE WHEN Venue = 'Away' THEN Points END),
        2
    ) AS HomeAwayPPGDifference,

    ROUND(AVG(Corners), 2) AS AvgCorners,
    ROUND(AVG(YellowCards), 2) AS AvgYellowCards,
    ROUND(AVG(RedCards), 2) AS AvgRedCards,

    SUM(IsUnderdog = 'True') AS UnderdogMatches,
    SUM(UnderdogWon = 'True') AS UnderdogWins,

    ROUND(
        SUM(UnderdogWon = 'True')
        / NULLIF(SUM(IsUnderdog = 'True'), 0) * 100,
        2
    ) AS UnderdogWinRate

FROM team_matches

GROUP BY
    League,
    Season,
    Team;
    
-- view --

SELECT *
FROM team_season_summary
LIMIT 10;

-- How do EPL and La Liga compare across seasons? --

SELECT
    League,
    Season,
    ROUND(AVG(GoalsFor / Played), 2) AS AvgGoalsPerTeamPerGame,
    ROUND(AVG(PointsPerGame), 2) AS AvgPPG,
    ROUND(AVG(ShotsPerGame), 2) AS AvgShotsPerGame,
    ROUND(AVG(ShotAccuracy), 2) AS AvgShotAccuracy,
    ROUND(AVG(HomePPG), 2) AS AvgHomePPG,
    ROUND(AVG(AwayPPG), 2) AS AvgAwayPPG
FROM team_season_summary
GROUP BY
    League,
    Season
ORDER BY
    Season,
    League;
    
-- Who were the top 5 teams in each league each season, based on PPG? --

WITH ranked_teams AS (
    SELECT
        League,
        Season,
        Team,
        PointsPerGame,
        WinPercentage,
        GoalsFor,
        GoalsAgainst,
        GoalDifference,

        RANK() OVER (
            PARTITION BY League, Season
            ORDER BY PointsPerGame DESC,
                     GoalDifference DESC,
                     GoalsFor DESC
        ) AS TeamRank

    FROM team_season_summary
)

SELECT
    League,
    Season,
    Team,
    PointsPerGame,
    WinPercentage,
    GoalsFor,
    GoalsAgainst,
    GoalDifference,
    TeamRank
FROM ranked_teams
WHERE TeamRank <= 5
ORDER BY
    League,
    Season,
    TeamRank;
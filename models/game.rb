require_relative('../db/sql_runner')

class Game

    attr_reader :id, :home_team_id, :away_team_id
    attr_accessor :home_goals, :away_goals

    def initialize(options)
        @id = options['id'].to_i if options['id']
        @home_team_id = options['home_team_id'].to_i
        @home_goals = options['home_goals'].to_i
        @away_team_id = options['away_team_id'].to_i
        @away_goals = options['away_goals'].to_i
    end

    def save()
        sql = "INSERT INTO games 
        (home_team_id, home_goals, away_team_id, away_goals)
        VALUES
        ($1, $2, $3, $4)
        RETURNING id"
        values = [@home_team_id, @home_goals, @away_team_id, @away_goals]
        result = SqlRunner.run(sql, values)
        id = result.first['id'].to_i
        @id = id
    end

    def home_team
        home_team = Team.find(@home_team_id)
        return home_team.name
    end

    def away_team
        away_team = Team.find(@away_team_id)
        return away_team.name
    end

    def game_info()
        sql = "SELECT * FROM games WHERE id = $1"
        values = [@id]
        info = SqlRunner.run(sql, values)
        game_data = Game.map_item(info)
    end

    def teams()
        home_team = game_info.home_team
        away_team = game_info.away_team
        return "#{home_team} versus #{away_team}"
    end

    def score()
        home_team = game_info.home_team
        home_goals = game_info.home_goals
        away_team = game_info.away_team
        away_goals = game_info.away_goals
        return "#{home_team} #{home_goals} - #{away_goals} #{away_team}"
    end

    def update()
        sql = "UPDATE games SET
        (home_team_id, home_goals, away_team_id, away_goals)
        = ($1, $2, $3, $4)
        WHERE id = $5"
        values = [@home_team_id, @home_goals, @away_team_id, @away_goals, @id]
        SqlRunner.run(sql, values)
    end

    def delete()
        sql = "DELETE FROM games WHERE id = $1"
        values = [@id]
        SqlRunner.run(sql, values)
    end

    def self.find(id)
        sql = "SELECT * FROM games WHERE id=$1"
        values = [id]
        result = SqlRunner.run(sql, values).first
        game = Game.new(result)
        return game
    end

    def self.all()
        sql = "SELECT * FROM games"
        game_data = SqlRunner.run(sql)
        games = map_items(game_data)
        return games
    end

    def self.delete_all()
        sql = "DELETE FROM games"
        SqlRunner.run(sql)
    end

    def self.map_items(game_data)
        return game_data.map {|game| Game.new(game)} 
    end

    def self.map_item(game_data)
        result = Game.map_items(game_data)
        return result.first
    end

end
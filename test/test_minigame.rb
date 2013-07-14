require 'minigame'
require 'minigame/player'
require 'minitest/autorun'
require 'minitest/unit'
#require 'debugger'

class MiniGameTest < Minitest::Test
  class Game
    include MiniGame
  end

  def new_players
    employer = Player.new name: "IBM"
    employee = Player.new name: "John Smith"
    [employer, employee]
  end
  def new_strategies
    strategies = Strategy.new [{name: "Accept Training"}, 
                               {name: "Generic Training"},
                               {name: "Task Specific Training"},
                               {name: "Deny Training"}]
    # send back an array of strategies
    strategies.inject([]){|x,y| x << y}
  end

  def new_profiles
    employer, employee = new_players
    accept, generic, task, deny = new_strategies 
    strategy_profile = StrategyProfile.new
    strategy_profile << {id: 1, strategy: generic, payoff: -2, player: employer}
    strategy_profile << {id: 1, strategy: accept, payoff: 5, player: employee}

    strategy_profile << {id: 2, strategy: generic, payoff: -1, player: employer}
    strategy_profile << {id: 2, strategy: deny, payoff: -2, player: employee}

    strategy_profile << {id: 3, strategy: task, payoff: 0, player: employer}
    strategy_profile << {id: 3, strategy: deny, payoff: -2, player: employee}

    strategy_profile << {id: 4, strategy: task, payoff: 4, player: employer}
    strategy_profile << {id: 4, strategy: accept, payoff: 1, player: employee}
    strategy_profile
  end

  def new_weak_profiles
    employer, employee = new_players
    accept, generic, task, deny = new_strategies 
    strategy_profile = StrategyProfile.new
    strategy_profile << {id: 1, strategy: generic, payoff: -2, player: employer}
    strategy_profile << {id: 1, strategy: accept, payoff: 5, player: employee}

    strategy_profile << {id: 2, strategy: generic, payoff: -1, player: employer}
    strategy_profile << {id: 2, strategy: deny, payoff: -2, player: employee}

    # not realistic
    strategy_profile << {id: 3, strategy: task, payoff: -1, player: employer}
    strategy_profile << {id: 3, strategy: deny, payoff: -2, player: employee}

    strategy_profile << {id: 4, strategy: task, payoff: 4, player: employer}
    strategy_profile << {id: 4, strategy: accept, payoff: 1, player: employee}
  end

  def test_mixin_game
    game = Game.new
    assert_equal Game, game.class
  end

  def test_new_player
    employer, employee = new_players
    assert_equal "IBM", employer.first[:name]
  end

  def test_new_strategy
    strategies = new_strategies
    assert_equal 4, strategies.count

  end

  def test_new_profiles
    profiles = new_profiles
    assert_equal 8, profiles.count
  end

  def test_game_w_profile
    game = Game.new
    game.strategy_profiles = new_profiles
    assert_equal 8, game.strategy_profiles.count
  end

  def test_strictly_dominated_list
    game = Game.new
    game.strategy_profiles = new_profiles
    assert_equal [{:name=>"Generic Training"}, {:name=>"Deny Training"}], game.strictly_dominated_list
  end

  def test_weakly_dominated_list
    game = Game.new
    game.strategy_profiles = new_weak_profiles
    assert_equal [{:name=>"Generic Training"}], game.weakly_dominated_list
  end

  def test_nash
    game = Game.new
    game.strategy_profiles = new_profiles
    assert_equal [["Accept Training", "Task Specific Training"]], game.nash
  end
    
end

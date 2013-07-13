require 'minigame'
require 'minigame/player'
require 'debugger'
require 'minitest/autorun'
require 'minitest/unit'

class MiniGameTest < Minitest::Test
  class Game
    include MiniGame
  end

  def test_mixin_game
    game = Game.new
    assert_equal Game, game.class
  end

  def test_new_player
    employer = Player.new name: "IBM"
    assert_equal "IBM", employer.first[:name]
  end
  
  def test_new_strategy
    strategies = Strategy.new [{name: "Accept Training"}, 
                               {name: "Generic Training"},
                               {name: "Task Specific Training"},
                               {name: "Deny Training"}]
    assert_equal 4, strategies.count

  end
end

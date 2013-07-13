require 'spec_helper'

describe Game do

  # training game -- generic weakly dominated (not realistic)
  # 
  #      Employer:            | Task Specific       |    Generic
  # You:     -----------------|---------------------|------------------
  #                           |                     |
  #   Deny Training           |  (-2, -1)           |     (-2, -1)
  #   ------------------------|---------------------|------------------
  #   Accept Training         |  (1, 4)             |     (5, -2)
  #   ------------------------|---------------------|------------------
  def game_with_weakly_dominated_strategies
    strategies = Strategy.new [{name: "Accept Training"}, {name: "Generic Training"},{name: "Task Specific Training"},{name: "Deny Training"}]
    accept = strategies.find{|x| x[:name] == "Accept Training"}
    generic = strategies.find{|x| x[:name] == "Generic Training"}
    task = strategies.find{|x| x[:name] == "Task Specific Training"}
    deny = strategies.find{|x| x[:name] == "Deny Training"}
    employer = Player.new name: "IBM"
    employee = Player.new name: "John Smith"

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
    gs = Game.new
    gs.strategy_profiles = strategy_profile
    gs
  end
  
  # Regular training game -- generic strictly dominated
  # 
  #      Employer:            | Task Specific       |    Generic
  # You:     -----------------|---------------------|------------------
  #                           |                     |
  #   Deny Training           |  (-2, 0)            |     (-2, -1)
  #   ------------------------|---------------------|------------------
  #   Accept Training         |  (1, 4)             |     (5, -2)
  #   ------------------------|---------------------|------------------
  before(:each) do
    @strategies = Strategy.new [{name: "Accept Training"}, {name: "Generic Training"},{name: "Task Specific Training"},{name: "Deny Training"}]
    @accept = @strategies.find{|x| x[:name] == "Accept Training"}
    @generic = @strategies.find{|x| x[:name] == "Generic Training"}
    @task = @strategies.find{|x| x[:name] == "Task Specific Training"}
    @deny = @strategies.find{|x| x[:name] == "Deny Training"}
    @employer = Player.new name: "IBM"
    @employee = Player.new name: "John Smith"

    @strategy_profile = StrategyProfile.new
    @strategy_profile << {id: 1, strategy: @generic, payoff: -2, player: @employer}
    @strategy_profile << {id: 1, strategy: @accept, payoff: 5, player: @employee}

    @strategy_profile << {id: 2, strategy: @generic, payoff: -1, player: @employer}
    @strategy_profile << {id: 2, strategy: @deny, payoff: -2, player: @employee}

    @strategy_profile << {id: 3, strategy: @task, payoff: 0, player: @employer}
    @strategy_profile << {id: 3, strategy: @deny, payoff: -2, player: @employee}

    @strategy_profile << {id: 4, strategy: @task, payoff: 4, player: @employer}
    @strategy_profile << {id: 4, strategy: @accept, payoff: 1, player: @employee}
    @gs = Game.new
    @gs.strategy_profiles = @strategy_profile
  end

  it ".strategies should allow assignment of strategies" do
    @gs.strategy_profiles.count.should == 8
  end

  it ".payoff should return the payoff for a strategy and player" do
    @gs.payoff(@generic, @employer).should == -2 
  end
  

  it '.players should return a list of players' do
    @gs.players.count.should == 2
  end

  it '.player_names should return a list of player names' do
    @gs.player_names.count.should == 2
  end

  it '.opposing_players should return a list of players who receive payouts for the passed in strategy profile' do
    gen_strat_profile = @gs.strategy_profiles.select{|x| x[:strategy][:name] == "Generic Training"}.first
    @gs.opposing_players(gen_strat_profile).count.should == 1
  end

  it '.player_strategy_profiles should return a list of strategy profiles for the players' do
    @gs.player_strategy_profiles(@employer).count.should == 4
  end

  it '.complementary_moves? should return a list of strategy profiles for a player other than the passed in profile' do
    gen_strat_profile = @gs.strategy_profiles.select{|x| x[:strategy][:name] == @generic[:name]}.first
    @gs.complementary_moves(gen_strat_profile).count.should == 1
    @gs.complementary_moves(gen_strat_profile).first[:strategy][:name].should == @task[:name]
  end

  it '.opposing_player_strategy_profile should return the name of the opposing players strategy for the passed in profile' do
    gen_strat_profile = @gs.strategy_profiles.select{|x| x[:strategy][:name] == @generic[:name]}.first
    @gs.opposing_player_strategy_profile(gen_strat_profile)[:strategy][:name].should == @accept[:name]
  end

  it '.better_payoffs? should return a list of strategy profiles that are better than the passed in profile for the passed in player' do
    gen_strat_profile = @gs.strategy_profiles.select{|x| x[:strategy][:name] == @generic[:name]}.first
    #@gs.better_moves?(gen_strat_profile).first[:strategy][:name].should == @task[:name]
    @gs.better_payoffs?(gen_strat_profile).first[:strategy][:name].should == @task[:name]
  end

  # should return this
  #      Employer:            | Task Specific       |    Generic
  # You:     -----------------|---------------------|------------------
  #                           | get all alternates  | Pass in this
  #   Deny Training           |  (  , 0)            |     (-2, )
  #   ------------------------|---------------------|------------------
  #   Accept Training         |                     |     (5,  )       
  #   ------------------------|---------------------|------------------
  it '.worse_payoffs? should return a list of strategy profiles that are worse than the passed in profile for the passed in player'do
    gen_strat_profile = @gs.strategy_profiles.select{|x| x[:strategy][:name] == @accept[:name]}.first
    @gs.worse_payoffs?(gen_strat_profile).should_not be_nil
    @gs.worse_payoffs?(gen_strat_profile).should_not be_empty
    @gs.worse_payoffs?(gen_strat_profile)[0][:payoff].should == -2
  end

  #      Employer:            | Task Specific       |    Generic
  # You:     -----------------|---------------------|------------------
  #                           |                     |
  #   Deny Training           |  (-2, -1)           |     (-2, -1)
  #   ------------------------|---------------------|------------------
  #   Accept Training         |  (1, 4)             |     (5, -2)
  #   ------------------------|---------------------|------------------
  it '.better_or_equal_moves? should return a list of strategy profiles that are better than the passed in profile for the passed in player' do
    gs = game_with_weakly_dominated_strategies
    # gets the generic strategy vs the deny training profile
    gen_strat_profile = gs.strategy_profiles.select{|x| x[:strategy][:name] == @generic[:name]}[1]
    gs.better_payoffs?(gen_strat_profile).count.should == 0
    gs.better_or_equal_payoffs?(gen_strat_profile).count.should == 1
    gs.better_or_equal_payoffs?(gen_strat_profile).first[:strategy][:name].should == @task[:name]
  end

  it ".strictly_dominated_list should return a list of strictly dominated strategies" do
    # generic training and deny training are strictly dominated
    @gs.strictly_dominated_list.count.should == 2
    @gs.strictly_dominated_list.select{|x| x[:name] == @generic[:name]}.count.should > 0
    @gs.strictly_dominated_list.select{|x| x[:name] == @deny[:name]}.count.should > 0
  end
  
  #      Employer:            | Task Specific       |    Generic
  # You:     -----------------|---------------------|------------------
  #                           |                     |
  #   Deny Training           |  (-2, -1)           |     (-2, -1)
  #   ------------------------|---------------------|------------------
  #   Accept Training         |  (1, 4)             |     (5, -2)
  #   ------------------------|---------------------|------------------
  it ".equal_moves should return a list of moves for a matchup that are equal in payoffs" do
    #  in the above game generic training is weakly dominated
    gs = game_with_weakly_dominated_strategies
    gen_strat_profiles = gs.strategy_profiles.select do |x| 
      x[:strategy][:name] == @generic[:name] &&
      x[:payoff] == -1
    end
    gen_strat_profile = gen_strat_profiles.first
    gs.equal_moves(gen_strat_profile).count.should == 1
    gs.equal_moves(gen_strat_profile).first[:payoff].should == -1
  end
  
  #      Employer:            | Task Specific       |    Generic
  # You:     -----------------|---------------------|------------------
  #                           |                     |
  #   Deny Training           |  (-2, -1)           |     (-2, -1)
  #   ------------------------|---------------------|------------------
  #   Accept Training         |  (1, 4)             |     (5, -2)
  #   ------------------------|---------------------|------------------
  it ".all_other_moves should return a list of moves for a matchup that are equal in payoffs" do
    #  in the above game generic training is weakly dominated
    gs = game_with_weakly_dominated_strategies
    gen_strat_profiles = gs.strategy_profiles.select do |x| 
      x[:strategy][:name] == @generic[:name] &&
      x[:payoff] == -1
    end
    gen_strat_profile = gen_strat_profiles.first
    gs.equal_moves(gen_strat_profile).count.should == 1
    gs.equal_moves(gen_strat_profile).first[:payoff].should == -1
  end

  #      Employer:            | Task Specific       |    Generic
  # You:     -----------------|---------------------|------------------
  #                           |                     |
  #   Deny Training           |  (-2, -1)           |     (-2, -1)
  #   ------------------------|---------------------|------------------
  #   Accept Training         |  (1, 4)             |     (5, -2)
  #   ------------------------|---------------------|------------------
  it ".weakly_dominated_list should return a list of weakly dominated strategies" do
    #  in the above game generic training is weakly dominated
    gs = game_with_weakly_dominated_strategies
    # generic should not be strictly but rather weakly dominated
    gs.strictly_dominated_list.count.should == 1
    gs.weakly_dominated_list.count.should == 2
    gs.weakly_dominated_list.select{|x| x[:name] == @generic[:name]}.count.should > 0
    gs.weakly_dominated_list.select{|x| x[:name] == @deny[:name]}.count.should > 0
  end

  #      Employer:            | Task Specific       |    Generic
  # You:     -----------------|---------------------|------------------
  #                           |                     |
  #   Deny Training           |  (-2, -1)           |     (-2, -1)
  #   ------------------------|---------------------|------------------
  #   Accept Training         |  (1, 4)             |     (5, -2)
  #   ------------------------|---------------------|------------------
  it ".valid_deviation? should not be nil if the strategy and the deviation belongs to the same player" do
    gs = game_with_weakly_dominated_strategies
    gs.valid_deviation?(@deny, @accept).should_not be_nil 
  end

  it ".valid_deviation? should not be nil if the strategy and the deviation belongs to the same player" do
    gs = game_with_weakly_dominated_strategies
    gs.valid_deviation?(@deny, @generic).should == nil 
  end

  #      Employer:            | Task Specific       |    Generic
  # You:     -----------------|---------------------|------------------
  #                           |                     |
  #   Deny Training           |  (-2, -1)           |     (-2, -1)
  #   ------------------------|---------------------|------------------
  #   Accept Training         |  (1, 4)             |     (5, -2)
  #   ------------------------|---------------------|------------------
  it ".compare_deviating_strategy should return a list of weakly dominated strategies" do
    #  in the above game generic training is weakly dominated
    gs = game_with_weakly_dominated_strategies
    gs.compare_deviating_strategy(@deny, @accept).should == :strictly_dominated
  end

  it ".deviating_strategies should return a list of deviations" do
    gen_strat_payoff = @gs.strategy_profiles.detect{|x| x[:strategy][:name] == @generic[:name]}
    task_strat_payoff = @gs.strategy_profiles.detect{|x| x[:strategy][:name] == @task[:name]}
    @gs.deviating_strategies(gen_strat_payoff).include?(gen_strat_payoff[:strategy]).should == false
    @gs.deviating_strategies(gen_strat_payoff).include?(task_strat_payoff[:strategy]).should == true
  end

  it ".player_from_strategy should get the player for a particular strategy" do
    @gs.player_from_strategy(@accept).should eq @employee
  end
   
  it ".best_response should be the action of a player that is best for him given his beliefs about the other's action" do
    task_strat_payoff = @gs.strategy_profiles.detect{|x| x[:strategy][:name] == @task[:name]}
    accept_strat_payoff = @gs.strategy_profiles.detect{|x| x[:strategy][:name] == @accept[:name]}
    @gs.best_response_against(task_strat_payoff)[:strategy][:name].should == accept_strat_payoff[:strategy][:name]

  end  
  
  it ".player_enum should get a list of player enumerators" do
    @gs.player_enum.include?(@employer).should == true 
  end

  it ".strategies_by_player should get a list of strategies by player" do
    @gs.strategies_by_player(@employee).include?(@accept).should == true 
  end

  it ".nash should return a list of strategy profiles that are nash equilibriums" do
    @gs.nash.include?([@accept[:name],@task[:name]]).should == true 
  end

   
end

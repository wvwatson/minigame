require 'spec_helper'

describe StrategyProfile do
  # 
  #      Employer:            | Task Specific       |    Generic
  # You:     -----------------|---------------------|------------------
  #                           |                     |
  #   Deny Training           |  (-2, 0)            |     (-2, -1)
  #   ------------------------|---------------------|------------------
  #   Accept Training         |  (1, 4)             |     (5, -2)
  #   ------------------------|---------------------|------------------
  before (:each) do
    @strategies = Strategy.new [{name: "Accept Training"}, {name: "Generic Training"},{name: "Task Specific Training"},{name: "Deny Training"}]
    @accept = @strategies.find{|x| x[:name] == "Accept Training"}
    @generic = @strategies.find{|x| x[:name] == "Generic Training"}
    @task_specific = @strategies.find{|x| x[:name] == "Task Specific Training"}
    @deny = @strategies.find{|x| x[:name] == "Deny Training"}
    @employer = Player.new name: "John Smith"
    @employee = Player.new name: "John Smith"
  end
  # hash of stategy, matchup, player, payoff
  it "should collect matchups" do
    @strategy_profile = StrategyProfile.new
    @strategy_profile << {id: 1, strategy: @accept, payoff: -2, player: @employer}
    @strategy_profile << {id: 1, strategy: @generic, payoff: 5, player: @employee}
    @strategy_profile.count.should == 2
    
  end
end

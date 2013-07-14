module Gameable
  attr_accessor :strategy_profiles

  # any set of strategies that are best responses for each other are nash equilibriums
  def nash
    # assume the same number of strategies for each side for now
    # get one player
    firstp = player_enum.first
    # get opposing player
    opp_p = player_enum[1]
    # get strategies for the player
    pstrats = player_strategy_profiles(firstp)
    oppstrats = player_strategy_profiles(opp_p)
    # loop through first strategies and get best responses
    nash ||=[]
    nash = pstrats.inject([]) do |acc, strat|
      #loop through opposing strategies
      oppstrats.map do |opp_strat|
        br = best_response_against(strat)[:strategy][:name]
        br_opposing = best_response_against(opp_strat)[:strategy][:name]
        # best response for both sides that match each other are nash equilibriums
        if br == opp_strat[:strategy][:name] && br_opposing == strat[:strategy][:name]
          acc << [br,br_opposing]
        end
      end
      acc
    end
    nash.uniq
  end

  def best_response_against(opponent_strategy)
    best_resp=[]
    # get opponent player from strategy
    opp_player = player_from_strategy(opponent_strategy[:strategy]).first
    # get player from strategy
    player = players.detect{|x| x[:name] != opp_player[:name]}
    strat_payoff_list ||=[]
    # only collect possible payoffs that are opposed to the passed in opponent's strategy
    strat_payoff_list = player_strategy_profiles(player).inject([]) do |acc, str|
      if opposing_player_strategy_profile(str)[:strategy][:name]==opponent_strategy[:strategy][:name]
        acc << str
      end
      acc
    end
    best_resp = strat_payoff_list.sort{|x| x[:payoff]}.reverse
    # return top performer, later need to return all strategies that are equal in payoff
    best_resp.first
  end

  def strictly_dominated_list
    dominated_list ||=[]
    players.each do |player|
      dominated_list << player_strategy_profiles(player).inject([]) do |acc, strat|
        # if count of total strategies for opposing player = count of better payoffs, then current strategy is strictly dominated
        dev = deviating_strategies(strat)
        new_strat_list =[]
        dev.each do |dev_strat|
          if compare_deviating_strategy(strat[:strategy], dev_strat) == :strictly_dominated  
            new_strat_list << strat[:strategy] 
          end
        end
        acc << new_strat_list
      end
    end
    dominated_list.flatten.uniq
  end

  def weakly_dominated_list
    dominated_list ||=[]
    players.each do |player|
      dominated_list << player_strategy_profiles(player).inject([]) do |acc, strat|
        dev = deviating_strategies(strat)
        dev.each do |dev_strat|
          if compare_deviating_strategy(strat[:strategy], dev_strat) == :weakly_dominated          
            acc << strat[:strategy] 
          else
            acc
          end
        end
      end
    end
    dom = dominated_list.flatten.uniq
    strict = strictly_dominated_list
    weakly_dominated_list = dom.take_while{|i| strict.include?(i)==false}
    weakly_dominated_list
  end

  def strategies_by_player(player)
    strats = strategy_profiles.inject([]) do |acc, strat| 
      if strat[:player] == player
        acc << strat[:strategy]
      else
        acc
      end
    end
    strats.uniq
  end

  # retrieve a player assigned to the strategy
  def player_from_strategy(strategy)
    stratp = strategy_profiles.detect{|x| x[:strategy][:name] == strategy[:name]}
    stratp[:player] 
  end
  
  # valid deviations must belong to the same player
  def deviating_strategies(strategy_payoff)
    strategies(strategy_payoff[:player].first).select{|x| x[:name] != strategy_payoff[:strategy][:name]}
  end

  # valid deviations must belong to the same player
  def valid_deviation?(strategy, deviation)
    selected_profile_list = self.strategy_profiles.detect{|x| x[:strategy][:name] == strategy[:name]}
    matching_strategy_deviation = self.strategy_profiles.detect{|x| x[:strategy][:name] == deviation[:name] && x[:player] == selected_profile_list[:player] }
  end

  # for a strategy, take each strategy profile and match it against 
  # it's corresonding but deviating strategy profile 
  def compare_deviating_strategy(strategy, deviation)
    raise "invalid deviation for submitted strategy" if !valid_deviation?(strategy, deviation)

    one_equal = false
    one_better = false
    selected_profile_list = self.strategy_profiles.select{|x| x[:strategy][:name] == strategy[:name]}
    # loop through strategy profiles from the strategy
    selected_profile_list.each do |strat|
      # store strat payoff e.g. -2
      strat_payoff = strat[:payoff]
      opposing_strategy = opposing_player_strategy_profile(strat)
      # get deviating profile's payoff that corresponds to opposing strategy
      deviating_profile = self.strategy_profiles.select do |x| 
        x[:strategy][:name] == deviation[:name]  && opposing_player_strategy_profile(x)[:strategy][:name] == opposing_strategy[:strategy][:name]
      end
      # compare payoffs
      # if strategy payoff is better than even just one deviating 
      # payoff, the strategy is not dominated
      if strat_payoff > deviating_profile[0][:payoff]
        return :not_dominated
      # if payoff for deviating strategy is better, remember that fact
      elsif strat_payoff < deviating_profile[0][:payoff]
        one_better = true
      # if payoff for deviating strategy is equal, remember that fact
      elsif strat_payoff == deviating_profile[0][:payoff]
        one_equal = true
      end
    end
    # if made it here, the deviating profile has either all better, or some better and some equal payoffs
    # if all deviation profiles are equal or better, strategy is weakly dominated by the deviation
    return :weakly_dominated if one_equal
    # if all deviating profiles are better, strategy is dominated by the deviation
    return :strictly_dominated if one_better

    raise "nothing better, equal, or worse"
  end


  def equal_moves(strat)
    complementary_moves(strat).select{|x|x["payoff"]==strat["payoff"]}
  end

  def payoff(strategy, player)
    strategy_profile = [@strategy_profiles.select{|x| x[:strategy]==strategy && x[:player]==player}].flatten.first
    strategy_profile[:payoff] if strategy_profile
  end

  def player_names
    players.inject([]) do |acc, x|
      acc << x[:name]
    end 
  end 

  def players
    # need inject to remove duplicates
    @strategy_profiles.inject([]) do |acc, x| 
      if acc.nil? || acc.empty?
        # should be only one player per strategy_profile
        acc << x[:player].first 
      elsif !acc.include?(x[:player].first)
        acc << x[:player].first 
      else
        acc
      end
    end
  end 
  
  def player_enum
    # need inject to remove duplicates
    player_enums = @strategy_profiles.inject([]) do |acc, x| 
        acc << x[:player] 
    end
    player_enums.uniq
  end 

  def opposing_players(strategy_profile)
    players - [strategy_profile[:player].first]
  end

  def player_strategy_profiles(player)
    # find some way to standardize what a player is ...
    # possibly plural is enumerable, singular is a hash
    # same problem with other classes
    if player.class == Player
      @strategy_profiles.select{|x| x[:player] == player}
    else
      @strategy_profiles.select{|x| x[:player].first == player}
    end
  end

  def strategies(player)
    player_strategy_profiles(player).reduce([]){|acc,strat| acc << strat[:strategy]}.uniq 
  end  

  # returns the strategy associated with the passed in profile
  # belonging to the opposing player
  def opposing_player_strategy_profile(strategy_profile)
    # list of players
    # get all strategies profiles for the first player that does not equal
    # the passed in player
    opposing_player = opposing_players(strategy_profile).first
    # return the first strategy with the strategy profile id equal
    # to the passed in strategy profile id
    opposing_strategies = player_strategy_profiles(opposing_player)
    opposing_strategies.select{|x| x[:id]==strategy_profile[:id]}.first
  end
 
  # all other moves other than the passed in strategy (for the player) 
  def complementary_moves(strategy_profile)
    psp = player_strategy_profiles(strategy_profile[:player])
    psp.select do |x| 
      # not the current strategy
      if x[:strategy] != strategy_profile[:strategy] && 
        # only return profiles matched vs original opposing strategy
        opposing_player_strategy_profile(strategy_profile)[:strategy] == 
          opposing_player_strategy_profile(x)[:strategy]
        true
      else
        false 
      end
    end
  end

  # all other payoffs other than the passed in strategy (for the player) 
  def deviating_payoffs(strategy_profile)
    psp = player_strategy_profiles(strategy_profile[:player])
    dev_pay = psp.select do |x| 
      # not the current strategy
      if x[:strategy] != strategy_profile[:strategy] && 
        # only payoffs matched with original opposing strategy are
        # considered deviating payoffs
        opposing_player_strategy_profile(strategy_profile)[:strategy] == 
          opposing_player_strategy_profile(x)[:strategy]
        true
      else
        false 
      end
    end
    dev_pay.reduce([]){|acc,p| acc << p}
  end

  alias_method :other_moves, :complementary_moves
  
  # this should list all of the deviating payoffs for the opponent's strategy
  # within the passed in strategy profile.  Only the payoffs corresponding
  # to the opponent's strategy are considered deviating payoffs
  def better_payoffs?(strategy_profile)
    deviating_payoffs(strategy_profile).select{|x| x[:payoff] > strategy_profile[:payoff]}
  end

  def better_or_equal_payoffs?(strategy_profile)
    deviating_payoffs(strategy_profile).select{|x| x[:payoff] >= strategy_profile[:payoff]}
  end

  def worse_payoffs?(strategy_profile)
    deviating_payoffs(strategy_profile).select{|x| x[:payoff] < strategy_profile[:payoff]}
  end

end

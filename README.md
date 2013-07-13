# MiniGame
## Simplistic Game Theory Library in Ruby

Installation
```
gem install minigame
```

Usage:

To create new players:
```
employer = Player.new name: "IBM"
employee = Player.new name: "John Smith
```

To create a new list of strategies for all players in a game:
```
strategies = Strategy.new [{name: "Accept Training"}, 
                           {name: "Generic Training"},
                           {name: "Task Specific Training"},
                           {name: "Deny Training"}]
```

To create new StrategyProfiles:
```

# Regular training game -- generic strictly dominated
# 
#      Employer:            | Task Specific       |    Generic
# Employee:  ---------------|---------------------|------------------
#                           |                     |
#   Deny Training           |  (-2, 0)            |     (-2, -1)
#   ------------------------|---------------------|------------------
#   Accept Training         |  (1, 4)             |     (5, -2)
#   ------------------------|---------------------|------------------
strategy_profile = StrategyProfile.new
strategy_profile << {id: 1, strategy: generic, payoff: -2, player: employer}
strategy_profile << {id: 1, strategy: accept, payoff: 5, player: employee}

strategy_profile << {id: 2, strategy: generic, payoff: -1, player: employer}
strategy_profile << {id: 2, strategy: deny, payoff: -2, player: employee}

strategy_profile << {id: 3, strategy: task, payoff: 0, player: employer}
strategy_profile << {id: 3, strategy: deny, payoff: -2, player: employee}

strategy_profile << {id: 4, strategy: task, payoff: 4, player: employer}
strategy_profile << {id: 4, strategy: accept, payoff: 1, player: employee}
```

To create a new game:
```
gs = Game.new
gs.strategy_profiles = strategy_profile
```

To get the list of strictly dominated strategies:
```
gs.strictly_dominated_list

  [{:name=>"Generic Training"}, {:name=>"Deny Training"}]

```

To get the list a weakly dominated strategies:
```
# training game -- generic weakly dominated (not realistic)
# 
#      Employer:            | Task Specific       |    Generic
# Employer: ----------------|---------------------|------------------
#                           |                     |
#   Deny Training           |  (-2, -1)           |     (-2, -1)
#   ------------------------|---------------------|------------------
#   Accept Training         |  (1, 4)             |     (5, -2)
#   ------------------------|---------------------|------------------
gs.weakly_dominated_list

  [{:name=>"Generic Training"}, {:name=>"Deny Training"}]

```

To get the list strategy profiles that are nash equilibria:
```
gs.nash 

  [["Accept Training", "Task Specific Training"]]

```



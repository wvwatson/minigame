require 'data_mapper'
#class Payoff < ActiveRecord::Base
#  belongs_to :player
#  belongs_to :matchup
#  attr_accessible :payoff
#end
class Payoff 
  include DataMapper::Resource
  belongs_to :player
  belongs_to :matchup
  #attr_accessible :payoff
end

#this file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
#require File.expand_path("../../config/environment", __FILE__)
require File.expand_path(File.dirname(__FILE__) + '/../lib/minigame/array_of_hashes.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/minigame/strategy.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/minigame/strategy_profile.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/minigame/player.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/minigame/payoff.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/minigame/gameable.rb')
require File.expand_path(File.dirname(__FILE__) + '/../lib/minigame/game.rb')
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
#Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

Dir["../app/models/*.rb"].each {|f| require_relative f}
RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec
  
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"
    
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # next line doesn't work with database cleaner
  #config.use_transactional_fixtures = true
  
  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  #config.infer_base_class_for_anonymous_controllers = false
  #config.include FactoryGirl::Syntax::Methods
    
  #config.before(:suite) do
  #  DatabaseCleaner.strategy = :transaction
  #  DatabaseCleaner.clean_with(:truncation)
  #end
  #config.before(:each) do
  #  DatabaseCleaner.start
  #end

  #config.after(:each) do
  #  DatabaseCleaner.clean
  #end

end


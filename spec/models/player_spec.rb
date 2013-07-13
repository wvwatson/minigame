require 'spec_helper'

describe Player do
  it "should check for an required keys when initializing" do
    players=Player.new 
    expect {
      players << {notname: "test1", description: "test2"}
    }.to raise_error(RuntimeError,/Name required/)
  end

  it "should allow and insert when name and description are present" do
    players=Player.new 
    expect {
      players << {name: "test1", description: "test2"}
      players << {name: "test3", description: "test4"}
    }.to_not raise_error
  end
end

require 'spec_helper'

describe Strategy do

  it "should check for an required keys when initializing" do
    strategies=Strategy.new 
    expect {
      strategies << {notname: "test1", description: "test2"}
    }.to raise_error(RuntimeError,/Name required/)
  end

  it "should allow and insert when name and description are present" do
    strategies=Strategy.new 
    expect {
      strategies << {name: "test1", description: "test2"}
      strategies << {name: "test3", description: "test4"}
    }.to_not raise_error
  end
end

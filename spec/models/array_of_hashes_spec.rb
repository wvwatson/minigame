require 'spec_helper'

describe ArrayOfHashes do
  before(:each) do
    class TestAOfH
      include ArrayOfHashes
    end
  end

  it "should instantiate with an array of hashes" do
    aoh = TestAOfH.new [{keyname1: "test1", keyname2: "test2"},{keyname3: "test3", keyname4: "test4"}]
    aoh.count.should == 2
  end

  it "should have enumerable functions" do
    aoh = TestAOfH.new [{keyname1: "test1", keyname2: "test2"},{keyname3: "test3", keyname4: "test4"}]
    @test2 = aoh.select{|x| x[:keyname2] == "test2"}
    @test2.count.should == 1
  end

  it ".required_keys should reject non-symbols" do
    aoh=TestAOfH.new
    expect {
      aoh.required_keys ["name", "description"]
    }.to raise_error(RuntimeError,/Not a symbol/)
  end

  it ".required_keys should work as assignment" do
    aoh=TestAOfH.new
    expect {
      aoh.required_keys = [:name, :description]
    }.to_not raise_error
  end

  it ".required_keys should also work with a single symbol (not an array)" do
    aoh=TestAOfH.new
    expect {
      aoh.required_keys = :name
    }.to_not raise_error
  end

  it ".required_keys should accept a list of symbols" do
    aoh=TestAOfH.new
    expect {
      aoh.required_keys([:name, :description])
    }.to_not raise_error
  end

  it ".check_keys should allow a name" do
    aoh=TestAOfH.new
    expect {
      aoh.check_keys({name: "Deny Training"})
    }.to_not raise_error
  end

  it ".check_keys should raise an error if not passed a hash" do
    aoh=TestAOfH.new
    expect {
      aoh.check_keys('notahash')
    }.to raise_error(RuntimeError,/Not a Hash/)
  end

  it ".check_keys should check for name" do
    aoh=TestAOfH.new
    aoh.required_keys :name
    expect {
      aoh.check_keys({hmm: 'notahash'})
    }.to raise_error(RuntimeError,/Name required/)
  end

  it "should allow addition of hashes with <<" do
    aoh = TestAOfH.new 
    aoh << {keyname1: "test1", keyname2: "test2"}
    aoh << {keyname3: "test3", keyname4: "test4"}
    aoh.count.should == 2
  end

  it "should check for an required keys when initializing" do
    aoh = TestAOfH.new 
    aoh.required_keys = [:name, :description]
    expect {
      aoh << {notname: "test1", description: "test2"}
    }.to raise_error(RuntimeError,/Name required/)
  end

  it "should allow inserts when required keys are present" do
    aoh = TestAOfH.new 
    aoh.required_keys = [:name, :description]
    expect {
      aoh << {name: "test1", description: "test2"}
      aoh << {name: "test3", description: "test4"}
    }.to_not raise_error
  end
end

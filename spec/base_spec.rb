require 'spec_helper'

describe Remnant do

  context "#configuration" do
    it "should return the same object for multiple calls" do
      Remnant.configuration.should == Remnant.configuration
    end
  end

  context "#configure" do
    it "should fail without a block" do
      lambda { Remnant.configure }.should raise_error
    end

    it "should instance_eval the block onto configuration" do
      block = Proc.new { handle {|payload| } }
      mock(Remnant).configuration.stub!.instance_eval(&block)
      Remnant.configure(&block)
    end
  end
end

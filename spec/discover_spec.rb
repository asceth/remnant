require 'spec_helper'

describe Remnant::Discover do

  before do
    Remnant::Discover.results.clear
  end

  context "#measure" do
    it "should preserve return" do
      Remnant::Discover.measure('troll') { 'bridge'}.should == 'bridge'
    end

    it "should add to existing result" do
      Remnant::Discover.results['fragment'].should == 0

      Remnant::Discover.measure('fragment') { 'shattered'; sleep 0.1 }
      shattered_measurement = Remnant::Discover.results['fragment']

      Remnant::Discover.measure('fragment') { 'intact'; sleep 0.1 }
      Remnant::Discover.results['fragment'].should > shattered_measurement
    end

    it "should add to existing nested results" do
      Remnant::Discover.results['fragment'].should == 0

      Remnant::Discover.measure('fragment') do
        sleep 0.2
        Remnant::Discover.measure('fragment') do
          sleep 0.2
        end
      end

      Remnant::Discover.results['fragment'].should < 410
      Remnant::Discover.results['fragment'].should > 390
    end
  end

  context "#find" do
    it "should be able to watch passing blocks" do
      Remnant::Discover.find('yielding', Some::Klass, :yielder)
      Some::Klass.new.yielder { 'techno'}.should == 'techno'
    end

    it "should be able to watch passing args" do
      Remnant::Discover.find('echo', Some::Klass, :echo)
      Some::Klass.new.echo(1, 1, 2, 3, 5).should == [1, 1, 2, 3, 5]
    end

    it "should be able to watch an instance method" do
      Remnant::Discover.find('instance', Some::Klass, :foo)

      Some::Klass.new.foo.should == 'foo'
      Remnant::Discover.results['instance'].should_not == nil
    end

    it "should be able to watch a class method" do
      Remnant::Discover.find('class_method', Some::Klass, :world, false)

      Some::Klass.world.should == 'world'
      Remnant::Discover.results['class_method'].should_not == nil
    end
  end
end

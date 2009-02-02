require 'babylon/state_machine'
require 'spec'

include Babylon

describe StateMachineClass do
  it 'should switch states' do
    class MyStateMachine1
      stateify self, :state1

      state :state1, :foo do
        next_state :state2
      end

      state :state2, :foo do
        next_state :state1
      end
    end

    s = MyStateMachine1.new
    s.state.should == :state1
    s.foo
    s.state.should == :state2
    s.foo
    s.state.should == :state1
  end

  it 'should execute states in instance context' do
    class MyStateMachine2
      attr_reader :calls

      def initialize
        @calls = 0
      end

      stateify self, :state1

      state :state1, :foo do
        @calls += 1
      end
    end
    s = MyStateMachine2.new
    s.calls.should == 0
    s.foo
    s.calls.should == 1
  end

  it 'should execute states with parameters' do
    class MyStateMachine3
      attr_reader :param

      def initialize
        @param = nil
      end

      stateify self, :state1

      state :state1, :foo do |*param|
        @param = param
      end
    end
    s = MyStateMachine3.new
    s.param.should == nil
    s.foo
    s.param.should == []
    s.foo('bar')
    s.param.should == ['bar']
    s.foo('bar', 42)
    s.param.should == ['bar', 42]
  end

  it 'should return state return values' do
    class MyStateMachine4
      stateify self, :state1

      state :state1, :foo do
        ['This is a', :return, 'value']
      end
    end
    s = MyStateMachine4.new
    s.foo.should == ['This is a', :return, 'value']
  end
end

require 'babylon/instance_exec'

module Babylon
  def stateify(klass, start_state_ = nil)
    klass.class_eval do
      extend StateMachineClass
      start_state start_state_
      include StateMachineInstance
    end
  end

  module StateMachineClass
    def start_state(state)
      @start_state = state
    end
    def state(state, method, &block)
      @state ||= self.class.instance_variable_get(:@start_state)
      @state_blocks ||= {}
      @state_blocks[[state, method]] = block
    end
  end

  module StateMachineInstance
    def state
      @state ||= self.class.instance_variable_get(:@start_state)
    end
    def next_state(state)
      @state = state
    end
    def method_missing(method, *args)
      block = self.class.instance_variable_get(:@state_blocks)[[state, method]]
      if block
        instance_exec(*args, &block)
      else
        raise NoMethodError.new(method)
      end
    end
  end
end

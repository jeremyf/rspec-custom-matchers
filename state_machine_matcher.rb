module Spec
  module Rails
    module Matchers
      # Specifies a valid state change
      #
      # options
      # :from: The from state
      # :to: The desired state
      # :via: The event to fire the transition
      def change_state(*args)
        options = args.extract_options!
        from_status = options[:from]
        to_status = options[:to]
        via_event = options[:via]
        return simple_matcher("model should change status from :#{from_status} to :#{to_status} via :#{via_event} event") do |klass|
          object = klass.is_a?(Class) ? klass.new : klass
          object.stub!(:current_state).and_return(from_status.to_sym)
          object.stub!(:status).and_return(from_status.to_s)
          if event = object.next_states_for_event(via_event).detect{|event| event.to == to_status}
            event.to.to_sym == to_status.to_sym
          else
            false
          end
        end
      end
    end
  end
end


class Spec::Rails::Example::RailsExampleGroup

  class << self
    # This method assumes the use of the awesome acts_as_state_machine, 
    #
    # Given all events (both defined and proposed to the validator)
    # and all statuses (both defined and proposed to the validator),
    # this method will iterate over the events, and then over
    # the statuses as the "from" status, and then over the
    # statuses again as the "to" status.  
    #
    # With the event, from status and to status, this method 
    # will check against the validator to say it should or
    # should_not state_change
    #
    #
    # Usage:
    #
    # describe MyStatedObject do
    #   describe_valid_event_transitions do |transition|
    #     transition.is_valid(:event => :approve!,  :from => :pending, :to => :active)
    #     transition.is_valid(:event => :reject!,   :from => :pending, :to => :rejected)
    #     transition.is_valid(:event => :complete!, :from => :active,  :to => :completed)
    #   end
    # end
    #
    def describe_valid_event_transitions
      collector = ValidTransitionCollector.new
      yield(collector)
      klass = description.constantize
      describe 'status changes' do
        (klass.event_table.keys + collector.events).uniq.each do |event|
          (klass.states + collector.states).each do |possible_from_state|
            (klass.states + collector.states).each do |possible_to_state|
              should_transition = false
              if result = collector.has?(event, possible_from_state, possible_to_state)
                should_transition = true
              end

              it "should #{should_transition ? '' : 'NOT '}change from :#{possible_from_state} to :#{possible_to_state} via :#{event}" do
                klass.send("#{should_transition ? 'should' : 'should_not'}", change_state(:via => event, :from => possible_from_state, :to => possible_to_state))
              end
            end
          end
        end
      end
    end

    class ValidTransitionCollector #:nodoc:

      def events
        transition_table.collect{|t| t[:event]}.uniq
      end

      def states
        transition_table.collect{|t| [t[:to], t[:from]]}.flatten.uniq
      end

      def add(options = {})
        options.symbolize_keys!
        transition_table << {:event => (options[:event] || options[:via]).to_sym, :from => options[:from].to_sym, :to => options[:to].to_sym}
      end
      alias_method :is_valid, :add

      def has?(event, from, to)
        transition_table.detect{|o| o[:event] == event && o[:from] == from && o[:to] == to}
      end
      protected
      def transition_table
        @transition_table ||= []
      end
    end


  end
end

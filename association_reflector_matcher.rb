module Spec
  module Rails
    module Matchers
      class AssociationReflector
        private
        attr_reader :expected, :actual, :macro, :options
        public
        def initialize(macro, expected, options = {})
          @macro = macro
          @expected = expected
          @options = options.symbolize_keys!
        end

        def matches?(object)
          @actual = object.is_a?(Class) ? object : object.class
          association = @actual.reflect_on_association(@expected)
          return false unless association.macro.to_sym == @macro.to_sym
          return true if options.empty?
          [:class_name, :polymorphic, :dependent, :as, :through].each do |option_key|
            if options.has_key?(option_key)
              return false unless association.options[option_key] == options[option_key]
            end
          end
          true
        rescue
          nil
        end

        def failure_message
          "expected #{actual.to_s} #{macro} #{expected} #{options.inspect}"
        end

        def negative_failure_message
          "expected #{actual.to_s} not #{macro} #{expected} #{options.inspect}"
        end

        def to_s
          "#{macro} #{expected.inspect}"
        end


      end
      [:belongs_to, :has_many, :has_one].each do |macro|
        define_method macro do |association, *options|
          AssociationReflector.new(macro, association, *options)
        end
      end
      alias_method :belong_to, :belongs_to
      alias_method :have_many, :has_many
      alias_method :have_one, :has_one
    end
  end
end

module Spec
  module Rails
    module Matchers
      class AttributeMatcher
        private
        attr_reader :attributes
        public
        def initialize(*attributes)
          @attributes = attributes.flatten
        end

        def matches?(object)
          @actual = object.is_a?(Class) ? object.new : object
          attributes.detect { |attribute| !(@actual.send(attribute) && @actual.send("#{attribute}=")) }
        end

        def failure_message
          "expected #{actual.class.to_s} to have attributes #{attributes.inspect}"
        end

        def negative_failure_message
          "expected #{actual.class.to_s} to NOT have attributes #{attributes.inspect}"
        end

        def to_s
          "#{actual.class.to_s} #{attributes.inspect}"
        end
      end
      def has_attribute?(*attributes)
        AttributeMatcher.new(*attributes)
      end
      alias_method :has_attributes?, :has_attribute?
      alias_method :have_attributes?, :has_attribute?
      alias_method :have_attributes, :has_attribute?
      alias_method :have_attribute, :has_attribute?
      alias_method :have_attribute?, :has_attribute?
    end
  end
end

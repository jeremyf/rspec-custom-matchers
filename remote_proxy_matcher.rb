module Spec
  module Rails
    module Matchers
      def have_attributes_for_creation(*attributes)
        attributes.flatten!
        return simple_matcher("model to have #{attributes.inspect} for creation") do |model|
          if model.attributes_for_creation.keys.size != attributes.size
            false
          elsif (model.attributes_for_creation.keys & attributes).size != attributes.size
            false
          else
            true
          end
        end
      end

      def have_remote_resource_required_attributes(*attributes)
        attributes.flatten!
        return simple_matcher("model to have required attributes #{attributes.inspect}") do |model|
          if model.class.required_attributes.size != attributes.size
            false
          elsif (model.class.required_attributes & attributes).size != attributes.size
            false
          else
            true
          end
        end
      end
    end
  end
end

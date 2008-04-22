module Spec
  module Rails
    module Matchers
      # it { @object.should have_class_property :table_name, 'objects' }
      def have_class_property(method_name, value)
        return simple_matcher("class to have #{method_name} of #{value.inspect}") do |model|
          model.class.send(method_name) == value
        end          
      end      
      alias_method :has_class_property, :have_class_property
    end
  end
end

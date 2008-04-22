class Spec::Rails::Example::RailsExampleGroup
  class << self
    def it_should_render_content_for(value)
      description_text = @description_text
      it "should render content for #{value.inspect}" do
        template.should_receive(:content_for).with(value)
        render description_text
      end
    end
    def method_missing(missing_method_name, *args)
      args.flatten!
      if match = missing_method_name.to_s.match(/^it_should_(not_)?(.*)/)
        work_args = args.dup
        method_name = work_args.shift
        options = work_args
        if match[1] == 'not_'
          it "should NOT #{match[2].gsub(/_/, ' ')} #{method_name.inspect} #{work_args.inspect unless work_args.empty?}" do
            self.class.description.constantize.new.send(:should_not, send(match[2], *args))
          end
        else
          it "should #{match[2].gsub(/_/, ' ')} #{method_name.inspect} #{work_args.inspect unless work_args.empty?}" do
            self.class.description_text.constantize.new.send(:should, send(match[2], *args))
          end
        end
      else
        super
      end
    end
  end
end

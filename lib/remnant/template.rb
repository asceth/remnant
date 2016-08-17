class Remnant
  class Template

    module ClassMethods
      def disable!
        @enabled = false
      end

      def enable!
        @enabled = true
      end

      def enabled?
        @enabled
      end

      def record(template)
        return yield unless Remnant::Template.enabled?

        trace.start(template)
        begin
          result = yield
        ensure
          trace.finished(template)
        end
        return result
      end

      def reset
        Thread.current['remnant.template.trace'] = Remnant::Template::Trace.new
      end

      def trace
        Thread.current['remnant.template.trace'] ||= Remnant::Template::Trace.new
      end
    end
    extend ClassMethods
  end
end

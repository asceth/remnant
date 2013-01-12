class Remnant
  class GC
    module ClassMethods
      def enabled?
        _gc.enabled?
      end

      def enable_stats
        _gc.enable_stats
      end

      def disable_stats
        _gc.disable_stats
      end

      def clear_stats
        _gc.clear_stats
      end

      def time
        _gc.time
      end

      def collections
        _gc.collections
      end

      def _gc
        Thread.current['remnant.gc'] ||= _gc_implementation
      end

      def _gc_implementation
        if ::GC.respond_to?(:time) && ::GC.respond_to?(:collections)
          Remnant::GC::Ree
        else
          Remnant::GC::Base
        end
      end
    end
    extend ClassMethods
  end
end

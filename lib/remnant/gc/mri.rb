class Remnant
  class GC
    class Mri
      module ClassMethods
        def enabled?
          true
        end

        def time
          # returns time in seconds, so convert to ms
          ::GC::Profiler.total_time * 1000
        end

        def collections
          ::GC::Profiler.raw_data.try(:size) || 0
        end

        def enable_stats
          ::GC::Profiler.enable
        end

        def disable_stats
          ::GC::Profiler.disable
        end

        def clear_stats
          ::GC::Profiler.clear
        end
      end
      extend ClassMethods
    end
  end
end

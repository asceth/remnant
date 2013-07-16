class Remnant
  class GC
    class Profiler
      module ClassMethods
        def enabled?
          ::GC::Profiler.enabled?
        end

        def time
          # returns time in seconds so convert to ms
          @time ||= raw_data.map {|data| data[:GC_TIME]}.sum * 1000
        end

        def raw_data
          @raw_data ||= ::GC::Profiler.raw_data || []
        end

        def collections
          raw_data.size
        end

        def enable_stats
          ::GC::Profiler.enable
        end

        def disable_stats
          ::GC::Profiler.disable
        end

        def clear_stats
          @raw_data = nil
          ::GC::Profiler.clear
        end
      end
      extend ClassMethods
    end
  end
end

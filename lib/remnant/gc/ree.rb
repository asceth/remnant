class Remnant
  class GC
    class Ree
      module ClassMethods
        def enabled?
          true
        end

        def time
          # returns time in microseconds so convert to ms
          ::GC.time / 1000
        end

        def collections
          ::GC.collections
        end

        def enable_stats
          ::GC.enable_stats
        end

        def disable_stats
          ::GC.disable_stats
        end

        def clear_stats
          ::GC.clear_stats
        end
      end
      extend ClassMethods
    end
  end
end

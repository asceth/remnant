class Remnant
  class GC
    class Base
      module ClassMethods
        def time
          0
        end

        def collections
          0
        end

        def enable_stats
          true
        end

        def disable_stats
          true
        end

        def clear_stats
          true
        end
      end
      extend ClassMethods
    end
  end
end

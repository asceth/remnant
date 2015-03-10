class Remnant
  class Filters
    module ClassMethods
      def record(filter_type, filter_name, &block)
        # ignore AroundFilters
        if filter_type.to_s == 'ActionController::Filters::AroundFilter'
          return block.call
        else
          start_time = Time.now
          result = block.call
          time = Time.now - start_time
          filters << {:type => filter_type, :name => filter_name, :time => time, :ms => time * 1000}

          return result
        end
      end

      def reset
        @total_time = nil
        Thread.current['remnant.filters.set'] = []
      end

      def filters
        Thread.current['remnant.filters.set'] ||= []
      end

      def total_time
        @total_time ||= filters.map {|filter| filter[:ms]}.sum
      end
    end
    extend ClassMethods
  end
end

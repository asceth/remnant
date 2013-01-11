class Remnant
  class Filters
    module ClassMethods
      def record(filter_type, filter_name, &block)
        start_time = Time.now
        result = block.call
        filters << Remnant::Filters::Filter.new(filter_type, filter_name, Time.now - start_time)

        return result
      end

      def reset
        @total_time = nil
        Thread.current['remnant.filters.set'] = []
      end

      def filters
        Thread.current['remnant.filters.set'] ||= []
      end

      def total_time
        @total_time ||= filters.map(&:time).sum * 1000
      end
    end
    extend ClassMethods
  end
end

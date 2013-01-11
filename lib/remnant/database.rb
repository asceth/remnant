class Remnant
  class Database
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

      def unsuppress!
        @suppress = false
      end

      def suppress?
        @suppress || true
      end

      def record(sql, backtrace = [], &block)
        return block.call unless Remnant::Database.enabled?

        start_time = Time.now
        result = block.call
        queries << Remnant::Database::Query.new(sql, Time.now - start_time, backtrace)

        return result
      end

      def reset
        @suppress = true
        @total_time = nil
        Thread.current['remnant.database.queries'] = []
      end

      def queries
        Thread.current['remnant.database.queries'] ||= []
      end

      def total_time
        @total_time ||= queries.map(&:time).sum * 1000
      end
    end
    extend ClassMethods
  end
end

class Remnant
  class Database
    class Query
      attr_reader :sql
      attr_reader :time
      attr_reader :backtrace

      def initialize(sql, time, backtrace = [])
        @sql = sql
        @time = time
        @backtrace = backtrace
      end

      def inspectable?
        sql.strip =~ /^SELECT /i
      end
    end
  end
end

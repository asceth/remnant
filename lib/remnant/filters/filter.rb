class Remnant
  class Filters
    class Filter
      attr_reader :time
      attr_reader :name
      attr_reader :type

      def initialize(type, name, time)
        @type = type
        @name = name
        @time = time
      end
    end
  end
end

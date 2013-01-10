class Remnant
  class Template
    class Rendering
      attr_accessor :name
      attr_accessor :start_time
      attr_accessor :end_time
      attr_accessor :parent
      attr_accessor :children

      def initialize(name)
        @name = name
        @children = []
      end

      def add(rendering)
        @children << rendering
        rendering.parent = self
      end

      def time
        @end_time - @start_time
      end

      def exclusive_time
        time - child_time
      end

      def child_time
        children.inject(0.0) {|memo, c| memo + c.time}
      end

      def results
        @results ||= {name.to_s => {
            'time' => time * 1000.0,
            'exclusive' => exclusive_time * 1000.0,
            'children' => children.map(&:results)
          }
        }
      end
    end
  end
end

class Remnant
  module Discover
    module ClassMethods
      def find(key, klass, method, instance = true)
        rediscover(key, klass, method, instance) if ActiveSupport::Dependencies.will_unload?(klass)
        _inject(key, klass, method, instance)
      end

      def _inject(key, klass, method, instance)
        klass.class_eval <<-EOL, __FILE__, __LINE__
          #{"class << self" unless instance}
          alias_method :#{method}_without_remnant, :#{method}

          def #{method}(*args, &block)
            ::Remnant::Discover.measure(#{key.inspect}) do
              #{method}_without_remnant(*args, &block)
            end
          end

          #{"end" unless instance}
        EOL
      end

      def find_with(klass, &block)
        rediscover(klass, block) if ActiveSupport::Dependencies.will_unload?(klass)
        block.call
      end

      def measure(key, &block)
        if Remnant::Discover.running.include?(key)
          yield
        else
          result = nil
          Remnant::Discover.running << key
          begin
            Remnant::Discover.results[key] += Benchmark.ms { result = yield }.to_i
          rescue
            raise
          ensure
            Remnant::Discover.running.delete(key)
          end
          result
        end
      end

      def results
        Thread.current[:result] ||= Hash.new(0)
      end

      def running
        Thread.current[:running] ||= []
      end

      def remnants_to_rediscover
        @remnants_to_rediscover ||= []
      end

      def rediscover(*args)
        remnants_to_rediscover << args unless remnants_to_rediscover.include?(args)
      end

      def rediscover!
        remnants_to_rediscover.map do |remnant|
          if remnant.size == 4
            key, klass_name, method, instance = remnant
            _inject(key, klass_name.constantize, method, instance)
          else
            remant.first.call
          end
        end
      end
    end
    extend ClassMethods
  end
end

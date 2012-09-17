class Remnant
  module Discover
    module ClassMethods
      def find(key, klass, method, instance = true)
        rediscover(key, klass, method, instance) if ActiveSupport::Dependencies.will_unload?(klass)

        klass.class_eval <<-EOL, __FILE__, __LINE__
          #{"class << self" unless instance}
          def #{method}_with_remnant(*args, &block)
            ::Remnant::Discover.measure(#{key.inspect}) do
              #{method}_without_remnant(*args, &block)
            end
          end

          alias_method_chain :#{method}, :remnant
          #{"end" unless instance}
        EOL
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
        remnants_to_rediscover.map do |(key, klass_name, method, instance)|
          find(key, klass_name.constantize, method, instance)
        end
      end
    end
    extend ClassMethods
  end
end

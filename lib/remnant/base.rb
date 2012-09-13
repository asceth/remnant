class Remnant
  module ClassMethods
    def configure(&block)
      configuration.instance_eval(&block)
    end

    def configuration
      @configuration ||= Remnant::Configuration.new.defaults!
    end

    def handler
      @handler ||= Statsd.new(Remnant.configuration.hostname, Remnant.configuration.port_number)
    end

    def collect
      extra_remnant_key = Remnant::Discover.results.delete(:extra_remnant_key)

      if ::Rails.env.production? || ::Rails.env.staging? || ::Rails.env.demo?
        # send on
        Remnant::Discover.results.map do |remnant_key, ms|
          key = [
                 Remnant.configuration.tag,
                 Remnant.configuration.env,
                 extra_remnant_key,
                 remnant_key
                ].compact.join('.')

          Remannt.handler.timing(key, ms.to_i)
        end
      else
        # log it
        Rails.logger.info "--------------Remnants Discovered--------------"

        Remnant::Discover.results.map do |remnant_key, ms|
          key = [
                 extra_remnant_key,
                 remnant_key
                ].compact.join('.')

          Rails.logger.info "#{ms.to_i}ms\t#{key}"
        end

        Rails.logger.info "-----------------------------------------------"
      end

      Remnant::Discover.results.clear
    end
  end
  extend ClassMethods
end

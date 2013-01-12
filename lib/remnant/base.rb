class Remnant
  module ClassMethods
    def color(default = false, heading = false)
      return "\033[0m" if default
      return "\033[0;01;33m" if heading

      @current_color ||= "\033[0;01;36m"
      @next_color ||= "\033[0;01;35m"

      @current_color, @next_color = @next_color, @current_color
      @current_color
    end

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
      @sample_counter ||= 0

      extra_remnant_key = Remnant::Discover.results.delete(:extra_remnant_key)

      if ::Rails.env.production? || ::Rails.env.staging? || ::Rails.env.demo?
        # only log if above sample rate
        if @sample_counter > configuration.sample_rate
          key_prefix = [
                        Remnant.configuration.tag,
                        Remnant.configuration.env,
                        extra_remnant_key
                       ].compact.join('.')

          Remnant::Discover.results.map do |remnant_key, ms|
            Remnant.handler.timing("#{key_prefix}.#{remnant_key}", ms.to_i)
          end

          Remnant.handler.timing("#{key_prefix}.gc", Remnant::GC.time.to_i)
          Remnant.handler.timing("#{key_prefix}.db", Remnant::Database.total_time.to_i)

          @sample_counter = 0
        else
          @sample_counter += 1
        end
      else
        # always log in development mode
        Rails.logger.info "#{color(false, true)}--------------Remnants Discovered--------------#{color(true)}"

        Remnant::Discover.results.map do |remnant_key, ms|
          key = [
                 extra_remnant_key,
                 remnant_key
                ].compact.join('.')

          Rails.logger.info "#{Remnant.color}#{ms.to_i}ms#{Remnant.color(true)}\t#{key}"
        end
        Rails.logger.info "#{Remnant.color}#{Remnant::GC.time.to_i}ms (#{Remnant::GC.collections} collections)#{Remnant.color(true)}\tGC"

        # filters
        Rails.logger.info ""
        Rails.logger.info("#{color(false, true)}----- Filters (%.2fms) -----#{color(true)}" % Remnant::Filters.total_time)
        Remnant::Filters.filters.map do |filter|
          Rails.logger.info("#{color}%.2fms#{color(true)}\t#{filter[:name]} (#{filter[:type]})" % filter[:ms])
        end

        # template captures
        if Remnant::Template.enabled?
          Rails.logger.info ""
          Rails.logger.info "#{color(false, true)}----- Templates -----#{color(true)}"
          Remnant::Template.trace.root.children.map do |rendering|
            Remnant::Template.trace.log(Rails.logger, rendering)
          end
        end

        # sql captures
        Rails.logger.info ""
        Rails.logger.info("#{color(false, true)}---- Database (%.2fms) -----#{color(true)}" % Remnant::Database.total_time)
        if Remnant::Database.suppress?
          Rails.logger.info "queries suppressed in development mode"
        else
          Remnant::Database.queries.map do |query|
            Rails.logger.info("#{color}%.2fms#{color(true)}\t#{query.sql}" % (query.time * 1000))
          end
        end

        Rails.logger.info "#{color(false, true)}-----------------------------------------------#{color(true)}"
      end

      # run hook if given
      unless Remnant.configuration.custom_hook.nil?
        Remnant.configuration.custom_hook.call(Remnant::Discover.results)
      end

      Remnant::Database.reset
      Remnant::Template.reset
      Remnant::Filters.reset
      Remnant::Discover.results.clear
    end
  end
  extend ClassMethods
end

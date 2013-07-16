class Remnant
  class Rack
    def initialize(app)
      @app = app
    end

    def call(env)
      @response = [500, '', '']

      if env['REQUEST_PATH'].include?('/asset')
        @response = @app.call(env)
      else

        begin
          # only gc capture as dev
          if env['rack.request.cookie_hash']['developer']
            ::Remnant::GC.enable_stats
          end

          # record request time
          ::Remnant::Discover.measure('request') do
            @response = @app.call(env)
          end

          # collect & clear stats for next request
          ::Remnant.collect

          # only gc capture as dev
          if env['rack.request.cookie_hash']['developer']
            ::Remnant::GC.clear_stats
          end

          ::Rails.logger.flush if ::Rails.logger.respond_to?(:flush)
        rescue ::Exception => exception
          if defined?(Flail)
            Flail::Exception.new(env, exception).handle!
          end

          raise
        end
      end

      @response
    end
  end
end

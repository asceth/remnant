class Remnant
  class Rails
    module ClassMethods
      def setup!
        Remnant.configure do
          environment ::Rails.env
        end

        #
        # helper hooks
        #

        # hook into dependency unloading
        ::ActiveSupport::Dependencies.class_eval do
          class << self
            def clear_with_remnant_rediscover(*args, &block)
              clear_without_remnant_rediscover(*args, &block).tap do
                Remnant::Discover.rediscover!
              end
            end
            alias_method_chain :clear, :remnant_rediscover
          end
        end


        #
        # stat collection below
        #

        # hook remnants
        Remnant::Discover.find('request',  ActionController::Dispatch,              :call)
        Remnant::Discover.find('dispatch', ActionController::Dispatch,              :_call)
        Remnant::Discover.find('process',  ActionController::Base,                  :process)
        Remnant::Discover.find('filters',  ActionController::Filters::BeforeFilter, :call)
        Remnant::Discover.find('action',   ActionController::Base,                  :perform_action)
        Remnant::Discover.find('rendering',ActionController::Base,                  :render)
        Remnant::Discover.find('filters',  ActionController::Filters::AfterFilter,  :call)

        # last hook into request cycle for sending results
        ::ActionController::Dispatcher.class_eval do
          def call_with_remnant_discovery(*args, &block) #:nodoc:
            call_without_remnant_discovery(*args, &block).tap do |status, headers, response|
              Remnant.collect(ActionController::Request.new(args.first))
              Rails.logger.flush if Rails.logger.respond_to? :flush
            end
          end
          alias_method_chain :call, :remnant_discovery
        end

        # hook into perform_action for the extra remnant key
        ::ActionController::Base.class_eval do
          def call_with_remnant_key(*args, &block) #:nodoc:
            Remnant::Discover.results[:extra_remnant_key] = "#{request.controller}.#{request.action}"
            call_without_remnant_key(*args, &block)
          end
          alias_method_chain :call, :remnant_key
        end
      end # setup!
    end
    extend ClassMethods
  end
end

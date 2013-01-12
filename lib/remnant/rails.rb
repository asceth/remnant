class Remnant
  class Rails
    module ClassMethods
      def logger
        ::Rails.logger
      end

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
        Remnant::Discover.find('request',  ActionController::Dispatcher,            :call)
        Remnant::Discover.find('action',   ActionController::Base,                  :perform_action)
        Remnant::Discover.find('view',     ActionController::Base,                  :render)

        #
        # Filter capturing
        #
        [
         ActionController::Filters::BeforeFilter,
         ActionController::Filters::AfterFilter,
         ActionController::Filters::AroundFilter
        ].map do |remnant_constant|
          Remnant::Discover.find_with(remnant_constant) do
            remnant_constant.class_eval do
              def call_with_remnant(*args, &block)
                ::Remnant::Filters.record(self.class.to_s, method.to_s) do
                  call_without_remnant(*args, &block)
                end
              end

              alias_method_chain :call, :remnant
            end
          end
        end

        #
        # Template rendering
        #
        if defined?(ActionView) && defined?(ActionView::Template)
          Remnant::Discover.find_with(ActionView::Template) do
            ActionView::Template.class_eval do
              def render_template_with_remnant(*args, &block)
                ::Remnant::Template.record(path_without_format_and_extension) do
                  render_template_without_remnant(*args, &block)
                end
              end

              alias_method_chain :render_template, :remnant
            end
          end
        end

        #
        # database query time
        #
        if ::Rails::VERSION::MAJOR == 2
          Remnant::Discover.find_with(ActiveRecord::ConnectionAdapters::AbstractAdapter) do
            ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval do
              def log_with_remnant(sql, name, &block)
                ::Remnant::Database.record(sql, Kernel.caller) do
                  log_without_remnant(sql, name, &block)
                end
              end

              alias_method_chain :log, :remnant
            end
          end
        end

        # last hook into request cycle for sending results
        ::ActionController::Dispatcher.class_eval do
          def call_with_remnant_discovery(*args, &block) #:nodoc:
            ::Remnant::GC.enable_stats
            call_without_remnant_discovery(*args, &block).tap do |status, headers, response|
              ::Remnant::GC.disable_stats
              begin
                ::Remnant.collect
                ::Remnant::GC.clear_stats
                ::Rails.logger.flush if ::Rails.logger.respond_to? :flush
              rescue Exception => e
                if defined?(::Flail)
                  Flail::Exception.notify(e)
                else
                  Rails.logger.error e.inspect
                end
              end
            end
          end
          alias_method_chain :call, :remnant_discovery
        end

        # hook into perform_action for the extra remnant key
        ::ActionController::Base.class_eval do
          def perform_action_with_remnant_key(*args, &block) #:nodoc:
            perform_action_without_remnant_key(*args, &block)
          end
          alias_method_chain :perform_action, :remnant_key
        end
      end # setup!
    end
    extend ClassMethods
  end
end

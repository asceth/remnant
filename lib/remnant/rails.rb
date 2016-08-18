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
            alias_method :clear_without_remnant_rediscover, :clear

            def clear(*args, &block)
              clear_without_remnant_rediscover(*args, &block).tap do
                Remnant::Discover.rediscover!
              end
            end
          end
        end


        #
        # stat collection below
        #

        # hook remnants
        Remnant::Discover.find('action',   ActionController::Base,                  :process_action)
        Remnant::Discover.find('view',     ActionController::Base,                  :render)

        #
        # Filter capturing
        #
        # TODO

        #
        # Template rendering
        #
        if defined?(ActionView) && defined?(ActionView::Template)
          Remnant::Discover.find_with(ActionView::Template) do
            ActionView::Template.class_eval do
              alias_method :render_without_remnant, :render

              def render(*args, &block)
                ::Remnant::Template.record(@virtual_path) do
                  render_without_remnant(*args, &block)
                end
              end
            end
          end
        end

        #
        # database query time
        #
        ActiveSupport::Notifications.subscribe("sql.active_record") do |name, started, ended, id, payload|
          duration = ended - started
          trace = ::Rails.backtrace_cleaner.clean(Kernel.caller[1..-1])

          ::Remnant::Database.queries << ::Remnant::Database::Query.new(payload[:sql], duration, trace)
        end
      end # setup!
    end
    extend ClassMethods
  end
end

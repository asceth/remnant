class Remnant
  class Railtie < ::Rails::Railtie
    initializer "remnant.use_rack_middleware" do |app|
      app.config.middleware.use ::Remnant::Rack
    end

    config.after_initialize do
      ::Remnant::Rails.setup!
    end
  end
end

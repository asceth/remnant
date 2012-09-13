class Remnant
  class Railtie < ::Rails::Railtie
    config.after_initialize do
      Remnant::Rails.setup!
    end
  end
end

class Remnant
  class Configuration
    # environment of application
    attr_reader :env

    # hostname to send to
    attr_reader :hostname

    # port to send to
    attr_reader :port_number

    # api key to use with payloads
    attr_reader :tag

    def host(value)
      @hostname = value
    end

    def port(value)
      @port_number = value
    end

    def tagged(value)
      @tag = value
    end

    def environment(value)
      @env = value
    end

    def defaults!
      # configure some defaults

      @hostname = '127.0.0.1'
      @port_number = 8125
      @tag = 'remnant'

      self
    end # end defaults!
  end
end

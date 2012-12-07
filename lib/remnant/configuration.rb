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

    # how often to use results
    attr_reader :sample_rate

    # allow applications to run custom code with stats
    attr_reader :custom_hook

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

    def sample(value)
      @sample_rate = value
    end

    def hook(&block)
      @custom_hook = block
    end

    def defaults!
      # configure some defaults

      @hostname = '127.0.0.1'
      @port_number = 8125
      @tag = 'remnant'
      @sample_rate = 10

      self
    end # end defaults!
  end
end

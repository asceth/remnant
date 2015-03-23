#
# majority of this code comes from NewRelic RPM
#
class Remnant
  class Queue
    FRONTEND_START_HEADER = 'HTTP_X_FRONTEND_START'.freeze
    LOAD_BALANCED_START_HEADER = 'HTTP_X_LOAD_BALANCER_START'.freeze

    START_HEADERS = {
      'lb' => [
        LOAD_BALANCED_START_HEADER
      ],
      'fe' => [
        FRONTEND_START_HEADER
      ]
    }.freeze

    # any timestamps before this are thrown out and the parser
    # will try again with a larger unit (2000/1/1 UTC)
    EARLIEST_ACCEPTABLE_TIME = 946684800


    class << self
      def process!
        lb_queue_start = ::Remnant::Discover.results.delete('lb_queue_start')
        fe_queue_start = ::Remnant::Discover.results.delete('fe_queue_start')
        app_queue_start = ::Remnant::Discover.results.delete('app_queue_start')

        if lb_queue_start && fe_queue_start
          ms = (fe_queue_start - lb_queue_start).round(2) # ms

          # if negative, clamp to 0
          if ms < 0
            ms = 0
          end

          ::Remnant::Discover.results['queue_lb'] = ms
        end

        if fe_queue_start && app_queue_start
          ms = (app_queue_start - fe_queue_start).round(2) # ms

          # if negative, clamp to 0
          if ms < 0
            ms = 0
          end

          ::Remnant::Discover.results['queue_fe'] = ms
        end
      end

      def parse_frontend_timestamp(headers, role, unit = :second, now = Time.now.to_f)
        now = now.to_f if now.is_a?(Time)
        earliest = nil

        (START_HEADERS[role] || []).map do |header|
          if headers[header]
            parsed = parse_timestamp(timestamp_string_from_header_value(headers[header]), unit)

            if parsed && (!earliest || parsed < earliest)
              earliest = parsed
            end
          end
        end

        if earliest && earliest > now
          earliest = now
        end

        earliest
      end

      def timestamp_string_from_header_value(value)
        case value
        when /^\s*([\d+\.]+)\s*$/ then $1
        # following regexp intentionally unanchored to handle
        # (ie ignore) leading server names
        when /t=([\d+\.]+)/       then $1
        end
      end

      # bring everything into a millisecond precision
      def parse_timestamp(string, unit = :second)
        case unit
        when :second
          string.to_f * 1_000.0
        when :millisecond
          string.to_f
        when :microsecond
          string.to_f / 1_000
        end
      end
    end
  end
end

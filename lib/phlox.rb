require 'active_resource/extend/static_path'
Dir.glob(File.dirname(__FILE__) + '/phlox/*.rb'){ |file| require file }
Dir.glob(File.dirname(__FILE__) + '/phlox/validators/*.rb'){ |file| require file }

module Phlox
end

if defined?(Rails)
  require "phlox/engine"

  if Rails.env.development?

    # Helps with debugging
    class ActiveResource::Connection
      private
      def configure_http(http)
        http = apply_ssl_options(http)

        # Net::HTTP timeouts default to 60 seconds.
        if @timeout
          http.open_timeout = @timeout
          http.read_timeout = @timeout
        end
        http.set_debug_output $stderr
        http
      end
    end

  end

end

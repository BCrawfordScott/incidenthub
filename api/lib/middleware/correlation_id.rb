# frozen_string_literal: true

require "securerandom"

module Middleware
  class CorrelationId
    RESPONSE_HEADER = "X-Correlation-Id"

    def initialize(app)
      @app = app
    end

    def call(env)
      correlation_id =
        env["HTTP_X_CORRELATION_ID"].presence ||
        env["HTTP_X_REQUEST_ID"].presence ||
        SecureRandom.uuid

      # Normalize so downstream code can always rely on this key existing
      env["HTTP_X_CORRELATION_ID"] = correlation_id

      Current.correlation_id = correlation_id

      status, headers, body = @app.call(env)

      headers[RESPONSE_HEADER] ||= correlation_id
      [status, headers, body]
    ensure
      Current.reset
    end
  end
end

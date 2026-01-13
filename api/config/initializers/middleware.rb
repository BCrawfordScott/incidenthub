# frozen_string_literal: true

require Rails.root.join("lib/middleware/correlation_id")

Rails.application.config.middleware.insert_before(0, Middleware::CorrelationId)
# frozen_string_literal: true

# Sidekiq::Web requires a Rack session for CSRF protection.
# Rails API mode doesn't include cookies/sessions by default, so we add them
# ONLY in development for the Sidekiq UI.

return unless Rails.env.development?

Rails.application.config.middleware.use ActionDispatch::Cookies

Rails.application.config.session_store :cookie_store, key: "_incidenthub_session"

Rails.application.config.middleware.use ActionDispatch::Session::CookieStore,
  Rails.application.config.session_options

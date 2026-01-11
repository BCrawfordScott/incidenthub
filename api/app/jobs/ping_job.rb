# frozen_string_literal: true

class PingJob < ApplicationJob
  queue_as :default

  def perform(message: "pong")
    # Do something later
    Rails.logger.info "[PingJob] #{message}"
  end
end

require "active_support/current_attributes"

class Current < ActiveSupport::CurrentAttributes
  attribute :correlation_id, :organization, :user
end
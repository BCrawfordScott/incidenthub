require 'rails_helper'

RSpec.describe Organization, type: :model do
  subject { build(:organization) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to allow_value(nil).for(:billing_email) }
    it { is_expected.to allow_value('test@example.com').for(:billing_email) }
    it { is_expected.not_to allow_value('invalid-email').for(:billing_email) }
  end

  it "defaults status to 'enabled'" do
    organization = Organization.new
    expect(organization.status).to eq('enabled')
  end
end

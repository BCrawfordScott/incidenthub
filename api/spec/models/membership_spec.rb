require 'rails_helper'

RSpec.describe Membership, type: :model do
  subject { build(:membership) }

  it {is_expected.to belong_to(:user) }
  it {is_expected.to belong_to(:organization) }

  it "defaults role to 'member'" do
    expect(subject.role).to eq('member')
  end

  it "enforces uniqueness of user per organization" do
    subject.save!
    failed_membership = build(:membership, user: subject.user, organization: subject.organization)
    expect(failed_membership).not_to be_valid
    expect(failed_membership.errors[:user_id]).to include("has already been taken")
  end
end

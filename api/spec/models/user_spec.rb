# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  subject { build(:user) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_length_of(:email).is_at_most(255) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to allow_value("a@b.com").for(:email) }
    it { is_expected.not_to allow_value("not-an-email").for(:email) }
  end

  it "authenticates with correct password" do
    subject.save!
    expect(subject.authenticate("Password123!")).to eq(subject)
  end

  it "rejects incorrect password" do
    subject.save!
    expect(subject.authenticate("wrong")).to be false
  end

  describe "soft deletion" do
    it "sets deleted_at instead of destroying the record" do
      user = create(:user)
      expect { user.soft_delete! }.to change { user.deleted_at }.from(nil)
      expect(User.find_by(id: user.id)).to be_present
    end

    it "marks the user as disabled upon soft deletion" do
      user = create(:user, status: :active)
      user.soft_delete!
      expect(user.status).to eq("disabled")
    end
  end

  describe "deleted? method" do
    it "returns true if deleted_at is set" do
      user = create(:user, deleted_at: Time.current)
      expect(user.deleted?).to be true
    end

    it "returns false if deleted_at is nil" do
      user = create(:user, deleted_at: nil)
      expect(user.deleted?).to be false
    end
  end
end

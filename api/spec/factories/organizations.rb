FactoryBot.define do
  factory :organization do
    name { Faker::Company.unique.name }
    status { :enabled }
    billing_email { Faker::Internet.unique.email }
    billing_metadata { { plan: 'basic' } }
  end
end
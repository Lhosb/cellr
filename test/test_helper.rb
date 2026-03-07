ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors)

  def build_user(email_suffix: SecureRandom.hex(4))
    User.create!(email: "user-#{email_suffix}@example.com")
  end

  def build_cellar(name: "Test Cellar", owner: build_user)
    Cellar.create!(name:, owner:)
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def sign_in_as(user = build_user)
    sign_in user
    user
  end
end

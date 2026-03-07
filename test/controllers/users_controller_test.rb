require "test_helper"

module Users
  class RegistrationsControllerTest < ActionDispatch::IntegrationTest
    test "registration creates account via html" do
      assert_difference("User.count", 1) do
        post user_registration_path, params: {
          user: {
            email: "new-user-html@example.com",
            password: "Password123!",
            password_confirmation: "Password123!"
          }
        }
      end

      assert_response :redirect
    end

    test "registration creates account via json" do
      assert_difference("User.count", 1) do
        post user_registration_path, params: {
          user: {
            email: "new-user-json@example.com",
            password: "Password123!",
            password_confirmation: "Password123!"
          }
        }, as: :json
      end

      assert_response :created
      body = JSON.parse(response.body)
      assert_equal "new-user-json@example.com", body.dig("user", "email")
    end

    test "registration creates account when other users already exist" do
      User.create!(email: "other@example.com", password: "Password123!", password_confirmation: "Password123!")

      assert_difference("User.count", 1) do
        post user_registration_path, params: {
          user: {
            email: "another@example.com",
            password: "Password123!",
            password_confirmation: "Password123!"
          }
        }
      end

      assert_response :redirect
    end

    test "registration provisions default cellar for new user" do
      post user_registration_path, params: {
        user: {
          email: "cellar-user@example.com",
          password: "Password123!",
          password_confirmation: "Password123!"
        }
      }

      user = User.find_by!(email: "cellar-user@example.com")
      assert user.cellar_memberships.exists?(role: :owner)
      assert user.owned_cellars.any?
    end

    test "registration activates invited user via html" do
      invited_user = User.create!(email: "invited@example.com")
      assert invited_user.invited?, "user should be passwordless"

      assert_no_difference("User.count") do
        post user_registration_path, params: {
          user: {
            email: "invited@example.com",
            password: "Password123!",
            password_confirmation: "Password123!"
          }
        }
      end

      assert_response :redirect
      assert_redirected_to root_path
      assert invited_user.reload.activated?, "user should now have a password"
    end

    test "registration activates invited user via json" do
      invited_user = User.create!(email: "invited@example.com")

      assert_no_difference("User.count") do
        post user_registration_path, params: {
          user: {
            email: "invited@example.com",
            password: "Password123!",
            password_confirmation: "Password123!"
          }
        }, as: :json
      end

      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal "invited@example.com", body.dig("user", "email")
      assert invited_user.reload.activated?
    end

    test "registration rejects duplicate email for activated user" do
      User.create!(email: "taken@example.com", password: "Password123!", password_confirmation: "Password123!")

      assert_no_difference("User.count") do
        post user_registration_path, params: {
          user: {
            email: "taken@example.com",
            password: "Password123!",
            password_confirmation: "Password123!"
          }
        }
      end

      assert_response :unprocessable_entity
    end
  end
end

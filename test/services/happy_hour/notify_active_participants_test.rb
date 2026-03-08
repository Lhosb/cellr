require "test_helper"

module HappyHour
  class NotifyActiveParticipantsTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    test "delivers only to other users with active sessions" do
      actor = build_user
      active_recipient = build_user
      inactive_user = build_user

      DrinkingSessions::Start.call(user: actor)
      DrinkingSessions::Start.call(user: active_recipient)

      wine = actor.default_cellar_or_fallback.wines.create!(
        winery: winery_named("Lafon"),
        wine_name: "Volnay",
        vintage: 2020
      )
      record = actor.active_drinking_session.drinking_records.create!(
        cellar_entry: wine,
        consumed_at: Time.current,
        quantity: 1
      )

      assert_difference("Noticed::Event.count", 1) do
        assert_difference("Noticed::Notification.count", 1) do
          perform_enqueued_jobs do
            NotifyActiveParticipants.call(actor:, record:)
          end
        end
      end

      recipients = Noticed::Notification.order(:id).last(1).map(&:recipient)
      assert_equal [ active_recipient.id ], recipients.map(&:id)
      assert_not_includes recipients.map(&:id), actor.id
      assert_not_includes recipients.map(&:id), inactive_user.id
    end
  end
end

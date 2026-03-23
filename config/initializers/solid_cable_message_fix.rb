# Workaround for a Rails 8.1.2 bug where ActiveRecord::InsertAll fails to
# detect the primary key of the solid_cable_messages table, causing:
#   ArgumentError: No unique index found for id
# when SolidCable::Message.insert is called during ActionCable broadcasting.
#
# Root cause: InsertAll#find_unique_index_for falls through to the primary-key
# check, which relies on schema_cache.primary_keys. On the secondary "cable"
# connection in Rails 8.1.2, that value is returned as nil, so the equality
# check ["id"] == [] fails and the ArgumentError is raised.
#
# Workaround: replace insert (which goes through InsertAll) with create!,
# which uses a plain single-row INSERT and bypasses the broken code path.
#
# This can be removed when Rails is upgraded to >= 8.1.3.
module SolidCableMessageBroadcastFix
  def broadcast(channel, payload)
    create!(
      created_at: Time.current,
      channel: channel,
      payload: payload,
      channel_hash: channel_hash_for(channel)
    )
  end
end

Rails.application.config.to_prepare do
  unless SolidCable::Message.singleton_class.ancestors.include?(SolidCableMessageBroadcastFix)
    SolidCable::Message.singleton_class.prepend(SolidCableMessageBroadcastFix)
  end
end

adapter = begin
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection
    if ActiveRecord::Base.connection.data_source_exists?("flipper_features") &&
       ActiveRecord::Base.connection.data_source_exists?("flipper_gates")
      Flipper::Adapters::ActiveRecord.new
    else
      Flipper::Adapters::Memory.new
    end
  else
    Flipper::Adapters::Memory.new
  end
rescue StandardError
  Flipper::Adapters::Memory.new
end

Flipper.configure do |config|
  config.default { Flipper.new(adapter) }
end

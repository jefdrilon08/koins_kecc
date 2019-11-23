Rollbar.configure do |config|
  if Rails.env.development?
    config.enabled = false
  else
    config.access_token = ENV['ROLLBAR_TOKEN']
  end

  if Rials.env.test?
    config.enabled = false
  end
end

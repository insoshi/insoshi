begin
  CarrierWave.configure do |config|
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: ENV['AMAZON_ACCESS_KEY_ID'],
      aws_secret_access_key: ENV['AMAZON_SECRET_ACCESS_KEY'],
      endpoint: 'https://s3.amazonaws.com'
    }
    config.fog_directory = ENV['S3_BUCKET_NAME']
    config.path_style = true
    config.fog_public = Preference.first.public_uploads unless Rails.env.test?
  end
rescue
  nil
end

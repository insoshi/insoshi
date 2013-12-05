namespace :heroku do
  desc "Creates a brand new heroku app and deploys oscurrency to it"
  task :install => :environment do
    APP_CONFIG = YAML.load_file("config/config.yml")

    ui = HighLine.new


    heroku_api_key = APP_CONFIG['HEROKU_API_KEY'] || ui.ask("Enter your Heroku API key: ")

    heroku = Heroku::API.new(:api_key => heroku_api_key)

    begin
      heroku.get_user
    rescue Heroku::API::Errors::Unauthorized
      puts "Unable to authorize your Heroku API key. Please try again"
      next
    rescue Heroku::API::Errors::ErrorWithResponse
      puts "Urk! An error occured when talking to Heroku. Please try again"
      next
    end

    amazon_id = APP_CONFIG['AMAZON_ACCESS_KEY_ID'] || ui.ask("Enter your Amazon Access Key ID: ")

    amazon_secret = APP_CONFIG['AMAZON_SECRET_ACCESS_KEY'] || ui.ask("Enter your Amazon Secret Access Key: ")

    AWS::S3::Base.establish_connection!(
      :access_key_id => amazon_id,
      :secret_access_key => amazon_secret
    )

    heroku_app = heroku.post_app.body

    AWS::S3::Bucket.create(heroku_app['name'])

    # `git remote add heroku git@heroku.com:#{app_name}.git`

    # `heroku config:add BUNDLE_WITHOUT="development:test"`
    # `heroku config:add AMAZON_ACCESS_KEY_ID=#{APP_CONFIG['AMAZON_ACCESS_KEY_ID']}`
    # `heroku config:add AMAZON_SECRET_ACCESS_KEY=#{APP_CONFIG['AMAZON_SECRET_ACCESS_KEY']}`
    # `heroku config:add SMTP_DOMAIN=#{APP_CONFIG['SMTP_DOMAIN']}`
    # `heroku config:add SMTP_SERVER=#{APP_CONFIG['SMTP_SERVER']}`
    # `heroku config:add SMTP_PORT=#{APP_CONFIG['SMTP_PORT']}`
    # `heroku config:add SMTP_USER=#{APP_CONFIG['SMTP_USER']}`
    # `heroku config:add SMTP_PASSWORD=#{APP_CONFIG['SMTP_PASSWORD']}`
    # `heroku config:add S3_BUCKET_NAME=#{app_name}`

    # # default values of preference object will be set to these.
    # `heroku config:add APP_NAME=#{app_name}`
    # `heroku config:add SERVER_NAME=#{app_name + '.' + 'herokuapp.com'}`
    # `heroku addons:add memcachier`
    # unless APP_CONFIG['SMTP_SERVER']
    #   `heroku addons:add sendgrid:starter`
    # end

    # `git push heroku master`
    # `heroku run rake install`
  end

  desc "Updates an existing heroku app with the latest oscurrency build"
  task :update => :environment do
  end

end

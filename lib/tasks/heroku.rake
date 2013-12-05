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

    begin
      AWS::S3::Service.buckets
    rescue AWS::S3::S3Exception => e
      puts e.message
      next
    end

    heroku_app = heroku.post_app.body

    AWS::S3::Bucket.create(heroku_app['name'])

    config_vars = {
      'BUNDLE_WITHOUT' => "development:test",
      'AMAZON_ACCESS_KEY_ID' => amazon_id,
      'AMAZON_SECRET_ACCESS_KEY' => amazon_secret,
      'APP_NAME' => heroku_app['name'],
      'SERVER_NAME' => "#{heroku_app['name']}.herokuapp.com",
      'S3_BUCKET_NAME' => heroku_app['name']
    }

    smtp_vars = {
      'SMTP_DOMAIN' APP_CONFIG['SMTP_DOMAIN'],
      'SMTP_SERVER' => APP_CONFIG['SMTP_SERVER'],
      'SMTP_PORT' => APP_CONFIG['SMTP_PORT'],
      'SMTP_USER' => APP_CONFIG['SMTP_USER'],
      'SMTP_PASSWORD' => APP_CONFIG['SMTP_PASSWORD']
    }

    heroku.put_config_vars(heroku_app['name'], config_vars)

    heroku.put_config_vars(heroku_app['name'], smtp_vars)

    heroku.put_addon(heroku_app['name'], 'memcachier')
    unless APP_CONFIG['SMTP_SERVER']
      heroku.put_addon(heroku_app['name'], 'sendgrid:starter')
    end

    git = Git.open(working_dir, :log => Logger.new(STDOUT))

    git.add_remote('heroku', "git@heroku.com:#{heroku_app['name']}.git")
    git.push('heroku', 'master')

    heroku.post_ps(heroku_app['name'], 'rake install')
  end

  desc "Updates an existing heroku app with the latest oscurrency build"
  task :update => :environment do
  end

end

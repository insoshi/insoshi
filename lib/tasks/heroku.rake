namespace :heroku do
  desc "Creates a brand new heroku app and deploys oscurrency to it"
  task :install => :environment do
    APP_CONFIG = YAML.load_file("config/config.yml")

    ui = HighLine.new

    next unless heroku = auth_to_heroku(ui, APP_CONFIG)

    next unless amazon_credentials = auth_to_amazon(ui, APP_CONFIG)

    print "Creating new heroku app... "
    heroku_app = heroku.post_app.body
    puts "done."

    print "Creating new S3 bucket... "
    AWS::S3::Bucket.create(heroku_app['name'])
    puts "done."

    config_vars = {
      'BUNDLE_WITHOUT' => "development:test",
      'AMAZON_ACCESS_KEY_ID' => amazon_credentials[:id],
      'AMAZON_SECRET_ACCESS_KEY' => amazon_credentials[:secret],
      'APP_NAME' => heroku_app['name'],
      'SERVER_NAME' => "#{heroku_app['name']}.herokuapp.com",
      'S3_BUCKET_NAME' => heroku_app['name']
    }

    smtp_vars = {
      'SMTP_DOMAIN' => APP_CONFIG['SMTP_DOMAIN'],
      'SMTP_SERVER' => APP_CONFIG['SMTP_SERVER'],
      'SMTP_PORT' => APP_CONFIG['SMTP_PORT'],
      'SMTP_USER' => APP_CONFIG['SMTP_USER'],
      'SMTP_PASSWORD' => APP_CONFIG['SMTP_PASSWORD']
    }

    print "Setting config vars... "
    heroku.put_config_vars(heroku_app['name'], config_vars)
    puts "done."

    print "Setting up mail server "
    if APP_CONFIG['SMTP_SERVER']
      print "using provided credentials... "
      heroku.put_config_vars(heroku_app['name'], smtp_vars)
    else
      print "using SendGrid addon... "
      heroku.post_addon(heroku_app['name'], 'sendgrid:starter')
    end
    puts "done."

    print "Setting up memcache... "
    heroku.post_addon(heroku_app['name'], 'memcachier')
    puts "done."

    git = Git.open(Dir.pwd, :log => Logger.new(STDOUT))

    print "Deploying to Heroku... "
    git.add_remote('heroku', "git@heroku.com:#{heroku_app['name']}.git")
    git.push('heroku', 'master')
    puts "done."

    print "Running first time install on Heroku... "
    heroku.post_ps(heroku_app['name'], 'rake install')
    puts "done."

    puts "Deploy completed successfully. App is now available at http://#{heroku_app['name']}.herokuapp.com"
    puts "Thanks!"
  end

  def auth_to_heroku(ui, config)
    heroku_api_key = config['HEROKU_API_KEY'] || ui.ask("Enter your Heroku API key: ")

    heroku = Heroku::API.new(:api_key => heroku_api_key)

    begin
      heroku.get_user
    rescue Heroku::API::Errors::Unauthorized
      puts "Unable to authorize your Heroku API key. Please try again"
      return
    rescue Heroku::API::Errors::ErrorWithResponse
      puts "Urk! An error occured when talking to Heroku. Please try again"
      return
    end

    heroku
  end

  def auth_to_amazon(ui, config)
    amazon_id = config['AMAZON_ACCESS_KEY_ID'] || ui.ask("Enter your Amazon Access Key ID: ")

    amazon_secret = config['AMAZON_SECRET_ACCESS_KEY'] || ui.ask("Enter your Amazon Secret Access Key: ")

    AWS::S3::Base.establish_connection!(
      :access_key_id => amazon_id,
      :secret_access_key => amazon_secret
    )

    begin
      AWS::S3::Service.buckets
    rescue AWS::S3::S3Exception => e
      puts e.message
      return
    end

    {:id => amazon_id, :secret => amazon_secret}
  end


  desc "Updates an existing heroku app with the latest oscurrency build"
  task :update => :environment do
    # TODO
  end

end

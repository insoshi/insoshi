namespace :heroku do
  desc "Creates a brand new heroku app and deploys oscurrency to it"
  task :install => :environment do
    APP_CONFIG = YAML.load_file("config/config.yml")

    ui = HighLine.new

    next unless heroku = auth_to_heroku(ui, APP_CONFIG)

    next unless amazon_credentials = auth_to_amazon(ui, APP_CONFIG)

    print "Creating new heroku app... "
    heroku_app = heroku.post_app.body
    APP_CONFIG["HEROKU_APP"] = heroku_app['name']
    File.open("config/config.yml", 'w+') {|f| f.write(APP_CONFIG.to_yaml) }
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

    print "Setting config vars... "
    heroku.put_config_vars(heroku_app['name'], config_vars)
    puts "done."

    print "Setting up mail server "

    smtp_credentials = collect_smtp_credentials(ui, APP_CONFIG)

    if smtp_credentials['server']
      print "using provided credentials... "
      smtp_vars = {
        'SMTP_SERVER' => smtp_credentials['smtp_server'],
        'SMTP_DOMAIN'=> smtp_credentials['smtp_domain'],
        'SMTP_PORT' => smtp_credentials['smtp_port'],
        'SMTP_USER' => smtp_credentials['smtp_user'],
        'SMTP_PASSWORD' => smtp_credentials['smtp_password']
      }
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
    git.remove_remote('heroku')
    git.add_remote('heroku', "git@heroku.com:#{heroku_app['name']}.git")
    git.push('heroku', 'master')
    puts "done."

    print "Running first time install on Heroku... "
    heroku.post_ps(heroku_app['name'], 'rake install')
    puts "done."

    puts "Deploy completed successfully. App is now available at http://#{heroku_app['name']}.herokuapp.com"
    puts "Thanks!"
  end

  desc "Updates an existing heroku app with the latest oscurrency build"
  task :update => :environment do
    APP_CONFIG = YAML.load_file("config/config.yml")

    ui = HighLine.new

    next unless heroku = auth_to_heroku(ui, APP_CONFIG)

    heroku_app = heroku.get_app(APP_CONFIG["HEROKU_APP"]).body

    git = Git.open(Dir.pwd, :log => Logger.new(STDOUT))

    if ui.agree("Do you want to fetch the latest code from GitHub? ")
      print "Getting latest OSCurrency code... "
      git.pull('origin', 'master')
      puts "done."
    end

    print "Deploying to Heroku... "
    git.push('heroku', 'master')
    puts "done."

    print "Running database migrations... "
    heroku.post_ps(heroku_app['name'], 'rake db:migrate')
    puts "done."

    puts "Update completed successfully. App is now available at http://#{heroku_app['name']}.herokuapp.com"
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

  def collect_smtp_credentials(ui, config)

    smtp_server = config['SMTP_SERVER'] || ui.ask("Enter your SMTP server address (or leave blank to use SendGrid): ")

    unless smtp_server.blank?
      smtp_domain = config['SMTP_DOMAIN'] || ui.ask("Enter your SMTP domain: ")
      smtp_port = config['SMTP_PORT'] || ui.ask("Enter your SMTP port: ")
      smtp_user = config['SMTP_USER'] || ui.ask("Enter your SMTP user: ")
      smtp_password = config['SMTP_PASSWORD'] || ui.ask("Enter your SMTP password: ")
    end

    {:server => smtp_server, :domain => smtp_domain, :port => smtp_port, :user => smtp_user, :password => smtp_password}
  end

end

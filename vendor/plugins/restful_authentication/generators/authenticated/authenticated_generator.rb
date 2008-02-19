require 'restful_authentication/rails_commands'
class AuthenticatedGenerator < Rails::Generator::NamedBase
  default_options :skip_migration => false,
                  :include_activation => false
                  
  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_singular_name,
                :controller_plural_name,
                :controller_file_name
  alias_method  :controller_table_name, :controller_plural_name
  attr_reader   :model_controller_name,
                :model_controller_class_path,
                :model_controller_file_path,
                :model_controller_class_nesting,
                :model_controller_class_nesting_depth,
                :model_controller_class_name,
                :model_controller_singular_name,
                :model_controller_plural_name
  alias_method  :model_controller_file_name,  :model_controller_singular_name
  alias_method  :model_controller_table_name, :model_controller_plural_name

  def initialize(runtime_args, runtime_options = {})
    super
    
    @rspec = has_rspec?

    @controller_name = args.shift || 'sessions'
    @model_controller_name = @name.pluralize

    # sessions controller
    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_file_name, @controller_plural_name = inflect_names(base_name)
    @controller_singular_name = @controller_file_name.singularize

    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end

    # model controller
    base_name, @model_controller_class_path, @model_controller_file_path, @model_controller_class_nesting, @model_controller_class_nesting_depth = extract_modules(@model_controller_name)
    @model_controller_class_name_without_nesting, @model_controller_singular_name, @model_controller_plural_name = inflect_names(base_name)
    
    if @model_controller_class_nesting.empty?
      @model_controller_class_name = @model_controller_class_name_without_nesting
    else
      @model_controller_class_name = "#{@model_controller_class_nesting}::#{@model_controller_class_name_without_nesting}"
    end
  end

  def manifest
    recorded_session = record do |m|
      # Check for class naming collisions.
      m.class_collisions controller_class_path,       "#{controller_class_name}Controller", # Sessions Controller
                                                      "#{controller_class_name}Helper"
      m.class_collisions model_controller_class_path, "#{model_controller_class_name}Controller", # Model Controller
                                                      "#{model_controller_class_name}Helper"
      m.class_collisions class_path,                  "#{class_name}", "#{class_name}Mailer", "#{class_name}MailerTest", "#{class_name}Observer"
      m.class_collisions [], 'AuthenticatedSystem', 'AuthenticatedTestHelper'

      # Controller, helper, views, and test directories.
      m.directory File.join('app/models', class_path)
      m.directory File.join('app/controllers', controller_class_path)
      m.directory File.join('app/controllers', model_controller_class_path)
      m.directory File.join('app/helpers', controller_class_path)
      m.directory File.join('app/views', controller_class_path, controller_file_name)
      m.directory File.join('app/views', class_path, "#{file_name}_mailer") if options[:include_activation]

      m.directory File.join('app/controllers', model_controller_class_path)
      m.directory File.join('app/helpers', model_controller_class_path)
      m.directory File.join('app/views', model_controller_class_path, model_controller_file_name)

      if @rspec
        m.directory File.join('spec/controllers', controller_class_path)
        m.directory File.join('spec/controllers', model_controller_class_path)
        m.directory File.join('spec/models', class_path)
        m.directory File.join('spec/fixtures', class_path)
      else
        m.directory File.join('test/functional', controller_class_path)
        m.directory File.join('test/functional', model_controller_class_path)
        m.directory File.join('test/unit', class_path)
      end

      m.template 'model.rb',
                  File.join('app/models',
                            class_path,
                            "#{file_name}.rb")

      if options[:include_activation]
        %w( mailer observer ).each do |model_type|
          m.template "#{model_type}.rb", File.join('app/models',
                                               class_path,
                                               "#{file_name}_#{model_type}.rb")
        end
      end

      m.template 'controller.rb',
                  File.join('app/controllers',
                            controller_class_path,
                            "#{controller_file_name}_controller.rb")

      m.template 'model_controller.rb',
                  File.join('app/controllers',
                            model_controller_class_path,
                            "#{model_controller_file_name}_controller.rb")

      m.template 'authenticated_system.rb',
                  File.join('lib', 'authenticated_system.rb')

      m.template 'authenticated_test_helper.rb',
                  File.join('lib', 'authenticated_test_helper.rb')

      if @rspec
        m.template 'functional_spec.rb',
                    File.join('spec/controllers',
                              controller_class_path,
                              "#{controller_file_name}_controller_spec.rb")
        m.template 'model_functional_spec.rb',
                    File.join('spec/controllers',
                              model_controller_class_path,
                              "#{model_controller_file_name}_controller_spec.rb")
        m.template 'unit_spec.rb',
                    File.join('spec/models',
                              class_path,
                              "#{file_name}_spec.rb")
        m.template 'fixtures.yml',
                    File.join('spec/fixtures',
                              "#{table_name}.yml")
      else
        m.template 'functional_test.rb',
                    File.join('test/functional',
                              controller_class_path,
                              "#{controller_file_name}_controller_test.rb")
        m.template 'model_functional_test.rb',
                    File.join('test/functional',
                              model_controller_class_path,
                              "#{model_controller_file_name}_controller_test.rb")
        m.template 'unit_test.rb',
                    File.join('test/unit',
                              class_path,
                              "#{file_name}_test.rb")
        if options[:include_activation]
          m.template 'mailer_test.rb', File.join('test/unit', class_path, "#{file_name}_mailer_test.rb")
        end
        m.template 'fixtures.yml',
                    File.join('test/fixtures',
                              "#{table_name}.yml")
      end

      m.template 'helper.rb',
                  File.join('app/helpers',
                            controller_class_path,
                            "#{controller_file_name}_helper.rb")

      m.template 'model_helper.rb',
                  File.join('app/helpers',
                            model_controller_class_path,
                            "#{model_controller_file_name}_helper.rb")


      # Controller templates
      m.template 'login.html.erb',  File.join('app/views', controller_class_path, controller_file_name, "new.html.erb")
      m.template 'signup.html.erb', File.join('app/views', model_controller_class_path, model_controller_file_name, "new.html.erb")

      if options[:include_activation]
        # Mailer templates
        %w( activation signup_notification ).each do |action|
          m.template "#{action}.html.erb",
                     File.join('app/views', "#{file_name}_mailer", "#{action}.html.erb")
        end
      end

      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
      end
      
      m.route_resource  controller_singular_name
      m.route_resources model_controller_plural_name
    end

    action = nil
    action = $0.split("/")[1]
    case action
      when "generate" 
        puts
        puts ("-" * 70)
        puts "Don't forget to:"
        puts
        if options[:include_activation]
          puts "    map.activate '/activate/:activation_code', :controller => '#{model_controller_file_name}', :action => 'activate'"
          puts
          puts "  - add an observer to config/environment.rb"
          puts "    config.active_record.observers = :#{file_name}_observer"
          puts
        end
        if options[:stateful]
          puts "Also, don't forget to install the acts_as_state_machine plugin and set your resource:"
          puts
          puts "  svn co http://elitists.textdriven.com/svn/plugins/acts_as_state_machine/trunk vendor/plugins/acts_as_state_machine"
          puts
          puts %w(map.resources :#{model_controller_file_name}, :member => { :suspend => :put, :unsuspend => :put, :purge => :delete })
          puts
        end
        puts "Try these for some familiar login URLs if you like:"
        puts
        puts %(map.activate '/activate/:activation_code', :controller => '#{model_controller_file_name}', :action => 'activate', :activation_code => nil)
        puts %(map.signup '/signup', :controller => '#{model_controller_file_name}', :action => 'new')
        puts %(map.login '/login', :controller => '#{controller_file_name}', :action => 'new')
        puts %(map.logout '/logout', :controller => '#{controller_file_name}', :action => 'destroy')
        puts
        puts ("-" * 70)
        puts
      when "destroy" 
        puts
        puts ("-" * 70)
        puts
        puts "Thanks for using restful_authentication"
        puts
        puts "Don't forget to comment out the observer line in environment.rb"
        puts "  (This was optional so it may not even be there)"
        puts "  # config.active_record.observers = :#{file_name}_observer"
        puts
        puts ("-" * 70)
        puts
      else
        puts
    end

    recorded_session
  end

  def has_rspec?
    options[:rspec] || (File.exist?('spec') && File.directory?('spec'))
  end
  
  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} authenticated ModelName [ControllerName]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-migration", 
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
      opt.on("--include-activation", 
             "Generate signup 'activation code' confirmation via email") { |v| options[:include_activation] = true }
      opt.on("--stateful", 
             "Use acts_as_state_machine.  Assumes --include-activation") { |v| options[:include_activation] = options[:stateful] = true }
      opt.on("--rspec",
             "Force rspec mode (checks for RAILS_ROOT/spec by default)") { |v| options[:rspec] = true }
    end
end

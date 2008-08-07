
module Ultrasphinx

  class Error < ::StandardError #:nodoc:
  end
  class ConfigurationError < Error #:nodoc:
  end  
  class DaemonError < Error #:nodoc:
  end
  class UsageError < Error #:nodoc:
  end

  # Internal file paths
  
  SUBDIR = "config/ultrasphinx"
  
  DIR = "#{RAILS_ROOT}/#{SUBDIR}"
  
  THIS_DIR = File.expand_path(File.dirname(__FILE__))

  CONF_PATH = "#{DIR}/#{RAILS_ENV}.conf"
  
  ENV_BASE_PATH = "#{DIR}/#{RAILS_ENV}.base" 
  
  GENERIC_BASE_PATH = "#{DIR}/default.base"
  
  BASE_PATH = (File.exist?(ENV_BASE_PATH) ? ENV_BASE_PATH : GENERIC_BASE_PATH)
  
  raise ConfigurationError, "Please create a '#{SUBDIR}/#{RAILS_ENV}.base' or '#{SUBDIR}/default.base' file in order to use Ultrasphinx in your #{RAILS_ENV} environment." unless File.exist? BASE_PATH # XXX lame

  # Some miscellaneous constants

  MAX_INT = 2**32-1

  MAX_WORDS = 2**16 # The maximum number of stopwords built  
  
  MAIN_INDEX = "main"
  
  DELTA_INDEX = "delta"
  
  INDEXES = [MAIN_INDEX, DELTA_INDEX]

  CONFIG_MAP = {
    # These must be symbols for key mapping against Rails itself.
    :username => 'sql_user',
    :password => 'sql_pass',
    :host => 'sql_host',
    :database => 'sql_db',
    :port => 'sql_port',
    :socket => 'sql_sock'
  }
  
  CONNECTION_DEFAULTS = {
    :host => 'localhost',
    :password => '',
    :username => 'root'
  }
     
  mattr_accessor :with_rake
  
  def self.load_stored_procedure(name)
    open("#{THIS_DIR}/postgresql/#{name}.sql").read.gsub(/\s+/, ' ')
  end

  SQL_FUNCTIONS = {
    'mysql' => {
      'group_concat' => "CAST(GROUP_CONCAT(DISTINCT ? ? SEPARATOR ' ') AS CHAR)",
      'delta' => "DATE_SUB(NOW(), INTERVAL ? SECOND)",      
      'hash' => "CAST(CRC32(?) AS unsigned)",
      'range_cast' => "?"
    },
    'postgresql' => {
      'group_concat' => "GROUP_CONCAT(?)",
      'delta' => "(NOW() - '? SECOND'::interval)",
      'range_cast' => "cast(coalesce(?,1) AS integer)",
      'hash' => "CRC32(?)"
    }      
  }
  
  DEFAULTS = {
    'mysql' => %(
      type = mysql
      sql_query_pre = SET SESSION group_concat_max_len = 65535
      sql_query_pre = SET NAMES utf8
    ), 
    'postgresql' => %(
      type = pgsql
      sql_query_pre =
    )
  }
    
  ADAPTER = ActiveRecord::Base.connection.instance_variable_get("@config")[:adapter] rescue 'mysql'
    
  # Warn-mode logger. Also called from rake tasks.  
  def self.say msg
    # XXX Method name is stupid.
    if with_rake
      puts msg[0..0].upcase + msg[1..-1]
    else
      msg = "** ultrasphinx: #{msg}"
      if defined?(RAILS_DEFAULT_LOGGER) && RAILS_DEFAULT_LOGGER
        RAILS_DEFAULT_LOGGER.warn msg
      else
        STDERR.puts msg
      end
    end        
    nil # Explicitly return nil
  end
  
  # Debug-mode logger.  
  def self.log msg
    # XXX Method name is stupid.
    if defined?(RAILS_DEFAULT_LOGGER) && RAILS_DEFAULT_LOGGER
      RAILS_DEFAULT_LOGGER.debug msg
    else
      STDERR.puts msg
    end
  end    
  
  # Configuration file parser.
  def self.options_for(heading, path)
    # Evaluate ERB
    template = ERB.new(File.open(path) {|f| f.read})
    contents = template.result(binding)
    
    # Find the correct heading.
    section = contents[/^#{heading.gsub('/', '__')}\s*?\{(.*?)\}/m, 1]
    
    if section
      # Convert to a hash
      options = section.split("\n").map do |line|
        line =~ /\s*(.*?)\s*=\s*([^\#]*)/
        $1 ? [$1, $2.strip] : []
      end      
      Hash[*options.flatten] 
    else
      # XXX Is it safe to raise here?
      Ultrasphinx.say "warning; heading #{heading} not found in #{path}; it may be corrupted. "
      {}    
    end    
  end
  
  def self.get_models_to_class_ids #:nodoc:
    # Reading the conf file makes sure that we are in sync with the actual Sphinx index, not
    # whatever you happened to change your models to most recently.
    if File.exist? CONF_PATH
      lines, hash = open(CONF_PATH).readlines, {}
      msg = "#{CONF_PATH} file is corrupted. Please run 'rake ultrasphinx:configure'."
      
      lines.each_with_index do |line, index| 
        # Find the main sources
        if line =~ /^source ([\w\d_-]*)_#{MAIN_INDEX}/
          # Derive the model name
          model = $1.gsub('__', '/').classify

          # Get the id modulus out of the adjacent sql_query
          query = lines[index..-1].detect do |query_line|
            query_line =~ /^sql_query /
          end
          raise ConfigurationError, msg unless query
          hash[model] = query[/(\d*) AS class_id/, 1].to_i
        end  
      end            
      raise ConfigurationError, msg unless hash.values.size == hash.values.uniq.size      
      hash          
    else
      # We can't raise here because you may be generating the configuration for the first time
      Ultrasphinx.say "configuration file not found for #{RAILS_ENV.inspect} environment"
      Ultrasphinx.say "please run 'rake ultrasphinx:configure'"
    end      
  end  

  # Introspect on the existing generated conf files.
  INDEXER_SETTINGS = options_for('indexer', BASE_PATH)
  CLIENT_SETTINGS = options_for('client', BASE_PATH)
  DAEMON_SETTINGS = options_for('searchd', BASE_PATH)
  SOURCE_SETTINGS = options_for('source', BASE_PATH)
  INDEX_SETTINGS = options_for('index', BASE_PATH)
  
  # Make sure there's a trailing slash.
  INDEX_SETTINGS['path'] = INDEX_SETTINGS['path'].chomp("/") + "/" 
  
  DICTIONARY = CLIENT_SETTINGS['dictionary_name'] || 'ap'  
  raise ConfigurationError, "Aspell does not support dictionary names longer than two letters" if DICTIONARY.size > 2

  STOPWORDS_PATH = "#{Ultrasphinx::INDEX_SETTINGS['path']}/#{DICTIONARY}-stopwords.txt"

  MODEL_CONFIGURATION = {}     
  
  # See if a delta index was defined.
  def self.delta_index_present?
    if File.exist?(CONF_PATH) 
      File.open(CONF_PATH).readlines.detect do |line|
        line =~ /^index delta/
      end
    end
  end
  
end

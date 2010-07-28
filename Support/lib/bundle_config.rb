require 'rubygems'
require 'yaml'




class BundleConfig
  def initialize
    @config = YAML::load(File.open(ENV["TM_BUNDLE_SUPPORT"] + "/config/config.yml").read)
    
    # Store some defaults, we're assuming english is the default locale, you can change that below
    $default_locale_file = File.join(ENV['TM_PROJECT_DIRECTORY'], @config['default_locale_file'])
    $default_locale = @config['default_locale']

    setup_mygengo
  end

  def setup_mygengo
    if @config['mygengo']
      $mygengo_api_key = @config['mygengo']['api_key']
      $mygengo_private_key = @config['mygengo']['private_key']
    end
  end
  
  def setup_keys
    @config['mygengo'] ||= {}
    @config['mygengo']['api_key'] = TextMate.input('Enter your mygengo.com API KEY', '')
    @config['mygengo']['private_key'] = TextMate.input('Enter your mygengo.com PRIVATE KEY', '')
    
    File.open(ENV["TM_BUNDLE_SUPPORT"] + "/config/config.yml", 'w') do |f|
      f.write(@config.to_yaml)
    end
    
    setup_mygengo
  end
  
end

BUNDLE_CONFIG = BundleConfig.new
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
    have_an_account = TextMate.message_yes_no_cancel('Do you have a MyGengo Account?')
    
    if !have_an_account
      `open "http://mygengo.com/a/e04cf"`
      TextMate.message('A browser window was opened for you to create an account.')
      TextMate.message('Once you are finished setting up the account, click OK.')
    end
    
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
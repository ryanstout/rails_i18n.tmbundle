require ENV["TM_BUNDLE_SUPPORT"] + "/lib/text_mate"
require 'rubygems'
require 'yaml'
# require 'ya2yaml'
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/translator"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/load_config"


class TranslateStrings
  def initialize
    check_requirements
    
    @translate_to = TextMate.input('Please enter the locale you want to auto-translate to (existing strings will not be overwritten)', '')

    default_locale = YAML::load(File.open(DEFAULT_LOCALE_FILE).read)['en']
    to_file = File.join(ENV['TM_PROJECT_DIRECTORY'], "config/locales/#{translate_to}.yml")

    # Create blank file if it doesn't exist
    if !File.exists?(to_file)
      File.open(to_file, 'w') do |f|
        f.write(translate_to + ":\n")
      end
    end

    # Load up the new file
    begin
      to_locale = YAML::load(File.open(to_file).read)[translate_to] || {}
    rescue
      to_locale = {}
    end
    
    
    process(default_locale, to_locale, translate_to)

    File.open(to_file, 'w') do |f|
      f.write({translate_to => to_locale}.to_yaml)
    end

  end
  
  def check_requirements
    # Check for httparty
    begin
      require "httparty"
    rescue
      TextMate.message("Please install the httpparty gem to use this bundle -- sudo gem install httparty")
      TextMate.exit_discard
      exit
    end
  end

  # Loop through the default locale and translate everything into the new locale
  # Skip if the translated version exists in the new locale
  def process(from_obj, to_obj, translate_to)
    if from_obj.is_a?(Hash)
      from_obj.each do |key,value|
        if value.is_a?(String)
          if !to_obj[key]
            # Change {{token}} to [[token]]
            tokened_value = value.gsub(/\{\{([^\}]+)\}\}/, '__\1__')
            string = Translator.translate(tokened_value, 'en', translate_to)
            # puts value + "\n" + tokened_value + "\n" + string
          
            # Change back
            string = string.gsub(/__(.*?)__/, '{{\1}}')
          
            # puts string
          
            to_obj[key] = string
          end
        else
          to_obj[key] ||= {}
          process(value, to_obj[key], translate_to)
        end
      end
    end
  end
end

TranslateStrings.new
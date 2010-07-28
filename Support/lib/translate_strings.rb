require ENV["TM_BUNDLE_SUPPORT"] + "/lib/text_mate"
require 'rubygems'
require 'yaml'
# require 'ya2yaml'
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/translator"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/bundle_config"


class TranslateStrings
  def initialize    
    check_requirements
    
    @translate_to = TextMate.input('Please enter the locale you want to auto-translate to (existing strings will not be overwritten)', '')
    
    @translate_via = TextMate.choose('Choose how you want to translate the english locale?', ['Google Translate', 'MyGengo - Standard', 'MyGengo - Pro', 'MyGengo - Ultra'])
    
    if @translate_via != 0
      # Use MyGengo
      # Ask for API_KEYS if we haven't set them up yet
      if !$mygengo_api_key || !$mygengo_private_key || !$mygengo_api_key == '' || !$mygengo_private_key == ''
        BundleConfig.setup_mygengo
      end
      
      # Confirm
      if !TextMate.message_yes_no_cancel('Are you sure you want to continue translating with MyGengo, it will cost money, be sure to calculate the cost with Rails i18n -> Estimate Translation Cost')
        return
      end
    end

    default_locale = YAML::load(File.open($default_locale_file).read)[$default_locale]
    to_file = File.join(ENV['TM_PROJECT_DIRECTORY'], "config/locales/#{@translate_to}.yml")

    # Create blank file if it doesn't exist
    if !File.exists?(to_file)
      File.open(to_file, 'w') do |f|
        f.write(@translate_to + ":\n")
      end
    end

    # Load up the new file
    begin
      to_locale = YAML::load(File.open(to_file).read)[@translate_to] || {}
    rescue
      to_locale = {}
    end
    
    
    process(default_locale, to_locale, @translate_to)

    File.open(to_file, 'w') do |f|
      f.write({@translate_to => to_locale}.to_yaml)
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
  
  # Do the actual translating, or setup the placeholder
  def translate_string(string, from_locale, to_locale)
    if @translate_via.to_i == 0
      # Change {{token}} to __token__ so it won't be replaced
      tokened_value = string.gsub(/\{\{([^\}]+)\}\}/, '__\1__')

      string = Translator.translate(tokened_value, from_locale, to_locale)

      # Change back
      string = string.gsub(/__(.*?)__/, '{{\1}}')
      
      return string
    else
      # Via MyGengo
      if !defined?(@auto_approve)
        @auto_approve = TextMate.message_yes_no_cancel('Do you want MyGengo jobs to be auto-approved?')
      end
      
      mygengo = MyGengo.new($mygengo_api_key, $mygengo_private_key)
      
      
      # play around with different parameter values to see their effect
      job = {
          'slug' => string.gsub(/\{\{([^\}]+)\}\}/, '[[[\1]]]'),
          'body_src' => string,
          'lc_src' => from_locale,
          'lc_tgt' => to_locale,
          'tier' => 'machine',
          'auto_approve' => @auto_approve
      }


      # place the full list of parameters relevant to this call in an array
      data = {'job' => job }

      resp = mygengo.create_job(data)
      begin
        return "___WAITING_JOB:#{resp['response']['job']['job_id']}___"
      rescue
        TextMate.textbox("An error happened while translating, the following was returned", resp.inspect)
        return string
      end
    end
  end

  # Loop through the default locale and translate everything into the new locale
  # Skip if the translated version exists in the new locale
  def process(from_obj, to_obj, translate_to)
    if from_obj.is_a?(Hash)
      from_obj.each do |key,value|
        if value.is_a?(String)
          if !to_obj[key]
            string = translate_string(value, $default_locale, translate_to)

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
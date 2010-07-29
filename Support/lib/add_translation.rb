# just to remind you of some useful environment variables
# see Help / Environment Variables for the full list
# echo File: "$TM_FILEPATH"
# echo Word: "$TM_CURRENT_WORD"
# echo Selection: "$TM_SELECTED_TEXT"

# print ENV['TM_' + 'SELECTED_TEXT'.to_s.upcase] + 'ok'

require ENV["TM_BUNDLE_SUPPORT"] + "/lib/text_mate"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/bundle_config"
require 'rubygems'
require 'yaml'

class AddTranslation
  def initialize
    @selected_text = ENV['TM_SELECTED_TEXT']
    @path = ENV['TM_FILEPATH']
    
    get_token_key
    
    add_to_locale

    # Print so the results are added back into textmate
    variables = []
    @selected_text.scan(/\{\{(.*?)\}\}/).flatten.each do |variable|
      variable.gsub!(/\s/, '_')
      variables << ":#{variable} => #{variable}"
    end
    
    variable_str = (variables.size > 0) ? (', ' + variables.join(', ')) : ''
    
    print "<%= t('.#{@token_key}'#{variable_str}) %>"
  end
  
  # Ask the user for the token they want to use for this key
  def get_token_key
    @token_key = TextMate.input("Text Key (by default uses controller.view.{your key})", '')

    if !@token_key
      print @selected_text
      exit
    end
  end

  def add_to_locale
    controller, file = @path.split(/\//)[-2..-1]

    # Remove partial _ and extensions from file url, or url
    if file
      file.gsub!('.html.erb', '')
      file.gsub!(/^[_]/, '')
    else
      # If controller
      controller.gsub!('.rb', '')
    end

    default_locale = YAML::load(File.open($default_locale_file).read)

    # Split token into sections
    token_parts = @token_key.split('.')
    
    # Add file controller and language
    token_parts.unshift(file) if file
    token_parts.unshift(controller)
    token_parts.unshift('en')

    # Pop the last key of the token
    final_key = token_parts.pop

    main_sections = default_locale
    last_section = main_sections
    last_part = nil

    # Loop through each part, see if its in the new locale and if not add it
    token_parts.each_with_index do |part,i|
      last_section[part] ||= {}
      last_part = part
      # Except on last set last_section to current one
      if i < token_parts.size - 1
        last_section = last_section[part]
      end
    end

    if last_section[last_part][final_key]
      TextMate.message("The token #{final_key} is already in use, please choose another")
      TextMate.exit_discard
      return
    else
      last_section[last_part][final_key] = @selected_text
    end

    # Dump into the english locale
    File.open($default_locale_file, 'w') do |f|
      f.write(default_locale.to_yaml)
    end
  end
end

# Run
AddTranslation.new



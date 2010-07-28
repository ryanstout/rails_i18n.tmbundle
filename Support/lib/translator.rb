# Ruby Implementation of Google Translate
# 
# requires the httparty gem. 
# 
# Copyright Bryce Roney <brycer22@gmail.com> 2008
# http://bryce.insanesparrow.com
 
require "rubygems"
gem "httparty"
require "httparty"
 
class Translator
  
  include HTTParty
                     
  base_uri "http://ajax.googleapis.com/ajax/services/language"
  
  def self.translate(text, from, to)
    options = {:query => {:v => "1.0", :q => text, :langpair => "#{from}|#{to}"}}
    format :json
    response = get("/translate", options)
    return response["responseData"]["translatedText"]                     
  end
  
end
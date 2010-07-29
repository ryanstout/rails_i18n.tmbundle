# Ruby Implementation of Google Translate
# 
# requires the httparty gem. 
# 
# Copyright Bryce Roney <brycer22@gmail.com> 2008
# http://bryce.insanesparrow.com
 
require "rubygems"
gem "httparty"
require "httparty"
require 'cgi'
 
class Translator
  
  include HTTParty
                     
  base_uri "http://ajax.googleapis.com/ajax/services/language"
  
  def self.escape(text)
    text.gsub('"', '&quot;')
  end
  
  def self.unescape(text)
    text.gsub(/[&]quot[;]/i, '"')
  end
  
  def self.translate(text, from, to)
    options = {:query => {:v => "1.0", :q => escape(text), :langpair => "#{from}|#{to}"}}
    format :json
    response = get("/translate", options)
    if response["responseData"]["translatedText"]
      return unescape(response["responseData"]["translatedText"])
    else
      return response["responseData"]["translatedText"]
    end
  end
  
end
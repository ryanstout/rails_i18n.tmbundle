require 'rubygems'

# Fix a bug loading active_support from textmate
# Object.send(:remove_const, :Builder)# if defined?(Builder)

require 'active_support'
require 'httparty'
require 'cgi'
require 'hmac-sha1'

class MyGengo
  # BASE_URL = 'http://api.sandbox.mygengo.com/v1/'
  BASE_URL = 'http://api.mygengo.com/v1/'
  include HTTParty
  
  def initialize(api_key, private_key)
    @api_key = api_key
    @private_key = private_key
  end
  
  def request(method, url, params={})
    if ![:get, :post, :put, :delete].include?(method.to_sym)
      raise "invalid method"
    end
    
    # if method != :get
    #   params["_method"] = method.to_s.downcase
    #   method = :get
    # end
    params['api_key'] = @api_key
    params["ts"] = Time.now.gmtime.to_i.to_s
    query = params.keys.sort_by {|k| k.to_s }.collect{ |key| "#{key}=#{CGI::escape(params[key].to_s)}" }.join('&')

    # puts query
    
    # calculate the API signature required for this call
    if method == :get
      hmac = HMAC::SHA1.hexdigest(@private_key, query)
    else
      # Convert params to ordered list
      new_params = ActiveSupport::OrderedHash.new
      
      params.keys.sort_by {|k| k.to_s }.each do |key|
        new_params[key] = params[key]
      end
      
      params = new_params
      
      hmac = HMAC::SHA1.hexdigest(@private_key, params.to_json)
    end
    
    query += "&api_sig=#{hmac}"
    
    params['api_sig'] = hmac
    
    puts url
  
    if method == :get
      return self.class.send(method.to_sym, BASE_URL + url, :query => params, :headers => { "Accept" => "application/json" })
    else
      puts "Using method: #{method}"
      return self.class.send(method.to_sym, BASE_URL + url, :body => query, :headers => { "Accept" => "application/json" })
    end
  end
  
  def get_job(job_id)
    return request(:get, "translate/job/#{job_id}")
  end
  
  def create_job(data)
    return request(:post, "translate/job", 'data' => data.to_json)
  end
end
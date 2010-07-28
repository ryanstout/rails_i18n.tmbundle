require ENV["TM_BUNDLE_SUPPORT"] + "/lib/text_mate"
require 'rubygems'
require 'yaml'
require 'active_support'
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/bundle_config"
require ENV["TM_BUNDLE_SUPPORT"] + "/lib/gengo_lib/my_gengo"


class PullTranslations
  def initialize
    @mygengo = MyGengo.new($mygengo_api_key, $mygengo_private_key)
    
    # Loads all locales except the default
    Dir[ENV["TM_PROJECT_DIRECTORY"] + '/config/locales/**.yml'].reject {|f| f =~ /#{$default_locale}.yml$/ }.each do |locale_file|
      # Load locale
      locale_obj = YAML::load(File.open(locale_file).read)
      
      # Replace finished jobs
      process(locale_obj)
      
      # Write back out
      File.open(locale_file, 'w') do |f|
        f.write(locale_obj.to_yaml)
      end
    end 
  end
  
  # Loops through each string in a yml file and replaces any waiting jobs
  def process(obj)
    if obj.is_a?(Hash)
      obj.each do |key,value|
        if value.is_a?(String)
          if value =~ /___WAITING_JOB:[0-9]+___/
            job_id = value.scan(/___WAITING_JOB:([0-9]+)___/).first.first
            res = get_job_result(job_id.to_i)
            
            obj[key] = res if res
          end
        else
          process(value)
        end
      end
    end
  end
  
  def get_job_result(job_id)
    resp = @mygengo.get_job(job_id)
    if resp && resp['response'] && resp['response']['job']
      job = resp['response']['job']

      if job['status'] == 'approved'# || job['status'] == 'reviewable'
        return job['body_tgt']
      end
    end
    
    # puts resp.inspect
    return nil
  end
end

PullTranslations.new
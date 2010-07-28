require 'rubygems'
require 'httparty'
require 'cgi'
require 'hmac-sha1'
require 'active_support'
require 'my_gengo'


gengo = MyGengo.new(MYGENGO_API_KEY, MYGENGO_PRIVATE_KEY)

@job_id = ARGV[0] if ARGV[0]
if @job_id

  resp = gengo.get_job(@job_id)
  puts resp.inspect
  job = resp['response']['job']

  if job['status'] == 'approved' || job['status'] == 'reviewable'
    puts "Finished: " + job['body_tgt'].inspect
  else
    puts "Not Finished"
  end

else
  
  # play around with different parameter values to see their effect
  job = {
      'slug' => 'API Job lazy loading test',
      'body_src' => 'Ok, this is my first test of the produciton system.',
      'lc_src' => 'en',
      'lc_tgt' => 'es',
      'tier' => 'standard',
      'auto_approve' => 'true'
  }
  
  
  # place the full list of parameters relevant to this call in an array
  data = {'job' => job }
  
  resp = gengo.create_job(data)
  puts resp.inspect
  puts resp['response']['job']['job_id'].inspect
  # puts resp.inspect
end

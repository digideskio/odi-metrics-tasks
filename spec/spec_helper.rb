require 'coveralls'
Coveralls.wear_merged!

require 'vcr'
require 'dotenv'
require 'timecop'
require 'pry'

Dotenv.load

ENV['RACK_ENV'] = "test"

$:.unshift File.dirname(__FILE__)+'../lib'
require 'ignore_env'
require 'odi-metrics-tasks'

VCR.configure do |c|
  # Automatically filter all secure details that are stored in the environment
  (ENV.keys-$ignore_env).select { |x| x =~ /\A[A-Z_]*\Z/ }.each do |key|
    c.filter_sensitive_data("<#{key}>") { ENV[key] }
  end
  c.cassette_library_dir     = 'spec/cassettes'
  c.default_cassette_options = { :record => :once }
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = true
  c.ignore_request do |request|
    # ignore google OAuth requests
    ignore = [
      'https://accounts.google.com/o/oauth2/token',
      'https://www.googleapis.com/discovery/v1/apis/drive/v2/rest',
    ]
    ignore.include? request.uri
  end
end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered                = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

def metrics_api_should_receive(metric, time, value)
  json = JSON.parse("{\"name\":\"#{metric}\",\"time\":\"#{time.xmlschema}\",\"value\":#{value}}").to_json
  auth = { :username => ENV['METRICS_API_USERNAME'], :password => ENV['METRICS_API_PASSWORD'] }
  HTTParty.should_receive(:post).
      with("#{ENV['METRICS_API_BASE_URL']}metrics/#{metric}",
           :body       => json,
           :headers    => { 'Content-Type' => 'application/json' },
           :basic_auth => auth).
      once
end

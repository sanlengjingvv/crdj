require 'cucumber-api/response'
require 'rest-client'
require 'json-schema'
require 'jsonpath'


if ENV['cucumber_api_verbose'] == 'true'
  RestClient.log = 'stdout'
end

Given(/^I send and accept JSON$/) do
  @headers = {
      :Accept => 'application/json',
      :'Cookie' => '',
      :'Content-Type' => 'application/json'
  }
end

Given(/^I'm already logged in as "(.*)"$/) do |username|
  steps %Q{
    When I send and accept JSON
  }
  file = File.read("./features/examples/authenticate.json")
  login = JSON.parse(file)
  login['params']['db'] = "demo4"
  login['params']['login'] = username
  @body = JSON.generate(login)
  steps %Q{
    When I send a POST request to "/app_api/session/authenticate/"
    Then the response status should be "200"
    Then the JSON response should follow "features/schemas/authenticate_response.schema.json"
    Then the JSON response should have key "$.result.username" with "#{username}"
    When I grab "$.result.session_id" as "session"
  }
  @headers[:Cookie] = "session_id=#{@grabbed["session"]}"
end

When(/^I set request body from "(.*)"$/) do |filename|
  path = %-#{Dir.pwd}/#{filename}-
  @body = File.read(path)
end

When(/^I grab "(.*?)" as "(.*?)"$/) do |json_path, place_holder|
  if @response.nil?
    raise 'No response found, a request need to be made first before you can grab response'
  end
  @grabbed = {} if @grabbed.nil?
  @grabbed[%/#{place_holder}/] = @response.get json_path
end

When(/^I send a POST request to "(.*?)" with:$/) do |url, table|
  table = table.raw
  table.each do |row|
    @grabbed.each do |key, value|
      row[1] = value if row[1] == %-{#{key}}-
    end
    @body = JsonPath.for(@body).gsub(row[0]) {|v| row[1] }.to_hash
  end
  @body = JSON.generate(@body)
  request_url = URI.encode (host + url)
  begin
    response = RestClient.post request_url, @body, @headers
  rescue RestClient::Exception => e
    response = e.response
  end
  @response = CucumberApi::Response.create response

  save_request
  save_response

  @body = nil
  @grabbed = nil
end

When(/^I send a POST request to "(.*?)"$/) do |url|
  request_url = URI.encode (host + url)
  begin
    response = RestClient.post request_url, @body, @headers
  rescue RestClient::Exception => e
    response = e.response
  end
  @response = CucumberApi::Response.create response
  
  save_request
  save_response

  @body = nil
  @grabbed = nil
end

Then(/^the response status should be "(\d+)"$/) do |status_code|
  expect(@response.code).to eq(status_code.to_i)
end

Then(/^the JSON response should follow "(.*?)"$/) do |schema|
  file_path = %-#{Dir.pwd}/#{schema}-
  expect(JSON::Validator.validate!(file_path, @response.to_s)).to be true
end

Then(/^the JSON response should have key "(.*?)" with "(.*?)"$/) do |json_path, value|
  expect((@response.get json_path).to_s).to eq value
end


def save_response
  timestamp = Time.now.to_i.to_s
  @scenario_name = @scenario_name.gsub(/\//,'-')
  File.open("responses/#{@scenario_name}-#{@step_count}-#{timestamp}.json",'w') do |f|
    f.puts YAML.dump(@response.headers)
    f.puts ''
    f.puts @response.to_json_s
  end
  puts 'responses/' + @scenario_name + '-' + @step_count.to_s + '-' + timestamp + '.json'
end

def save_request
  timestamp = Time.now.to_i.to_s
  @scenario_name = @scenario_name.gsub(/\//,'-')
  File.open("requests/#{@scenario_name}-#{@step_count}-#{timestamp}.json",'w') do |f|
    f.puts YAML.dump(@headers)
    f.puts ''
    f.puts @body
  end
  puts 'requests/' + @scenario_name + '-' + @step_count.to_s + '-' + timestamp + '.json'
end
require 'raml_parser'
require 'yaml'

class RamlParser::YamlHelper
    def self.read_yaml(path)
      raw = File.read(path)
      node = YAML.load(raw)
      node
    end
end

raml = RamlParser::Parser.parse_file('./features/hollywant.raml')
test_data = YAML.load(File.read('test-data.yaml'))

File.open('features/smoke.feature', 'w') do |f|
  indent = '  '
  f.puts 'Feature: Smoke Test'
  f.puts ''
  for resource in raml.resources do
    begin
      req_example = resource.methods['post'].bodies["application/json"].example
      f.puts indent + 'Scenario: ' + resource.display_name
      if resource.type.key? 'logined'
        user_name = test_data[resource.display_name]['user']
        f.puts indent * 2 + %Q{Given I'm already logged in as "#{user_name}"}
      else
        f.puts indent * 2 + 'When I send and accept JSON'
      end
      f.puts indent * 2 + %Q{When I set request body from "features/#{req_example}"}
      url = resource.relative_uri
      uri_parameter = url[/{(.*)}/, 1]
      if resource.uri_parameters.key? uri_parameter
        url = url.gsub(/{.*}/,resource.uri_parameters[uri_parameter].example.to_s)
      end
      f.puts indent * 2 + %Q{When I send a POST request to "#{url}"}
      f.puts indent * 2 + 'Then the response status should be "200"'
      res_schema = resource.methods['post'].responses[200].bodies["application/json"].schema
      f.puts indent * 2 + %Q{Then the JSON response should follow "features/#{res_schema}"}
      f.puts ""
      rescue => exception
    end
  end
end
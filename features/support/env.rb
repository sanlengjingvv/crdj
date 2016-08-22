require 'cucumber-api'
require 'open3'
require 'fileutils'

module KnowsHost
  def host
    @host = "#{ENV['test_ip']}:#{ENV['test_port']}"
  end
end
World(KnowsHost)

FileUtils.rm_r "responses" if Dir.exist? 'responses'
Dir.mkdir 'responses'
FileUtils.rm_r "requests" if Dir.exist? 'requests'
Dir.mkdir 'requests'

Before do |scenario|
  @scenario_name = scenario.name
  @step_count = 0
  
  # Open3.popen3('docker exec -i test-application psql -f "my_file.psql"') {|i,o,e,t|
  #   puts o.read
  # }
end

AfterStep do |scenario|
  @step_count += 1
end

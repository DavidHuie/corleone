docker_settings do |config|
  config.num_containers = 8
end

docker_image do |config|
  config.alias = 'test_spec'
  config.image = 'localhost:5000/docker_spec_test'
  config.local_code_directory = '/docker_test'
  config.command = 'ruby -Ilib ./bin/dt_rspec_worker'
end

define_setup do
  puts 'setup'
end

define_teardown do
  puts 'teardown'
end

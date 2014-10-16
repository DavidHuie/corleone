docker_settings do |config|
  config.num_containers = 8
end

testing_image do |image|
  image.alias = 'test_spec'
  image.image = 'localhost:5000/docker_spec_test'
  image.binds = ['/docker_test:/docker_test']
  image.command = 'ruby -Ilib ./bin/dt_rspec_worker'
  image.dns = ['8.8.8.8', '8.8.4.4']
  image.env = ['TEST_ENV_VAR=1']
end

define_setup do
  puts 'setup'
end

define_teardown do
  puts 'teardown'
end

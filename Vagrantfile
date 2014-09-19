Vagrant.configure('2') do |config|

  config.vm.box = 'precise64'
  config.vm.synced_folder '.', '/docker_test'

  config.vm.define 'dev' do |l|
    l.vm.hostname = 'dev'
  end

  config.vm.provider :virtualbox do |vb|
    vb.name = 'docker_test'
    vb.memory = 2048
    vb.cpus = 4
  end

  config.vm.provision 'ansible' do |ansible|
    ansible.playbook = 'ansible/dev.yml'
    ansible.groups = { 'dev' => ['dev'] }
  end

  config.ssh.forward_agent = true

end

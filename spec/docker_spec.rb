require 'spec_helper'

describe DockerTest::Docker::Image do

  context 'linked containers' do

    let(:image_1) do
      DockerTest::Docker::Image.new(image: 'localhost:5000/docker_spec_test',
                                    alias: 'i1',
                                    local_code_directory: '/docker_test',
                                    command: 'sleep 500')
    end

    let(:image_2) do
      DockerTest::Docker::Image.new(image: 'localhost:5000/docker_spec_test',
                                    alias: 'i2',
                                    local_code_directory: '/docker_test',
                                    command: 'sleep 500')
    end

    after(:each) do
      image_1.kill_all
    end

    it 'should link containers correctly' do
      image_1.add_linked_image(image_2)
      image_1.create_linked_containers
      image_1.create_container
      expect(image_1.container.json['HostConfig']['Links'])
        .to eq(["/#{image_2.name}:/#{image_1.name}/#{image_2.alias}"])
    end

  end

end

require 'spec_helper'

EXAMPLES = 100
SLEEP = 0.01

EXAMPLES.times do |n|

  describe "passing example #{n}" do

    it 'should do something' do
      sleep(SLEEP)
      expect(1).to eq(1)
    end

  end

end

EXAMPLES.times do |n|

  describe "failing example #{n}" do

    it 'should do something' do
      sleep(SLEEP)
      expect(1).to eq(2)
    end

  end

end

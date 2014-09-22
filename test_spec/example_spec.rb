require 'spec_helper'

EXAMPLES = 10_000
SLEEP_SECONDS = 0.1

EXAMPLES.times do |n|

  describe "passing example #{n}" do

    it 'should do something' do
      sleep(SLEEP_SECONDS)
      expect(1).to eq(1)
    end

  end

end

EXAMPLES.times do |n|

  describe "failing example #{n}" do

    it 'should do something' do
      sleep(SLEEP_SECONDS)
      expect(1).to eq(2)
    end

  end

end

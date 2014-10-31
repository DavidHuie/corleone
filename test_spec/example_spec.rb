require 'spec_helper'

EXAMPLES = 20
SLEEP = 0.01

EXAMPLES.times do |n|

  describe "passing example #{n}" do

    it 'should do something' do
      sleep(SLEEP)
      expect(1).to eq(1)
    end

    2.times do |n|

      describe "failing example #{n}" do

        it 'should do something' do
          sleep(SLEEP)
          expect(1).to eq(2)
        end

      end

    end

  end

end

require 'spec_helper'

describe Klear::File do 
  it 'exists' do
    Klear::File.should be_kind_of(Class)
  end

  context 'with test.kle fixture' do
    let(:path) { "#{RSpec.configuration.fixtures}/test.kle" }
    let(:klear) { Klear::File.new path }

    it 'calculates playtimes from the number of frames in the zipfile' do
      klear.frame_count.should eq(264)
    end

    it 'reads info' do
      klear.info.should be_kind_of(Hash)
    end

    it 'knows the dimensions' do
      klear.dimensions.should eq({:columns => 14, :rows => 11})
    end

    it 'reads frames' do
      (frames = klear.frames).should_not be(nil)
      frames.columns.should eq(14)
      frames.rows.should eq(11)
    end

    it 'reads motors' do
      (motors = klear.motors).should_not be(nil)
      motors.should be_kind_of(Klear::Motors)
      motors.count.should eq(14)
      motors.blade_count.should eq(motors.count)
      motors.frame_count.should eq(264)
    end
  end

  context 'default config' do
    let(:klear) { Klear::File.new }

    it 'info raises no path exception' do 
      expect { klear.info }.to raise_error /path not specified/
    end
  end
end

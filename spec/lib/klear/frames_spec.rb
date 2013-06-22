require 'spec_helper'

describe Klear::Frames do 
  it 'exists' do
    Klear::Frames.should be_kind_of(Class)
  end

  context 'with test.kle fixture' do
    let(:path) { "#{RSpec.configuration.fixtures}/test.kle" }
    let(:data) { Zip::ZipFile.new(path).read("cache/frames.bin") }

    it 'initializes with data' do 
      expect { Klear::Frames.new(14, 11, data) }.to_not raise_error
    end

    it 'load from binary string' do
      expect { Klear::Frames.new(14, 11).load(data) }.to_not raise_error
    end

    context 'loaded frames fixture' do
      let(:frames) { Klear::Frames.new(14, 11, data) }

      it 'knows the frames cell count' do
        frames.framesize.should eq(14 * 11)
      end

      it 'knows the frame count' do 
        frames.count.should eq(264)
      end

      it 'gets me all frames' do
        (all = frames.all).should be_kind_of(Array)
        all.size.should eq(264)
      end

      it 'gets me any frame' do
        frames.get(0).should be_kind_of(Klear::Frame)
      end

      it 'raises on out of bound frame numbers' do
        high = frames.count # frames go from [0; framecount[
        expect { frames.get(high) }.to raise_error /bound.*#{high}/
      end

      it 'raises on negative frame numbers' do
        expect { frames.get(-1) }.to raise_error /negative.*#{-1}/
      end
    end
  end
end

require 'spec_helper'

describe Klear::Frame do 
  context 'loaded frames fixture' do
    let(:path) { "#{RSpec.configuration.fixtures}/test.kle" }
    let(:data) { Zip::ZipFile.new(path).read("cache/frames.bin") }
    let(:frames) { Klear::Frames.new(14, 11, data) }

    context 'with frame zero from test fixture' do
      let(:frame) { frames.get(0) }

      it 'has row, column and size' do
        frame.row_count.should eq(11)
        frame.column_count.should eq(14)
        frame.size.should eq(11 * 14)
      end
    end
  end
end

require 'spec_helper'

describe Klear::Frame do 
  context 'loaded frames fixture' do
    let(:path) { "#{RSpec.configuration.fixtures}/test.kle" }
    let(:data) { Zip::ZipFile.new(path).read("cache/frames.bin") }
    let(:frames) { Klear::Frames.new(14, 11, data) }

    context 'with frame zero from test fixture' do
      let(:frame) { frames.get(0) }

      it 'loops over all cells' do
        cell_count = 0
        frame.each_cell do |val, x, y|
          cell_count += 1
          expect(val).to eq(frame.cell(x, y))
          expect(val).to eq(frame.row(y)[x])
          expect(val).to eq(frame.column(x)[y])
        end
        expect(cell_count).to eq(frame.size)
      end

      it 'has row, column and size' do
        frame.row_count.should eq(11)
        frame.column_count.should eq(14)
        frame.size.should eq(11 * 14)
      end

      it 'reads a single cell' do
        expect(cell = frame.cell(3, 2)).to eq(57031)
        expect(cell).to eq(frame.column(3)[2])
        expect(cell).to eq(frame.row(2)[3])
      end

      it 'reads complete rows from frame' do
        expect(row = frame.row(0)).to be_kind_of(Array)
        expect(row.size).to eq(frame.column_count)
        expect(row).to eq([27009, 38885, 47331, 51027, 51233, 49789, 47645, 45039, 41857, 38387, 35095, 32101, 29395, 27007])
      end

      it 'reads complete rows from frame' do
        expect(row = frame.row(0)).to be_kind_of(Array)
        expect(row.size).to eq(frame.column_count)
      end

      it 'reads complete columns from frame' do
        expect(column = frame.column(0)).to be_kind_of(Array)
        expect(column.size).to eq(frame.row_count)
        expect(column).to eq([27009, 63689, 64223, 64219, 63417, 61537, 58347, 53747, 47923, 41223, 33761])
      end
    end
  end
end

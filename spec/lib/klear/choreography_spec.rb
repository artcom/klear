require 'spec_helper'

describe Klear::Choreography do

  context 'live MADE space bug with klear file loading' do
    let(:test_kle_path) { "#{RSpec.configuration.fixtures}/diagonal_normal_40.klea" }
    let(:choreography) { Klear::Choreography.load(test_kle_path) }

    it 'knows about rows' do
      frame = choreography.frame(0)
      
      frame.row(0).should eq([
        27009, 38885, 47331, 51027, 51233, 49789, 47645,
        45039, 41857, 38387, 35095, 32101, 29395, 27007])
      total_size = 0
      frame.rows {|row| total_size += row.size }
      total_size.should eq(frame.data.size)
    
      total_size = 0
      frame.rows {|row| total_size += row.size }
      total_size.should eq(frame.data.size)
      
      frame.rows.should be_kind_of(Array)
      frame.rows[choreography.geometry[:rows] - 1].should eq([
        33761, 48607, 59165, 63785, 64043, 62237, 59557,
        56301, 52323, 47985, 43869, 40127, 36745, 33759
      ])
    end
  end
  context 'with test.kle fixture' do
    let(:test_kle_path) { "#{RSpec.configuration.fixtures}/test.kle" }
    let(:choreography) { Klear::Choreography.load(test_kle_path) }

    it 'reads kle files' do
      choreography.should be_kind_of(Klear::Choreography)
    end
    
    it 'knows details about kle files when read' do
      choreography.framecount.should eq(264)
      choreography.framesize.should eq(14*11)
      choreography.geometry.should eq({:columns => 14, :rows => 11})
      choreography.fps.should eq(25)
      choreography.gamma.should eq(1.0)
      
      frame = choreography.frame(0)
      frame.should be_kind_of(Klear::Frame)
      frame.data.size.should eq(14*11)
    end
    
    it 'raises on out of bound frame numbers' do
      high = choreography.framecount # frames go from [0; framecount[
      expect { choreography.frame(high) }.to raise_error /bound.*#{high}/
    end

    it 'raises on negative frame numbers' do
      expect { choreography.frame(-1) }.to raise_error /negative.*#{-1}/
    end

    it 'knows about rows' do
      frame = choreography.frame(0)
      
      frame.row(0).should eq([
        27009, 38885, 47331, 51027, 51233, 49789, 47645,
        45039, 41857, 38387, 35095, 32101, 29395, 27007])
      total_size = 0
      frame.rows {|row| total_size += row.size }
      total_size.should eq(frame.data.size)
    
      total_size = 0
      frame.rows {|row| total_size += row.size }
      total_size.should eq(frame.data.size)
      
      frame.rows.should be_kind_of(Array)
      frame.rows[choreography.geometry[:rows] - 1].should eq([
        33761, 48607, 59165, 63785, 64043, 62237, 59557,
        56301, 52323, 47985, 43869, 40127, 36745, 33759
      ])
    end
    
    it 'knows about columns' do
      frame = choreography.frame(0)
      
      frame.column(0).should eq([
        27009, 63689, 64223, 64219, 63417,
        61537, 58347, 53747, 47923, 41223, 33761
      ])
      
      total_size = 0
      frame.columns { |col| total_size += col.size }
      total_size.should eq(frame.data.size)
      
      total_size = 0
      frame.columns { |col| total_size += col.size }
      total_size.should eq(frame.data.size)
      
      frame.columns.should be_kind_of(Array)
      frame.columns[choreography.geometry[:columns] - 1].should eq([
        27007, 24163, 25097, 26035, 26997,
        27991, 29027, 30111, 31259, 32473, 33759])
    end
    
    it 'knows about blades (the same as columns)' do
      frame = choreography.frame(0)
      
      frame.blade(0).should eq([
        27009, 63689, 64223, 64219, 63417,
        61537, 58347, 53747, 47923, 41223, 33761])
      frame.blade(0).should eq([
        27009, 63689, 64223, 64219, 63417,
        61537, 58347, 53747, 47923, 41223, 33761])
      
=begin
      total_size = 0
      frame.blades { |col| total_size += col.size }
      total_size.should eq(frame.data.size)
      
      frame.blades.should be_kind_of(Hash)
      frame.blades[choreography.geometry[:columns] - 1].should eq([
        27007, 24163, 25097, 26035, 26997,
        27991, 29027, 30111, 31259, 32473, 33759
      ])
=end
    end

    pending 'has direct col/row access to the buffer' do
      frame = choreography.frame(0)
      frame.cell(2,5).should eq(frame.column(2)[5])
      frame.cell(1,7).should eq(frame.row(7)[1])
      # frame.cell(1,15).should eq(nil)
      # frame.cell(12,1).should eq(nil)
    end
  end
  
  ##it 'should just work dammit' do
  ##  choreography = Kleac::Choreography.load("#{RSpec.configuration.fixtures}/black_to_white_linear.kle")
  ##  puts "framesize #{choreography.framesize}"
  ##  puts "framecount #{choreography.framecount}"
  ##  #puts choreography.frame(0).dump
  ##  choreography.each_frame { |frame, idx|
  ##    puts "Frame #{idx}"
  ##    puts frame.dump
  ##    puts "\n"
  ##    #puts "#{idx} => #{frame.row(0)[0]}"
  ##  }
  ##end
  
  context 'with test.kle fixture' do
    let(:path) { "#{RSpec.configuration.fixtures}/test_without_gamma_and_fps.kle" }
    let(:choreography) { Klear::Choreography.load(path) }
    
    it 'produces defaults for missing gamma and fps' do
      choreography.fps.should eq(25)
      choreography.gamma.should eq(1.0)
    end
  end
end

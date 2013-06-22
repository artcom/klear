require 'spec_helper'

describe Klear::Motors do 
  it 'exists' do
    Klear::Motors.should be_kind_of(Class)
  end

  it 'initializes blade_count data' do 
    Klear::Motors.new(7).blade_count.should eq(7)
  end

  context 'with three blades, four frames data' do
    let(:data) { 
      [[1, 2, 3], [10, 20, 30], [100, 200, 300], [1000, 2000, 3000]]
    }

    it 'initializes with blade data' do 
      expect { motors = Klear::Motors.new(3, data) }.to_not raise_error
    end

    context 'with motors from three blades, four frames data' do
      let(:motors) { Klear::Motors.new(3, data) }

      it 'knows the frame count' do
        motors.frame_count.should eq(4)
      end

      it 'gets me the second frame values (frames are null based!!!!)' do
        motors.frame(2).should eq([100, 200, 300])
      end

      it 'gets me any motor sequence (motors are one based!!!!)' do
        motors.get(2).should eq([2, 20, 200, 2000])
      end

      it 'gets works with strings and integer args' do 
        motors.get(2).should eq(motors.get('2'))
      end

      it 'raises on to high motor numbers' do
        max = motors.blade_count
        expect { motors.get(max+1) }.to raise_error /bound.*#{max+1}/
      end

      it 'raises on to low motor numbers' do
        expect { motors.get(0) }.to raise_error /invalid motor no.*#{0}/
      end
    end
  end
end

__END__

  context 'with kle file fixture' do
    #let(:path) { "#{RSpec.configuration.fixtures}/motors_test.kle" }
    #let(:data) { Zip::ZipFile.new(path).read("cache/motors.bin") }

    it 'initializes with data' do 
      expect { Klear::Motors.new(14, data) }.should_not raise_error
    end

    it 'load from binary string' do
      expect { Klear::Motors.new(14).load(data) }.should_not raise_error
    end

    context 'with loaded motors fixture' do
      let(:motors) { Klear::Motors.new(14, data) }

      it 'calculated the frame count' do 
        motors.frame_count.should eq(264)
      end

      it 'gets me a for any frame a array with a one value per blade motor' do
        (a = motors.get(7)).should be_kind_of(Array)
        a.size.should eq(a.blade_count)
      end
    end
  end
end

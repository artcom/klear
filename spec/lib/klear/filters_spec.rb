require 'spec_helper'

describe Klear::Filters do 
  it 'exists' do
    Klear::Filters.should be_kind_of(Module)
  end

  it 'projects values to range' do
    Klear::Filters.project([0, 0x8000, 0xffff], 10, 14).should eq([10, 12, 14])
  end

  it 'provides JJ/F14 sampling' do
    Klear::Filters.f14jj((0...90)).should eq([0,30,60])
  end
end

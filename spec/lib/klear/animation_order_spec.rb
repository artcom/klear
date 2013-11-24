require 'spec_helper'

describe Klear::AnimationOrder do
  let(:ao) { subject }

  it 'globs animation from directory' do
    ao_dir = "#{RSpec.configuration.fixtures}/animation_order"
    expect(ao.glob("#{ao_dir}/*.png")).to eq(%W(
      #{ao_dir}/frame_1.png
      #{ao_dir}/frame_2.png
      #{ao_dir}/frame_10.png
      #{ao_dir}/frame_12.png
      #{ao_dir}/frame_100.png
    ))
  end

  it 'raises exception on non numbered frames' do
    expect{ao.frame_number_from_string('a.png')}.to raise_error(
      /no frame number in filename: 'a.png'/
    )
  end

  it 'extracts leading number' do
    expect(ao.frame_number_from_string('23_a.png')).to eq(23)
  end

  it 'extracts trailing number' do
    expect(ao.frame_number_from_string('tmp/frames/frame_0.png')).to eq(0)
  end

  it 'extracts zero padded leading number' do
    expect(ao.frame_number_from_string('0023_a.png')).to eq(23)
  end

  it 'extracts zero padded trailing number' do
    expect(ao.frame_number_from_string('a_0023.png')).to eq(23)
  end

  it 'is no confused by trailing zeros' do
    expect(ao.frame_number_from_string('1000')).to eq(1000)
  end


  it 'sorts plain numbers' do 
    expect(ao.sort(%w(1 2 3 4))).to eq(%w(1 2 3 4))
  end

  it 'handles zero padded numbers' do 
    expect(ao.sort(%w(03 02 01 04))).to eq(%w(01 02 03 04))
  end

  it 'sorts numerical' do 
    expect(ao.sort(%w(100 1 2 10))).to eq(%w(1 2 10 100))
  end

  it 'sorts numerical when number is in string' do 
    expect(ao.sort(%w(f1 f100 f2 f20))).to eq(%w(f1 f2 f20 f100))
  end
end

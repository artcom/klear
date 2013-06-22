require 'klear/frame'

class Klear::Frames
  class Data < BinData::Record
    array :numbers, :type => :uint16be, :read_until => :eof
  end

  attr_reader :framesize, :rows, :columns

  def initialize columns, rows, binary_string = nil
    @rows, @columns = rows, columns
    @framesize =  @rows * @columns
    @data = nil
    load(binary_string) unless binary_string.nil?
  end

  def load binary_string
    @data = Data.read(binary_string).numbers
    self
  end

  def count
    @data.size / framesize
  end

  def each &blk
    0.upto(count-1) do |frame_no|
      yield(get(frame_no), frame_no)
    end
  end

  def get frame_no
    (0 <= frame_no) or (raise "invalid negative frame no: #{frame_no}")
    (frame_no < count) or (raise "frame no out of bound: #{frame_no}")
    Klear::Frame.new(
      @columns, @rows, @data.slice(frame_no * @framesize, @framesize)
    )
  end

  def all
    (0...count).map { |frame_no| get(frame_no) }
  end
end

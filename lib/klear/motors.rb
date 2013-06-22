class Klear::Motors
  #class Data < BinData::Record
  #  array :numbers, :type => :uint16be, :read_until => :eof
  #end

  attr_reader :count, :frame_count
  alias :blade_count :count

  def initialize blade_count, frames = nil
    @count = blade_count
    @frames = frames || [[0] * @count] # init with one frame
    @frame_count ||= @frames.size
  end

  #def frame_count
  #end

  def each &blk
    #0.upto(@frame_count - 1) do |frame_no|
    (1..@count).each do |motor_no|
      yield(get(motor_no), motor_no)
    end
  end

  # motor_no is one-based!!!
  def get motor_no
    motor_no = Integer(motor_no)
    (0 < motor_no) or (raise "invalid motor no: #{motor_no}")
    (motor_no <= @count) or (raise "motor no out of bounds: #{motor_no}")
    @frames.map {|frame| frame[motor_no-1]}
  end

  # frame_no is zero based!!!
  def frame frame_no
    (0 <= frame_no) or (raise "invalid negative frame no: #{frame_no}")
    (frame_no < @frame_count) or (raise "frame no out of bound: #{frame_no}")
    @frames[frame_no]
  end

  def render motor_no, options = {}
    low = options[:low] || 0
    high = options[:high] || 20000
    values = get(motor_no)
    values = f14jj(values)
    values = project(values, low, high)
  end

  def render_all options = {}
    low = options[:low] || 0
    high = options[:high] || 20000
    (1..@count).map {|i| render(i, low, high)}
  end
end

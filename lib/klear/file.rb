require 'klear/frames'
require 'klear/motors'

class Klear::File
  attr_accessor :path

  def initialize path = nil
    @path = path
  end

  def info
    @info ||= YAML.load(zipfile.read('META-INF/kle.yml'))
  end

  def manifest
    @manifest ||= YAML.load(zipfile.read('META-INF/MANIFEST.MF'))
  end

  def dimensions
    @dimensions ||= info['geometry']
  end

  def frames
    @frames ||= (
      data = zipfile.read("cache/frames.bin")
      Klear::Frames.new(dimensions[:columns], dimensions[:rows], data)
    )
  end

  def motors
    @motors ||= (
      #begin 
      #  data = zipfile.read("cache/motors.bin")
      #  Klear::Motors.new(dimensions[:columns], data)
      ##rescue Errno::ENOENT => e
      #  puts " ~~ empty motors cache (#{e})"
      #  Klear::Motors.new(dimensions[:columns])
      #end

      motors = frames.all.map do |frame|
        (frame.row 0) # convention: row zero is the motors
      end
      Klear::Motors.new(dimensions[:columns], motors)

      #animations = {}
      #frames.each do |frame, no|
      #  puts "frame: ##{no}"
      #  row = (frame.row 0) # convention: row zero is the motors
#
#        # scale input onto manta geometry
#        low, high = @config[:low], @config[:high]
#        d = (high - low).to_f
#
#        row.each_with_index do |v_in, x|
#          v_out = (low + d * (v_in.value.to_f / 0xffff)).to_i
#          (animations[x+1] ||= []) << v_out
#        end
#      end
    )
  end

  private
  def zipfile
    @zipfile ||= (
      @path or (raise 'path not specified')
      Zip::ZipFile.new(@path)
    )
  end
end

__END__

  def self.load theKleFile
    myChoreography = nil
    Zip::ZipFile.open(theKleFile) { |kle|
      myChoreography = new kle
    }
    myChoreography
  end

  def initialize theKleFile
    @kle_file = theKleFile
    @geometry = YAML.load(@kle_file.read("META-INF/kle.yml"))['geometry']
    @frames = Kleac::Choreography::Frames.read @kle_file.read("cache/frames.bin")
  end

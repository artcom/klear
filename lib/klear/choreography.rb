# TODO Add separate accessors for motors and lights?
# TODO Add row/blade accessors to Frames so a time-slice can be retrieved?

# Note: Row 0 is the motor setting / this is equivalent to the first value of a blade
class Klear::Choreography

  #class Frames < BinData::Record
  #  array :numbers, :type => :uint16be, :read_until => :eof
  #end

  attr_reader :geometry, :gamma, :fps
  attr_accessor :location

  def self.prefetch_playtime path
    Zip::ZipFile.open(path) { |zip| zip.dir.entries("/frames").size }
  end
  
  def self.load path
    #choreo = Zip::ZipFile.open(path) { |klear| new klear }
    self.new(Klear::File.new(path))
  end

  def initialize archive
    @archive = archive
    @location = @archive.path
    #info = YAML.load(@archive.read("META-INF/kle.yml"))
    info = @archive.info
    @geometry = info['geometry']
    @fps = info['fps'] || 25
    @gamma = info['gamma'] || 1.0
    @frames = @archive.frames
  end

  def info
    puts <<-INFO
Klear file at: #{@location}

Settings:
----------------
fps     : #{@fps}
gamma   : #{@gamma}
geometry: 
    columns: #{@geometry[:columns]}
    rows   : #{@geometry[:rows]}
----------------


Frames:
----------------
framesize : #{framesize}
framecount: #{framecount}
----------------


MANIFEST:
----------------
#{@archive.manifest}
----------------
    INFO
  end

  def id
    File.basename(self.location, ".kle")
  end

  def framesize
    @geometry[:columns] * @geometry[:rows]
  end
  
  def framecount
    @frames.count
  end

  def frame no
    @frames.get(no)
  end

  def each_frame &blk #block_given?
    (0...framecount).each do |n|
      myFrame = frame(n)
      blk.call(myFrame, n+1)
    end
  end
end

__END__
class Klear::Choreography::Frame

  attr_reader :data

  def initialize data, geometry
    @data = data
    @geometry = geometry
    @num_cols = @geometry[:columns] # local copy of columns to avoid per pixel symbol lookups
    @num_rows = @geometry[:rows] # local copy of columns to avoid per pixel symbol lookups
  end

  def size
    [@geometry[:columns], @geometry[:rows]]
  end

  def cell column, row
    @data[@num_cols * row + column] 
  end

  def row(no)
    @data.slice(no * @geometry[:columns], @geometry[:columns])
  end

  # XXX returning an array would be better than hashed by row number...
  def rows &blk
    myRows = {}
    (0...@geometry[:rows]).each do |n|
      current = myRows[n] = row(n)
      blk.call(current, n) if block_given?
    end
    myRows
  end

  def column theColumnNumber
    col = []
    (0...@geometry[:rows]).each { |curRow|
      col << @data[theColumnNumber + curRow * @geometry[:columns]]
    }
    col
  end

  def columns &blk
    myColumns = {}
    (0...@geometry[:columns]).each do |n|
      current = myColumns[n] = column(n)
      blk.call(current, n) if block_given?
    end
    myColumns
  end

  #def each_column &blk
  #  (0...@geometry[:columns]).each do |n|
  #    myColumn = column(n)
  #    blk.call(myColumn, n)
  #  end
  #end

  def dump
    myStr = ""
    rows { |row, idx|
      myStr << "#{idx} || " << row.collect{|x| x.to_s}.join(" | ") << "\n"
    }
    myStr
  end

  alias :blade :column
  alias :blades :columns
end

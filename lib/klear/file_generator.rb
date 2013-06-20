# TODO maybe use Zip::ZipOutputStream for generating the zip first in-memory?
# TODO extract java/jruby specific stuff

class Klear::FileGenerator
  
  def initialize options = {}
    @png_path = nil
    @kle_path = nil
    @fps = 25
    if options.has_key? :fps
      @fps = options[:fps]
    end
    @gamma = 1.0
    if options.has_key? :gamma
      @gamma = options[:gamma]
    end
    @geometry = nil
    @raw_frame_values = []
    @kle_file = nil
    @silent = true
    if options.has_key? :silent
      @silent = !!options[:silent]
    end
  end
  
  def load
    Zip::ZipFile.open(@kle_path) { |kle|
      @kle_file = kle
    }
  end
  
  def write
    Zip::ZipFile.open(@kle_path, Zip::ZipFile::CREATE) { |kle|
      @kle_file = kle
      add_pngs
      regenerate_cache
      
      # Meta
      kle.mkdir('META-INF')
      kle.file.open("META-INF/MANIFEST.MF", "w") do |os|
        os.write <<-MANIFEST
Manifest-Version: 1.0

Kle-Version: 1.0
Created-By: #{__FILE__} (#{Klear::VERSION})
Generated-At: #{Time.now}

        MANIFEST
      end
      kle.file.open("META-INF/kle.yml", "w") { |os|
        os.write({
          "geometry"    => @geometry,
          "gamma"       => @gamma,
          "fps"         => @fps
        }.to_yaml)
      }
    }
  end
  
  def generate thePngPath, theKleFile
    @png_path = thePngPath
    @kle_path = theKleFile
    if File.exists? @kle_path
      raise "File #{@kle_path} already exists"
    end
    write
    report
  end
  
  def report
    report = <<-REPORT

Input  Directory : '#{@png_path}'
Output KleFile : '#{@kle_path}'

  Details:
    * number of [png files|frames]: #{@kle_file.dir.entries("/frames").size}
    * fps: #{@fps}
    * gamma : #{@gamma}
    * geometry : #{@geometry}

    REPORT
    puts report if !@silent
  end
  
  def regenerate theKleFile
    @kle_path = theKleFile
    load
    regenerate_cache
  end
  
  private
  
  def add_pngs
    @kle_file.mkdir('frames')
    Dir.glob("#{@png_path}/*.png") do |file|
      puts " * adding png file '#{file}' to '#{@kle_path}'" if !@silent
      @kle_file.add("frames/#{File.basename(file)}", file)
    end
  end
  
  def regenerate_cache
    puts "regenerating cache..." if !@silent
    if @kle_file.dir.entries("/").include?("cache")
      @kle_file.dir.rmdir('cache')
    end
    @kle_file.dir.mkdir('cache')
    if @raw_frame_values.empty?
      analyze_images
    end
    @kle_file.file.open("cache/frames.bin", "wb") { |os|
      arr = BinData::Array.new(:type => :uint16be)
      arr.assign @raw_frame_values
      arr.write(os)
    }
    @kle_file.commit
  end
  
if RUBY_PLATFORM.match /java/i
  include Java
  import 'javax.media.jai.JAI'
  import 'com.sun.media.jai.codec.ByteArraySeekableStream'

  def analyze_images
    @kle_file.dir.entries("/frames").each { |png|
      puts "analyzing image file '#{png}'" if !@silent
      seekable = ByteArraySeekableStream.new(@kle_file.file.read("/frames/#{png}").to_java_bytes)
      image = JAI.create("stream", seekable)
      @raw_frame_values = @raw_frame_values + analyze_image(image)
    }
  end

  def analyze_image image
    if !@geometry
      @geometry = { :columns => image.width  / 10,
                    :rows    => image.height / 10 }
      puts "Determined geometry: #{@geometry.inspect}" if !@silent
    end

    raster = image.getData
    bytes = []
    (0...@geometry[:rows]).to_a.reverse!.each { |row|
      (0...@geometry[:columns]).each { |col|
        myPixelY = 5 + 10 * (row)
        myPixelX = 5 + 10 * (col)
        myPickedValue = raster.getPixel(myPixelX, myPixelY, nil)[0].to_i
        #puts "value at (col #{col}, #{@geometry[:rows] - row - 1}) - pixel-coords: (#{myPixelX}, #{myPixelY}) => #{myPickedValue}"
        bytes << myPickedValue
      }
    }
    bytes
  end

else # NOT JAVA!
  def analyze_images
    raise "use JRUBY to run this script with #analyse_images support"
  end
end
  
end

class Klear::FileGenerator
  
  Defaults = {
    overwrite: false, 
    fps: 25,
    gamma: 1.0,
    pixel_scale: [10, 10],
  }

  def initialize options = {}
    @options = Defaults.merge(options)
    @fps = @options[:fps]
    @gamma = @options[:gamma]

    @raw_frame_values = []
    @png_path = nil
    @kle_path = nil
    @geometry = nil
    @kle_file = nil
  end

  def pixel_scale
    @options[:pixel_scale]
  end

  def overwrite?
    @options[:overwrite]
  end
  
  def load
    Zip::ZipFile.open(@kle_path) {|kle| @kle_file = kle}
  end
  
  def write(path)
    # TODO:  maybe use Zip::ZipOutputStream to generate zip file in-memory?
    Zip::ZipFile.open(path, Zip::ZipFile::CREATE) do |klear|
      @kle_file = klear
      add_pngs(@kle_file)
      recache
      
      # Meta
      klear.mkdir('META-INF')
      klear.file.open("META-INF/MANIFEST.MF", "w") do |fd|
        fd.write <<-MANIFEST
Manifest-Version: 1.0

Kle-Version: 1.1
Created-By: #{__FILE__} (#{Klear::VERSION})
Generated-At: #{Time.now}

        MANIFEST
      end

      klear.file.open("META-INF/kle.yml", "w") do |fd|
        fd.write({
          "geometry"    => @geometry,
          "pixel_scale" => pixel_scale,
          "gamma"       => @gamma,
          "fps"         => @fps
        }.to_yaml)
      end
    end
  end
  
  def generate thePngPath, theKleFile
    @png_path = thePngPath
    @kle_path = theKleFile
    if (File.exists? @kle_path) 
      if overwrite?
        FileUtils.rm(@kle_path, force: true)
      else
        raise "'#{@kle_path}' :: already exists! (use --overwrite to force it)"
      end
    end
    write(@kle_path)
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
    puts report if !$silent
  end
  
  def regenerate theKleFile
    @kle_path = theKleFile
    load
    recache
  end
  
  private
  
  def add_pngs(klear)
    klear.mkdir('frames')
    Klear::AnimationOrder.glob("#{@png_path}/*.png") do |file|
      puts " * adding png file '#{file}' to '#{@kle_path}'" if !$silent
      klear.add("frames/#{File.basename(file)}", file)
    end
  end
  
  def recache
    puts "regenerating cache..." if !$silent
    if @kle_file.dir.entries("/").include?("cache")
      @kle_file.dir.rmdir('cache')
    end
    @kle_file.dir.mkdir('cache')
    if @raw_frame_values.empty?
      @raw_frame_values = analyze_images(@kle_file)
    end
    @kle_file.file.open("cache/frames.bin", "wb") do |os|
      arr = BinData::Array.new(:type => :uint16be)
      arr.assign @raw_frame_values
      arr.write(os)
    end
    @kle_file.commit
  end
  
# TODO: extract java/jruby specific stuff
if RUBY_PLATFORM.match /java/i
  include Java
  import 'javax.media.jai.JAI'
  import 'com.sun.media.jai.codec.ByteArraySeekableStream'

  def analyze_images(klear)
    bytes = []
    klear.dir.entries("/frames").each do |png|
      puts "analyzing image file '#{png}'" if !$silent
      image = load_image(klear.file.read("/frames/#{png}"))
      bytes.concat(analyze_image(image, pixel_scale))
    end
    bytes
  end

  def load_image(ruby_bytes)
      istream = ByteArraySeekableStream.new(ruby_bytes.to_java_bytes)
      image = JAI.create("stream", istream)

      if @geometry.nil? # first loaded image defines the geometry
        xs, ys = *pixel_scale
        @geometry = {columns: image.width / xs, rows: image.height / ys}
        puts "Determined geometry: #{@geometry.inspect}" if !$silent

        if(image.width.modulo(xs) != 0) or (image.height.modulo(ys) != 0) 
          raise "image size / pixel scale mismatch: #{@geometry} - #{p@ixel_scale}"
        end
      end

      image
  end

  def analyze_image(image, pixel_scale)
    #@geometry ||= (
    #  puts "Determined geometry: #{@geometry.inspect}" if !$silent
    #  {columns: image.width  / 10, rows: image.height / 10}
    #)

    xs, ys = *pixel_scale
    xc, yc = image.width / xs, image.height / ys

    raster = image.getData
    bytes = []
    (0...yc).to_a.reverse!.each do |row|
      (0...xc).each do |col|
        yi = (row + 0.5) * ys    # 5 + 10 * (row)
        xi = (col + 0.5) * xs # 5 + 10 * (col)
        val = raster.getPixel(xi, yi, nil)[0].to_i
        #puts "value at (col #{col}, #{@geometry[:rows] - row - 1}) - pixel-coords: (#{xi}, #{yi}) => #{val}"
        bytes << val
      end
    end
    bytes
  end

else # NOT JAVA!
  def analyze_images(*_)
    raise "use JRUBY to run this script with #analyse_images support"
  end
end
  
end

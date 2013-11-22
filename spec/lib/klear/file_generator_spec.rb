require 'spec_helper'
require 'tmpdir'
require 'fileutils'

describe Klear::FileGenerator do
  unless RUBY_PLATFORM.match /java/i
    pending 'porting tests from jruby'
  else
    context 'default options' do
      let(:fg) { Klear::FileGenerator.new }
      it 'defaults to not overwrite' do 
        expect(fg.overwrite?).to be(false)
      end
    end

  
    it "reads a directory with pngs and produces a valid kle file" do
      fg = Klear::FileGenerator.new :fps => 33, :gamma => 2.4
      tmpDir = Dir.mktmpdir
  
      path = "#{tmpDir}/Waves.kle"
      pngDirPath = "#{RSpec.configuration.fixtures}/kle_generate/simple_Waves"
  
      fg.generate pngDirPath, path
      Zip::ZipFile.open(path) { |kle|
        # test generated files' existence
        ["META-INF/kle.yml", "META-INF/MANIFEST.MF","cache/frames.bin"]. each { |entry|
          kle.get_entry entry
        }
        
        myKleYaml = YAML.load(kle.read("META-INF/kle.yml"))
        myKleYaml["gamma"].should eq(2.4)
        myKleYaml["fps"].should eq(33)
        myKleYaml["geometry"][:columns].should eq(14)
        myKleYaml["geometry"][:rows].should eq(11)
        
        # Test if pngs were added
        counter = 0
        Dir.glob("#{pngDirPath}/*.png") do |png|
          kle.get_entry "frames/#{File.basename(png)}"
          counter += 1
        end
        counter.should eq(2)
      }
  
      FileUtils.rmtree tmpDir
    end
    
    it "uses default values for fps and gamma" do
      fg = Klear::FileGenerator.new
      tmpDir = Dir.mktmpdir
      path = "#{tmpDir}/Waves.kle"
      pngDirPath = "#{RSpec.configuration.fixtures}/kle_generate/simple_Waves"
  
      fg.generate pngDirPath, path
      Zip::ZipFile.open(path) { |kle|
        myKleYaml = YAML.load(kle.read("META-INF/kle.yml"))
        myKleYaml["gamma"].should eq(1.0)
        myKleYaml["fps"].should eq(25)
      }
      FileUtils.rmtree tmpDir
    end
  
    it "regenerates a kle file's cache" do
      fg = Klear::FileGenerator.new
      tmpDir = Dir.mktmpdir
  
      path = "#{tmpDir}/Waves.kle"
      pngDirPath = "#{RSpec.configuration.fixtures}/kle_generate/simple_Waves"
  
      fg.generate pngDirPath, path
      Zip::ZipFile.open(path) { |kle|
        # test generated files' existence
        kle.remove "cache/frames.bin"
      }
  
      fg = Klear::FileGenerator.new
      fg.regenerate path
  
      Zip::ZipFile.open(path) { |kle|
        ["cache/frames.bin"]. each { |entry|
          kle.get_entry entry
        }
      }
  
      FileUtils.rmtree tmpDir
    end
  end # JAVA
end

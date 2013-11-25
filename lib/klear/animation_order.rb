module Klear::AnimationOrder

  def glob pattern, &blk
    filenames = sort(Dir.glob(pattern))
    blk.nil? or filenames.each {|fname| blk.call(fname)}
    filenames
  end

  def sort(filenames)
    filenames.sort do |a, b| 
      begin
        frame_number_from_string(a) <=> frame_number_from_string(b)
      rescue ArgumentError => e
        a <=> b
      end
    end
  end

  def frame_number_from_string(filename)
    Integer(filename.tr('^0-9', '').sub(/^0+(\d)/, '\1'))
  rescue ArgumentError => e
    raise e, "no frame number in filename: '#{filename}' - #{e}"
  end

  extend(self)
end

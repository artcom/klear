class Klear::Frame

  attr_reader :data, :row_count, :column_count, :size

  def initialize column_count, row_count, data = nil
    @row_count, @column_count = row_count, column_count
    @size = @row_count * @column_count
    @data = data
  end

  def cell x, y
    column(x)[y]
  end

  def row no
    @data.slice(no * @column_count, @column_count)
  end

  #def rows *args, &blk
  #  if block_given?
  #    each_row(&blk)
  #  else
  #    myRows = {}
  #    (0...@row_count).each do |n|
  #      myRows[n] = row(n)
  #    end
  #    myRows
  #  end
  #end

  # returns array of rows
  def each_row &blk
    @rows ||= (0...@row_count).map {|n| row(n)}

    if block_given?
      @rows.each_with_index {|row, idx| blk.call(row, idx)}
    end

    @rows
  end
  alias_method :rows, :each_row 

  def column no
    col = []
    (0...@row_count).each do |curRow|
      col << @data[no + curRow * @column_count]
    end
    col
  end
  alias_method :blade, :column

  def each_column &blk
    @columns ||= (0...@column_count).map {|n| column(n)}

    if block_given?
      @columns.each_with_index {|column, idx| blk.call(column, idx)}
    end

    @columns
  end
  alias_method :each_blade, :each_column 
  alias_method :columns, :each_column 

  #def dump
  #  myStr = ""
  #  rows do |row, idx|
  #    myStr << "#{idx} || " << row.collect{|x| x.to_s}.join(" | ") << "\n"
  #  end
  #  myStr
  #end
end

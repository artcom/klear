module Klear::Filters
  # scale input onto manta geometry
  def project values, low, high
    #low, high = @config[:low], @config[:high]
    d = (high - low).to_f

    values.map do |val|
      (low + d * (val.to_f / 0xffff)).to_i
    end
  end

  # hack: sample(F14 by JJ) 600 down to 2 times 20 => 40 frame positions
  def f14jj values 
    no = -1
    values.select { (no += 1) % 30 == 0 }
  end

  extend(self)
end

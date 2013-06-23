describe Klear::VERSION do 
  it 'defines a VERSION' do 
    Klear::VERSION.should be_kind_of(String)
    Klear::VERSION.should match(/\d\.\d\.\d/)
  end
end

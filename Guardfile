# Guardfile info at: https://github.com/guard/guard#readme

guard 'rspec', all_on_start: true, cli: '--format nested --debug --color' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
  watch('lib/klear.rb')  { "spec" }
end

# encoding: utf-8

batch :build do
  puts 'Nothing to build!'
end

batch :test do
  rubocop
  rspec
end

invoke_batch :test

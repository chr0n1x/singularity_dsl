on_fail do
  puts 'failed'
end

on_error do
  puts 'error'
end

on_success do
  puts 'okee dokee'
end

always do
  puts 'RAISE YO DONGERS'
end

rubocop
rspec

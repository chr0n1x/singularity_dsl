# encoding: utf-8

# YEAH, THAT'S RIGHT
if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  throw 'Sorry, wont run on mswin|mingw32|windows'
end

require 'singularity_dsl/application'
require 'singularity_dsl/dsl/components'

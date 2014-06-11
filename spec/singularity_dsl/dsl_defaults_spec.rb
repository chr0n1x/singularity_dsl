# encoding: utf-8

require 'singularity_dsl/dsl_defaults'

describe 'DslDefaults' do
  include SingularityDsl::DslDefaults

  context '#on_error' do
    it 'creates an error_proc' do
      on_error {}
      expect(@error_proc).to be_a_kind_of Proc
    end
  end

  context '#on_fail' do
    it 'creates an fail_proc' do
      on_fail {}
      expect(@fail_proc).to be_a_kind_of Proc
    end
  end

  context '#on_success' do
    it 'creates an error_proc' do
      on_success {}
      expect(@success_proc).to be_a_kind_of Proc
    end
  end

  context '#always' do
    it 'creates an error_proc' do
      always {}
      expect(@always_proc).to be_a_kind_of Proc
    end
  end
end

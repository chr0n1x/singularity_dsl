# encoding: utf-8

require 'singularity_dsl/dsl_generator'

describe 'DslGenerator' do
  context '#initialize' do
    it 'creates a DSL object' do
      instance = SingularityDsl::DslGenerator.new
      expect(instance.dsl.class <= SingularityDsl::Dsl).to eql true
    end
  end
end

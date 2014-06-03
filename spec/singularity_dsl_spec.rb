# encoding: utf-8

require 'singularity_dsl'

include SingularityDsl

describe 'SingularityDsl' do
  context '#task_name' do
    it 'returns classname without context' do
      expect(SingularityDsl.task_name('Some::Class::Foo')).to eql('Foo')
    end
  end
end

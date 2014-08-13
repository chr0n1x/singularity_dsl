# encoding: utf-8

require 'singularity_dsl/dsl/batch'

# dummy class to use for block contexts
class TestObject
  def meth
  end
end

describe 'Batch' do
  context '#initialize' do
    it 'converts name to symbol' do
      batch = SingularityDsl::Dsl::Batch.new('test', self)
      expect(batch.name).to eql(:test)
    end
  end

  context '#execute' do
    it 'executes block in passed context' do
      dummy = TestObject.new
      allow(dummy).to receive(:meth)
      batch = SingularityDsl::Dsl::Batch.new('test', dummy) do |thing|
        thing.meth
      end
      expect(dummy).to receive(:meth)
      batch.execute
    end
  end
end

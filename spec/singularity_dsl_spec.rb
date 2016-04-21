# encoding: utf-8

require 'singularity_dsl'

# WARNING: HERE THERE BE DRAGONS
describe 'SingularityDsl' do
  after(:all) { SingularityDsl.reset_map }

  context '#map_task_file' do
    it 'saves class as sym, maps it to file' do
      SingularityDsl.map_task_file 'string', 'foo'
      expect(SingularityDsl.task_map).to include(String: 'foo')
    end
  end

  context '#task_file' do
    it 'returns false when no such class' do
      expect(SingularityDsl.task_file(1)).to eql false
    end

    it 'returns the correct mapping for a class' do
      # THIS VALUE IS FROM THE RUN IN '#map_task_file'
      expect(SingularityDsl.task_file('foo')).to eql('foo')
    end
  end
end

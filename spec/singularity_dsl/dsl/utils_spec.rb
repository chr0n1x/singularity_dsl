# encoding: utf-8

require 'singularity_dsl/dsl/utils'

class TestTask < SingularityDsl::Task
end

describe 'Utils' do
  include SingularityDsl::Dsl::Utils

  context '#task_name' do
    it 'simplifies class names correctly' do
      expect(task_name('Foo::Bar::Blah')).to eql 'Blah'
    end
  end

  context '#task' do
    it 'returns lowercase sym representing DSL fx' do
      expect(task(TestTask)).to eql :testtask
    end
  end

  context '#task_list' do
    it 'returns array of tasks' do
      tasks = task_list
      expect(tasks).to be_a_kind_of Array
      expect(tasks).to_not be_empty
      tasks.each do |task|
        expect(task <= SingularityDsl::Task).to eql true
      end
    end
  end
end

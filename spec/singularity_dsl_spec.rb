# encoding: utf-8

require 'singularity_dsl'

module SingularityDsl
  class TestTask < Task
  end
end

include SingularityDsl

describe 'SingularityDsl' do
  context '#task_list' do
    it 'returns an array of Tasks' do
      tasks = SingularityDsl.task_list
      expect(tasks).to be_a_kind_of Array
      tasks.each do |task|
        task.should be < Task
      end
    end
  end

  context '#load_tasks' do
    it 'dynamically creates task methods' do
      SingularityDsl.load_tasks
      expect(SingularityDsl.method_defined? :testtask).to eql true
    end
  end
end

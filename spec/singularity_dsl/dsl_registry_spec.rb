# encoding: utf-8

require 'singularity_dsl/dsl/registry'
require 'singularity_dsl/task'

class TestTask < SingularityDsl::Task
end

describe 'DslRegistry' do
  before :each do
    @instance = SingularityDsl::Dsl::Registry.new
  end

  context '#initialize' do
    it 'creates empty task_list array' do
      expect(@instance.task_list).to be_kind_of Array
      expect(@instance.task_list).to be_empty
    end
  end

  context '#add_task' do
    it 'adds tasks' do
      task = TestTask.new
      @instance.add_task task
      expect(@instance.task_list).to_not be_empty
      expect(@instance.task_list).to eql [task]
    end

    it 'fails when non-task is given' do
      expect { @instance.add_task 'fail' }
        .to raise_error ::RuntimeError, /Non-task given - /
    end

    it 'fails when raw task is given' do
      expect { @instance.add_task SingularityDsl::Task.new }
        .to raise_error ::RuntimeError, /Cannot use raw Task objects - /
    end
  end
end

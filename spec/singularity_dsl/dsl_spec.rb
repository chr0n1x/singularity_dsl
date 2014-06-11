# encoding: utf-8

require 'singularity_dsl/dsl'
require 'singularity_dsl/task'

class TestTask < SingularityDsl::Task
end

describe 'Dsl' do
  before :each do
    @instance = SingularityDsl::Dsl.new
  end

  context '#initialize' do
    it 'creates tasks array with base tasks' do
      expect(@instance.tasks).to be_a_kind_of Array
      expect(@instance.tasks).to_not be_empty
    end
  end

  context '#define_task' do
    it 'creates task function for given task' do
      @instance.define_task TestTask
      expect(@instance.singleton_methods).to include :testtask
    end

    it 'keeps a record of dynamically defined methods' do
      @instance.define_task TestTask
      expect(@instance.tasks).to include :testtask
    end

    it 'throws when tasks have the same name' do
      @instance.define_task TestTask
      expect { @instance.define_task TestTask }
        .to raise_error RuntimeError, /task name clash/
    end
  end

  context '#task_name' do
    it 'simplifies class names correctly' do
      expect(@instance.task_name 'Foo::Bar::Blah').to eql 'Blah'
    end
  end

  context '#task_list' do
    it 'returns array of tasks' do
      tasks = @instance.task_list
      expect(tasks).to be_a_kind_of Array
      expect(tasks).to_not be_empty
      tasks.each do |task|
        expect(task <= SingularityDsl::Task).to eql true
      end
    end
  end
end

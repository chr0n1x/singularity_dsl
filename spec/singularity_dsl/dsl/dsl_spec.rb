# encoding: utf-8

require 'singularity_dsl/dsl/dsl'
require 'singularity_dsl/dsl/registry'
require 'singularity_dsl/task'

class TestTask < SingularityDsl::Task
end

describe 'Dsl' do
  let(:dsl) { SingularityDsl::Dsl::Dsl.new }

  context '#initialize' do
    it 'creates registry' do
      expect(dsl.registry).to be_a_kind_of SingularityDsl::Dsl::Registry
    end
  end

  context '#define_task' do
    it 'creates task function for given task' do
      dsl.define_task TestTask
      expect(dsl.singleton_methods).to include :testtask
    end

    it 'throws when tasks have the same name' do
      dsl.define_task TestTask
      expect { dsl.define_task TestTask }
        .to raise_error RuntimeError, /task name clash/
    end
  end

  context '#load_tasks_in_path' do
    it 'does not load tasks that have already been required' do
      path = ::File.dirname(__FILE__) + '/../../lib/singularity_dsl/tasks'
      expect(dsl).to receive(:load_tasks).with []
      dsl.load_tasks_in_path path
    end

    it 'actually loads new tasks from dir' do
      path = ::File.dirname(__FILE__) + '/stubs/tasks'
      dsl.load_tasks_in_path path
      expect(dsl.singleton_methods).to include :dummytask
      # IMPORTANT: do this to prevent the singleton
      # from having this task in the map
      SingularityDsl.reset_map
    end
  end
end

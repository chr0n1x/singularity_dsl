# encoding: utf-8

require 'singularity_dsl'

module SingularityDsl
  class TestTask < Task
  end
end

include SingularityDsl

describe 'SingularityDsl' do
  context '#task_name' do
    it 'returns classname without context' do
      expect(SingularityDsl.task_name('Class::Foo')).to eql('Foo')
      expect(SingularityDsl.task_name('Foo')).to eql('Foo')
    end
  end

  context '#task_to_sym' do
    it 'returns symbol' do
      sym = SingularityDsl.task_to_sym('Some::Class::Foo')
      expect { throw sym }.to throw_symbol
    end
  end

  context '#task_list' do
    it 'returns an array of Tasks' do
      tasks = SingularityDsl.task_list
      expect(tasks).to be_a_kind_of(Array)
      tasks.each do |task|
        task.should be < Task
      end
    end
  end

  context '#load_tasks' do
    it 'dynamically creates task methods' do
      context_it = self
      SingularityDsl.load_tasks
      TestTask do
        context_it.expect(true).to context_it.eql(true)
      end
    end
  end
end

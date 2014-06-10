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
    it 'creates tasks array' do
      expect(@instance.tasks).to be_a_kind_of Array
      expect(@instance.tasks).to be_empty
    end
  end

  context '#define_resource' do
    it 'creates resource function for given task' do
      @instance.define_resource TestTask
      expect(@instance.singleton_methods).to include :testtask
    end

    it 'keeps a record of dynamically defined methods' do
      @instance.define_resource TestTask
      expect(@instance.tasks).to eql [:testtask]
    end

    it 'throws when resources have the same name' do
      @instance.define_resource TestTask
      expect { @instance.define_resource TestTask }
        .to raise_error RuntimeError, /resource name clash/
    end
  end
end

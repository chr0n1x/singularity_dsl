# encoding: utf-8

require 'singularity_dsl/dsl/event_store'

describe 'DslEventStore' do
  let(:instance) { SingularityDsl::Dsl::EventStore.new }

  context '#on_error' do
    it 'creates an array of error_procs' do
      expect(instance.error_procs).to be_a_kind_of Array
      instance.on_error {}
      expect(instance.error_procs.first).to be_a_kind_of Proc
    end
  end

  context '#on_fail' do
    it 'creates an array of fail_procs' do
      expect(instance.fail_procs).to be_a_kind_of Array
      instance.on_fail {}
      expect(instance.fail_procs.first).to be_a_kind_of Proc
    end
  end

  context '#on_success' do
    it 'creates an array of success_procs' do
      expect(instance.success_procs).to be_a_kind_of Array
      instance.on_success {}
      expect(instance.success_procs.first).to be_a_kind_of Proc
    end
  end

  context '#always' do
    it 'creates an array of procs to always execute' do
      expect(instance.always_procs).to be_a_kind_of Array
      instance.always {}
      expect(instance.always_procs.first).to be_a_kind_of Proc
    end
  end
end

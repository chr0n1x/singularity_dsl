# encoding: utf-8

require 'singularity_dsl/dsl/event_store'

# container to include DslEventStore
class EventStoreTest
  include SingularityDsl::Dsl::EventStore
end

describe 'DslEventStore' do
  let(:instance) { EventStoreTest.new }

  context '#on_error' do
    it 'creates an error_proc' do
      expect(instance.error_proc).to be_a_kind_of Proc
      instance.on_error {}
      expect(instance.error_proc).to be_a_kind_of Proc
    end
  end

  context '#on_fail' do
    it 'creates an fail_proc' do
      expect(instance.fail_proc).to be_a_kind_of Proc
      instance.on_fail {}
      expect(instance.fail_proc).to be_a_kind_of Proc
    end
  end

  context '#on_success' do
    it 'creates an error_proc' do
      expect(instance.success_proc).to be_a_kind_of Proc
      instance.on_success {}
      expect(instance.success_proc).to be_a_kind_of Proc
    end
  end

  context '#always' do
    it 'creates an error_proc' do
      expect(instance.always_proc).to be_a_kind_of Proc
      instance.always {}
      expect(instance.always_proc).to be_a_kind_of Proc
    end
  end
end

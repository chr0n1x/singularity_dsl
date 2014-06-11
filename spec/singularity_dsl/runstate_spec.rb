# encoding: utf-8

require 'singularity_dsl/runstate'

describe 'Runstate' do
  before :each do
    @instance = SingularityDsl::Runstate.new
  end

  context '#initialize' do
    it 'sets error & failed to false' do
      expect(@instance.error).to eql false
      expect(@instance.failed).to eql false
    end

    it 'starts of with empty failure & error arrays' do
      expect(@instance.errors).to be_kind_of Array
      expect(@instance.errors).to be_empty
      expect(@instance.failures).to be_kind_of Array
      expect(@instance.failures).to be_empty
    end
  end

  context '#add_failure' do
    it 'sets failed to true' do
      @instance.add_failure 'failed'
      expect(@instance.failed).to eql true
    end

    it 'adds failure' do
      @instance.add_failure 'failed'
      expect(@instance.failures).to eql ['failed']
    end

    it 'does NOT affect error state' do
      @instance.add_failure 'failed'
      expect(@instance.error).to eql false
    end
  end

  context '#add_error' do
    it 'sets error to true' do
      @instance.add_error 'error'
      expect(@instance.error).to eql true
    end

    it 'adds error' do
      @instance.add_error 'error'
      expect(@instance.errors).to eql ['error']
    end

    it 'does NOT affect failed state' do
      @instance.add_error 'error'
      expect(@instance.failed).to eql false
    end
  end

  context '#exit_code' do
    it 'returns 1 on error' do
      @instance.add_error 'error'
      expect(@instance.exit_code).to eql 1
    end

    it 'returns 1 on failure' do
      @instance.add_failure 'failure'
      expect(@instance.exit_code).to eql 1
    end

    it 'returns 0 otherwise' do
      expect(@instance.exit_code).to eql 0
    end
  end
end

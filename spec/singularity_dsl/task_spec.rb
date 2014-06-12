# encoding: utf-8

require 'singularity_dsl/task'

describe 'Task' do
  context '#initialize' do
    it 'does nothing if no block given' do
      expect(SingularityDsl::Task).to_not receive :instance_eval
      SingularityDsl::Task.new
    end

    it 'evals given block if given' do
      expect(Kernel).to receive(:puts).with('woooooo')
      SingularityDsl::Task.new { Kernel.puts 'woooooo' }
    end
  end

  context '#validate_file' do
    it 'throws if file DNE' do
      expect { SingularityDsl::Task.new.validate_file('asdbfadf') }
        .to raise_error(ArgumentError, /Cannot find/)
    end
  end

  context '#execute' do
    it 'throws' do
      expect { SingularityDsl::Task.new.execute }
        .to raise_error(RuntimeError,
                        'SingularityDsl::Task::execute not implemented')
    end
  end

  context '#failed_status' do
    it 'returns false for specific values' do
      task = SingularityDsl::Task.new
      expect(task.failed_status nil).to eql false
      expect(task.failed_status 0).to eql false
      expect(task.failed_status false).to eql false
    end
  end

  context '#self.description' do
    it 'auto-generates task description' do
      expect(SingularityDsl::Task.new.description)
        .to eql 'Runs SingularityDsl::Task task'
    end
  end
end

# encoding: utf-8

require 'singularity_dsl/tasks/shell_task'

describe 'ShellTask' do
  let(:sh_task) { ShellTask.new }

  context '#command' do
    it 'sets commands!' do
      cmd = 'echo "hi :)"'
      sh_task.command cmd
      expect(sh_task.shell.command).to eql cmd
    end

    it 'sets live_stream to STDOUT' do
      cmd = 'echo "hi :)"'
      sh_task.command cmd
      expect(sh_task.shell.live_stream).to eql STDOUT
    end
  end

  context '#task_name' do
    it 'returns command' do
      expect(sh_task.task_name).to eql false
    end

    it 'returns command' do
      cmd = 'echo "hi :)"'
      sh_task.command cmd
      expect(sh_task.task_name).to eql 'echo "hi :)"'
    end
  end

  context '#execute' do
    it 'errors when command() was never called' do
      expect { sh_task.execute }.to raise_error
    end

    it 'runs command returns correct status' do
      cmd = 'echo "hi :)"'
      sh_task.command cmd
      expect(sh_task.shell).to receive(:run_command)
      expect(sh_task.shell).to receive(:exitstatus).and_return 0
      expect(sh_task.execute).to eql 0
    end
  end
end

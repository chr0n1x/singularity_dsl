# encoding: utf-8

require 'singularity_dsl/tasks/shell_task'

describe 'ShellTask' do
  let(:sh_task) { ShellTask.new }
  before(:each) do
    allow(sh_task).to receive(:log_shell)
  end

  context '#initialize' do
    it 'starts with no conditionals' do
      expect(sh_task.conditionals).to eql []
    end

    it 'has an echo notification as a default alt cmd' do
      expect(sh_task.alternative)
        .to eql 'echo "no alternative shell cmd defined"'
    end
  end

  context '#condition' do
    it 'throws when non string given' do
      expect { sh_task.condition([]) }.to raise_error(/must be string/)
    end

    it 'appends the cmd to conditionals array' do
      sh_task.condition 'woo'
      expect(sh_task.conditionals).to eql ['woo']
    end
  end

  context '#no_fail' do
    it 'fails when non-bool given' do
      expect { sh_task.no_fail [] }.to raise_error(/must be bool/)
    end
  end

  context '#alt' do
    it 'throws when non string given' do
      expect { sh_task.alt([]) }.to raise_error(/must be string/)
    end

    it 'sets alternative cmd' do
      sh_task.alt 'woo'
      expect(sh_task.alternative).to eql 'woo'
    end
  end

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
      expect { sh_task.execute }.to raise_error(/command never/)
    end

    it 'runs command returns correct status, with conditionals' do
      cmd = 'echo "hi :)"'
      alt = 'echo "no"'
      sh_task.live_stream = false
      sh_task.command cmd
      sh_task.alt alt
      sh_task.condition 'ls'
      expect(sh_task).to_not receive(:command).with(alt)
      expect(sh_task.shell).to receive(:run_command)
      expect(sh_task.shell).to receive(:exitstatus).and_return 0
      expect(sh_task.execute).to eql 0
    end

    it 'runs alternative command' do
      cmd = 'echo "hi :)"'
      alt = 'echo "no"'
      sh_task.live_stream = false
      sh_task.command cmd
      sh_task.alt alt
      sh_task.condition 'ls -z'
      expect(sh_task).to_not receive(:command).with(cmd)
      expect(sh_task).to receive(:command).with(alt)
      expect(sh_task.shell).to receive(:run_command)
      expect(sh_task.shell).to receive(:exitstatus).and_return 0
      expect(sh_task.execute).to eql 0
    end

    it 'runs command returns correct status, no conditionals' do
      sh_task.command 'echo "hi :)"'
      expect(sh_task.shell).to receive(:run_command)
      expect(sh_task.shell).to receive(:exitstatus).and_return 0
      expect(sh_task.execute).to eql 0
    end

    it 'returns 0 if no_fail set' do
      sh_task.command 'ls -z'
      sh_task.no_fail true
      expect(sh_task.shell).to receive(:run_command)
      expect(sh_task.shell).to_not receive(:exitstatus)
      expect(sh_task.execute).to eql 0
    end
  end
end

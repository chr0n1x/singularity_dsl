# encoding: utf-8

require 'singularity_dsl/tasks/boot_coveralls'

describe BootCoveralls do
  let(:coveralls) { BootCoveralls.new }

  context '#no_fail' do
    it 'fails when non-bool given' do
      expect { coveralls.no_fail [] }.to raise_error
    end
  end

  context '#execute' do
    before(:each) do
      allow(coveralls).to receive(:info)
    end

    context 'environment not correct' do
      it 'return if COVERALLS_REPO_TOKEN is not set' do
        allow(ENV).to receive(:key?)
          .with('COVERALLS_REPO_TOKEN').and_return false

        expect(coveralls).to receive(:info)
          .with('Missing ENV variable: COVERALLS_REPO_TOKEN')
        expect(coveralls).to receive(:info)
          .with('Skipping coveralls')
        expect(coveralls.execute).to eql nil
      end
    end
  end
end

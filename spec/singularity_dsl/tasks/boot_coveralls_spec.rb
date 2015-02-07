# encoding: utf-8

require 'singularity_dsl/tasks/boot_coveralls'

describe BootCoveralls do
  let(:coveralls) { BootCoveralls.new }

  describe '#token' do
    it 'sets COVERALLS_REPO_TOKEN' do
      # cannot actually set var - will overwrite the ACTUAL
      # value ...UGGGGH :(
      expect(ENV).to receive(:[]=)
        .with('COVERALLS_REPO_TOKEN', 'foobar')
      coveralls.token 'foobar'
    end
  end

  describe '#report_endpoint' do
    after(:each) do
      ENV['COVERALLS_ENDPOINT'] = nil
    end

    it 'sets COVERALLS_ENDPOINT' do
      coveralls.report_endpoint 'foobar'

      expect(ENV['COVERALLS_ENDPOINT']).to eql 'foobar'
    end
  end

  describe '#no_fail' do
    it 'fails when non-bool given' do
      expect { coveralls.no_fail [] }.to raise_error
    end
  end

  describe '#execute' do
    before(:each) do
      allow(coveralls).to receive(:info)
    end

    context 'environment not correct' do
      before(:each) do
        allow(ENV).to receive(:key?)
          .with('COVERALLS_REPO_TOKEN').and_return false
      end

      it 'return if COVERALLS_REPO_TOKEN is not set' do
        expect(coveralls).to receive(:info)
          .with('Missing ENV variable: COVERALLS_REPO_TOKEN')
        expect(coveralls).to receive(:info)
          .with('Skipping coveralls')
        expect(coveralls.execute).to eql nil
      end
    end

    context '::Coveralls itself no bueno' do
      before(:each) do
        allow(ENV).to receive(:key?)
          .with('COVERALLS_REPO_TOKEN').and_return true
        allow(::Coveralls).to receive(:wear!)
          .and_raise(::StandardError.new 'NO PANTS FOR YOU')
      end

      it 'does not fail by default' do
        expect(coveralls).to receive(:info).with(/NO PANTS/)
        expect(coveralls.execute).to eql nil
      end

      it 'fails when no_fail flipped off' do
        coveralls.no_fail false

        expect { coveralls.execute }.to raise_error(/NO PANTS/)
      end
    end
  end
end

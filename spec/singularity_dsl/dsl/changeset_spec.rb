# encoding: utf-8

require 'singularity_dsl/dsl/changeset'

# container to include DslChangeset
class ChangesetTest
  include SingularityDsl::Dsl::Changeset
end

describe 'DslChangeset' do
  let(:instance) { ChangesetTest.new }
  before :each do
    instance.changeset = %w(something.php
                            something.js
                            something.css
                            a/file/path)
  end

  context '#files_changed?' do
    it 'correctly evals for single file type' do
      expect(instance.files_changed?('php')).to eql true
    end

    it 'returns false when file type not in changeset' do
      expect(instance.files_changed?(%w(golang py))).to eql false
    end

    it 'correctly evals for multiple file types' do
      expect(instance.files_changed?(%w(js css))).to eql true
    end

    it 'correctly detects literal file paths' do
      expect(instance.files_changed?(%w(a/file/path))).to eql true
    end

    it 'returns false for non-existing literal file paths' do
      expect(instance.files_changed?(%w(another/file/path))).to eql false
    end
  end

  context '#changed_files' do
    before :each do
      allow(::File).to receive(:exist?)
        .with('something.css')
        .and_return(true)
      allow(::File).to receive(:exist?)
        .with('something.js')
        .and_return(true)
      allow(::File).to receive(:exist?)
        .with('a/file/path')
        .and_return(true)
      allow(::File).to receive(:exist?)
        .with('something.php')
        .and_return(false)
    end

    it 'correctly evals for single file type' do
      expect(instance.changed_files('css')).to eql %w(something.css)
    end

    it 'returns [] when file type not in changeset' do
      expect(instance.changed_files(%w(golang py))).to eql []
    end

    it 'filters for existing files & sorts' do
      expect(instance.changed_files(%w(php js css a/file/path)))
        .to eql %w(a/file/path something.css something.js)
    end

    it 'correctly detects literal file paths' do
      expect(instance.changed_files(%w(a/file/path))).to eql %w(a/file/path)
    end

    it 'returns false for non-existing literal file paths' do
      expect(instance.changed_files(%w(another/file/path))).to eql []
    end
  end
end

# encoding: utf-8

require 'singularity_dsl/dsl/changeset'

# container to include DslChangeset
class ChangesetTest
  include SingularityDsl::Dsl::Changeset
end

describe 'DslChangeset' do
  let(:instance) { ChangesetTest.new }
  before :each do
    instance.changeset = %w(something.php something.js something.css)
  end

  context '#files_changed?' do
    it 'correct eval for single file type' do
      expect(instance.files_changed? 'php').to eql true
    end

    it 'correct eval for multiple file types' do
      expect(instance.files_changed? %w(js css)).to eql true
    end
  end

  context '#changed_files' do
    before :each do
      ::File.stub(:exist?)
            .with('something.css')
            .and_return(true)
      ::File.stub(:exist?)
            .with('something.js')
            .and_return(true)
      ::File.stub(:exist?)
            .with('something.php')
            .and_return(false)
    end

    it 'correct eval for single file type' do
      expect(instance.changed_files 'css').to eql %w(something.css)
    end

    it 'correct eval for multiple file types' do
      expect(instance.changed_files %w(js css))
        .to eql %w(something.css something.js)
    end

    it 'filters for existing files' do
      expect(instance.changed_files %w(php js css))
        .to eql %w(something.css something.js)
      expect(instance.changed_files 'php').to eql []
    end
  end
end

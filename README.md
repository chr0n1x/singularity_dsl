# SingularityDsl

A DSL lib for your [SingularityCI](https://github.com/behance/singularity) instance.
Inspired by TravisCI's `.travis.yml`

...Except with the full power of Ruby, its gems & your awesome JenkinsCI machine(s).

All you need is a `.singularityrc` file in your repository and you're ready to go!

## Installation

    $ gem install singularity_dsl

This will get you the `singularity_runner` executable.

## Usage

    Commands:
     singularity_runner batch BATCH_NAME                               # Run single task batch in the .singularityrc script.
     singularity_runner help [COMMAND]                                 # Describe available commands or one specific command
     singularity_runner tasks                                          # Available tasks.
     singularity_runner test                                           # Run singularity script.
     singularity_runner testmerge FORK BRANCH INTO_BRANCH [INTO_FORK]  # Perform a testmerge into the local repo and then run .singularityrc

    Options:
      -t, [--task-path=TASK_PATH]          # Directory where custom tasks are defined
                                           # Default: ./.singularity
      -a, [--all-tasks], [--no-all-tasks]  # Do not stop on task failure(s), collect all results
      -s, [--script=SCRIPT]                # Specify path to a .singularityrc file
                                           # Default: ./.singularityrc

The `singularity_runner` is designed to do two things:

- load custom tasks from the repository you're running it in (`.singularity` dir by default).
- read a `.singularityrc` file.

### .singularityrc

Just a ruby file describing what you want to be run. The things that will be run are called `task`s. For example:

```
shelltask { command 'bundle' }
rubocop
rspec
```

Running `singularity_runner test` in the same directory as this file, everything just gets executed. Simple, right?
What's actually happening is:

- the runner first loads up any task definitions. Built in task definitions [here](https://github.com/behance/singularity_dsl/tree/master/lib/singularity_dsl/tasks)
- runner then looks for any *custom* defined definitions in your `cwd/.singularity` dir
- loads the entire `.singularityrc` file into an internally managed DSL object
- depending on what command is run, evaluates blocks in `.singularityrc`

You can even define `batch`es of tasks to be run. So for example:

```
batch :test do
  rubocop
  rspec
end

shelltask { command 'bundle' }
```

Running `singularity_runner test` on this file will only run the `bundle` shelltask. Why? Because defining a `batch` does not run anything. It's just a way for your to organize what tasks should be run together.

To actually run it, you need this line: `invoke_batch :test`

Or, if you **just** want to run that one batch, without the `bundle` shelltask, you can tell the runner to do just that! `singularity_runner batch test`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Make sure you run the tests!

```
bundle exec rake test:all
```

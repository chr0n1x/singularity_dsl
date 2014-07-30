# SingularityDsl

A DSL lib for your [SingularityCI](https://github.com/behance/singularity) instance.
Inspired by TravisCI's `.travis.yml`

...Except with the full power of Ruby, its gems & your awesome JenkinsCI machine(s).

All you need is a `.singularityrc` file in your repository, the `singularity_runner` (provided by this gem) and you're ready to go!

## Installation

    $ gem install singularity_dsl

## Runner Usage

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

Just a ruby file describing what you want to run. The commands that are run are called `task`s. For example:

```
shelltask { command 'bundle' }
rubocop
rspec
```

Running `singularity_runner test` in the same directory as this file, everything just gets executed. Simple, right?

### Runner Execution Breakdown

What's actually happening is:

- the runner first loads up any task definitions. Built in task definitions [here](https://github.com/behance/singularity_dsl/tree/master/lib/singularity_dsl/tasks)
- runner then looks for any *custom* defined definitions in your `cwd/.singularity` dir
- loads the entire `.singularityrc` file into an internally managed DSL object
- depending on what command is run, evaluates blocks in `.singularityrc`

### Task Batches

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

### Task API, Custom Tasks & Task Extensions

A task is just a ruby class. For base functionality, it needs an `execute` method. You can have it do whatever you want in that method.
To further customize it, you can define a `description` method that returns a string with some info about the task.

Tasks also take [ruby blocks](http://www.reactive.io/tips/2008/12/21/understanding-ruby-blocks-procs-and-lambdas/)
What this means is that you can pass blocks of code to tasks from your `.singularityrc`. Those blocks of code would then be executed in the context of the Task. Think [resources in chef](http://docs.getchef.com/resource.html). You can use these blocks to configure how certain task declarations run.

### `singularity_runner`, Custom Tasks & Task Extensions

As mentioned, `singularity_runner` can load custom tasks or task extensions. By default, it will load **all** files in `cwd/.singularity`
This allows you to do multiple things:

1. abstract out common tasks that you use to build, test, etc your code
2. configure tools / tasks with default values specific to your use case
3. create a common lib of task definitions to be shared amoungst your repositories

To see a list of base tasks, their class names, what their names are in `.singularityrc`'s context, you just have to run:

```
singularity_runner tasks
```

Which yields something like:

```
Task       Task Function  Description

Rake       rake           Simple resource to just wrap the Rake CLI
RSpec      rspec          Run RSpec tests. Uses RSpec::Core
Rubocop    rubocop        Runs rubocop, loads .rubocop.yml from ./
ShellTask  shelltask      Runs a SH command using Mixlib::ShellOut
```

Note that there is a task called `shelltask`, defined by a ruby Task class called `ShellTask`.
Say you wanted to create a task for a common echo command. You can simply create a ruby file in `cwd/.singularity`, say `echo.rb`

```
class Echo extends ShellTask
  def execute
    command 'echo "hello"'
    super
  end
end
```

The `singularity_runner tasks` command should then list your task as one of the tasks usable from your cwd.

```
Task       Task Function  Description

Rake       rake           Simple resource to just wrap the Rake CLI
RSpec      rspec          Run RSpec tests. Uses RSpec::Core
Rubocop    rubocop        Runs rubocop, loads .rubocop.yml from ./
ShellTask  shelltask      Runs a SH command using Mixlib::ShellOut
Echo       echo           Runs the Echo task.
```

The `Echo` task does a couple of things. Take a look at the [ShellTask class](https://github.com/behance/singularity_dsl/blob/master/lib/singularity_dsl/tasks/shell_task.rb).
So all this is doing is setting the shell command in the parent class to `echo "hello"` & then calling it. Nothing special here, but you can hopefully see that this opens up a lot of possibilities.

### Builtin Tasks

**Task**

Base task that all tasks extend from. If an instance of this class is ever used, or if a child class does not define `execute`, an error is raised.

Configuration Methods | Description
---- | ----
N/A | N/A

**Rake**

Run a rake task!

Configuration Methods | Description
---- | ----
`target` | What Rake task to execute

**RSpec**

Run a suite of rspec tests.

Configuration Methods | Description
---- | ----
`config_file` | Where rspec config file is
`spec_dir` | Where rspec tests are

**Rubocop**

Run rubocop.

Configuration Methods | Description
---- | ----
`config_file` | Where Rubocop.yml is
`file` | Add a file to the list of files to run rubocop against

**ShellTask**

Run a SH task using [Mixlib::ShellOut](https://github.com/opscode/mixlib-shellout)

Configuration Methods | Description
---- | ----
`no_fail` | Runner does not fail if this task fails to run
`command` | Shell command to execute
`alt` | Alternative shell command to execute (used in conjunction with `condition`)
`condition` | Shell command to execute. If successful, run the command set via `command`, otherwise run `alt`

### Runstate Callbacks

These are blocks of tasks that you can run depending on the status of the runner (i.e.: whether all of your tasks succeeded in running, failed, errored, etc).

Block Name | Description
---- | ----
`on_success` | invoked when `singularity_runner` runs everything (via `test`, `testmerge`, `batch`) successfully
`on_error` | invoked when `singularity_runner` errors out while trying to run something in your `.singularityrc`, **after** it has been processed
`on_fail` | invoked when any of your tasks error out (e.g.: shelltask returns a non-zero exit code)
`always` | always invoked **after** a `.singularityrc` run

### Advanced Usage with `testmerge`

`singularity_runner testmerge` has a very bare-bones implementation of a git merge. Given a fork, a branch in that fork, a base_repo & base_branch, the runner will:

- merge fork:branch into base_repo:base_branch
- perform a diff between the two
- take the file list (the changeset) and inject it into a running instance of the DSL
- run the `test` command (unless the `-r` flag is given with a batch name, then it runs a batch)

Why would you do this? To conditionally execute blocks of tasks or batches based on what files changed! This can help in automating test workflows in your CI system, testing merges into trunk, etc.

But how?

### Working with changesets from the `testmerge` command

The DSL exposes 2 methods to help you determine whether you want to execute blocks of code or not:

Method | Args | Return | Desc
---- | ---- | ---- | ----
`files_changed?` | `String | Array` | `Boolean` | Performs a file extension regex match, returns true if any files in the changeset match, false otherwise
`changed_files` | `String | Array` | `Array` | Returns all files that have extensions that match the given values, returns an array of those files

So for example, say you only want to execute rspec tests when there are Ruby file changes. You can do something like this:

```
batch :ruby do
  shelltask { command 'bundle' }
  rake { target 'build_app' }
  rspec
end

batch :test_merge do
  if files_changed? 'js'
    shelltask { command 'grunt testjs' }
  end

  if files_changed? 'rb'
    rubocop { files changed_files('rb') }
    invoke_batch :ruby
  end
end
```

Running
```
singularity_runner testmerge git@github.com:me/repo feature-branch master git@github.com:org/repo -r test_merge
```
Will perform the test merge & then pass ALL of the changed files in that merge into the `.singularityrc`!

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

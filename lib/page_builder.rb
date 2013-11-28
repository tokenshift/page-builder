require 'page-builder/folder'
require 'page-builder/layout'
require 'rake'

module PageBuilder
  VERSION = "0.0.1"

  # Defines and returns the "build" rake task.
  def self.rake_task(root_dir = ".")
    @task ||= Rake::Task.define_task :build do
      Folder.new(root_dir).process
    end
  end
end

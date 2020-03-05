# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

# load tasks from folder 'tasks'
Dir.glob('tasks/*.rake').each { |r| load r}
Dir.glob('tasks/**/*.rake').each { |r| load r}

Rails.application.load_tasks

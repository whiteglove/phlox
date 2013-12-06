begin
  require 'rspec/core'
  require 'rspec/core/rake_task'

  task :cruise => [
      'cruise_spec',
  ]

  spec_prereq = :noop
  task :noop do
  end

  desc "Run all specs in spec directory (excluding plugin specs)"
  RSpec::Core::RakeTask.new(:cruise_spec => spec_prereq) do |t|
    out = ENV['CC_BUILD_ARTIFACTS'] || Dir.pwd
    t.rspec_opts = ["--format", "html", "-o", "#{out}/UnitTests/index.html"]
    t.pattern = "spec/**/*_spec.rb"
    bundle_paths = `bundle show --paths --no-color`.split(/\n/)
    excluded_paths = ['bundle', '/spec/', '/var/', '/usr', "gems/ree"] + bundle_paths
  end

rescue LoadError => e
  p e
end

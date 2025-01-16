SUFFIX = %w(ar7.0 ar7.1)

SUFFIX.each do |suffix|
  task suffix do
    Dir.chdir(suffix) do
      sh "bundle install"
      sh "env SUFFIX=#{suffix} bundle exec ruby ../generate_docset.rb"
    end
  end
end

task :default => SUFFIX

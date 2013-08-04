task :default => [:update]

task :update => [:update_repo, :update_submodules, :install]

task :install => [:archive_symlinks, :create_symlinks]

task :update_repo do
  puts "Updating dotfile repo..."
  sh "git pull"
end

task :update_submodules do
  puts "Updating submodules..."
end

task :archive_configs do
  puts "Archiving existing configs..."
end

task :install_configs do
  puts "Installing managed configs..."
end


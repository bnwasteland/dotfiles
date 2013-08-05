require 'pathname'

desc "Pull the latest dotfiles from github and install"
task :default => [:update]

task :update => [:update_repo, :install]

task :update_repo do
  sh "git pull"
end

desc "Install local versions"
task :install do
  targets = Dir['*.linkme*']

  targets.each do |target| 
    ensure_link target_name(target), link_name(target)
  end
end

namespace :submodules do
  desc "Update submodules to their respective HEAD's"
  task :update do
    sh "git submodule foreach git pull"
  end
end

def ensure_link(target_name, link_name)
  if link_name.exist?
    unless already_installed? link_name, target_name
      archive link_name
      create_link target_name, link_name
    end
  else
    create_link target_name, link_name
  end
end

def target_name(target)
  Pathname.new(target).realpath
end

def link_name(target)
  swizzled = target.sub(/(.*)\.linkme(\.?)$/, '\2\1')
  home.join(swizzled)
end

def already_installed?(link_name, target_name)
  link_name.symlink? and link_name.realpath == target_name
end

def archive(link_name)
  archived_name = home.join "#{link_name}.old"
  i = 0
  while archived_name.exist?
    i = i + 1
    archived_name = home.join "#{link_name}.old.#{i}"
  end
  mv link_name, archived_name
end

def create_link(target_name, link_name)
  ln_s target_name, link_name
end

def home
  Pathname.new(ENV['HOME'])
end


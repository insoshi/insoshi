gems = Dir[File.join(RAILS_ROOT, "vendor/gems/*")]
if gems.any?
  # Prepend load paths first so that gems can depend on eachother
  gems.each do |dir|
    lib = File.join(dir, 'lib')
    $LOAD_PATH.unshift(lib) if File.directory?(lib)
  end
  
  # Require each gem
  gems.each do |dir|
    init_rb = File.join(dir, 'init.rb')
    require init_rb if File.file?(init_rb)
  end
end
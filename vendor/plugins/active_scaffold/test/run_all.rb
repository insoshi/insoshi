test_folders = %w[bridges config data_structures extensions misc]

all_tests = test_folders.inject([]) {|output, folder|
  output + Dir[File.join(File.dirname(__FILE__), "#{folder}/**/*.rb")] 
}
all_tests.each{|filename|
  require filename
}
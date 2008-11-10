spec = Gem::Specification.new do |s| 
  s.name = "find_mass_assignment"
  s.version = "1.0"
  s.author = "Michael Hartl"
  s.email = "michael@insoshi.com"
  s.homepage = "http://insoshi.com/"
  s.summary = "Find likely mass assignment vulnerabilities"
  s.files = ["README.markdown", "Rakefile", "find_mass_assignment.gemspec",
             "lib/find_mass_assignment.rb",
             "tasks/find_mass_assignment_tasks.rake",
             "MIT-LICENSE"]
end

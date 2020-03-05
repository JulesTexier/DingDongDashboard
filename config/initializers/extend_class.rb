Dir[File.join(Rails.root, "lib", "ext", "*.rb")].each {|l| require l }

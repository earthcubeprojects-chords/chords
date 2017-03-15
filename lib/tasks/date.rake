task :data => :environment  do
	input_array = ARGV

	puts input_array.length

	puts input_array.to_s
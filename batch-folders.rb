#!/usr/bin/env ruby
# This program accepts a file path and a number of your choice for how many
# files to split into folders.
#
# eg: If you have 1000 files and need 100 files per folder, then enter 100 as
# the number, and this program will create 10 folders and move 100 files into
# each.

require "Pathname"
require "FileUtils"

prepend = "Batch_"
batchsize = ""
filepath = ""

def leave(message)
	puts message
	puts "Usage: ./batch-files.rb \"/path/to/folder\" 5000"
	exit
end

def prompt(*args)
	print(*args)
	result = $stdin.gets.chomp
	return result.empty? ? exit : result
end

ARGV[0] != nil ? filepath = Pathname.new(File.expand_path(ARGV[0].strip)) : filepath = Pathname.new(File.expand_path(prompt("Please supply the filepath: ")))
ARGV[1] != nil ? batchsize = ARGV[1].strip : batchsize = prompt("Please specify how large to make the batches: ")

# Check if directory exists
filepath.directory? ? nil : leave("Directory does not exist")
Dir.chdir(filepath)

# Check if there are any files in the directory
Dir.glob("*.*").size == 0 ? leave("No files in the directory") : nil

# Check if given number is a real number.
begin
	batchsize = batchsize.to_i
rescue
	leave("Not a valid batch size")
end
batchsize < 1 ? leave("Number is not above 0") : nil

# start dividing files
folderi = 1
i = 1

Dir.glob("*.*") do |f|
	if File.file?(f) # skip anything not a file
		# check if we're needing to create a batch folder and increment
		if i > batchsize
			i = 1
			folderi += 1
		end

		# create new path
		newpath = filepath.join(prepend + folderi.to_s)
		begin
			FileUtils.mkdir(newpath)
		rescue
			# new path already exists, so continue.
		end

		# move the file into the batch folder
		puts "#{prepend}#{folderi.to_s} \t Moving #{f}"
		begin
			FileUtils.mv(f,newpath.join(File.basename(f)))
		rescue
			puts "Failed to move #{f} to Batch #{newpath}"
		end
		i += 1
	end
end

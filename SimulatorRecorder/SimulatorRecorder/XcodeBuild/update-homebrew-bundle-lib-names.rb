#!/usr/bin/ruby

#
# Borrowed and modified from https://github.com/Mendeley/Mac-OS-X-Bundle-Utilities/update-mac-bundle-lib-names.rb
#

require 'optparse'
require 'pathname'

# Return an array listing the dependencies of 'lib_path'
# (as returned by 'otool -L $LIB_PATH')
def get_dependencies(lib_path)
	deps = []
	entry_name_regex = /(.*)\(compatibility version.*\)/
	`otool -L '#{lib_path}'`.strip.split("\n").each do |entry|
		match = entry_name_regex.match(entry)
		if (match)
			dep_path = match[1].strip

			# Note - otool lists dependencies separately for each architecture
			# in a universal binary - only return the unique paths
			deps << dep_path if !deps.include?(dep_path)
		end
	end
	return deps
end

BUNDLE_MAIN_EXE_PATH = "bin"

def is_system_lib(lib_path)
	return lib_path =~ /^\/System/ ||
	       lib_path =~ /^\/usr\/lib/
end

def install_name_needs_fixup?(lib)
	return !lib.include?("@executable_path") && !lib.include?("@rpath") && !lib.include?("@loader_path")
end

# returns the path of 'binary' relative to the executable path
# within the binary
def get_bundle_install_name(bundle_dir, binary)
	current_dir = "#{bundle_dir}/#{BUNDLE_MAIN_EXE_PATH}"
	relative_path = Pathname.new(binary).relative_path_from(Pathname.new(current_dir)).to_s
	relative_path = "@executable_path/#{relative_path}"
	return relative_path
end

def find_executables(bundle_path)
	binaries = []
	lines = `find -H "#{bundle_path}"/Cellar "#{bundle_path}"/bin "#{bundle_path}"/sbin -type f -path '**/bin/*'`
	lines.each_line do |binary|
		binary = binary.strip
		binaries << binary
	end
	return binaries
end

def find_dylibs(bundle_path)
	binaries = []
	lines = `find -H "#{bundle_path}"/Cellar "#{bundle_path}"/lib "#{bundle_path}"/opt -type f -name '*.dylib'`
	lines.each_line do |binary|
		binary = binary.strip
		binaries << binary
	end
	return binaries
end

def read_install_name(path)
	`otool -X -D "#{path}"`.each_line do |line|
		return line.strip
	end
	return nil
end

def run_cmd(dry_run,verbose,command)
	if (verbose)
		puts command
	end
	if (!dry_run)
		if (!system(command))
			raise "Failed to run: #{command}"
		end
	end
end

dry_run = false
verbose = false
debug = false

OptionParser.new do |parser|
	parser.banner = <<END
Change the library install names referenced by binaries within a homebrew bundle
to reference copies of the library within the bundle.
END
	parser.on("-v","--verbose","Print details of install name changes") do
		verbose = true
	end
	parser.on("-d","--dry-run","Do not actually perform the install name changes") do
		dry_run = true
	end
end.parse!

# find all binaries in the bundle
bundle_dir = File.realpath(ARGV[0])
executables = find_executables(bundle_dir)
dylibs = find_dylibs(bundle_dir)

# |install_name_path_map| maps from current install name of a binary
# to the path to that binary within the bundle.
install_name_path_map = {}
rev_install_name_path_map = {}

# first pass - update the install names of each shared library
# in the bundle to be relative to the Contents/MacOS directory
dylibs.each do |binary|
	current_install_name = read_install_name(binary)
	if (current_install_name &&
		install_name_needs_fixup?(current_install_name))
		new_install_name = get_bundle_install_name(bundle_dir,binary)
		run_cmd(dry_run,verbose,"install_name_tool -id \"#{new_install_name}\" \"#{binary}\"")
	end
end

binaries = executables + dylibs

# second pass - update the install names referenced by each executable
# or shared library to use the executable-relative paths determined in
# the first pass
binaries.each do |binary|
	puts "binary: #{binary}" if debug
	deps = get_dependencies(binary)
	deps.each do |dep|
		# do not try to look for copies of system libraries inside the bundle
		next if is_system_lib(dep)

		if (install_name_needs_fixup?(dep))
			puts "dep: #{dep}" if debug
			binary_path = File.dirname(binary)
			rel_path = Pathname.new(dep).relative_path_from(Pathname.new(binary_path)).to_s
			if (debug)
				puts "binary_path: #{binary_path}"
				puts "dep: #{dep}"
				puts "rel_path: #{rel_path}"
			end
	
			# @loader_path is replaced at runtime with the path to the binary
			# see http://www.mikeash.com/pyblog/friday-qa-2009-11-06-linking-and-install-names.html
			# for an explanation.
			install_name = "@loader_path/#{rel_path}"
			run_cmd(dry_run,verbose,"install_name_tool -change \"#{dep}\" \"#{install_name}\" \"#{binary}\"")
		end
	end
end

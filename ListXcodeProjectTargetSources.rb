require 'xcodeproj'

project_path = ARGV[0]
targetName = ARGV[1]

project = Xcodeproj::Project.open(project_path)

target = project.targets.find {|t| t.name == targetName}
files = target.source_build_phase.files.to_a.select do |pbx_build_file|
  pbx_build_file.file_ref.source_tree != "BUILT_PRODUCTS_DIR"
end.map do |pbx_build_file|
  pbx_build_file.file_ref.real_path.to_s
end

puts files

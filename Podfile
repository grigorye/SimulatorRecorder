source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/grigorye/podspecs.git'

platform :osx, '10.10'

project "SimulatorRecorder/SimulatorRecorder.xcodeproj"

pod 'GEContinuousIntegration', :git => 'https://github.com/grigorye/GEContinuousIntegration'

target 'SimulatorRecorder' do
  use_frameworks!

  pod 'MASShortcut'
  pod 'GETracing', '~> 0.1'
  pod 'GEFoundation', :git => 'https://github.com/grigorye/GEFoundation'

  pod 'GEXcodeBuildPhases', :git => 'https://github.com/grigorye/GEXcodeBuildPhases'
  script_phase :name => 'Embed Source Version into Bundle', :script => '"${PODS_ROOT:?}"/GEXcodeBuildPhases/Scripts/EmbedSourceVersionIntoBundle'
  
  target 'SimulatorRecorderTests' do
    inherit! :search_paths
  end

  target 'SimulatorRecorderUITests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      configuration.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.9'
      configuration.build_settings['OTHER_CFLAGS'] = '$(inherited) -Wno-comma'
      configuration.build_settings['CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF'] = 'NO'
    end
  end
end

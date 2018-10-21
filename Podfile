source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/grigorye/podspecs.git'

platform :osx, '10.10'

project "SimulatorRecorder/SimulatorRecorder.xcodeproj"

pod 'GEContinuousIntegration', :git => 'https://github.com/grigorye/GEContinuousIntegration'

###

$injected_pod_dir_as_xcconfig_vars = Hash.new

def inject_pod_dir_as_xcconfig_var(var_name, pod_name)
  $injected_pod_dir_as_xcconfig_vars[var_name] = pod_name
end

def post_install_inject_pod_dir_in_aggregate_xcconfig_var(installer, var_name, pod_name)
  sandbox = installer.sandbox

  installer.aggregate_targets.each do |target|
    pod_dir = sandbox.pod_dir(pod_name)
    path_in_xcconfig = sandbox.local_path_was_absolute?(pod_name) ? pod_dir : "#{target.relative_pods_root}/#{pod_dir.relative_path_from(Pathname.new(sandbox.root))}"
    target.xcconfigs.each do |config_name, xcconfig|
      xcconfig_path = target.user_project_path.dirname.join(target.xcconfig_relative_path(config_name))
      xcconfig_path.exist? && warn
      xcconfig.merge!(var_name => path_in_xcconfig)
      xcconfig.save_as(xcconfig_path)
    end
  end
end

###

target 'SimulatorRecorder' do
  use_frameworks!

  pod 'MASShortcut'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'GETracing', '~> 0.1'
  pod 'GEFoundation', :git => 'https://github.com/grigorye/GEFoundation'

  pod 'GEXcodeScripts', :git => 'https://github.com/grigorye/GEXcodeScripts'
  inject_pod_dir_as_xcconfig_var('GE_XCODE_SCRIPTS_POD_ROOT', 'GEXcodeScripts')

  pod 'GEXcodeBuildPhases', :git => 'https://github.com/grigorye/GEXcodeBuildPhases'
  inject_pod_dir_as_xcconfig_var('GE_XCODE_BUILD_PHASES_POD_ROOT', 'GEXcodeBuildPhases')
  script_phase :name => 'Integrate Fabric', :shell_path => '/bin/sh -e', :script => <<~END
    "${GE_XCODE_BUILD_PHASES:?}/IntegrateFabric"
  END
  script_phase :name => 'Embed Source Version into Bundle', :shell_path => '/bin/sh -e', :script => <<~END
    "${GE_XCODE_BUILD_PHASES:?}/EmbedSourceVersionIntoBundle"
  END
  
  target 'SimulatorRecorderTests' do
    inherit! :search_paths
  end

  target 'SimulatorRecorderUITests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  $injected_pod_dir_as_xcconfig_vars.each do |var_name, pod_name|
    post_install_inject_pod_dir_in_aggregate_xcconfig_var(installer, var_name, pod_name)
  end

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      configuration.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '10.9'
      configuration.build_settings['OTHER_CFLAGS'] = '$(inherited) -Wno-comma'
      configuration.build_settings['CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF'] = 'NO'
    end
  end
end

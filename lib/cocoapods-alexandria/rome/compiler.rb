module PodAlexandria
  class Compiler
    attr_reader :sandbox, :build_dir, :destination, :configuration, :flags

    def initialize(sandbox, build_dir, destination, configuration, flags)
      @sandbox = sandbox
      @build_dir = build_dir
      @destination = destination
      @configuration = configuration
      @flags = flags
    end

    def build(target)
      sdk = platform_sdk[target.platform_name]
      deployment_target = target.platform_deployment_target
      target_label = target.cocoapods_target_label

      # build each dependency of target
      spec_names = target.specs.map { |spec| [spec.root.name, spec.root.module_name] }.uniq
      
      spec_names.map { |root_name, module_name|
        next if skip_build?(root_name, module_name, sdk)
        if File.directory?(build_path(target, module_name, sdk))
          build_path(target, module_name, sdk)
        else
          xcodebuild(root_name, module_name, sdk, deployment_target)
        end
      }.compact
    end

    private

    def platform_sdk
      { :ios => 'iphoneos', :osx => 'macosx', :tvos => 'appletvos', :watchos => 'watchos' }
    end

    def skip_build?(target, module_name, sdk)
      File.directory?(destination_path(module_name)) ||
        !is_native_target?(target)
    end

    def is_native_target?(target_name)
      project.targets
        .find { |t| t.name == target_name }
        .is_a?(Xcodeproj::Project::Object::PBXNativeTarget)
    end

    def xcodebuild(target, module_name, sdk, deployment_target)
      args = %W(-project #{sandbox.project_path.realdirpath} -scheme #{target} -configuration #{configuration} -sdk #{sdk})
      args += flags unless flags.nil? 
      
      Pod::UI.puts "Building '#{target}' for #{sdk}..."
      Pod::Executable.execute_command 'xcodebuild', args, true

      build_path(target, module_name, sdk)
    end

    def project
      @project ||= Xcodeproj::Project.open(sandbox.project_path)
    end

    def build_path(target, module_name, sdk)
      "#{build_dir}/#{configuration}-#{sdk}/#{target}/#{module_name}.framework"
    end

    def destination_path(module_name)
      "#{destination}/#{module_name}.framework"
    end
  end
end

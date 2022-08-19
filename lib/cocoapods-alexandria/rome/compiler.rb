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

      # find & build all dependencies
      project.all_dependencies_for(target).map { |target|
        # skip if already built (product, or by other target)
        next if skip_build?(target, sdk)

        # may already be built (by another target)
        if File.directory?(build_path(target, sdk))
          Pod::UI.puts "Already built '#{target.name}', probably by another dependency."
        else
          Pod::UI.puts "Building '#{target.name}' for #{sdk}..."
          xcodebuild(target, sdk, deployment_target)
        end

        build_path(target, sdk)
      }.compact
    end

    private

    def platform_sdk
      { :ios => 'iphoneos', :osx => 'macosx', :tvos => 'appletvos', :watchos => 'watchos' }
    end

    def skip_build?(target, sdk)
      File.directory?(destination_path(target))
    end

    def xcodebuild(target, sdk, deployment_target)
      args = %W(-project #{sandbox.project_path.realdirpath} -scheme #{target.name} -configuration #{configuration} -sdk #{sdk})
      args += flags unless flags.nil? 
      
      Pod::Executable.execute_command 'xcodebuild', args, true
    end

    def project
      @project ||= Xcodeproj::Project.open(sandbox.project_path)
    end

    def build_path(target, sdk)
      # Note: using target.product_name is wrong in some cases (Cocoapods project generation bug)
      # See https://github.com/CocoaPods/CocoaPods/issues/8007
      "#{build_dir}/#{configuration}-#{sdk}/#{target.name}/#{target.product_reference.name}"
    end

    def destination_path(target)
      # Note: using target.product_name is wrong in some cases (Cocoapods project generation bug)
      # See https://github.com/CocoaPods/CocoaPods/issues/8007
      "#{destination}/#{target.product_reference.name}"
    end
  end
end

module Xcodeproj
  class Project
    module Object
      class AbstractTarget
        def is_native?
          is_a?(Xcodeproj::Project::Object::PBXNativeTarget)
        end
      end

      class PBXNativeTarget
        def is_bundle?
          product_type == 'com.apple.product-type.bundle'
        end

        def all_dependencies
          dependencies
            .filter { |d| d.target.is_native? && !d.target.is_bundle? }
            .map { |d| [d.target] + d.target.all_dependencies }
            .flatten.uniq
        end
      end
    end

    def all_dependencies_for(umbrella_target)
      target(umbrella_target.cocoapods_target_label).all_dependencies
    end

    def target(target_name)
      result = targets.find { |t| t.name == target_name }
      if result.is_native?
        return result
      else
        return nil
      end
    end
  end
end

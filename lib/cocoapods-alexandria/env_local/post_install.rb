module PodAlexandria
  class LocalPostInstallHook
    attr_reader :pods_project, :sandbox_root, :umbrella_targets, :options

    def initialize(installer_context, user_options)
      @pods_project = installer_context.pods_project
      @sandbox_root = installer_context.sandbox_root
      @umbrella_targets = installer_context.umbrella_targets
      @options = UserOptions.new(installer_context, user_options)
    end

    def run
      Pod::UI.title "Tweaking CocoaPods for XcodeGen..."
      pods_project.fix_deployment_target_warnings
      include_user_configs_in_pods_xcconfigs
    end

    private

    def include_user_configs_in_pods_xcconfigs
      umbrella_targets.each do |target|
        pods_project.configurations.each do |config|
          append_include_to_config(target, config, options.environment_configs[config])
        end
      end
    end

    def append_include_to_config(target, config, include)
      xcconfig = "#{sandbox_root}/Target Support Files/#{target.cocoapods_target_label}/#{target.cocoapods_target_label}.#{config.downcase}.xcconfig"
      
      File.open(xcconfig, 'a') do |f|
        f.puts ''
        f.puts "#include \"../../../#{include}\""
      end
    end
  end
end

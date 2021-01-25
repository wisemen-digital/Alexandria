module PodAlexandria
  class UserOptions
    attr_reader :environment_configs
    attr_reader :force_bitcode
    attr_reader :xcodegen_dependencies_file

    def initialize(installer_context, user_options)
      @environment_configs = user_options.fetch('environment_configs', default_configurations(installer_context))
      @force_bitcode = user_options.fetch('force_bitcode', true)
      @xcodegen_dependencies_file = user_options.fetch('xcodegen_dependencies_file', 'projectDependencies.yml')
    end

    def environment_configs_for(target)
      environment_configs[normalize_target(target)]
    end

    private

    def default_configurations(installer_context)
      if installer_context.respond_to? :umbrella_targets
        installer_context.umbrella_targets.map { |target|
          target_name = normalize_target(target.cocoapods_target_label)
          configs = installer_context.pods_project.configurations
            .map { |config| [config, "Supporting Files/Settings-#{config.gsub('-', ' ').split[0]}.xcconfig"] }
            .to_h
          [target_name, configs]
        }.to_h
      else
        {}
      end
    end

    def normalize_target(target)
      target.sub(/^Pods-/, '')
    end
  end
end

module Xcodeproj
  class Project
    def configurations
      build_configurations
        .map(&:name)
        .reject { |c| ['Debug', 'Release'].include? c }
    end

    def fix_deployment_target_warnings
      targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0' if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] == '8.0'
        end
      end
      save
    end

    def force_bitcode_generation
      targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['BITCODE_GENERATION_MODE'] = 'bitcode'
        end
      end
      save
    end
  end
end

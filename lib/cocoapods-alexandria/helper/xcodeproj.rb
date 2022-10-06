module Xcodeproj
  class Project
    def configurations
      build_configurations
        .map(&:name)
        .reject { |c| ['Debug', 'Release'].include? c }
    end

    def fix_deployment_target_warnings(minimum_version)
      targets.each do |target|
        target.build_configurations.each do |config|
          version = Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = minimum_version.to_s if version < minimum_version
        end
      end
      save
    end

    def fix_bundle_code_signing
      targets.each do |target|
        if target.respond_to?(:product_type) and target.product_type == 'com.apple.product-type.bundle'
          target.build_configurations.each do |config|
            config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
          end
        end
      end
      save
    end

    def disable_bitcode_generation
      targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['ENABLE_BITCODE'] = 'NO'
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

require_relative 'helper/environment'
require_relative 'helper/podfile'
require_relative 'helper/user_options'
require_relative 'helper/xcodeproj'
require_relative 'rome/compiler'
require_relative 'rome/framework_cache'
require_relative 'rome/lockfile'
require_relative 'xcodegen/dependencies_generator'
require_relative 'xcodegen/dependency'
require_relative 'xcodegen/xcodegen'

require_relative 'env_ci/post_install'
require_relative 'env_ci/pre_install'
require_relative 'env_local/post_install'
require_relative 'env_local/pre_install'


require_relative 'register_hooks'

module PodAlexandria
  class CIPostInstallHook
    attr_reader :installer_context, :pods_project, :cache, :options

    def initialize(installer_context, user_options)
      @installer_context = installer_context
      @pods_project = installer_context.pods_project
      @cache = FrameworkCache.new(installer_context)
      @options = UserOptions.new(installer_context, user_options)
    end

    def run
      Pod::UI.title "Compile dependencies"
      
      if options.force_bitcode
        Pod::UI.puts "Forcing bitcode generation"
        pods_project.force_bitcode_generation
      end
      cache.delete_changed_frameworks
      cache.build_frameworks
      cache.cache_lockfile

      Pod::UI.title "Generating project using XcodeGen"
      XcodeGen::generate_dependencies(
        installer_context,
        options.xcodegen_dependencies_file,
        options.environment_configs
      )
      XcodeGen::generate
    end
  end
end

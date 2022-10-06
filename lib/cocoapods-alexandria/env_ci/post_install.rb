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
      
      if options.disable_bitcode
        Pod::UI.puts "Disabling bitcode generation"
        pods_project.disable_bitcode_generation
      elsif options.force_bitcode
        Pod::UI.puts "!!DEPRECTATED!! Forcing bitcode generation"
        pods_project.force_bitcode_generation
      end
      cache.delete_changed_frameworks
      cache.build_frameworks
      cache.cache_lockfile

      Pod::UI.title "Generating project using XcodeGen"
      XcodeGen::generate_dependencies(installer_context, options)
      XcodeGen::generate
    end
  end
end

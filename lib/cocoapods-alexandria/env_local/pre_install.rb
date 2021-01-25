module PodAlexandria
  class LocalPreInstallHook
    attr_reader :podfile, :options

    def initialize(installer_context, user_options)
      @podfile = installer_context.podfile
      @options = UserOptions.new(installer_context, user_options)
    end

    def run
      Pod::UI.puts "Cocoapods Alexandria running in local mode."

      Pod::UI.title "Generating project using XcodeGen"
      XcodeGen::cleanupRome
      XcodeGen::clearDependencies(options.xcodegen_dependencies_file)
      XcodeGen::generate

      Pod::UI.title "Preparing environment..."
      podfile.prepare_for_xcodegen

      Pod::UI.title "Continuing with normal CocoaPods"
    end
  end
end

module PodAlexandria
  class CIPreInstallHook
    attr_reader :podfile, :options

    def initialize(installer_context, user_options)
      @podfile = installer_context.podfile
      @options = UserOptions.new(installer_context, user_options)
    end

    def run
      Pod::UI.puts "Cocoapods Alexandria running in CI mode."

      Pod::UI.title "Preparing environment..."
      podfile.prepare_for_xcodegen
      podfile.disable_integration
      delete_workspace

      Pod::UI.title "Continuing with normal CocoaPods"
    end

    private

    def delete_workspace
      Dir['*.xcworkspace'].each do |workspace|
        FileUtils.remove_dir(workspace, force: true)
      end
    end
  end
end

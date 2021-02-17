module PodAlexandria
  class LocalPreInstallHook
    attr_reader :podfile, :options

    def initialize(installer_context, user_options)
      @podfile = installer_context.podfile
      @options = UserOptions.new(installer_context, user_options)
    end

    def run
      Pod::UI.puts 'Cocoapods Alexandria running in local mode.'

      if should_predownload_dep
        Pod::UI.title 'Pre-downloading dependency for XcodeGen'
        predownload_dep
      end

      Pod::UI.title 'Generating project using XcodeGen'
      XcodeGen::cleanupRome
      XcodeGen::clearDependencies(options.xcodegen_dependencies_file)
      XcodeGen::generate

      Pod::UI.title 'Preparing environment...'
      podfile.prepare_for_xcodegen

      Pod::UI.title 'Continuing with normal CocoaPods'
    end

    private

    def should_predownload_dep
      File.readlines('project.yml').grep(/Pods\/AppwiseCore\/XcodeGen/).any? &&
        !File.directory?('Pods/AppwiseCore/XcodeGen')
    end

    def predownload_dep
      system(
        'rm -rf Pods/AppwiseCore && '\
        'mkdir -p Pods && '\
        'rm -f /tmp/ac.zip && '\
        'curl -L "https://github.com/appwise-labs/AppwiseCore/archive/master.zip" > /tmp/ac.zip && '\
        'unzip -q -d Pods /tmp/ac.zip && '\
        'mv Pods/AppwiseCore-master Pods/AppwiseCore'
      )
    end
  end
end

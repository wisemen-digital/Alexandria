module PodAlexandria
  class XcodeGen
    def self.cleanupRome
      FileUtils.remove_dir('build', force: true)
      FileUtils.remove_dir('dSYM', force: true)
      FileUtils.remove_dir('Rome', force: true)
    end

    def self.clearDependencies(xcodegen_dependencies_file)
      File.truncate(xcodegen_dependencies_file, 0)
    end

    def self.generate
      unless system('which xcodegen > /dev/null')
        abort 'XcodeGen is not installed. Visit https://github.com/yonaskolb/XcodeGen to learn more.'
      end

      system('xcodegen')
    end
  end
end

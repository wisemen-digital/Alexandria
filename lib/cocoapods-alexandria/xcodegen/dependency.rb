module PodAlexandria
  class Dependency
    attr_reader :flag
    attr_reader :module_name

    def initialize(value)
      @flag = value.start_with?('-wf') ? 'wf' : value[1]
      @module_name = value.delete_prefix('-l').delete_prefix('-f').delete_prefix('-wf')
    end

    def xcodegen_info(allow_embed)
      if exists?
        {
          'framework' => path,
          'embed' => is_dynamic? && allow_embed,
          'weak' => is_weak?
        }
      else
        {
          'sdk' => sdk,
          'weak' => is_weak?
        }
      end
    end

    private

    def path
      binary = Dir["Rome/*.{framework,xcframework}/**/#{binary_name}"].first
      binary&.split(File::SEPARATOR)&.first(2)&.join(File::SEPARATOR)
    end

    def sdk
      if is_library?
        "lib#{module_name}.tbd"
      else
        "#{module_name}.framework"
      end
    end

    def exists?
      path != nil
    end

    def is_dynamic?
      if path.end_with? 'xcframework'
        any_arch = Dir["#{path}/*/*.framework"].first
        binary = "#{any_arch}/#{module_name}"
      else
        binary = "#{path}/#{module_name}"
      end
      !%x(file #{binary} | grep dynamic).to_s.strip.empty?
    end

    def is_library?
      flag == 'l'
    end

    def is_weak?
      flag == 'wf'
    end

    def binary_name
      if is_library?
        "lib#{module_name}.a"
      else
        module_name
      end
    end
  end
end

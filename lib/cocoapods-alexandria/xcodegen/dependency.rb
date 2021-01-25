module PodAlexandria
  class Dependency
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def path
      binary = Dir["Rome/*.{framework,xcframework}/**/#{binary_name}"].first
      binary&.split(File::SEPARATOR)&.first(2)&.join(File::SEPARATOR)
    end

    def sdk
      if is_library?
        "lib#{module_name}.tbd"
      else
        "#{value}.framework"
      end
    end

    def exists?
      path != nil
    end

    def is_dynamic?
      if path.end_with? 'xcframework'
        any_arch = Dir["#{path}/*/*.framework"].first
        binary = "#{any_arch}/#{value}"
      else
        binary = "#{path}/#{value}"
      end
      !%x(file #{binary} | grep dynamic).to_s.strip.empty?
    end

    private

    def is_library?
      value.start_with? '-l'
    end

    def binary_name
      if is_library?
        "lib#{module_name}.a"
      else
        module_name
      end
    end

    def module_name
      value.delete_prefix('-l')
    end
  end
end

module PodAlexandria
  class Dependency
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def path
      ['framework', 'xcframework'].map { |extension|
        "Rome/#{value}.#{extension}" 
      }.select { |path|
        File.directory? path
      }.first
    end

    def sdk
      if value.start_with? '-l'
        "lib#{value.delete_prefix('-l')}.tbd"
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
  end
end

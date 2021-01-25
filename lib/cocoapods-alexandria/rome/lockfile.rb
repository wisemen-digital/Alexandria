module PodAlexandria
  class Lockfile
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def exists?
      File.file?(path)
    end

    def matches?(lockfile)
      FileUtils.identical?(path, lockfile.path)
    end

    # collect changed specs (changed checksum, checkout or deleted pod)
    def changed_specs(lockfile)
      changed_checksums = spec_checksums.select { |k,v| v != lockfile.spec_checksums[k] }.keys
      changed_checkout = checkout_options.select { |k,v| v != lockfile.checkout_options[k] }.keys
      deleted_specs = lockfile.spec_checksums.keys - spec_checksums.keys

      changed_checksums.to_set.merge(changed_checksums).merge(deleted_specs)
    end

    # collect affected frameworks (and filter out subspecs)
    def specs_affected_by(specs)
      affected = specs

      loop do
        items = pods.select { |s|
          s.is_a?(Hash) && s.values.flatten.any? { |ss| affected.include? ss.split.first }
        }.map { |s| s.keys.first.split.first }

        break if affected.superset? (affected + items)
        affected.merge(items)
      end

      affected = affected & spec_checksums.keys
    end

    def copy_to(lockfile)
      FileUtils.copy_file(path, lockfile.path)
    end

    def delete
      FileUtils.remove_file(path, true)
    end

    protected

    def contents
      @contents ||= YAML.load_file(path)
    end

    def spec_checksums
      contents.fetch('SPEC CHECKSUMS', {})
    end

    def checkout_options
      contents.fetch('CHECKOUT OPTIONS', {})
    end

    def pods
      contents.fetch('PODS', [])
    end
  end
end

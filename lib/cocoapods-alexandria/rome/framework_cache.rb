module PodAlexandria
  class FrameworkCache
    attr_reader :configuration, :flags, :sandbox, :sandbox_root, :project_dir, :build_dir, :destination, :umbrella_targets

    def initialize(installer_context)
      @configuration = 'Release'
      @flags = []
      @sandbox_root = Pathname(installer_context.sandbox_root)
      @sandbox = Pod::Sandbox.new(sandbox_root)
      @project_dir = sandbox_root.parent
      @build_dir = project_dir + 'build'
      @destination = project_dir + 'Rome'
      @umbrella_targets = installer_context.umbrella_targets
    end

    def podfile_lock
      @podfile_lock ||= Lockfile.new(project_dir + 'Podfile.lock')
    end

    def cached_podfile_lock
      @cached_podfile_lock ||= Lockfile.new(sandbox_root + 'Rome-Podfile.lock')
    end

    def delete_changed_frameworks
      # if first run (no cache), make sure we nuke partials
      if !cached_podfile_lock.exists?
        Pod::UI.info 'No cached lockfile, deleting all cached frameworks'
        delete_all
        return
      end

      # return early if identical
      return unless podfile_lock.exists? and cached_podfile_lock.exists?
      if podfile_lock.matches? cached_podfile_lock
        Pod::UI.info 'Podfile.lock did not change, leaving frameworks as is'
        return
      end

      Pod::UI.info '⚠️  Podfile.lock did change, deleting updated frameworks'
      changed = podfile_lock.changed_specs(cached_podfile_lock)
      affected = podfile_lock.specs_affected_by(changed)

      # delete affected frameworks
      Pod::UI.info "Affected frameworks: #{affected.sort.join(', ')}" unless affected.empty?
      affected.each { |pod| delete(pod) }
    end

    def build_frameworks
      compiler = Compiler.new(sandbox, build_dir, destination, configuration, flags)
      frameworks = umbrella_targets.select { |t| t.specs.any? }.flat_map { |target|
        compiler.build(target)
      }

      Pod::UI.info "🔥  Built #{frameworks.count} #{'frameworks'.pluralize(frameworks.count)}" unless frameworks.empty?

      FileUtils.mkdir_p destination
      collect_files(frameworks).each do |file|
        FileUtils.cp_r file, destination, :remove_destination => true
      end

      build_dir.rmtree if build_dir.directory?
    end

    def cache_lockfile
      if podfile_lock.exists?
        Pod::UI.info "Caching new Podfile.lock"
        podfile_lock.copy_to(cached_podfile_lock)
      else
        Pod::UI.info "Deleting cached Podfile.lock"
        cached_podfile_lock.delete
      end
    end

    private

    def spec_modules
      @spec_modules ||= umbrella_targets.map { |t|
        t.specs.map { |spec| [spec.root.name, spec.root.module_name] }
      }.flatten(1).uniq.to_h
    end

    def module_name(spec)
      spec.gsub(/^([0-9])/, '_\1').gsub(/[^a-zA-Z0-9_]/, '_')
    end

    def delete_all
      FileUtils.remove_dir(build_dir, true)
      FileUtils.remove_dir(destination, true)
    end

    def delete(spec)
      name = spec_modules[spec] || module_name(spec)
      paths = Dir["#{destination}/#{name}.{framework,xcframework}"]
      
      if !paths.empty?
        paths.each { |path| FileUtils.remove_dir(path, true) }
      else
        Pod::UI.warn "🤔  Could not delete #{destination}/#{name}.(xc)framework, it does not exist! (this is normal for newly added pods)"
      end
    end

    def collect_files(frameworks)
      resources = []

      umbrella_targets.each do |target|
        target.specs.each do |spec|
          consumer = spec.consumer(target.platform_name)
          file_accessor = Pod::Sandbox::FileAccessor.new(sandbox.pod_dir(spec.root.name), consumer)
          frameworks += file_accessor.vendored_libraries + file_accessor.vendored_frameworks
          resources += file_accessor.resources
        end
      end
      
      frameworks.uniq + resources.uniq
    end
  end
end

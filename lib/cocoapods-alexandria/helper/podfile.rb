module Pod
  class Podfile
    def prepare_for_xcodegen
      use_frameworks!
    end

    def disable_integration
      install!(
        'cocoapods',
        installation_method.last.merge(:integrate_targets => false)
      )
    end
  end
end

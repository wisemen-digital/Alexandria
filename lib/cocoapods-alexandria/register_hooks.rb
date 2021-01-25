Pod::HooksManager.register("cocoapods-alexandria", :pre_install) do |installer_context, user_options|
  if is_ci?
    PodAlexandria::CIPreInstallHook.new(installer_context, user_options).run
  else
    PodAlexandria::LocalPreInstallHook.new(installer_context, user_options).run
  end
end

Pod::HooksManager.register("cocoapods-alexandria", :post_install) do |installer_context, user_options|
  if is_ci?
    PodAlexandria::CIPostInstallHook.new(installer_context, user_options).run
  else
    PodAlexandria::LocalPostInstallHook.new(installer_context, user_options).run
  end
end

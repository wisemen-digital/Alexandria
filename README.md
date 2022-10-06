# cocoapods-alexandria

Alexandria allows for easier integration with XcodeGen, and automatically switches to a "Rome" mode on CI (pre-compile frameworks).

## Installation

```bash
$ gem install cocoapods-alexandria
```

## Important

This library depends on XcodeGen being installed, and you having a (correct) `project.yml` file for project generation.

## Usage 

Write a simple Podfile, like this:

```ruby
platform :ios, '12.0'

plugin 'cocoapods-alexandria'

target 'Alexander' do
  pod 'Alamofire'
end
```

then run this:

```bash
bundler exec pod install
```

Locally, it will **first** generate the project using XcodeGen, and then integratie with CocoaPods.

On CI, it'll first install the pods, compile them if needed, and only then generate your project using XcodeGen. To integratie with these binary frameworks, it'll generate the necessary information into the dependencies file, which you should import in your XcodeGen project.

## Advanced Usage

### Environment Configuration Files

Used to define the xcconfig files for each target and configuration combination. You can customise it using `environment_configs`:

```ruby
platform :ios, '12.0'

plugin 'cocoapods-alexandria',
  :environment_configs => {
    'Alexander' => {
      'Config1-Debug' => 'Configs/Config1.xcconfig',
      'Config1-Release' => 'Configs/Config1.xcconfig',
      'Config2-Debug' => 'Configs/Config2.xcconfig',
      'Config2-Release' => 'Configs/Config2.xcconfig'
    }
  }

target 'Alexander' do
  pod 'Alamofire'
end
```

By default, it will use the following path for each combination, where `$CONFIG_ENV` is the first part of the configuration name (`Development-Debug` becomes `Development`):

```bash
Supporting Files/Settings-${CONFIG_ENV}.xcconfig
```

Locally it will include this configuration file from each CocoaPods's `xcconfig` file, so that you can configure target settings while still using CocoaPods.

On CI, CocoaPods's settings are not used, and instead only the environment configs will be used.

### Bitcode generation

By default, Bitcode generation will be disabled. You can set the `disable_bitcode` option to `false` to turn off this behaviour. Know that the App Store no longer accepts builds with Bitcode built with Xcode 14 or higher.

**Deprecated**: When this behaviour is disabled, you can additionally force all modules to be compiled with Bitcode by setting the `force_bitcode` flag to `true`.

```ruby
platform :osx, '10.10'

plugin 'cocoapods-alexandria',
  :disable_bitcode => false,
  :force_bitcode => true

target 'Alexander' do
  pod 'Alamofire'
end
```

### XcodeGen Dependencies File

By default set to `projectDependencies.yml`, this defines the XcodeGen integration file. You can point Alexandria to a custom path using `xcodegen_dependencies_file`:

```ruby
platform :osx, '10.10'

plugin 'cocoapods-alexandria',
  :xcodegen_dependencies_file => 'customDependenciesFile.yml'

target 'Alexander' do
  pod 'Alamofire'
end
```

The plugin will generate some XcodeGen settings (for each target) to this file, which you can then include from your project file using:

```yaml
include:
  - projectDependencies.yml
```

### Opt-out of dependency embedding

By default, every dependency that's a dynamic library will be embedded in each target. But in some cases, you may want to opt-out of this behaviour.

For example, in your notification service extension, you may not want to embed the OneSignal library, as it's already embedded in your app (and app extensions cannot contain libraries).

To customise this, define the list of targets that should not embed dependencies, using the `do_not_embed_dependencies_in_targets` option:

```ruby
platform :osx, '10.10'

plugin 'cocoapods-alexandria',
  :do_not_embed_dependencies_in_targets => ['AlexanderExtension']

target 'Alexander' do
  pod 'OneSignal'
end

target 'AlexanderExtension' do
  pod 'OneSignal'
end
```

#### How it works

Locally this file will be empty. On CI though, it'll contain all the information needed to link with the binary frameworks, as well as your target's configurations.

For example:

```yaml
targets:
  Alexander:
    configFiles:
      Development-Debug: Application/Supporting Files/Settings-Development.xcconfig
      Development-Release: Application/Supporting Files/Settings-Development.xcconfig
      Production-Debug: Application/Supporting Files/Settings-Production.xcconfig
      Production-Release: Application/Supporting Files/Settings-Production.xcconfig
    dependencies:
      - framework: Rome/Alamofire.framework
        embed: true
```

## Authors

* [David Jennes](https://github.com/djbe)

This library is originally based on the [Cocoapods-Rome](https://github.com/CocoaPods/Rome) library, which was first forked but ended up almost completely rewritten.

## License

Alexandria is available under the MIT license. See the LICENSE file for more info.

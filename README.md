# cocoapods-alexandria

Alexandria allows for easier integration with XcodeGen, and automatically switches to a "Rome" mode on CI (pre-compile frameworks).

## Installation

```bash
$ gem install cocoapods-alexandria
```

## Important

In the examples below the target 'Alexander' could either be an existing target of a project managed by cocapods for which you'd like to run a swift script **or** it could be fictitious, for example if you wish to run this on a standalone Podfile and get the frameworks you need for adding to your xcode project manually.

## Usage 

Write a simple Podfile, like this:

### MacOS

```ruby
platform :osx, '11.1'

plugin 'cocoapods-alexandria'

target 'Alexander' do
  pod 'Alamofire'
end
```

### iOS 

```ruby
platform :ios, '12.0'

plugin 'cocoapods-alexandria',
  :environment_configs => {
    'Config1-Debug' => 'Configs/Config1.xcconfig',
    'Config1-Release' => 'Configs/Config1.xcconfig',
    'Config2-Debug' => 'Configs/Config2.xcconfig',
    'Config2-Release' => 'Configs/Config2.xcconfig',
  },
  :force_bitcode => false,
  :xcodegen_dependencies_file => 'customDependenciesFile.yml'

target 'Alexander' do
  pod 'Alamofire'
end
```

then run this:

```bash
pod install
```

and you will end up with dynamic frameworks:

```
$ tree Rome/
Rome/
└── Alamofire.framework
```

## Advanced Usage

### Environment Configuration Files

TODO: write documentation

### Bitcode generation

By default, bitcode generation will be enforced. You can set the `force_bitcode` option to `false` to disable this behaviour.

```ruby
platform :osx, '10.10'

plugin 'cocoapods-alexandria',
  :force_bitcode => false

target 'Alexander' do
  pod 'Alamofire'
end
```

### XcodeGen Dependencies File

TODO: write documentation

## Authors

* [David Jennes](https://github.com/djbe)

This library is originally based on the [Cocoapods-Rome](https://github.com/CocoaPods/Rome) library, which was first forked but ended up almost completely rewritten.

## License

Alexandria is available under the MIT license. See the LICENSE file for more info.

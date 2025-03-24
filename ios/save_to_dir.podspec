Pod::Spec.new do |s|
    s.name             = "save_to_dir"
    s.version          = "0.1.0"
    s.summary          = "A Flutter plugin to save widgets to a directory."
    s.description      = <<-DESC
    A Flutter plugin that allows saving widgets to a specified directory.
    DESC
    s.homepage         = "https://antsf.com/save_to_dir"
    s.license          = { :type => "MIT", :file => "LICENSE" }
    s.author           = { "antasofa" => "antsf73@gmail.com" }

    s.source           = { :git => "https://antsf.com/save_to_dir", :tag => s.version.to_s }

    s.ios.deployment_target = "10.0"

    s.source_files     = "Classes/**/*"
    s.public_header_files = "Classes/**/*.h"
    s.dependency       "Flutter"
    # s.dependency       "FlutterPluginRegistrant"
end
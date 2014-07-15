
Pod::Spec.new do |s|

  s.name         = "NBUTableViewController"
  s.version      = "1.0.0"
  s.summary      = "Storyboard-centric block-based controller that simplifies management and sync of UITableView and its dataSource."

  s.description  = <<-DESC
                   A longer description of NBUTableViewController in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "http://ghe.amb.ca.local/ameba-smartphone/iOS-NBUTableViewController"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = "All rights reserved."
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }


  s.author             = { "利辺羅エルネスト" => "rivera_ernesto@cyberagent.co.jp" }
  # Or just: s.author    = "利辺羅エルネスト"
  # s.authors            = { "利辺羅エルネスト" => "rivera_ernesto@cyberagent.co.jp" }
  # s.social_media_url   = "http://twitter.com/利辺羅エルネスト"

  s.platform     = :ios, "5.0"

  s.source       = { :git => "git@ghe.amb.ca.local:ameba-smartphone/iOS-NBUTableViewController.git", :commit => "16da9dd20e11169761be1328a00b43305d1f6691" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any h, m, mm, c & cpp files. For header
  #  files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  s.source_files  = "Source/NBUTableViewController.{h,m}"

  # s.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end

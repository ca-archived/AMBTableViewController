
Pod::Spec.new do |s|

    s.name         = "NBUTableViewController"
    s.version      = "1.0.0"
    s.summary      = "Storyboard and Prototype Cells-centric block-based UITableView controller to manage complex layouts."
    s.description  = <<-DESC
                        * Use Storyboards' Prototype Cells to design your cells.
                        * Separate table code with NBUTableViewSection's.
                        * Uses blocks instead of delegate calls and avoid having section code separated through multiple methods.
                        * Individual hide/shown, add/remove sections and rows.
                        * Support for dynamic height cells.
                        * Support for special "No Content Cell"'s for empty sections.
                        DESC
    s.homepage     = "http://cyberagent.github.io/iOS-NBUTableViewController/"

    s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
    s.author       = { "CyberAgent Inc." => "", "Ernesto Rivera" => "rivera_ernesto@cyberagent.co.jp" }
    s.screenshots  = [ "http://cyberagent.github.io/iOS-NBUTableViewController/images/screenshot1.png",
                       "http://cyberagent.github.io/iOS-NBUTableViewController/images/screenshot2.png" ]
    s.source       = { :git => "https://github.com/CyberAgent/iOS-NBUTableViewController.git", :tag => "#{s.version}" }

    s.platform       = :ios, '5.0'
    s.requires_arc   = true
    s.source_files   = 'Source/*.{h,m}'
    s.preserve_paths = "README.md", "NOTICE"

end


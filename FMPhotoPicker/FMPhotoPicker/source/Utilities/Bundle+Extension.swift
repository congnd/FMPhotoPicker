//
//  Bundle+Extension.swift
//  FMPhotoPicker
//
//  Created by Nguyen Dinh Cong on 2020/07/04.
//  Copyright © 2020 Cong Nguyen. All rights reserved.
//

import class Foundation.Bundle

private class BundleFinder {}

extension Foundation.Bundle {
    /// Returns the resource bundle associated with the current Swift module.
    static var current: Bundle = {
        let bundleName = "FMPhotoPicker_FMPhotoPicker"

        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: BundleFinder.self).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL,
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        
        return Bundle(for: BundleFinder.self)
    }()
}

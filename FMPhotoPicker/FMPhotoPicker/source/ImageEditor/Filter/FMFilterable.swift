//
//  FMFilterable.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/01.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

public protocol FMFilterable {
    func filter(image: UIImage) -> UIImage
    func filterName() -> String
}

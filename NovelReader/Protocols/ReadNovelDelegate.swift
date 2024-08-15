//
//  ReadNovelDelegate.swift
//  NovelReader
//
//  Created by Yu Li Lin on 2024/8/13.
//  Copyright © 2024 Rex. All rights reserved.
//

import Foundation

enum ScrollType {
    case previous
    case next
    case resetFont
}

protocol ReadNovelDelegate: NSObject {
    func didSplitChapter(scrollType:ScrollType?)
}

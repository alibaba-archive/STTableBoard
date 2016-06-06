//
//  InternationalControl.swift
//  RefreshView
//
//  Created by bruce on 16/5/12.
//  Copyright © 2016年 ZouLiangming. All rights reserved.
//

import Foundation

public enum CustomRefreshLanguage {
    case English
    case SimplifiedChinese
    case TraditionalChinese
    case Korean
    case Japanese

    internal var identifier: String {
        switch self {
        case .English: return "en"
        case .SimplifiedChinese: return "zh-Hans"
        case .TraditionalChinese: return "zh-Hant"
        case .Korean: return "ko"
        case .Japanese: return "ja"
        }
    }
}

internal func LocalizedString(key key: String, comment: String? = nil) -> String {
    return InternationalControl.sharedControl.localizedString(key: key, comment: comment)
}

internal struct InternationalControl {
    internal static var sharedControl = InternationalControl()
    internal var language: CustomRefreshLanguage = .English

    internal func localizedString(key key: String, comment: String? = nil) -> String {
        let path = NSBundle(identifier: "Teambition.RefreshView")?.pathForResource(language.identifier, ofType: "lproj") ?? NSBundle.mainBundle().pathForResource(language.identifier, ofType: "lproj")
        guard let localizationPath = path else {
            return key
        }
        let bundle = NSBundle(path: localizationPath)
        return bundle?.localizedStringForKey(key, value: nil, table: "Localizable") ?? key
    }
}

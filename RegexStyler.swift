//
//  RegexStyler.swift
//  Tom
//
//  Created by Abdurrahman Şanlı on 15.06.2022.
//  Copyright © 2022 Tom. All rights reserved.
//

import UIKit

struct RegexStyle: Equatable {
    let specialChar: String
    let styleType: RegexStyleType
}

enum RegexStyleType {
    case highlighted
    case underlined
}

final class RegexStyler {
    
    var highlightedTextColor: UIColor = .brown
    
    private var attributedString: NSMutableAttributedString
    private let enabledStyles: [RegexStyle]
    
    init(attributedString: NSMutableAttributedString, enabledStyles: [RegexStyle]) {
        self.attributedString = attributedString
        self.enabledStyles = enabledStyles
    }
    
    func getStyledText(completion: (NSMutableAttributedString) -> Void) {
        enabledStyles.forEach { regexStyle in
            getStyledText(attributedString: attributedString,
                          specialChar: regexStyle.specialChar,
                          styleType: regexStyle.styleType) { attributedString in
                self.attributedString = attributedString
                if regexStyle == enabledStyles.last {
                    completion(attributedString)
                }
            }
        }
    }
    
    private func getStyledText(attributedString: NSMutableAttributedString,
                               specialChar: String,
                               styleType: RegexStyleType,
                               completion: (NSMutableAttributedString) -> Void) {
        let text = attributedString.mutableString as String
        do {
            let pattern = "\\\(specialChar)(.*?)\\\(specialChar)"
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let results = regex.matches(in: text,
                                        options: .withoutAnchoringBounds,
                                        range: NSRange(location: 0, length: text.count))
            var stringsToStyle = results.map { String(text[Range($0.range, in: text)!]) }
            stringsToStyle = stringsToStyle.map { $0.replacingOccurrences(of: specialChar, with: "") }
            switch styleType {
            case .highlighted:
                attributedString.highlightStrings(highlightedStrings: stringsToStyle,
                                                  highlightedTextColor: highlightedTextColor,
                                                  fullText: attributedString.mutableString as String)
            case .underlined:
                attributedString.underlineStrings(underlinedStrings: stringsToStyle,
                                                  fullText: attributedString.mutableString as String)
            }
            attributedString.mutableString.replaceOccurrences(of: specialChar,
                                                              with: "",
                                                              options: .caseInsensitive,
                                                              range: NSRange(location: 0,
                                                                             length: attributedString.string.count))
            completion(attributedString)
        } catch {
            completion(attributedString)
        }
    }
}

extension NSMutableAttributedString {
    
    func highlightStrings(highlightedStrings: [String], highlightedTextColor: UIColor, fullText: String) {
        highlightedStrings.forEach({ highlightedText in
            let highlightRanges = fullText.ranges(of: highlightedText)
            highlightRanges.forEach { highlightRange in
                self.addAttribute(NSAttributedString.Key.foregroundColor,
                                  value: highlightedTextColor,
                                  range: NSRange(highlightRange, in: fullText))
            }
        })
    }
    
    func underlineStrings(underlinedStrings: [String], fullText: String) {
        underlinedStrings.forEach({ highlightedText in
            let highlightRanges = fullText.ranges(of: highlightedText)
            highlightRanges.forEach { highlightRange in
                self.addAttribute(NSAttributedString.Key.underlineStyle,
                                  value: NSUnderlineStyle.single.rawValue,
                                  range: NSRange(highlightRange, in: fullText))
            }
        })
    }
}

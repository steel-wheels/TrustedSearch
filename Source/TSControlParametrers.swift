/*
 * @file TSControlParametrers.swift
 * @description Define TSControlParameters class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import Foundation

@Observable final public class TSControlrameters
{
        public static let MAX_TAG_NUM = 3

        public var allWordsKeyword      : String
        public var entireTextKeyword    : String
        public var someWordsKeyword     : String
        public var notWordsKeyword      : String
        public var language             : TSLanguage?
        public var limitDate            : TSLimitedDate?
        public var category             : String?
        public var tag0Label            : String?
        public var tag1Label            : String?
        public var tag2Label            : String?
        public var tag3Label            : String?

        public init() {
                self.allWordsKeyword    = ""
                self.entireTextKeyword  = ""
                self.someWordsKeyword   = ""
                self.notWordsKeyword    = ""
                self.language           = nil
                self.limitDate          = nil
                self.category           = nil
                self.tag0Label          = nil
                self.tag1Label          = nil
                self.tag2Label          = nil
        }

        public func hasNoKeyword() -> Bool {
                return     self.allWordsKeyword.isEmpty
                        && self.entireTextKeyword.isEmpty
                        && self.someWordsKeyword.isEmpty
                        && self.notWordsKeyword.isEmpty
        }

        public func setTag(index idx: Int, tag tgs: String?) {
                switch idx {
                case 0: self.tag0Label = tgs
                case 1: self.tag1Label = tgs
                case 2: self.tag2Label = tgs
                default: NSLog("[Error] Invalid index: \(idx)")
                }
        }
}


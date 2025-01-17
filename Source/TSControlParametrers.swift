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
        public var allCategories        : Array<String>
        public var category             : String?
        public var tag0Labels           : Array<String>
        public var tag1Labels           : Array<String>
        public var tag2Labels           : Array<String>

        public init() {
                self.allWordsKeyword    = ""
                self.entireTextKeyword  = ""
                self.someWordsKeyword   = ""
                self.notWordsKeyword    = ""
                self.language           = nil
                self.limitDate          = nil
                self.allCategories      = []
                self.category           = nil
                self.tag0Labels         = []
                self.tag1Labels         = []
                self.tag2Labels         = []
        }

        public func hasNoKeyword() -> Bool {
                return     self.allWordsKeyword.isEmpty
                        && self.entireTextKeyword.isEmpty
                        && self.someWordsKeyword.isEmpty
                        && self.notWordsKeyword.isEmpty
        }

        public func setTagLabels(index idx: Int, labels labs: Array<String>) {
                switch idx {
                case 0: self.tag0Labels = labs
                case 1: self.tag1Labels = labs
                case 2: self.tag2Labels = labs
                default: NSLog("[Error] Invalid index: \(idx)")
                }
        }

        public static func copy(from fparam: TSControlrameters, to tparam: TSControlrameters) {
                tparam.allWordsKeyword          = fparam.allWordsKeyword
                tparam.entireTextKeyword        = fparam.entireTextKeyword
                tparam.someWordsKeyword         = fparam.someWordsKeyword
                tparam.notWordsKeyword          = fparam.notWordsKeyword
                tparam.language                 = fparam.language
                tparam.limitDate                = fparam.limitDate
                tparam.allCategories            = fparam.allCategories
                tparam.category                 = fparam.category
                tparam.tag0Labels               = fparam.tag0Labels
                tparam.tag1Labels               = fparam.tag1Labels
                tparam.tag2Labels               = fparam.tag2Labels
        }
}

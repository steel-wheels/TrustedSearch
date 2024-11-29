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

        public var keyword      : String
        public var language     : TSLanguage?
        public var limitDate    : TSLimitedDate?
        public var category     : String?
        public var tag0Labels   : Array<String>
        public var tag1Labels   : Array<String>
        public var tag2Labels   : Array<String>

        public init() {
                self.keyword    = ""
                self.language   = nil
                self.limitDate  = nil
                self.category   = nil
                self.tag0Labels = []
                self.tag1Labels = []
                self.tag2Labels = []
        }

        public func setTagLabels(index idx: Int, labels labs: Array<String>) {
                switch idx {
                case 0: self.tag0Labels = labs
                case 1: self.tag1Labels = labs
                case 2: self.tag1Labels = labs
                default: NSLog("[Error] Invalid index: \(idx)")
                }
        }
}

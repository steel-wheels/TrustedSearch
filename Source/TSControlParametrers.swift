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

        public init() {
                self.keyword    = ""
                self.language   = nil
                self.limitDate  = nil
                self.category   = nil
                self.tag0Labels = []
        }
}

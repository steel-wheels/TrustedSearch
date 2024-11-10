/*
 * @file TSSearchParameters.swift
 * @description Define TSSearchParameters class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiUIKit
import Observation
import Foundation

@Observable final public class TSSearchParameters
{
        public var keyword       : String

        public init() {
                self.keyword    = ""
        }
}


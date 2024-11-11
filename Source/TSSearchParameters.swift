/*
 * @file TSSearchParameters.swift
 * @description Define TSSearchParameters class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import Observation
import Foundation

@Observable final public class TSSearchParameters
{
        public var keyword      : String
        public var sites        : Array<URL>

        public init() {
                self.keyword    = ""
                self.sites      = []
        }
}


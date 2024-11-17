/*
 * @file TSCategoryTable.swift
 * @description Define TSCategoryTable class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiDataKit
import Foundation

public class TSCategory {
        public var tags:  Array<String>
        public var sites: Array<URL>

        public init(tags: Array<String>, sites: Array<URL>) {
                self.tags  = tags
                self.sites = sites
        }

        public func hasTag(_ tag: String) -> Bool {
                for src in tags {
                        if tag == src {
                                return true
                        }
                }
                return false
        }
}

public class TSCategoryTable
{
        private var mCategorizeSites:   Array<TSCategory>
        private var mEntireTags:        Array<String>

        public init() {
                mCategorizeSites  = []
                mEntireTags       = []
        }

        public var categories: Array<TSCategory> { get {
                return mCategorizeSites
        }}

        public var entireTags: Array<String> { get {
                return mEntireTags
        }}

        public func selectSites(byTag tag: String) -> Array<URL> {
                var result: Set<URL> = []
                for cat in mCategorizeSites {
                        if cat.hasTag(tag) {
                                for site in cat.sites {
                                        result.insert(site)
                                }
                        }
                }
                return Array(result)
        }

        public func load()  {
                if let resdir = FileManager.default.resourceDirectory {
                        let file = resdir.appendingPathComponent("categorized_sites.json")
                        switch MIJsonFile.load(from: file) {
                        case .success(let val):
                                let table = load(file: val)
                                mCategorizeSites = table
                                /* Uupcate tag table */
                                mEntireTags = entireTags(table)
                        case .failure(let err):
                                NSLog(MIError.errorToString(error: err))
                        }
                } else {
                        let err = MIError.error(errorCode: .fileError, message: "No resource directory")
                        NSLog(MIError.errorToString(error: err))
                }
        }

        private func load(file src: MIValue) -> Array<TSCategory> {
                var result: Array<TSCategory> = []
                switch src.value {
                case .array(let arr):
                        for elm in arr {
                                switch elm.value {
                                case .interface(let dict):
                                        if let cat = load(element: dict) {
                                                result.append(cat)
                                        }
                                default:
                                        NSLog("category value is required")
                                }
                        }
                default:
                        NSLog("array of categories is required")
                }
                return result
        }

        private func load(element src: Dictionary<String, MIValue>) -> TSCategory? {
                var tags: Array<String> = []
                var result = true
                if let val = src["tags"] {
                        if let strs = load(strings: val) {
                                tags.append(contentsOf: strs)
                        } else {
                                result = false
                        }
                } else {
                        NSLog("Tag property is required")
                        result = false
                }
                var sites: Array<URL> = []
                if let val = src["sites"] {
                        if let strs = load(strings: val) {
                                for str in strs {
                                        if let url = URL(string: str) {
                                                sites.append(url)
                                        } else {
                                                NSLog("Invalid URL")
                                        }
                                }
                        } else {
                                result = false
                        }
                } else {
                        NSLog("Sites property is required")
                        result = false
                }
                if result {
                        return TSCategory(tags: tags, sites: sites)
                } else {
                        return nil
                }
        }

        private func load(strings src: MIValue) -> Array<String>? {
                var result: Array<String>? = nil
                switch src.value {
                case .array(let elms):
                        var strings: Array<String> = []
                        for elm in elms {
                                if let str = elm.stringValue {
                                        strings.append(str)
                                } else {
                                        NSLog("Array element must be strings")
                                }
                        }
                        result = strings.count > 0 ? strings: nil
                default:
                        NSLog("Array of strings is required")
                }
                NSLog("*4")
                return result
        }

        private func load(sites src: MIValue) -> Array<URL> {
                var result: Array<URL> = []
                switch src.value {
                case .array(let paths):
                        for path in paths {
                                switch path.value {
                                case .string(let str):
                                        //NSLog("src: \(str)")
                                        if let url = URL(string: str) {
                                                result.append(url)
                                        } else {
                                                NSLog("[Error] imvalid URL: \(str)")
                                        }
                                default:
                                        NSLog("[Error] imvalid array member")
                                }
                        }
                default:
                        NSLog("[Error] array member")
                }
                return result
        }

        private func entireTags(_ table: Array<TSCategory>) -> Array<String> {
                var tags: Set<String> = []
                for category in table {
                        for tag in category.tags {
                                tags.insert(tag)
                        }
                }
                return Array(tags)
        }

        public func dump() {
                for cat in mCategorizeSites {
                        NSLog("category: {")
                        for tag in cat.tags {
                                NSLog("  tag:  \(tag)")
                        }
                        for site in cat.sites {
                                NSLog("  site: \(site.absoluteString)")
                        }
                        NSLog("}")
                }
        }
}

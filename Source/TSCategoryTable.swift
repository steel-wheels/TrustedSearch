/*
 * @file TSCategoryTable.swift
 * @description Define TSCategoryTable class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiDataKit
import Foundation

public class TSCategory {
        public var category:    String
        public var tags:        Array<String>
        public var sites:       Array<URL>

        public init(category cat: String, tags tgs: Array<String>, sites sts: Array<URL>) {
                self.category = cat
                self.tags     = tgs
                self.sites    = sts
        }
}

public class TSCategoryTable
{
        private var mCategoryTable: Dictionary<String, Array<TSCategory>> // [Category-name, array of TSCategory]

        public init() {
                mCategoryTable  = [:]
        }

        public var categoryNames: Array<String> { get {
                return Array(mCategoryTable.keys.sorted())
        }}

        public func selectByCategory(categoryName catname: String) -> Array<URL> {
                var result: Array<URL> = []
                if let cats = mCategoryTable[catname] {
                        for cat in cats {
                                for site in cat.sites {
                                        //NSLog("select \(site.absoluteString)")
                                        result.append(site)
                                }
                        }
                } else {
                        NSLog("[Error] Unknown category: \(catname)")
                }
                return result
        }

        public func load()  {
                if let resdir = FileManager.default.resourceDirectory {
                        let file = resdir.appendingPathComponent("sites.json")
                        switch MIJsonFile.load(from: file) {
                        case .success(let val):
                                let table = load(file: val)
                                for cat in table {
                                        let catname = cat.category
                                        if var cats = mCategoryTable[catname] {
                                                cats.append(cat)
                                                mCategoryTable[catname] = cats
                                        } else {
                                                mCategoryTable[catname] = [cat]
                                        }
                                }
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
                                        NSLog("[Error] category value is required")
                                }
                        }
                default:
                        NSLog("[Error] array of categories is required")
                }
                return result
        }

        private func load(element src: Dictionary<String, MIValue>) -> TSCategory? {
                var category:   String        = "?"
                var tags:       Array<String> = []

                var result = true
                if let val = src["category"] {
                        if let str = val.stringValue {
                                category = str
                        } else {
                                NSLog("[Error] category string is required")
                        }
                } else {
                        NSLog("[Error] category section is not exist")
                }
                if let val = src["tags"] {
                        if let strs = load(strings: val) {
                                tags.append(contentsOf: strs)
                        } else {
                                result = false
                        }
                } else {
                        NSLog("[Error] Tag property is required")
                        result = false
                }
                var sites: Array<URL> = []
                if let val = src["sites"] {
                        if let strs = load(strings: val) {
                                for str in strs {
                                        if let url = URL(string: str) {
                                                sites.append(url)
                                        } else {
                                                NSLog("[Error] Invalid URL")
                                        }
                                }
                        } else {
                                result = false
                        }
                } else {
                        NSLog("[Error] Sites property is required")
                        result = false
                }
                if result {
                        return TSCategory(category: category, tags: tags, sites: sites)
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
                return result
        }

        public func dump() {
                for (_, cats) in mCategoryTable {
                        for cat in cats {
                                NSLog("category \"\(cat.category)\" : {")
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
}

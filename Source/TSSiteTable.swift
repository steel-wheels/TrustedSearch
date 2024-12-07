/*
 * @file TSSiteTable.swift
 * @description Define TSSiteTable class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiDataKit
import Foundation

public class TSSite {
        public var category:    String
        public var tags:        Array<String>
        public var URLs:        Array<URL>

        public init(category cat: String, tags tgs: Array<String>, URLs urls: Array<URL>) {
                self.category = cat
                self.tags     = tgs
                self.URLs     = urls
        }

        public func hasTag(tag src: String) -> Bool {
                for tag in tags {
                        if tag == src {
                                return true
                        }
                }
                return false
        }

        public func hasAllTags(tags srcs: Array<String>) -> Bool {
                for src in srcs {
                        if !hasTag(tag: src) {
                                return false
                        }
                }
                return true
        }
}

public class TSSiteTable
{
        private var mSiteTable: Dictionary<String, Array<TSSite>>

        public init() {
                mSiteTable  = [:]
        }

        public var categoryNames: Array<String> { get {
                return Array(mSiteTable.keys.sorted())
        }}

        public func selectByCategory(category cat: String) -> Array<TSSite>? {
                return mSiteTable[cat]
        }

        public func load()  {
                guard let resdir = FileManager.default.resourceDirectory else {
                        let err = MIError.error(errorCode: .fileError, message: "No resource directory")
                        NSLog(MIError.errorToString(error: err))
                        return
                }
                let resfile = resdir.appendingPathComponent("sites.json")
                let cachefile: URL
                switch FileManager.default.createCacheFile(source: resfile) {
                case .success(let cfile):
                        NSLog("cache file = \(cfile.absoluteString)")
                        cachefile = cfile
                case .failure(let err):
                        NSLog("[Error] \(MIError.errorToString(error: err))")
                        return
                }

                switch MIJsonFile.load(from: cachefile) {
                case .success(let val):
                        let table = load(file: val)
                        for cat in table {
                                let catname = cat.category
                                if var cats = mSiteTable[catname] {
                                        cats.append(cat)
                                        mSiteTable[catname] = cats
                                } else {
                                        mSiteTable[catname] = [cat]
                                }
                        }
                case .failure(let err):
                        NSLog(MIError.errorToString(error: err))
                }
        }

        private func load(file src: MIValue) -> Array<TSSite> {
                var result: Array<TSSite> = []
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

        private func load(element src: Dictionary<String, MIValue>) -> TSSite? {
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
                var URLs: Array<URL> = []
                if let val = src["sites"] {
                        if let strs = load(strings: val) {
                                for str in strs {
                                        if let url = URL(string: str) {
                                                URLs.append(url)
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
                        return TSSite(category: category, tags: tags, URLs: URLs)
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
                for (_, cats) in mSiteTable {
                        for cat in cats {
                                NSLog("site: {")
                                NSLog("  category: \(cat.category)")
                                for tag in cat.tags {
                                        NSLog("  tag:  \(tag)")
                                }
                                for url in cat.URLs {
                                        NSLog("  url: \(url.absoluteString)")
                                }
                                NSLog("}")
                        }
                }
        }
}

/*
 * @file TSCategorizedSites.swift
 * @description Define TSCategorizedSites class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiDataKit
import Foundation

public class TSCategory {
        public var name: String
        public var sites: Array<URL>

        public init(name: String, sites: Array<URL>) {
                self.name = name
                self.sites = sites
        }
}

public class TSCategorizedSites
{
        private var mCategorizeSites:   Array<TSCategory>

        public init() {
                mCategorizeSites  = []
        }

        public var categories: Array<TSCategory> { get {
                return mCategorizeSites
        }}

        public func load()  {
                if let resdir = FileManager.default.resourceDirectory {
                        let file = resdir.appendingPathComponent("categorized_sites.json")
                        switch MIJsonFile.load(from: file) {
                        case .success(let val):
                                mCategorizeSites = load(file: val)
                        case .failure(let err):
                                NSLog(MIError.errorToString(error: err))
                        }
                } else {
                        let err = MIError.error(errorCode: .fileError, message: "No resource directory")
                        NSLog(MIError.errorToString(error: err))
                }

                let appdir = FileManager.default.applicationSupportDirectory
                NSLog("appdir = \(appdir.path)")
        }

        private func load(file src: MIValue) -> Array<TSCategory> {
                var result: Array<TSCategory> = []
                switch src.value {
                case .interface(let dict):
                        for catname in dict.keys {
                                var sites: Array<URL>
                                if let catdata = dict[catname] {
                                        sites = load(sites: catdata)
                                } else {
                                        NSLog("[Error] Unexpected member in \(catname)")
                                        sites = []
                                }
                                let newcat = TSCategory(name: catname, sites: sites)
                                result.append(newcat)
                        }
                default:
                        NSLog("Interface value is required")
                }
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

        public func dump() {
                for cat in mCategorizeSites {
                        NSLog("category: \(cat.name)")
                        for site in cat.sites {
                                NSLog("  site: \(site.absoluteString)")
                        }
                }
        }
}

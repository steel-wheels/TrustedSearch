/*
 * @file TSCategorizedSites.swift
 * @description Define TSCategorizedSites class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiDataKit
import Foundation

public class TSCategorizeSites
{
        private var mCategorizeSites: Dictionary<String, Array<URL>>

        public init() {
                mCategorizeSites = [:]
        }

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
        }

        private func load(file src: MIValue) -> Dictionary<String, Array<URL>> {
                var result: Dictionary<String, Array<URL>> = [:]
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
                                result[catname] = sites
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
                for (name, sites) in mCategorizeSites {
                        NSLog("category: \(name)")
                        for site in sites {
                                NSLog("  site: \(site.absoluteString)")
                        }
                }
        }
}

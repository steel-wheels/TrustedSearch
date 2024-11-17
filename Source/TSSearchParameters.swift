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
        public var language     : TSLanguage
        public var limitDate    : TSLimitDate

        public init() {
                self.keyword    = ""
                self.sites      = []
                self.language   = .all
                self.limitDate  = .none
        }
}

/* See https://serpapi.com/google-languages */
public enum TSLanguage: Int {
        case all
        case english
        case french
        case german
        case italian
        case japanese
        case korean
        case portuguese
        case spanish
        case afrikaans
        case arabic
        case chinese
        case dutch
        case ukrainian

        public static var allLanguages: Array<TSLanguage> { get {
                let result: Array<TSLanguage> = [
                        all,
                        english,
                        french,
                        german,
                        italian,
                        japanese,
                        korean,
                        portuguese,
                        spanish,
                        afrikaans,
                        arabic,
                        chinese,
                        dutch,
                        ukrainian
                ]
                return result
        }}

        public var langeage: String { get {
                let result: String
                switch self {
                case .all:              result = "ALL"
                case .english:          result = "English"
                case .french:           result = "French"
                case .german:           result = "German"
                case .italian:          result = "Itarian"
                case .japanese:         result = "Japanese"
                case .korean:           result = "Korean"
                case .portuguese:       result = "Portuguese"
                case .spanish:          result = "Spanish"
                case .afrikaans:        result = "Afrikaans"
                case .arabic:           result = "Arabic"
                case .chinese:          result = "Chinese (Simplified)"
                case .dutch:            result = "Dutch"
                case .ukrainian:        result = "Ukrainian"
                }
                return result
        }}

        public var query: String { get {
                let result: String
                switch self {
                case .all:              result = ""
                case .english:          result = "en"
                case .french:           result = "fr"
                case .german:           result = "de"
                case .italian:          result = "it"
                case .japanese:         result = "ja"
                case .korean:           result = "ko"
                case .portuguese:       result = "pt"
                case .spanish:          result = "es"
                case .afrikaans:        result = "af"
                case .arabic:           result = "ar"
                case .chinese:          result = "zh-cn"
                case .dutch:            result = "nl"
                case .ukrainian:        result = "uk"
                }
                return result
        }}
}

public enum TSLimitDate: Int {
        case none
        case before1day
        case before1month
        case before1year

        public static var allLimiteDates: Array<TSLimitDate> { get {
                let result: Array<TSLimitDate> = [
                        .none,
                        .before1day,
                        .before1month,
                        .before1year
                ]
                return result
        }}

        public var titile: String { get {
                let result: String
                switch self {
                case .none:             result = "None"
                case .before1day:       result = "Before 1 day"
                case .before1month:     result = "Before 1 month"
                case .before1year:      result = "Before 1 year"
                }
                return result
        }}
}


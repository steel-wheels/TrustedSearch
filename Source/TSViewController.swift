/*
 * @file TSViewCpntrpller.swift
 * @description Define TSViewController class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiUIKit
import Foundation

class TSViewController: MIViewController
{
        private var mRootView:          MIStack?        = nil
        private var mKeywordField:      MITextField?    = nil
        private var mLanguageMenu:      MIPopupMenu?    = nil
        private var mSearchButton:      MIButton?       = nil

        private var mBrowserController  = TSBrowserController()

        public func setRootView(_ root: MIStack) {
                mRootView = root
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                /* make contents */
                if let root = mRootView {
                        makeContents(rootView: root)
                }

                /* repeat tracking */
                self.tracking()
        }

        private func makeContents(rootView root: MIStack) {
                /* keyword field */
                let keywordfield = MITextField()
                keywordfield.placeholderString = "Keywords to search"
                root.addArrangedSubView(keywordfield)
                keywordfield.setCallback({
                        (_ str: String) -> Void in
                        self.mBrowserController.parameters.keyword = str
                })
                mKeywordField = keywordfield

                /* Language menu */
                var mitems: Array<MIPopupMenu.MenuItem> = []
                for lang in TSLanguage.allLanguages {
                        let item = MIPopupMenu.MenuItem(menuId: lang.rawValue,
                                                        title: lang.langeage)
                        mitems.append(item)
                }
                let langmenu = MIPopupMenu()
                langmenu.setMenuItems(items: mitems)
                mLanguageMenu = langmenu
                let langbox = TSViewController.allocateLabeledStack(label: "Language", content: langmenu)
                root.addArrangedSubView(langbox)

                /* search button */
                let searchbutton = MIButton()
                searchbutton.title = "Search"
                searchbutton.setCallback {
                        () -> Void in self.searchButtonPressed()
                }
                root.addArrangedSubView(searchbutton)
                mSearchButton = searchbutton
        }

        /* this operation is called in main thread*/
        private func tracking() {
                withObservationTracking {
                        [weak self] in
                        guard let self = self else { return }
                        self.keywordIsUpdated(self.mBrowserController.parameters.keyword)
                } onChange: {
                        DispatchQueue.main.async {
                                self.tracking()
                        }
                }
        }

        private func keywordIsUpdated(_ str: String) {
                if let button = mSearchButton {
                        button.isEnabled = !str.isEmpty
                }
        }

        private func searchButtonPressed() {
                /* set language parameter */
                if let langmenu = mLanguageMenu {
                        if let menuid = langmenu.selectedItem() {
                                if let lang = TSLanguage(rawValue: menuid) {
                                        mBrowserController.set(language: lang)
                                } else {
                                        NSLog("Invalid language menu id: \(menuid)")
                                }
                        }
                }

                if let url = mBrowserController.URLToLaunchBrowser() {
                        super.open(URL: url)
                }
        }

        private static func allocateLabeledStack(label labstr: String, content cont: MIInterfaceView) -> MIStack {
                let newbox = MIStack()
                newbox.axis = .horizontal
                let label = MILabel()
                label.title = labstr
                newbox.addArrangedSubView(label)
                newbox.addArrangedSubView(cont)
                return newbox
        }
}


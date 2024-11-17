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
        private var mRootView:          MIStack?                = nil
        private var mKeywordField:      MITextField?            = nil
        private var mLanguageMenu:      MIPopupMenu?            = nil
        private var mDateMenu:          MIPopupMenu?            = nil
        private var mCategoryMenu:      MIPopupMenu?            = nil
        private var mSearchButton:      MIButton?               = nil

        private var mCategoryTable:     TSCategoryTable?        = nil

        private var mBrowserController  = TSBrowserController()

        public func setRootView(_ root: MIStack) {
                mRootView = root
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                /* load categorized sites data */
                let cattable = TSCategoryTable()
                cattable.load()
                cattable.dump()
                mCategoryTable = cattable

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
                mitems.append(MIPopupMenu.MenuItem(menuId: 0, title: "All"))
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

                /* limit date menu */
                mitems.removeAll()
                mitems.append(MIPopupMenu.MenuItem(menuId: 0, title: "All"))
                for ldata in TSLimitedDate.allLimitedDates {
                        let item = MIPopupMenu.MenuItem(menuId: ldata.rawValue,
                                                        title: ldata.titile)
                        mitems.append(item)
                }
                let datemenu = MIPopupMenu()
                datemenu.setMenuItems(items: mitems)
                mDateMenu = datemenu
                let datebox = TSViewController.allocateLabeledStack(label: "Limit date", content: datemenu)
                root.addArrangedSubView(datebox)

                /* categorized site menu */
                mitems.removeAll()
                if let cattable = mCategoryTable {
                        let tags = cattable.entireTags
                        mitems.append(MIPopupMenu.MenuItem(menuId: 0, title: "All"))
                        var idx = 1
                        for tag in tags {
                                mitems.append(MIPopupMenu.MenuItem(menuId: idx, title: tag))
                                idx += 1
                        }
                } else {
                        mitems.append(MIPopupMenu.MenuItem(menuId: 0, title: "?"))
                }
                let catmenu = MIPopupMenu()
                catmenu.setMenuItems(items: mitems)
                mCategoryMenu = catmenu
                let catbox =  TSViewController.allocateLabeledStack(label: "Category", content: catmenu)
                root.addArrangedSubView(catbox)

                /* search button */
                let searchbutton = MIButton()
                searchbutton.title = "Search"
                searchbutton.setCallback {
                        () -> Void in self.searchButtonPressed()
                }
                root.addArrangedSubView(searchbutton)
                mSearchButton = searchbutton
        }

        private func searchButtonPressed() {
                /* set language parameter */
                if let langmenu = mLanguageMenu {
                        if let menuid = langmenu.selectedItem() {
                                if let lang = TSLanguage(rawValue: menuid) {
                                        mBrowserController.set(language: lang)
                                }
                        }
                }

                /* set limit date */
                if let datemenu = mDateMenu {
                        if let menuid = datemenu.selectedItem() {
                                if let ldate = TSLimitedDate(rawValue: menuid) {
                                        mBrowserController.set(limitDate: ldate)
                                }
                        }
                }

                /* set sites parameter */
                if let catmenu = mCategoryMenu, let cattable = mCategoryTable {
                        if let menuid = catmenu.selectedItem() {
                                if menuid == 0 {
                                        mBrowserController.set(sites: [])
                                } else {
                                        let tag   = cattable.entireTags[menuid - 1]
                                        let sites = cattable.selectSites(byTag: tag)
                                        mBrowserController.set(sites: sites)
                                }
                        }
                }

                if let url = mBrowserController.URLToLaunchBrowser() {
                        super.open(URL: url)
                }
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


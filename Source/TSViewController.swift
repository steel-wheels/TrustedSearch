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

        private var mBrowserController  = TSBrowserController()

        public func setRootView(_ root: MIStack) {
                mRootView = root
        }

        override func viewDidLoad() {
                super.viewDidLoad()

                /* load categorized sites data */
                let table = mBrowserController.siteTable
                table.load()
                table.dump()

                /* make contents */
                if let root = mRootView {
                        makeContents(rootView: root)
                }

                /* repeat tracking */
                self.tracking()
        }

        private func makeContents(rootView root: MIStack) {
                /* keyword field */
                let keywordfield = makeKeywordField()
                root.addArrangedSubView(keywordfield)
                mKeywordField = keywordfield

                /* Language menu */
                let langmenu = makeLanguageMenu()
                let langbox  = makeLabeledStack(label: "Language", content: langmenu)
                root.addArrangedSubView(langbox)
                mLanguageMenu = langmenu

                /* limit date menu */
                let datemenu = makeLimitDateMenu()
                mDateMenu = datemenu
                let datebox = makeLabeledStack(label: "Limit date", content: datemenu)
                root.addArrangedSubView(datebox)

                /* categorized site menu */
                let catmenu = makeCategoryeMenu()
                mCategoryMenu = catmenu
                let catbox = makeLabeledStack(label: "Category", content: catmenu)
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

        private func makeKeywordField() -> MITextField {
                let keywordfield = MITextField()
                keywordfield.placeholderString = "Keywords to search"
                keywordfield.setCallback({
                        (_ str: String) -> Void in
                        self.mBrowserController.parameters.keyword = str
                })
                return keywordfield
        }

        private func makeLanguageMenu() -> MIPopupMenu {
                var mitems: Array<MIPopupMenu.MenuItem> = []
                mitems.append(MIPopupMenu.MenuItem(menuId: 0, title: "All"))
                for lang in TSLanguage.allLanguages {
                        let item = MIPopupMenu.MenuItem(menuId: lang.rawValue,
                                                        title:  lang.langeage)
                        mitems.append(item)
                }
                let langmenu = MIPopupMenu()
                langmenu.setMenuItems(items: mitems)
                langmenu.setCallback({
                        (_ menuid: Int) -> Void in
                        let lang = TSLanguage(rawValue: menuid)
                        self.mBrowserController.set(language: lang)
                })
                return langmenu
        }

        private func makeLimitDateMenu() -> MIPopupMenu {
                var mitems: Array<MIPopupMenu.MenuItem> = []
                mitems.append(MIPopupMenu.MenuItem(menuId: 0, title: "All"))
                for ldata in TSLimitedDate.allLimitedDates {
                        let item = MIPopupMenu.MenuItem(menuId: ldata.rawValue,
                                                        title: ldata.titile)
                        mitems.append(item)
                }
                let datemenu = MIPopupMenu()
                datemenu.setMenuItems(items: mitems)
                datemenu.setCallback({
                        (_ menuid: Int) -> Void in
                        let date = TSLimitedDate(rawValue: menuid)
                        self.mBrowserController.set(limitDate: date)

                })
                return datemenu
        }

        private func makeCategoryeMenu() -> MIPopupMenu {
                let cattable = mBrowserController.siteTable
                let catnames = cattable.categoryNames

                var mitems: Array<MIPopupMenu.MenuItem> = []
                mitems.append(MIPopupMenu.MenuItem(menuId: 0, title: "All"))
                var idx = 1
                for catname in catnames {
                        mitems.append(MIPopupMenu.MenuItem(menuId: idx, title: catname))
                        idx += 1
                }
                let catmenu = MIPopupMenu()
                catmenu.setMenuItems(items: mitems)
                catmenu.setCallback({
                        (_ menuId: Int) -> Void in
                        if menuId > 0 {
                                let catid = menuId - 1
                                if 0<=catid && catid < catnames.count {
                                        self.mBrowserController.set(category: catnames[catid])
                                } else {
                                        NSLog("can not happen at \(#function)")
                                }
                        } else {
                                self.mBrowserController.set(category: nil)
                        }
                })
                return catmenu
        }

        private func makeLabeledStack(label labstr: String, content cont: MIInterfaceView) -> MIStack {
                let newbox = MIStack()
                newbox.axis = .horizontal
                let label = MILabel()
                label.title = labstr
                newbox.addArrangedSubView(label)
                newbox.addArrangedSubView(cont)
                return newbox
        }

        private func searchButtonPressed() {
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
}


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
        private var mTagMenus:          Array<MIPopupMenu>      = []
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
                trackKeyword()
                trackLanguage()
                trackCategory()
                trackTag0Label()
                trackTag1Label()
                trackTag2Label()
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

                /* category site menu */
                let catmenu = makeCategoryeMenu()
                mCategoryMenu = catmenu
                let catbox = makeLabeledStack(label: "Category", content: catmenu)
                root.addArrangedSubView(catbox)

                /* tags menu */
                let tagmenus = makeTagMenus()
                mTagMenus    = tagmenus
                let tagsbox  = makeLabeledStack(label: "Tags", contents: tagmenus)
                root.addArrangedSubView(tagsbox)

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
                        self.mBrowserController.controlParameters.keyword = str
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
                        self.mBrowserController.controlParameters.language = lang
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
                                        self.mBrowserController.controlParameters.category = catnames[catid]
                                } else {
                                        NSLog("can not happen at \(#function)")
                                }
                        } else {
                                self.mBrowserController.set(category: nil)
                        }
                })
                return catmenu
        }

        private func makeTagMenus() -> Array<MIPopupMenu> {
                let mitems: Array<MIPopupMenu.MenuItem> = [
                        MIPopupMenu.MenuItem(menuId: 0, title: "None")
                ]
                var result: Array<MIPopupMenu> = []
                for tagid in 0..<TSControlrameters.MAX_TAG_NUM {
                        let tagmenu = MIPopupMenu()
                        tagmenu.setMenuItems(items: mitems)
                        tagmenu.setCallback({
                                (_ menuId: Int) -> Void in
                                if menuId > 0 {
                                        let tag = tagmenu.selectedTitle()
                                        self.mBrowserController.set(tag: tag, at: tagid)
                                } else {
                                        self.mBrowserController.set(tag: nil, at: tagid)
                                }
                        })
                        tagmenu.setEnable(false)
                        result.append(tagmenu)
                }
                return result
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

        private func makeLabeledStack(label labstr: String, contents conts: Array<MIInterfaceView>) -> MIStack {
                let newbox = MIStack()
                newbox.axis = .horizontal
                let label = MILabel()
                label.title = labstr
                newbox.addArrangedSubView(label)
                for cont in conts {
                        newbox.addArrangedSubView(cont)
                }
                return newbox
        }

        private func searchButtonPressed() {
                if let url = mBrowserController.URLToLaunchBrowser() {
                        super.open(URL: url)
                }
        }

        /* track text in mKeywordField */
        private func trackKeyword() {
                withObservationTracking {
                        [weak self] in
                        guard let self = self else { return }
                        let keyword = mBrowserController.controlParameters.keyword
                        /* Update search button */
                        if let button = mSearchButton {
                                button.isEnabled = !keyword.isEmpty
                        }
                        /* Set to browser controller */
                        self.mBrowserController.set(keyword: keyword)
                } onChange: {
                        DispatchQueue.main.async {
                                self.trackKeyword()
                        }
                }
        }

        /* track language in mLanguageMenu */
        private func trackLanguage() {
                withObservationTracking {
                        [weak self] in
                        guard let self = self else { return }
                        let lang = mBrowserController.controlParameters.language
                        /* Set to browser controller */
                        self.mBrowserController.set(language: lang)
                } onChange: {
                        DispatchQueue.main.async {
                                self.trackLanguage()
                        }
                }
        }

        /* Track string in mCategoryMenu */
        private func trackCategory() {
                withObservationTracking {
                        [weak self] in
                        guard let self = self else { return }
                        let category = mBrowserController.controlParameters.category
                        /* Set to browser controller */
                        self.mBrowserController.set(category: category)
                } onChange: {
                        DispatchQueue.main.async {
                                self.trackCategory()
                        }
                }
        }

        private func trackTag0Label() {
                withObservationTracking {
                        [weak self] in
                        guard let self = self else { return }
                        let tag0Labels = mBrowserController.controlParameters.tag0Labels
                        /* erace current setting */
                        self.mBrowserController.set(tag: nil, at: 0)
                        /* Update tag0 menu */
                        let tag0items = allocateTagMenuItems(tags: tag0Labels)
                        mTagMenus[0].setMenuItems(items: tag0items)
                        mTagMenus[0].setEnable(tag0items.count > 1)
                } onChange: {
                        DispatchQueue.main.async {
                                self.trackTag0Label()
                        }
                }
        }

        private func trackTag1Label() {
                withObservationTracking {
                        [weak self] in
                        guard let self = self else { return }
                        let tag1Labels = mBrowserController.controlParameters.tag1Labels
                        /* erace current setting */
                        self.mBrowserController.set(tag: nil, at: 1)
                        /* Update tag0 menu */
                        let tag1items = allocateTagMenuItems(tags: tag1Labels)
                        mTagMenus[1].setMenuItems(items: tag1items)
                        mTagMenus[1].setEnable(tag1items.count > 1)
                } onChange: {
                        DispatchQueue.main.async {
                                self.trackTag1Label()
                        }
                }
        }

        private func trackTag2Label() {
                withObservationTracking {
                        [weak self] in
                        guard let self = self else { return }
                        let tag2Labels = mBrowserController.controlParameters.tag2Labels
                        /* erace current setting */
                        self.mBrowserController.set(tag: nil, at: 2)
                        /* Update tag0 menu */
                        let tag2items = allocateTagMenuItems(tags: tag2Labels)
                        mTagMenus[2].setMenuItems(items: tag2items)
                        mTagMenus[2].setEnable(tag2items.count > 1)
                } onChange: {
                        DispatchQueue.main.async {
                                self.trackTag1Label()
                        }
                }
        }

        private func allocateTagMenuItems(tags tgs: Array<String>) -> Array<MIPopupMenu.MenuItem> {
                var tagitems: Array<MIPopupMenu.MenuItem> = [
                        MIPopupMenu.MenuItem(menuId: 0, title: "None")
                ]
                var tagid = 1
                for tag in tgs {
                        tagitems.append(MIPopupMenu.MenuItem(menuId: tagid, title: tag))
                        tagid += 1
                }
                return tagitems
        }
}


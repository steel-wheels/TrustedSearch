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

                /* make contents */
                if let root = mRootView {
                        makeContents(rootView: root)
                }

                /* repeat tracking */
                trackKeyword()
                trackLanguage()
                trackAllCategories()
                trackCategory()
                trackTag0Label()
                trackTag1Label()
                trackTag2Label()

                /* load categorized sites data */
                Task {
                        let table = TSSiteTable.shared
                        await table.load()
                        await table.dump()
                        await mBrowserController.controlParameters.allCategories = table.categoryNames
                }
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
                let catmenu = MIPopupMenu()
                var mitems: Array<MIPopupMenu.MenuItem> = []
                mitems.append(MIPopupMenu.MenuItem(menuId: 0, title: "All"))
                catmenu.setCallback({
                        (_ menuId: Int) -> Void in
                        Task { await self.mBrowserController.set(category: nil)}
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
                                        Task { await self.mBrowserController.set(tag: tag, at: tagid)}
                                } else {
                                        Task { await self.mBrowserController.set(tag: nil, at: tagid)}
                                }
                        })
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
                Task { @MainActor in
                        if let url = await mBrowserController.URLToLaunchBrowser() {
                                super.open(URL: url)
                        }
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
        private func trackAllCategories() {
                withObservationTracking {
                        [weak self] in
                        guard let self = self else { return }
                        let categories = mBrowserController.controlParameters.allCategories

                        var mitems: Array<MIPopupMenu.MenuItem> = []
                        mitems.append(MIPopupMenu.MenuItem(menuId: 0, title: "All"))
                        var idx = 1
                        for catname in categories {
                                mitems.append(MIPopupMenu.MenuItem(menuId: idx, title: catname))
                                idx += 1
                        }
                        if let catmenu = mCategoryMenu {
                                catmenu.setMenuItems(items: mitems)
                                catmenu.setCallback({
                                        (_ menuId: Int) -> Void in
                                        if menuId > 0 {
                                                let catid = menuId - 1
                                                if 0<=catid && catid < categories.count {
                                                        self.mBrowserController.controlParameters.category = categories[catid]
                                                } else {
                                                        NSLog("can not happen at \(#function)")
                                                }
                                        } else {
                                                Task { await self.mBrowserController.set(category: nil) }
                                        }
                                })
                        } else {
                                NSLog("[Error] No category menu")
                        }
                        /* Unselect category menu */
                        Task { await self.mBrowserController.set(category: nil) }
                } onChange: {
                        DispatchQueue.main.async {
                                self.trackAllCategories()
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
                        Task { await self.mBrowserController.set(category: category) }
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
                        let labels = mBrowserController.controlParameters.tag0Labels
                        trackTagLabel(tagId: 0, labels: labels)
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
                        let labels = mBrowserController.controlParameters.tag1Labels
                        trackTagLabel(tagId: 1, labels: labels)
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
                        let labels = mBrowserController.controlParameters.tag2Labels
                        trackTagLabel(tagId: 2, labels: labels)
                } onChange: {
                        DispatchQueue.main.async {
                                self.trackTag2Label()
                        }
                }
        }

        private func trackTagLabel(tagId tid: Int, labels labs: Array<String>) {
                NSLog("trackTagLabel tagid=\(tid). labels=\(labs)")

                /* Update tag0 menu */
                let tagitems = allocateTagMenuItems(tags: labs)
                mTagMenus[tid].setMenuItems(items: tagitems)
                //mTagMenus[tid].setEnable(tag0items.count > 1)

                /* erace current setting */
                Task { await self.mBrowserController.set(tag: nil, at: tid) }
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


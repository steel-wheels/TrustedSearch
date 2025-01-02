/*
 * @file TSSearchViewCpntrpller.swift
 * @description Define TSSearchViewController class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiUIKit
import Foundation

class TSSearchViewController: MIStackViewController
{
        private var mAllWordsField:     MITextField?            = nil
        private var mEntireTextField:   MITextField?            = nil
        private var mSomeWordsField:    MITextField?            = nil
        private var mNotWordsField:     MITextField?            = nil
        private var mLanguageMenu:      MIPopupMenu?            = nil
        private var mDateMenu:          MIPopupMenu?            = nil
        private var mCategoryMenu:      MIPopupMenu?            = nil
        private var mTagMenus:          Array<MIPopupMenu>      = []
        private var mSearchButton:      MIButton?               = nil

        private var mBrowserController  = TSBrowserController()

        override func viewDidLoad() {
                super.setup(axis: .vertical)
                super.viewDidLoad()

                /* make contents */
                makeContents(rootView: self.root)

                /* repeat tracking */
                trackAllWordsKeyword()
                trackEntireTextKeyword()
                trackSomeWordsKeyword()
                trackNotWordsKeyword()
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
                /* all Words Match field */
                let allwordslabel = MILabel()
                allwordslabel.title = "Contains all words"
                root.addArrangedSubView(allwordslabel)
                let allwordsfield = makeAllWordsField()
                root.addArrangedSubView(allwordsfield)
                mAllWordsField = allwordsfield

                /* Entire text match field */
                let entiretextlabel = MILabel()
                entiretextlabel.title = "Contains entire Text"
                root.addArrangedSubView(entiretextlabel)
                let entiretextfield = makeEntireTextField()
                root.addArrangedSubView(entiretextfield)
                mEntireTextField = entiretextfield

                /* Some words field */
                let somewordslabel = MILabel()
                somewordslabel.title = "Contains some words"
                root.addArrangedSubView(somewordslabel)
                let somewordsfield = makeSomeWordsField()
                root.addArrangedSubView(somewordsfield)
                mSomeWordsField = somewordsfield

                /* Not words field */
                let notwordslabel = MILabel()
                notwordslabel.title = "Does not contain these words"
                root.addArrangedSubView(notwordslabel)
                let notwordsfield = makeNotWordsField()
                root.addArrangedSubView(notwordsfield)
                mNotWordsField = notwordsfield

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

        private func makeAllWordsField() -> MITextField {
                let keywordfield = MITextField()
                keywordfield.placeholderString = "Keywords to search"
                keywordfield.setCallback({
                        (_ str: String) -> Void in
                        self.mBrowserController.controlParameters.allWordsKeyword = str
                })
                return keywordfield
        }

        private func makeEntireTextField() -> MITextField {
                let keywordfield = MITextField()
                keywordfield.placeholderString = "Keywords to search"
                keywordfield.setCallback({
                        (_ str: String) -> Void in
                        self.mBrowserController.controlParameters.entireTextKeyword = str
                })
                return keywordfield
        }

        private func makeSomeWordsField() -> MITextField {
                let keywordfield = MITextField()
                keywordfield.placeholderString = "Keywords to search"
                keywordfield.setCallback({
                        (_ str: String) -> Void in
                        self.mBrowserController.controlParameters.someWordsKeyword = str
                })
                return keywordfield
        }

        private func makeNotWordsField() -> MITextField {
                let keywordfield = MITextField()
                keywordfield.placeholderString = "Keywords to search"
                keywordfield.setCallback({
                        (_ str: String) -> Void in
                        self.mBrowserController.controlParameters.notWordsKeyword = str
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
                newbox.distribution = .fillEqually
                return newbox
        }

        private func searchButtonPressed() {
                Task { @MainActor in
                        if let url = await mBrowserController.URLToLaunchBrowser() {
                                super.open(URL: url)
                        }
                }
        }

        /* track all words */
        private func trackAllWordsKeyword() {
                withObservationTracking {
                        [weak self] in
                        guard let self = self else { return }
                        let keyword = mBrowserController.controlParameters.allWordsKeyword
                        /* Update search button */
                        if let button = mSearchButton {
                                button.isEnabled = !mBrowserController.controlParameters.hasNoKeyword()
                        }
                        /* Set to browser controller */
                        self.mBrowserController.set(type: TSQuery.KeywordType.allWords,  keyword: keyword)
                } onChange: {
                        DispatchQueue.main.async {
                                self.trackAllWordsKeyword()
                        }
                }
        }

        /* track entire text */
        private func trackEntireTextKeyword() {
                withObservationTracking {
                        [weak self] in
                        guard let self = self else { return }
                        let keyword = mBrowserController.controlParameters.entireTextKeyword
                        /* Update search button */
                        if let button = mSearchButton {
                                button.isEnabled = !mBrowserController.controlParameters.hasNoKeyword()
                        }
                        /* Set to browser controller */
                        self.mBrowserController.set(type: TSQuery.KeywordType.entireText,  keyword: keyword)
                } onChange: {
                        DispatchQueue.main.async {
                                self.trackEntireTextKeyword()
                        }
                }
        }

        /* track some words */
        private func trackSomeWordsKeyword() {
                withObservationTracking {
                        [weak self] in
                        guard let self = self else { return }
                        let keyword = mBrowserController.controlParameters.someWordsKeyword
                        /* Update search button */
                        if let button = mSearchButton {
                                button.isEnabled = !mBrowserController.controlParameters.hasNoKeyword()
                        }
                        /* Set to browser controller */
                        self.mBrowserController.set(type: TSQuery.KeywordType.someWords,  keyword: keyword)
                } onChange: {
                        DispatchQueue.main.async {
                                self.trackSomeWordsKeyword()
                        }
                }
        }

        /* track not words */
        private func trackNotWordsKeyword() {
                withObservationTracking {
                        [weak self] in
                        guard let self = self else { return }
                        let keyword = mBrowserController.controlParameters.notWordsKeyword
                        /* Update search button */
                        if let button = mSearchButton {
                                button.isEnabled = !mBrowserController.controlParameters.hasNoKeyword()
                        }
                        /* Set to browser controller */
                        self.mBrowserController.set(type: TSQuery.KeywordType.notWords,  keyword: keyword)
                } onChange: {
                        DispatchQueue.main.async {
                                self.trackNotWordsKeyword()
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


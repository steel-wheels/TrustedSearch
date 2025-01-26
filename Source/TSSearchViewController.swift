/*
 * @file TSSearchViewCpntrpller.swift
 * @description Define TSSearchViewController class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiUIKit
import Foundation

class TSSearchViewController: MIViewController
{
#if os(iOS)
        @IBOutlet weak var mRootView: MIStack!
#else
        @IBOutlet weak var mRootView: MIStack!
#endif

        public var controlParameters = TSControlrameters()

        private var mBrowserController = TSBrowserController()

        private var mAllWordsField:     MITextField?            = nil
        private var mEntireTextField:   MITextField?            = nil
        private var mSomeWordsField:    MITextField?            = nil
        private var mNotWordsField:     MITextField?            = nil
        private var mLanguageMenu:      MIPopupMenu?            = nil
        private var mDateMenu:          MIPopupMenu?            = nil
        private var mCategoryMenu:      MIPopupMenu?            = nil
        private var mTag0Menu:          MIPopupMenu?            = nil
        private var mTag1Menu:          MIPopupMenu?            = nil
        private var mTag2Menu:          MIPopupMenu?            = nil
        private var mSearchButton:      MIButton?               = nil

        override func viewDidLoad() {
                mRootView.axis = .vertical
                super.viewDidLoad()

                /* make contents */
                makeContents(rootView: mRootView)

                /* repeat tracking */
                trackAllWordsKeyword()
                trackEntireTextKeyword()
                trackSomeWordsKeyword()
                trackNotWordsKeyword()
                trackLanguage()
                trackCategory()
                trackTag0Label()
                trackTag1Label()
                trackTag2Label()

                /* load categorized sites data */
                Task {
                        let table = TSSiteTable.shared
                        await table.load()
                        await table.dump()
                        await self.initContents()
                        await updateTags()
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
                let langbox  = makeLabeledStack(label: "Language", contents: [langmenu])
                root.addArrangedSubView(langbox)
                mLanguageMenu = langmenu

                /* limit date menu */
                let datemenu = makeLimitDateMenu()
                mDateMenu = datemenu
                let datebox = makeLabeledStack(label: "Limit date", contents: [datemenu])
                root.addArrangedSubView(datebox)

                /* category site menu */
                let catmenu = makeCategoryMenu()
                mCategoryMenu = catmenu
                let catbox = makeLabeledStack(label: "Category", contents: [catmenu])
                root.addArrangedSubView(catbox)

                /* tags menu */
                let tag0menu = makeTagMenu(level: 0) ; mTag0Menu = tag0menu
                let tag1menu = makeTagMenu(level: 1) ; mTag1Menu = tag1menu
                let tag2menu = makeTagMenu(level: 2) ; mTag2Menu = tag2menu
                let tagsbox  = makeLabeledStack(label: "Tags", contents:
                                                        [tag0menu, tag1menu, tag2menu])
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

        private func initContents() async {
                /* capabilities */
                guard let popupmenu = mCategoryMenu else {
                        NSLog("[Error] No PopupMenu \(#function)")
                        return
                }
                var mitems: Array<MIPopupMenu.MenuItem> = [
                        MIPopupMenu.MenuItem(title: "All", value: .none)
                ]
                let allcats = await TSSiteTable.shared.allCategories.sorted()
                for cat in allcats {
                        mitems.append(MIPopupMenu.MenuItem(title: cat, value: .stringValue(cat)))
                }
                popupmenu.setMenuItems(items: mitems)
        }

        private func makeAllWordsField() -> MITextField {
                let keywordfield = MITextField()
                keywordfield.placeholderString = "Keywords to search"
                keywordfield.setCallback({
                        (_ str: String) -> Void in
                        self.controlParameters.allWordsKeyword = str
                })
                return keywordfield
        }

        private func makeEntireTextField() -> MITextField {
                let keywordfield = MITextField()
                keywordfield.placeholderString = "Keywords to search"
                keywordfield.setCallback({
                        (_ str: String) -> Void in
                        self.controlParameters.entireTextKeyword = str
                })
                return keywordfield
        }

        private func makeSomeWordsField() -> MITextField {
                let keywordfield = MITextField()
                keywordfield.placeholderString = "Keywords to search"
                keywordfield.setCallback({
                        (_ str: String) -> Void in
                        self.controlParameters.someWordsKeyword = str
                })
                return keywordfield
        }

        private func makeNotWordsField() -> MITextField {
                let keywordfield = MITextField()
                keywordfield.placeholderString = "Keywords to search"
                keywordfield.setCallback({
                        (_ str: String) -> Void in
                        self.controlParameters.notWordsKeyword = str
                })
                return keywordfield
        }

        private func makeLanguageMenu() -> MIPopupMenu {
                var mitems: Array<MIPopupMenu.MenuItem> = []
                mitems.append(MIPopupMenu.MenuItem(title: "All", value: .none))
                for lang in TSLanguage.allLanguages {
                        let item = MIPopupMenu.MenuItem(title: lang.langeage, value: .intValue(lang.rawValue))
                        mitems.append(item)
                }
                let langmenu = MIPopupMenu()
                langmenu.setMenuItems(items: mitems)
                langmenu.setCallback({
                        (_ value: MIMenuItem.Value) -> Void in
                        switch value {
                        case .none:
                                self.controlParameters.language = nil
                        case .intValue(let ival):
                                if let lang = TSLanguage(rawValue: ival) {
                                        self.controlParameters.language = lang
                                } else {
                                        NSLog("[Error] Unexpected int value: \(ival)")
                                }
                        case .stringValue(let sval):
                                NSLog("[Error] Unexpected string value: \(sval)")
                        @unknown default:
                                NSLog("[Error] can not happen at \(#function)")
                        }
                })
                return langmenu
        }

        private func makeLimitDateMenu() -> MIPopupMenu {
                var mitems: Array<MIPopupMenu.MenuItem> = []
                mitems.append(MIPopupMenu.MenuItem(title: "All", value: .none))
                for ldata in TSLimitedDate.allLimitedDates {
                        let item = MIPopupMenu.MenuItem(title: ldata.titile,
                                                        value: .intValue(ldata.rawValue))
                        mitems.append(item)
                }
                let datemenu = MIPopupMenu()
                datemenu.setMenuItems(items: mitems)
                datemenu.setCallback({
                        (_ value: MIMenuItem.Value) -> Void in
                        switch value {
                        case .none:
                                self.controlParameters.limitDate = nil
                        case .intValue(let ival):
                                if let ldate = TSLimitedDate(rawValue: ival) {
                                        self.controlParameters.limitDate = ldate
                                } else {
                                        NSLog("[Error] Unexpected int value: \(ival)")
                                }
                        case .stringValue(let sval):
                                NSLog("[Error] Unexpected string value: \(sval)")
                        @unknown default:
                                NSLog("[Error] can not happen at \(#function)")
                        }
                })
                return datemenu
        }

        private func makeCategoryMenu() -> MIPopupMenu {
                let catmenu = MIPopupMenu()
                let mitems: Array<MIPopupMenu.MenuItem> = [
                        MIPopupMenu.MenuItem(title: "All", value: .none)
                ]
                catmenu.setMenuItems(items: mitems)
                catmenu.setCallback({
                        (_ value: MIMenuItem.Value) -> Void in
                        switch value {
                        case .none:
                                self.controlParameters.category = nil
                        case .stringValue(let sval):
                                self.controlParameters.category = sval
                        case .intValue(let ival):
                                NSLog("[Error] Unexpected int value: \(ival)")
                        @unknown default:
                                NSLog("[Error] can not happen at \(#function)")
                        }
                })
                return catmenu
        }

        private func makeTagMenu(level lvl: Int) -> MIPopupMenu {
                let tagmenu = MIPopupMenu()
                let mitems = tagsToMenuItems(tags: [])
                tagmenu.setMenuItems(items: mitems)
                tagmenu.setCallback({
                        (_ value: MIMenuItem.Value) -> Void in
                        switch value {
                        case .none:
                                self.controlParameters.setTag(index: lvl, tag: nil)
                        case .stringValue(let str):
                                self.controlParameters.setTag(index: lvl, tag: str)
                        case .intValue(let ival):
                                NSLog("[Error] Unexpected int value: \(ival)")
                        @unknown default:
                                NSLog("[Error] can not happen at \(#function)")
                        }
                })
                return tagmenu
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
                        /* refer the value */
                        let _ = self.controlParameters.allWordsKeyword
                        /* Update search button */
                        if let button = mSearchButton {
                                button.isEnabled = self.controlParameters.hasNoKeyword()
                        }
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
                        /* refer the value */
                        let _ = self.controlParameters.entireTextKeyword
                        /* Update search button */
                        if let button = mSearchButton {
                                button.isEnabled = !self.controlParameters.hasNoKeyword()
                        }
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
                        /* refer the value */
                        let _ = self.controlParameters.someWordsKeyword
                        /* Update search button */
                        if let button = mSearchButton {
                                button.isEnabled = !self.controlParameters.hasNoKeyword()
                        }
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
                        /* refer the value */
                        let _ = self.controlParameters.notWordsKeyword
                        /* Update search button */
                        if let button = mSearchButton {
                                button.isEnabled = !self.controlParameters.hasNoKeyword()
                        }
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
                        /* refer the value */
                        let _ = self.controlParameters.language
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
                        /* refer the value */
                        let _ = self.controlParameters.category
                        Task {
                                await self.updateTags()
                        }
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
                        /* refer the value */
                        let _ = self.controlParameters.tag0Label
                        Task {
                                await self.updateTags()
                        }
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
                        /* refer the value */
                        let _ = self.controlParameters.tag1Label
                        Task {
                                await self.updateTags()
                        }
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
                        /* refer the value */
                        let _ = self.controlParameters.tag2Label
                        Task {
                                await self.updateTags()
                        }
                } onChange: {
                        DispatchQueue.main.async {
                                self.trackTag2Label()
                        }
                }
        }

        private func updateTags() async {
                guard let tag0menu = mTag0Menu,
                      let tag1menu = mTag1Menu,
                      let tag2menu = mTag2Menu else {
                        NSLog("[Error] No menu at \(#function)")
                        return
                }
                let cat = self.controlParameters.category
                NSLog("updateTags: \(String(describing: cat))")

                /* update tag0 */
                let tag0tags = await TSSiteTable.shared.collectTags(category: cat, tags: [])
                let tag0items = tagsToMenuItems(tags: tag0tags)
                if let sel0title = tag0menu.selectedTitle() {
                        tag0menu.setMenuItems(items: tag0items)
                        let _ = tag0menu.selectByTitle(sel0title)
                } else {
                        tag0menu.setMenuItems(items: tag0items)
                }

                /* update tag1 */
                var definedtags: Array<String> = []
                if let tag = self.controlParameters.tag0Label {
                        definedtags.append(tag)
                }
                let tag1tags = await TSSiteTable.shared.collectTags(category: cat, tags: definedtags)
                let tag1items = tagsToMenuItems(tags: tag1tags)
                if let sel1title = tag1menu.selectedTitle() {
                        tag1menu.setMenuItems(items: tag1items)
                        let _ = tag1menu.selectByTitle(sel1title)
                } else {
                        tag1menu.setMenuItems(items: tag1items)
                }

                /* update tag2 */
                if let tag = self.controlParameters.tag1Label {
                        definedtags.append(tag)
                }
                let tag2tags = await TSSiteTable.shared.collectTags(category: cat, tags: definedtags)
                let tag2items = tagsToMenuItems(tags: tag2tags)
                if let sel2title = tag2menu.selectedTitle() {
                        tag2menu.setMenuItems(items: tag2items)
                        let _ = tag2menu.selectByTitle(sel2title)
                } else {
                        tag2menu.setMenuItems(items: tag2items)
                }
        }

        private func tagsToMenuItems(tags tgs: Set<String>) -> Array<MIMenuItem> {
                var mitems: Array<MIPopupMenu.MenuItem> = [
                        MIPopupMenu.MenuItem(title: "None", value: .none)
                ]
                for tag in tgs.sorted() {
                        mitems.append(MIPopupMenu.MenuItem(title: tag, value: .stringValue(tag)))
                }
                return mitems
        }

        /*
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
        }*/
}


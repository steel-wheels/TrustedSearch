/*
 * @file TSViewCpntrpller.swift
 * @description Define TSViewController class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiUIKit
import Foundation

@Observable final public class TSControlrameters
{
        public static let MAX_TAG_NUM  = TSBrowserController.MAX_TAG_NUM

        public var keyword      : String
        public var language     : TSLanguage?
        public var limitDate    : TSLimitedDate?
        public var category     : String?
        public var tags         : Array<String?>
        
        public init() {
                self.keyword    = ""
                self.language   = nil
                self.limitDate  = nil
                self.category   = nil

                var tgs :Array<String?> = []
                for _ in 0 ..< TSControlrameters.MAX_TAG_NUM {
                        tgs.append(nil)
                }
                self.tags       = tgs

        }
}

class TSViewController: MIViewController
{
        public static let MAX_TAG_NUM = TSBrowserController.MAX_TAG_NUM

        private var mRootView:          MIStack?                = nil
        private var mKeywordField:      MITextField?            = nil
        private var mLanguageMenu:      MIPopupMenu?            = nil
        private var mDateMenu:          MIPopupMenu?            = nil
        private var mCategoryMenu:      MIPopupMenu?            = nil
        private var mTagMenus:          Array<MIPopupMenu>      = []
        private var mSearchButton:      MIButton?               = nil

        private var mControlParameters  = TSControlrameters()
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
                trackTags()
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
                        self.mControlParameters.keyword = str
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
                        self.mControlParameters.language = lang
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
                                        self.mControlParameters.category = catnames[catid]
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
                for taglvl in 0..<TSViewController.MAX_TAG_NUM {
                        let tagmenu = MIPopupMenu()
                        tagmenu.setMenuItems(items: mitems)
                        tagmenu.setCallback({
                                (_ menuId: Int) -> Void in
                                if menuId > 0 {
                                        let tagid = menuId - 1
                                        if let labs = self.mBrowserController.tagLabels(level: taglvl) {
                                                if 0<=tagid && tagid < labs.count {
                                                        self.mControlParameters.tags[taglvl] = labs[tagid]
                                                } else {
                                                        NSLog("can not happen at \(#function)")
                                                }
                                        } else {
                                                self.mControlParameters.tags[taglvl] = nil
                                        }
                                } else {
                                        self.mControlParameters.tags[taglvl] = nil
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
                        let keyword = mControlParameters.keyword
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
                        let lang = mControlParameters.language
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
                        let category = mControlParameters.category
                        /* Set to browser controller */
                        self.mBrowserController.set(category: category)
                        /* Update tag menu */
                        self.updateFirstTag(forCategory: category)
                } onChange: {
                        DispatchQueue.main.async {
                                self.trackCategory()
                        }
                }
        }

        /* Track string in mTagMenus */
        private func trackTags() {
                withObservationTracking {
                        [weak self] in
                        guard let self = self else { return }
                        let tags = mControlParameters.tags
                        /* Set to browser controller */
                        self.mControlParameters.tags = tags
                } onChange: {
                        DispatchQueue.main.async {
                                self.trackTags()
                        }
                }
        }

        private func updateFirstTag(forCategory str: String?) {
                if let labels = self.mBrowserController.tagLabels(level: 0) {
                        var mitems: Array<MIPopupMenu.MenuItem> = []
                        mitems.append(MIPopupMenu.MenuItem(menuId: 0, title: "None"))
                        for i in 0..<labels.count {
                                mitems.append(MIPopupMenu.MenuItem(menuId: 1+i, title: labels[i]))
                        }
                        mTagMenus[0].setMenuItems(items: mitems)
                        mTagMenus[0].setEnable(true)
                } else {
                        mTagMenus[0].setEnable(false)
                }
        }
}


/*
 * @file TSSiteViewCpntrpller.swift
 * @description Define TSSiteViewController class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

import MultiUIKit
import Foundation

class TSSiteViewController: TSBaseViewController
{
        #if os(iOS)
        @IBOutlet weak var mRootView: MIStack!
        #else
        @IBOutlet weak var mRootView: MIStack!
        #endif

        public var controlParameters = TSControlrameters()

        private var mCategoryMenu:      MIPopupMenu?    = nil
        private var mTag0Menu:          MIPopupMenu?    = nil
        private var mTag1Menu:          MIPopupMenu?    = nil
        private var mTag2Menu:          MIPopupMenu?    = nil
        private var mURLTable:          MITable?        = nil

        override func viewDidLoad() {
                mRootView.axis = .vertical
                super.viewDidLoad()

                /* make contents */
                makeContents(rootView: mRootView)

                /* repeat tracking */
                trackCategory()
                trackTag0Label()
                trackTag1Label()
                trackTag2Label()
        }

        #if os(OSX)
        public override func viewWillAppear() {
                super.viewWillAppear()
                executeBeforeAppearing()
        }
        #else
        public override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                executeBeforeAppearing()
        }
        #endif
        private func executeBeforeAppearing() {
                NSLog("viewWillAppear")
                Task {
                        /* capabilities */
                        await self.updateCategory()
                        /* tags */
                        await self.updateContents()
                        await self.updateSelection()
                }
        }

        private func makeContents(rootView root: MIStack) {
                /* Category menu */
                let catmenu = makeCategoryMenu(controlParameter: self.controlParameters)
                mCategoryMenu = catmenu
                let catbox = makeLabeledStack(label: "Category", contents: [catmenu])
                root.addArrangedSubView(catbox)

                /* tags menu */
                let tag0menu = makeTagMenu(controlParameter: self.controlParameters,  level: 0) ; mTag0Menu = tag0menu
                let tag1menu = makeTagMenu(controlParameter: self.controlParameters,  level: 1) ; mTag1Menu = tag1menu
                let tag2menu = makeTagMenu(controlParameter: self.controlParameters,  level: 2) ; mTag2Menu = tag2menu
                let tagsbox  = makeLabeledStack(label: "Tags", contents:
                                                        [tag0menu, tag1menu, tag2menu])
                root.addArrangedSubView(tagsbox)

                /* URL table */
                let urltbl  = MITable()
                let urllbl  = MILabel() ; urllbl.title = "URLs"
                root.addArrangedSubView(urllbl)
                root.addArrangedSubView(urltbl)
                mURLTable = urltbl
        }
        
        private func trackCategory() {
                withObservationTracking {
                        [weak self] in
                        guard let self = self else { return }
                        /* refer the value */
                        let _ = self.controlParameters.category
                        Task { await self.updateContents() }
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
                        Task { await self.updateContents() }
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
                        Task { await self.updateContents() }
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
                        Task { await self.updateContents() }
                } onChange: {
                        DispatchQueue.main.async {
                                self.trackTag2Label()
                        }
                }
        }

        private func updateURLTable() async {
                let bcontroller = TSBrowserController(controlParameter: self.controlParameters)
                let urls = await bcontroller.siteURLs()
                if let table = mURLTable {
                        let data: Array<String> = urls.map { $0.absoluteString }
                        table.setTableData(data)
                }
        }

        private func updateContents() async {
                await self.updateTags()
                await self.updateURLTable()
        }

        private func updateTags() async {
                guard let tag0menu = mTag0Menu,
                      let tag1menu = mTag1Menu,
                      let tag2menu = mTag2Menu else {
                        NSLog("[Error] No menu at \(#function)")
                        return
                }
                await super.updateTags(tag0Menu: tag0menu, tag1Menu: tag1menu, tag2Menu: tag2menu, controlParameter: self.controlParameters)
        }

        private func updateCategory() async {
                /* capabilities */
                if let popupmenu = mCategoryMenu {
                        await super.updateCategoryMenu(menu: popupmenu)
                } else {
                        NSLog("[Error] No PopupMenu \(#function)")
                }
        }

        private func updateSelection() async {
                /* category */
                if let menu = mCategoryMenu {
                        if let cat = self.controlParameters.category {
                                let _ = menu.selectByTitle(cat)
                        } else {
                                let _ = menu.selectByValue(.none)
                        }
                }
                /* tag0 */
                if let menu = mTag0Menu {
                        if let label = self.controlParameters.tag0Label {
                                let _ = menu.selectByTitle(label)
                        } else {
                                let _ = menu.selectByValue(.none)
                        }
                }
                /* tag1 */
                if let menu = mTag1Menu {
                        if let label = self.controlParameters.tag1Label {
                                let _ = menu.selectByTitle(label)
                        } else {
                                let _ = menu.selectByValue(.none)
                        }
                }
                /* tag2 */
                if let menu = mTag2Menu {
                        if let label = self.controlParameters.tag2Label {
                                let _ = menu.selectByTitle(label)
                        } else {
                                let _ = menu.selectByValue(.none)
                        }
                }
        }
}


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

        private var mCategoryMenu: MIPopupMenu? = nil
        private var mURLTable:     MITable?     = nil

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

                /* load categorized sites data */
                Task {
                        await self.initContents()
                }
        }

        #if os(OSX)
        public override func viewWillAppear() {
                super.viewWillAppear()
                applyControlParameters()
        }
        #else
        public override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                applyControlParameters()
        }
        #endif
        private func applyControlParameters() {
                if let cap = self.controlParameters.category, let menu = mCategoryMenu {
                        let _ = menu.selectByTitle(cap)
                }
        }

        private func makeContents(rootView root: MIStack) {
                /* Category menu */
                let catmenu = makeCategoryMenu(controlParameter: self.controlParameters)
                mCategoryMenu = catmenu
                let catbox = makeLabeledStack(label: "Category", contents: [catmenu])
                root.addArrangedSubView(catbox)

                /* URL table */
                let urltbl  = MITable()
                let urllbl  = MILabel() ; urllbl.title = "URLs"
                root.addArrangedSubView(urllbl)
                root.addArrangedSubView(urltbl)
                mURLTable = urltbl
        }

        private func initContents() async {
                /* capabilities */
                if let popupmenu = mCategoryMenu {
                        await super.initCategoryMenu(menu: popupmenu)
                        if let curcap = controlParameters.category {
                                let _ = popupmenu.selectByTitle(curcap)
                        }
                } else {
                        NSLog("[Error] No PopupMenu \(#function)")
                }
        }
        
        private func trackCategory() {
                withObservationTracking {
                        [weak self] in
                        guard let self = self else { return }
                        /* refer the value */
                        let _ = self.controlParameters.category
                        Task { await self.updateURLTable() }
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
                        Task { await self.updateURLTable() }
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
                        Task { await self.updateURLTable() }
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
                        Task { await self.updateURLTable() }
                } onChange: {
                        DispatchQueue.main.async {
                                self.trackTag2Label()
                        }
                }
        }

        public func updateURLTable() async {
                let bcontroller = TSBrowserController(controlParameter: self.controlParameters)
                let urls = await bcontroller.siteURLs()
                if let table = mURLTable {
                        let data: Array<String> = urls.map { $0.absoluteString }
                        table.setTableData(data)
                }
        }

}


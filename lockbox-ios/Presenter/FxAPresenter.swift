/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import FxAUtils
import RxSwift
import RxCocoa
import SwiftyJSON
import Account

protocol FxAViewProtocol: class, ErrorView {
    func loadRequest(_ urlRequest: URLRequest)
}

class FxAPresenter {
    private weak var view: FxAViewProtocol?
    fileprivate let settingActionHandler: SettingActionHandler
    fileprivate let routeActionHandler: RouteActionHandler
    fileprivate let dataStoreActionHandler: DataStoreActionHandler
    fileprivate let dataStore: DataStore
    fileprivate let userDefaults: UserDefaults

    private var disposeBag = DisposeBag()

    public var onCancel: AnyObserver<Void> {
        return Binder(self) { target, _ in
            target.routeActionHandler.invoke(LoginRouteAction.welcome)
        }.asObserver()
    }

    init(view: FxAViewProtocol,
         settingActionHandler: SettingActionHandler = SettingActionHandler.shared,
         routeActionHandler: RouteActionHandler = RouteActionHandler.shared,
         dataStoreActionHandler: DataStoreActionHandler = DataStoreActionHandler.shared,
         dataStore: DataStore = DataStore.shared,
         userDefaults: UserDefaults = UserDefaults.standard
    ) {
        self.view = view
        self.settingActionHandler = settingActionHandler
        self.routeActionHandler = routeActionHandler
        self.dataStoreActionHandler = dataStoreActionHandler
        self.dataStore = dataStore
        self.userDefaults = userDefaults
    }

    func onViewReady() {
        self.view?.loadRequest(URLRequest(url: ProductionFirefoxAccountConfiguration().signInURL))
    }

    func onLogin(_ data: JSON) {
        Observable.combineLatest(self.userDefaults.onLock, self.dataStore.syncState)
                .map { LockedSyncState(locked: $0.0, state: $0.1) }
                .subscribe(onNext: { latest in
                    if latest.locked {
                        self.settingActionHandler.invoke(.visualLock(locked: false))
                        self.routeActionHandler.invoke(MainRouteAction.list)
                    } else if latest.state == SyncState.Syncing {
                        self.dataStoreActionHandler.invoke(.initialize(blob: data))
                    }
                })
                .disposed(by: self.disposeBag)
    }
}

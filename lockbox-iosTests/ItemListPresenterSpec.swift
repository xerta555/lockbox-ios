/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Quick
import Nimble
import RxSwift
import RxCocoa
import RxTest
import Storage

@testable import Lockbox

class ItemListPresenterSpec: QuickSpec {
    class FakeItemListView: ItemListViewProtocol {
        var itemsObserver: TestableObserver<[ItemSectionModel]>!
        var sortButtonEnableObserver: TestableObserver<Bool>!
        var tableViewScrollObserver: TestableObserver<Bool>!
        var sortingButtonTitleObserver: TestableObserver<String>!
        var dismissSpinnerObserver: TestableObserver<Void>!
        let disposeBag = DisposeBag()
        var dismissKeyboardCalled = false
        var displaySpinnerCalled = false

        var displayOptionSheetButtons: [AlertActionButtonConfiguration]?
        var displayOptionSheetTitle: String?

        func bind(items: Driver<[ItemSectionModel]>) {
            items.drive(itemsObserver).disposed(by: self.disposeBag)
        }

        func bind(sortingButtonTitle: Driver<String>) {
            sortingButtonTitle.drive(sortingButtonTitleObserver).disposed(by: self.disposeBag)
        }

        func displayAlertController(buttons: [AlertActionButtonConfiguration], title: String?, message: String?, style: UIAlertControllerStyle) {
            self.displayOptionSheetButtons = buttons
            self.displayOptionSheetTitle = title
        }

        func dismissKeyboard() {
            self.dismissKeyboardCalled = true
        }

        var sortingButtonEnabled: AnyObserver<Bool>? {
            return self.sortButtonEnableObserver.asObserver()
        }

        var tableViewScrollEnabled: AnyObserver<Bool> {
            return self.tableViewScrollObserver.asObserver()
        }

        func displaySpinner(_ dismiss: Driver<Void>, bag: DisposeBag) {
            self.displaySpinnerCalled = true
            dismiss.drive(self.dismissSpinnerObserver).disposed(by: bag)
        }
    }

    class FakeRouteActionHandler: RouteActionHandler {
        var invokeActionArgument: RouteAction?

        override func invoke(_ action: RouteAction) {
            self.invokeActionArgument = action
        }
    }

    class FakeItemListDisplayActionHandler: ItemListDisplayActionHandler {
        var invokeActionArgument: [ItemListDisplayAction] = []

        override func invoke(_ action: ItemListDisplayAction) {
            self.invokeActionArgument.append(action)
        }
    }

    class FakeDataStore: DataStore {
        var itemListStub = PublishSubject<[Login]>()
        var syncStateStub = PublishSubject<SyncState>()

        override var list: Observable<[Login]> {
            return self.itemListStub.asObservable()
        }

        override var syncState: Observable<SyncState> {
            return self.syncStateStub.asObservable()
        }
    }

    class FakeItemListDisplayStore: ItemListDisplayStore {
        var itemListDisplaySubject = PublishSubject<ItemListDisplayAction>()

        override var listDisplay: Observable<ItemListDisplayAction> {
            return self.itemListDisplaySubject.asObservable()
        }
    }

    private var view: FakeItemListView!
    private var routeActionHandler: FakeRouteActionHandler!
    private var itemListDisplayActionHandler: FakeItemListDisplayActionHandler!
    private var dataStore: FakeDataStore!
    private var itemListDisplayStore: FakeItemListDisplayStore!
    private let scheduler = TestScheduler(initialClock: 0)
    private let disposeBag = DisposeBag()
    var subject: ItemListPresenter!

    override func spec() {
        describe("ItemListPresenter") {
            beforeEach {
                self.view = FakeItemListView()
                self.routeActionHandler = FakeRouteActionHandler()
                self.itemListDisplayActionHandler = FakeItemListDisplayActionHandler()
                self.dataStore = FakeDataStore()
                self.itemListDisplayStore = FakeItemListDisplayStore()
                self.view.itemsObserver = self.scheduler.createObserver([ItemSectionModel].self)
                self.view.sortingButtonTitleObserver = self.scheduler.createObserver(String.self)
                self.view.sortButtonEnableObserver = self.scheduler.createObserver(Bool.self)
                self.view.tableViewScrollObserver = self.scheduler.createObserver(Bool.self)
                self.view.dismissSpinnerObserver = self.scheduler.createObserver(Void.self)

                self.subject = ItemListPresenter(
                        view: self.view,
                        routeActionHandler: self.routeActionHandler,
                        itemListDisplayActionHandler: self.itemListDisplayActionHandler,
                        dataStore: self.dataStore,
                        itemListDisplayStore: self.itemListDisplayStore
                )
            }

            describe(".onViewReady()") {
                describe("when the datastore pushes an empty list of items") {
                    beforeEach {
                        self.subject.onViewReady()
                        self.dataStore.itemListStub.onNext([])
                    }

                    describe("when the datastore is still syncing") {
                        beforeEach {
                            self.dataStore.syncStateStub.onNext(SyncState.Syncing)
                            self.itemListDisplayStore.itemListDisplaySubject.onNext(ItemListFilterAction(filteringText: ""))
                            self.itemListDisplayStore.itemListDisplaySubject.onNext(ItemListSortingAction.alphabetically)
                        }

                        it("tells the view to display the spinner") {
                            expect(self.view.displaySpinnerCalled).to(beTrue())
                        }

                        it("pushes the search field and placeholder image to the itemlist") {
                            let expectedItemConfigurations = [
                                LoginListCellConfiguration.Search(enabled: Observable.just(false), cancelHidden: Observable.just(true), text: Observable.just("")),
                                LoginListCellConfiguration.SyncListPlaceholder
                            ]
                            expect(self.view.itemsObserver.events.first!.value.element).notTo(beNil())
                            let configuration = self.view.itemsObserver.events.first!.value.element!
                            expect(configuration.first!.items).to(equal(expectedItemConfigurations))
                        }

                        it("disables the sorting button and the tableview") {
                            expect(self.view.sortButtonEnableObserver.events.last!.value.element).to(beFalse())
                            expect(self.view.tableViewScrollObserver.events.last!.value.element).to(beFalse())
                        }

                        describe("once the datastore is synced") {
                            beforeEach {
                                self.dataStore.syncStateStub.onNext(SyncState.Synced)
                            }

                            it("dismisses the spinner") {
                                expect(self.view.dismissSpinnerObserver.events.count).to(equal(1))
                            }

                            it("keeps the sorting button and the tableviewscroll disabled") {
                                expect(self.view.sortButtonEnableObserver.events.last!.value.element).to(beFalse())
                                expect(self.view.tableViewScrollObserver.events.last!.value.element).to(beFalse())
                            }

                            it("displays the emptylist placeholder") {
                                let fakeObserver = self.scheduler.createObserver(Void.self).asObserver()
                                let expectedItemConfigurations = [
                                    LoginListCellConfiguration.Search(enabled: Observable.just(false), cancelHidden: Observable.just(true), text: Observable.just("")),
                                    LoginListCellConfiguration.EmptyListPlaceholder(learnMoreObserver: fakeObserver)
                                ]
                                expect(self.view.itemsObserver.events.last!.value.element).notTo(beNil())
                                let configuration = self.view.itemsObserver.events.last!.value.element!
                                expect(configuration.first!.items).to(equal(expectedItemConfigurations))
                            }

                            describe("tapping the learnMore button in the empty list placeholder") {
                                beforeEach {
                                    let configuration = self.view.itemsObserver.events.last!.value.element!

                                    let emptyListPlaceholder = configuration.first!.items[1] as! LoginListCellConfiguration
                                    if case let .EmptyListPlaceholder(learnMoreObserver) = emptyListPlaceholder {
                                        learnMoreObserver.onNext(())
                                    } else {
                                        fail("wrong item configuration!")
                                    }
                                }

                                it("routes to the learn more view") {
                                    expect(self.routeActionHandler.invokeActionArgument).notTo(beNil())
                                    let argument = self.routeActionHandler.invokeActionArgument as! MainRouteAction
                                    expect(argument).to(equal(MainRouteAction.learnMore))
                                }
                            }
                        }
                    }
                }

                describe("when the datastore pushes a populated list of items") {
                    let webAddress1 = "http://meow"
                    let webAddress2 = "http://aaaaaa"
                    let username = "cats@cats.com"

                    let id1 = "fdsdfsfdsfds"
                    let id2 = "ghfhghgff"
                    let items = [
                        Login(guid: id1, hostname: webAddress1, username: username, password: ""),
                        Login(guid: id2, hostname: "", username: "", password: ""),
                        Login(guid: "", hostname: webAddress2, username: "", password: "fdsfdsfd")
                    ]

                    beforeEach {
                        self.subject.onViewReady()
                        self.dataStore.itemListStub.onNext(items)
                        self.itemListDisplayStore.itemListDisplaySubject.onNext(ItemListFilterAction(filteringText: ""))
                        self.itemListDisplayStore.itemListDisplaySubject.onNext(ItemListSortingAction.alphabetically)
                        self.dataStore.syncStateStub.onNext(SyncState.Synced)
                    }

                    it("tells the view to display the items in alphabetic order by title") {
                        let expectedItemConfigurations = [
                            LoginListCellConfiguration.Search(enabled: Observable.just(true), cancelHidden: Observable.just(true), text: Observable.just("")),
                            LoginListCellConfiguration.Item(title: "", username: Constant.string.usernamePlaceholder, guid: id2),
                            LoginListCellConfiguration.Item(title: "aaaaaa", username: Constant.string.usernamePlaceholder, guid: ""),
                            LoginListCellConfiguration.Item(title: "meow", username: username, guid: id1)
                        ]
                        expect(self.view.itemsObserver.events.first!.value.element).notTo(beNil())
                        let configuration = self.view.itemsObserver.events.first!.value.element!
                        expect(configuration.first!.items).to(equal(expectedItemConfigurations))
                    }

                    describe("when text is entered into the search bar") {
                        describe("when the text matches an item's username") {
                            beforeEach {
                                self.itemListDisplayStore.itemListDisplaySubject.onNext(ItemListFilterAction(filteringText: "cat"))
                            }

                            it("updates the view with the appropriate items") {
                                let expectedItemConfigurations = [
                                    LoginListCellConfiguration.Search(enabled: Observable.just(true), cancelHidden: Observable.just(true), text: Observable.just("")),
                                    LoginListCellConfiguration.Item(title: "meow", username: username, guid: id1)
                                ]

                                expect(self.view.itemsObserver.events.last!.value.element).notTo(beNil())
                                let configuration = self.view.itemsObserver.events.last!.value.element!
                                expect(configuration.first!.items).to(equal(expectedItemConfigurations))
                            }
                        }

                        describe("when the text matches an item's origins") {
                            beforeEach {
                                self.itemListDisplayStore.itemListDisplaySubject.onNext(ItemListFilterAction(filteringText: "meow"))
                            }

                            it("updates the view with the appropriate items") {
                                let expectedItemConfigurations = [
                                    LoginListCellConfiguration.Search(enabled: Observable.just(true), cancelHidden: Observable.just(true), text: Observable.just("")),
                                    LoginListCellConfiguration.Item(title: "meow", username: username, guid: "")
                                ]

                                expect(self.view.itemsObserver.events.last!.value.element).notTo(beNil())
                                let configuration = self.view.itemsObserver.events.last!.value.element!
                                expect(configuration.first!.items).to(equal(expectedItemConfigurations))
                            }
                        }
                    }

                    xdescribe("when sorting method switches to recently used") {
                        // pended until it's possible to construct Logins with recently_used dates
                        beforeEach {
                            self.itemListDisplayStore.itemListDisplaySubject.onNext(ItemListSortingAction.recentlyUsed)
                        }

                        it("pushes the new configuration with the items") {
                            let expectedItemConfigurations = [
                                LoginListCellConfiguration.Search(enabled: Observable.just(true), cancelHidden: Observable.just(true), text: Observable.just("")),
                                LoginListCellConfiguration.Item(title: webAddress1, username: username, guid: id1),
                                LoginListCellConfiguration.Item(title: "", username: Constant.string.usernamePlaceholder, guid: id2),
                                LoginListCellConfiguration.Item(title: webAddress2, username: Constant.string.usernamePlaceholder, guid: "fdssdf")
                            ]
                            expect(self.view.itemsObserver.events.last!.value.element).notTo(beNil())
                            let configuration = self.view.itemsObserver.events.last!.value.element!
                            expect(configuration.last!.items).to(equal(expectedItemConfigurations))
                        }
                    }

                    describe("hiding and showing the cancel button, enabling and disabling search field") {
                        let enabledObserver = self.scheduler.createObserver(Bool.self)
                        let cancelHiddenObserver = self.scheduler.createObserver(Bool.self)
                        let textObserver = self.scheduler.createObserver(String.self)

                        beforeEach {
                            let searchCellConfig = self.view.itemsObserver.events.first!.value.element![0].items[0] as! LoginListCellConfiguration
                            if case let .Search(enabled: enabledObservable, cancelHidden: cancelObservable, text: textObservable) = searchCellConfig {
                                enabledObservable
                                        .bind(to: enabledObserver)
                                        .disposed(by: self.disposeBag)

                                cancelObservable
                                        .bind(to: cancelHiddenObserver)
                                        .disposed(by: self.disposeBag)

                                textObservable
                                        .bind(to: textObserver)
                                        .disposed(by: self.disposeBag)
                            }
                        }

                        describe("when the list of entries is empty") {
                            beforeEach {
                                self.dataStore.itemListStub.onNext([])
                            }

                            it("disables the search field") {
                                expect(enabledObserver.events.last!.value.element).to(beFalse())
                            }
                        }

                        describe("when the list of entries is populated") {
                            beforeEach {
                                self.dataStore.itemListStub.onNext([Login(guid: "sfsdf", hostname: "sds", username: "sdfds", password: "kjklfd")])
                            }

                            it("enables the search field") {
                                expect(enabledObserver.events.last!.value.element).to(beTrue())
                            }
                        }

                        describe("when the text is empty, regardless of whether the keyboard is displayed") {
                            beforeEach {
                                self.itemListDisplayStore.itemListDisplaySubject.onNext(ItemListFilterAction(filteringText: ""))
                            }

                            it("keeps the cancel button hidden") {
                                self.itemListDisplayStore.itemListDisplaySubject.onNext(ItemListFilterEditAction(editing: true))
                                expect(cancelHiddenObserver.events.last!.value.element).to(beTrue())
                                self.itemListDisplayStore.itemListDisplaySubject.onNext(ItemListFilterEditAction(editing: false))
                                expect(cancelHiddenObserver.events.last!.value.element).to(beTrue())
                            }

                            it("updates the text field") {
                                expect(textObserver.events.last!.value.element).to(equal(""))
                            }
                        }

                        describe("when the text is not empty") {
                            let text = "sum"
                            beforeEach {
                                self.itemListDisplayStore.itemListDisplaySubject.onNext(ItemListFilterAction(filteringText: text))
                            }

                            it("keeps the cancel button hidden when the text field is not selected and tells the text observer") {
                                self.itemListDisplayStore.itemListDisplaySubject.onNext(ItemListFilterEditAction(editing: false))
                                expect(cancelHiddenObserver.events.last!.value.element).to(beTrue())
                                expect(textObserver.events.last!.value.element).to(equal(text))
                            }

                            it("dispalys the cancel button when the text field is not selected and tells the text observer") {
                                self.itemListDisplayStore.itemListDisplaySubject.onNext(ItemListFilterEditAction(editing: true))
                                expect(cancelHiddenObserver.events.last!.value.element).to(beFalse())
                                expect(textObserver.events.last!.value.element).to(equal(text))
                            }
                        }
                    }
                }
            }

            describe("filterText") {
                let text = "entered text"

                beforeEach {
                    let textObservable = self.scheduler.createColdObservable([next(40, text)])
                    textObservable.bind(to: self.subject.filterTextObserver).disposed(by: self.disposeBag)
                    self.scheduler.start()
                }

                it("dispatches the filtertext item list display action and editing action") {
                    let editingAction = self.itemListDisplayActionHandler.invokeActionArgument.popLast() as! ItemListFilterEditAction
                    expect(editingAction.editing).to(beTrue())
                    let action = self.itemListDisplayActionHandler.invokeActionArgument.popLast() as! ItemListFilterAction
                    expect(action.filteringText).to(equal(text))
                }
            }

            describe("filterCancelButton") {
                beforeEach {
                    let cancelButtonObservable = self.scheduler.createColdObservable([next(40, ())])
                    cancelButtonObservable.bind(to: self.subject.filterCancelObserver).disposed(by: self.disposeBag)
                    self.scheduler.start()
                }

                it("hides keyboard and dispatches false editing action, clearing the text from the textfield") {
                    expect(self.view.dismissKeyboardCalled).to(beTrue())
                    let filteringAction = self.itemListDisplayActionHandler.invokeActionArgument.popLast() as! ItemListFilterAction
                    expect(filteringAction.filteringText).to(equal(""))
                    let editingAction = self.itemListDisplayActionHandler.invokeActionArgument.popLast() as! ItemListFilterEditAction
                    expect(editingAction.editing).to(beFalse())
                }
            }

            describe("editEnded event") {
                beforeEach {
                    let editEndedObservable = self.scheduler.createColdObservable([next(40, ())])
                    editEndedObservable.bind(to: self.subject.editEndedObserver).disposed(by: self.disposeBag)
                    self.scheduler.start()
                }

                it("hides keyboard and dispatches false editing action") {
                    expect(self.view.dismissKeyboardCalled).to(beTrue())
                    let editingAction = self.itemListDisplayActionHandler.invokeActionArgument.popLast() as! ItemListFilterEditAction
                    expect(editingAction.editing).to(beFalse())
                }
            }

            describe("itemSelected") {
                describe("when the item has an id") {
                    let id = "fsjksdfjklsdfjlkdsf"

                    beforeEach {
                        let itemObservable = self.scheduler.createColdObservable([
                            next(50, id)
                        ])

                        itemObservable
                                .bind(to: self.subject.itemSelectedObserver)
                                .disposed(by: self.disposeBag)

                        self.scheduler.start()
                    }

                    it("tells the route action handler to display the detail view for the relevant item") {
                        expect(self.routeActionHandler.invokeActionArgument).notTo(beNil())
                        let argument = self.routeActionHandler.invokeActionArgument as! MainRouteAction
                        expect(argument).to(equal(MainRouteAction.detail(itemId: id)))
                    }
                }

                describe("when the item does not have an id") {
                    beforeEach {
                        let itemObservable: TestableObservable<String?> = self.scheduler.createColdObservable([next(50, nil)])

                        itemObservable
                                .bind(to: self.subject.itemSelectedObserver)
                                .disposed(by: self.disposeBag)

                        self.scheduler.start()
                    }

                    it("does nothing") {
                        expect(self.routeActionHandler.invokeActionArgument).to(beNil())
                    }
                }
            }

            describe("sortingButton") {
                beforeEach {
                    let voidObservable = self.scheduler.createColdObservable([next(50, ())])

                    voidObservable
                            .bind(to: self.subject.sortingButtonObserver)
                            .disposed(by: self.disposeBag)

                    self.scheduler.start()
                }

                it("tells the view to display an option sheet") {
                    expect(self.view.displayOptionSheetButtons).notTo(beNil())
                    expect(self.view.displayOptionSheetTitle).notTo(beNil())

                    expect(self.view.displayOptionSheetTitle).to(equal(Constant.string.sortEntries))
                }

                describe("tapping alphabetically") {
                    beforeEach {
                        self.view.displayOptionSheetButtons![0].tapObserver!.onNext(())
                    }

                    it("dispatches the alphabetically ItemListSortingAction") {
                        let action = self.itemListDisplayActionHandler.invokeActionArgument.popLast() as! ItemListSortingAction
                        expect(action).to(equal(ItemListSortingAction.alphabetically))
                    }
                }

                describe("tapping recently used") {
                    beforeEach {
                        self.view.displayOptionSheetButtons![1].tapObserver!.onNext(())
                    }

                    it("dispatches the alphabetically ItemListSortingAction") {
                        let action = self.itemListDisplayActionHandler.invokeActionArgument.popLast() as! ItemListSortingAction
                        expect(action).to(equal(ItemListSortingAction.recentlyUsed))
                    }
                }
            }

            describe("settings button") {
                beforeEach {
                    let voidObservable = self.scheduler.createColdObservable([next(50, ())])

                    voidObservable
                            .bind(to: self.subject.onSettingsTapped)
                            .disposed(by: self.disposeBag)

                    self.scheduler.start()
                }

                it("dispatches the setting route action") {
                    let action = self.routeActionHandler.invokeActionArgument as! SettingRouteAction
                    expect(action).to(equal(SettingRouteAction.list))
                }
            }
        }
    }
}

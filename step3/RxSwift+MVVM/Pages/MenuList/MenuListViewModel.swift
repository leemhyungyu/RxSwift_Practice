//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by 임현규 on 2022/11/03.
//  Copyright © 2022 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

class MenuListViewModel {
    /*
     Observalbe: 비동기적으로 생성되는 데이터를 관측하는 객체. 나중에 데이터가 생성되면 subscrible로 데이터 사용가능?
     Subject: Observable처럼 값을 받아올 수 도 있지만 외부에서 값을 통제할 수 있음
     
     데이터를 받아오는 종류에 따라 subject가 나뉨.
     
     PublishSubject: subscrible하는 시점에 이미 생성된 데이터는 안받아옴
     BehaviorSubject: 초기값을 가지고, 데이터가 생성되기전에 subscrible을 하면 초기값과, 이후 데이터 계속 받아옴, 데이터가 생성된 후 subscrible하면 가장 최근에 생성된 데이터와 이후의 데이터들을 계속 받아옴
     
     Relay: subject와 똑같지만 에러가 나면 스트림이 끊어지지 않고 무시함.
        -> UI와 관련된 observable은 Relay로..
        subscrible에서 error, complete호출하지 않음
        -> complete되거나 error가 발생하지 않기 때문
        -> 옵저버블에 데이터 전달할때 onNext 대신 accpect사용
     
     */
    
//    lazy var menuObservable = Observable.just(menus)
//    var menuObservable = PublishSubject<[Menu]>()
//    var menuObservable = BehaviorSubject<[Menu]>(value: [])
    
    var menuObservable = BehaviorRelay<[Menu]>(value: [])
    
//    var itemsCount: Int = 5
    lazy var itemsCount = menuObservable.map {
        $0.map { $0.count }.reduce(0, +)
    }
//    var totalPrice: Observable<Int> = Observable.just(10_000)
//    var totalPrice: PublishSubject<Int> = PublishSubject()
    
    lazy var totalPrice = menuObservable.map {
        $0.map { $0.price *  $0.count }.reduce(0, +)
    }
    
    
    init() {
        
        APIService.fetchAllMenusRx()
            .map { data -> [MenuItem] in
                struct Response: Decodable {
                    let menus: [MenuItem]
                }
                
                let response = try! JSONDecoder().decode(Response.self, from: data)
                
                return response.menus
            }
            // 서버에서 받은 데이터 형식을 필요한 형태로 바꿈
            .map { menuItems -> [Menu] in
                var menus: [Menu] = []
                menuItems.enumerated().forEach { (index, item)  in
                    let menu = Menu.fromMenuItems(id: index, item: item)
                    menus.append(menu)
                }
                
                return menus
            }
            .take(1)
            .subscribe(onNext: {
//                self.menuObservable.onNext($0)
                self.menuObservable.accept($0)
            })
    }
    
    func clearAllItemSelctions() {
        menuObservable
            .map { menus in
                menus.map { m in
                    Menu(id: m.id, name: m.name, price: m.price, count: 0)
                }
            }
            .take(1) // 해당 함수가 실행될때마다 스트림이 계속 생기는거를 방지
            .subscribe(onNext: {
//                self.menuObservable.onNext($0)
                self.menuObservable.accept($0)
            })
    }
    
    func changeCount(item: Menu, increase: Int) {
        
        menuObservable
            .map { menus in
                menus.map { m -> Menu in
                    if m.id == item.id {
                        return Menu(id: m.id, name: m.name, price: m.price, count: max(m.count + increase, 0))
                    } else {
                        return Menu(id: m.id, name: m.name, price: m.price, count: m.count)
                    }
                }
            }
            .take(1) // 해당 함수가 실행될때마다 스트림이 계속 생기는거를 방지
            .subscribe(onNext: {
//                self.menuObservable.onNext($0)
                self.menuObservable.accept($0)
            })
    }
    
    func onOrder() {
        
    }
}

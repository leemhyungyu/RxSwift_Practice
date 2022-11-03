//
//  MenuListViewModel.swift
//  RxSwift+MVVM
//
//  Created by 임현규 on 2022/11/03.
//  Copyright © 2022 iamchiwon. All rights reserved.
//

import Foundation
import RxSwift

class MenuListViewModel {
    
    // Subject: Observable처럼 값을 받아올 수 도 있지만 외부에서 값을 통제할 수 있음

//    lazy var menuObservable = Observable.just(menus)
//    var menuObservable = PublishSubject<[Menu]>()
    var menuObservable = BehaviorSubject<[Menu]>(value: [])
    
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
        let menus: [Menu] = [
            Menu(id: 0, name: "튀김1", price: 100, count: 0),
            Menu(id: 1, name: "튀김2", price: 200, count: 0),
            Menu(id: 2, name: "튀김3", price: 300, count: 0),
            Menu(id: 3, name: "튀김4", price: 400, count: 0),
            Menu(id: 4, name: "튀김5", price: 500, count: 0),
        ]
        
        menuObservable.onNext(menus)
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
                self.menuObservable.onNext($0)
            })
    }
    
    func changeCount(item: Menu, increase: Int) {
        menuObservable
            .map { menus in
                menus.map { m in
                    if m.id == item.id {
                        return Menu(id: m.id, name: m.name, price: m.price, count: m.count + increase)
                    } else {
                        return Menu(id: m.id, name: m.name, price: m.price, count: m.count)
                    }
                }
            }
            .take(1) // 해당 함수가 실행될때마다 스트림이 계속 생기는거를 방지
            .subscribe(onNext: {
                self.menuObservable.onNext($0)
            })
    }
}

//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!

//    var disposable: Disposable?
//    var disposable: [Disposable] = [] -> dispose해야하는 작업이 여러개 있을때 리스트로 사용
    var disposeBag = DisposeBag() // view가 사라지면 변수도 사라지므로 dispose() 안해줘도 작업 취소 가능
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        disposable?.dispose() // 다운로드 받는 중에 뷰 나가면 다운로드 취소 가능
//        disposable.forEach { $0.dispose() } // 여러개의 작업들 한꺼번에 dispose
//    }
    
    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }
    
    // 기본적인 비동기 방식 구현
    
    // Observable의 생명 주기
    // 1. Create -> Create로 OBservable만든다고 안에 내용이 실행되는 것이 아님
    // 2. Subscrible -> Subscrible이 되면 Observale 동작
    // 3. onNext -> 데이터 전달
    // ---- 끝 ----
    // 4. onCompleted / onError -> 동작 끝
    // 5. Disposed -> 모든 동작 끝나면 Disposed
    // 동작이 끝난(Completed, Error) Observable은 다시 재사용 못함. 다시 Subscrible로 사용해줘야 함
    
    func downLoadJosn(_ Url: String) -> Observable<String> {
        // 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
        return Observable.create() { emitter in
            let url = URL(string: Url)!
            let task = URLSession.shared.dataTask(with: url) { data, _, error in

                guard error == nil else {
                    emitter.onError(error!) // 에러 호출
                    return
                }

                // 데이터가 제대로 왔으면
                if let data = data, let json = String(data: data, encoding: .utf8) {
                    emitter.onNext(json) // 데이터 넘겨줌
                }

                // Observal을 onCompletion으로 종료
                emitter.onCompleted()
            }

            task.resume()

            // 모든 동작 끝나면 Disposed
            return Disposables.create() {
                task.cancel()
            }
        }
        
        // 생성 operator 사용 예시
//        return Observable.just("Hello World") -> "Hello World" 전달
//        return Observable.just(["Hello", "World"]) -> "Hello", "World" 전달
//        return Observable.from(["Hello", "World"]) -> "Hello" 전달 "World" 전달
        
    }
    
    // RxSwift: 비동기적으로 발생하는 데이터를 리턴값으로 전달, 사용할때는 subcrible로 사용
    // MARK: SYNC

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)

        // 이전 코드 축약
        

        downLoadJosn(MEMBER_LIST_URL)
//            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default)) // Observable을 .
//            .map { $0!.count } // operator
//            .filter { $0 > 0 } // operator
//            .map { "\($0)" } // operator
            .observeOn(MainScheduler.instance) // 메인 쓰레드에서 subscribe처리 = DispatchQueue.main.async
            .subscribe(onNext: { json in // onNext말고도 나머지도 지정 가능 (onError, onCompleted, onDisposed)
                self.editView.text = json
                self.setVisibleWithAnimation(self.activityIndicator, false)
            })
            .disposed(by: disposeBag) 
        
        // zip operator 사용 예시
        
//      let jsonObservable = downLoadJosn(MEMBER_LIST_URL)
//        let helloObservable = Observable.just("Hello world")
//
//        disposable = Observable.zip(jsonObservable, helloObservable) { $1 + "\n" + $0}
//            .observeOn(MainScheduler.instance)
//            .subscribe(onNext: { json in
//                self.editView.text = json
//                self.setVisibleWithAnimation(self.activityIndicator, false)
//            })
    }
}

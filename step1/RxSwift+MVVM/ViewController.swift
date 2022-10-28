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

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

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
    
    func downLoadJosn(_ Url: String) -> Observable<String?> {
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
    }
    
    // RxSwift: 비동기적으로 발생하는 데이터를 리턴값으로 전달, 사용할때는 subcrible로 사용
    // MARK: SYNC

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)

        // 2. Observable로 오는 데이터를 받아서 처리하는 방법
        
        // subscrible은 disposable 리턴함, disposable은 작업 취소할 때 사용 -> disposalble.dispose()

        downLoadJosn(MEMBER_LIST_URL)
            .subscribe { event in
                // 해당 클로저가 순환참조 일으키는데 이 클로저는 observable이 종료되면(completed, error, disposed) 종료됨 -> 순환참조 끝남
                switch event {
                case .next(let json):
                    DispatchQueue.main.async {
                        self.editView.text = json
                        self.setVisibleWithAnimation(self.activityIndicator, false)
                    }
                    break
                    
                case .error(let error):
                    break
                    
                case .completed:
                    break
                }
            }

    }
}

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

// Observable: 나중에생기는데이터
// Subscribe: 나중에오면

/// Observable 생명주기
// 1. Create
// 2. Subscribe (여기서 실행되기 때문에 create문도 여기 이후 코드 실행)
// 3. onNext
// ------ 끝 ------
// 4. onCompleted / onError
// 5. Disposed (한번 끝나면 재사용 불가, 새로 sub 해야함)

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

//class 나중에생기는데이터<T> {
//    private let task: (@escaping (T) -> Void) -> Void
//
//    init(task: @escaping (@escaping (T) -> Void) -> Void) {
//        self.task = task
//    }
//
//    func 나중에오면(_ f: @escaping (T) -> Void) {
//        task(f)
//    }
//}

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
    
    // 기존 비동기
    // 간단한 return으로 비동기를 전달할 수 없을까? -> 이를 해결해주는 유틸리티가 rxswift!
    // 나중에 생기는 데이터 <Stirng?> 요런 형태로
//    func downloadJson(_ url: String, _ completion: @escaping ((String?) -> Void)) {
//        DispatchQueue.global().async {
//            let url = URL(string: MEMBER_LIST_URL)!
//            let data = try! Data(contentsOf: url)
//            let json = String(data: data, encoding: .utf8)
//            DispatchQueue.main.async {
//                completion(json)
//            }
//        }
//    }
    
    // rxSwift
    // 또 다른 유틸리티: PromiseKit, Bolt
    func downloadJson(_ url: String) -> Observable<String> {
        // just로 아래 주석을 한 줄로 표현 가능 (데이터 하나만 전송 가능)
        // just 대신 from을 쓰면 한 줄 띄어 내려받기 가능 [Hello, World] -> Hello\n World
        return Observable.just("Hello World")
//        return Observable.create { emitter in
//            emitter.onNext("Hello World")
//            emitter.onCompleted()
//            return Disposables.create()
//        }
    }

    // MARK : SYNC

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        
        // 2. Observable로 오는 데이터를 받아서 처리
        let jsonObservable = downloadJson(MEMBER_LIST_URL)
        let helloObservable = Observable.just("Hello World")
        
        _ = Observable.zip(jsonObservable, helloObservable) { $1 + "\n" + $0 }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {json in
                self.editView.text = json
                self.setVisibleWithAnimation(self.activityIndicator, false)
            })
        
    }
}

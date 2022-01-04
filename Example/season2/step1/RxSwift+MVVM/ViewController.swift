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
    func downloadJson(_ url: String) -> Observable<String?> {
        // 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴
        return Observable.create() { emitter in
            let url = URL(string: url)!
            let task = URLSession.shared.dataTask(with: url) { (data, _, err) in
                guard err == nil else {
                    emitter.onError(err!)
                    return
                }
                
                if let dat = data, let json = String(data: dat, encoding: .utf8) {
                    emitter.onNext(json)    //  url 스레드에서 전달됨 (subsrcibe에서 ui 변경은 메인스레드로 감싸기)
                }
                emitter.onCompleted()
            }
            
            task.resume()
            
            return Disposables.create() {   // 데이터가 캔슬됨
                task.cancel()
            }
        }
        
//        return Observable.create() { f in
//            DispatchQueue.global().async {
//                let url = URL(string: MEMBER_LIST_URL)!
//                let data = try! Data(contentsOf: url)
//                let json = String(data: data, encoding: .utf8)
//
//                DispatchQueue.main.async {
//                    // onNext 스테이트로 값 전달
//                    f.onNext(json)
//                }
//            }
//            return Disposables.create()
//        }
    }

    // MARK: SYNC

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)
        
        // rx
        // 2. Observable로 오는 데이터를 받아서 처리
        downloadJson(MEMBER_LIST_URL)
            .subscribe { event in
                switch event{
                case let .next(json):
                    DispatchQueue.main.async {
                        self.editView.text = json
                        self.setVisibleWithAnimation(self.activityIndicator, false)
                    }
                    
                case .completed:
                    break
                case .error:
                    break
                }
            }
        
        // 기존 비동기
//        self.downloadJson(MEMBER_LIST_URL) { json in
//            self.editView.text = json
//            self.setVisibleWithAnimation(self.activityIndicator, false)
//        }
         
    }
}

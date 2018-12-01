//
//  ViewController.swift
//  2chPost
//
//  Created by cano on 2018/12/01.
//  Copyright © 2018 deskplate. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.postTo2ch("http://awabi.2ch.sc/test/read.cgi/male/1514976917/", "投稿テスト")
    }

    func postTo2ch(_ urlString: String, _ postText: String) {

        let url     = URL(string: urlString)
        let domain  = (url?.host)!  // ドメイン

        let subStrings  = domain.components(separatedBy: ".")
        let server      = subStrings[0] // サーバー

        let paths   = urlString.components(separatedBy: "/")
        let thread  = paths[paths.count-2]  // スレッド
        let board   = paths[paths.count-3]  // 掲示板種別

        let bbsUrl  = "https://\(server).5ch.net/test/bbs.cgi"  // 投稿先CGI

        let headers: HTTPHeaders = [
            "Referer": urlString,
            "Accept-Encoding": "gzip",
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
            "Accept-Charset": "ISO-8859-1,utf-8;q=0.7,*;q=0.3",
            "Accept-Language": "en-US,en;q=0.8",
            "Connection": "keep-alive"
        ]
        let parameters: [String: Any] = [
            "bbs": board,
            "key": thread,
            "time": Int(Date().timeIntervalSince1970) - 60,
            "FROM": "",
            "subject": "",
            "mail": "",
            "MESSAGE": postText,
            "submit": "書き込む"
        ]

        Alamofire.request(bbsUrl, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseString { response in
            print(response)
            let res = response.response
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: res?.allHeaderFields as! [String : String], for: (res?.url!)!)
            print(cookies)
            if response.description.contains("書き込み確認") { // 書きこみました。
                let res = response.response
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: res?.allHeaderFields as! [String : String], for: (res?.url!)!)
                Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookies(cookies, for: response.response?.url, mainDocumentURL: nil)
                Alamofire.request(bbsUrl, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseString { response in
                    print(response)
                }
            }
        }
    }
}


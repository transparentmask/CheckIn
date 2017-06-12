//
//  CheckInTests.swift
//  CheckInTests
//
//  Created by Martin Yin on 10/05/2017.
//  Copyright © 2017 Martin Yin. All rights reserved.
//

import XCTest
@testable import CheckIn

class CIAppInfoTests: XCTestCase {
    var appInfo: CIAppInfo!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        appInfo = CIAppInfo()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        appInfo = nil
        
        super.tearDown()
    }
    
    func testAppInfoDictionary() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        appInfo.id = "test"
        appInfo.name = "测试"
        appInfo.iconURL = "https://nas.mask911.net/checkin/test.png"
        appInfo.url = "https://nas.mask911.net/checkin/"
        appInfo.checkinTime = 10000
        
        XCTAssert(NSDictionary(dictionary: appInfo.dictionary()).isEqual(to: NSDictionary(dictionary: ["id": "test", "name": "测试", "icon": "https://nas.mask911.net/checkin/test.png", "url": "https://nas.mask911.net/checkin/", "checkinTime": 10000]) as! [String : Any]))
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}

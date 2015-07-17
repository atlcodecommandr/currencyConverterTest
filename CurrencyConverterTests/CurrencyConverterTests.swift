//
//  CurrencyConverterTests.swift
//  CurrencyConverterTests
//
//  Created by gabriel arronte on 7/16/15.
//  Copyright (c) 2015 Make and Build. All rights reserved.
//

import UIKit
import XCTest

class CurrencyConverterTests: XCTestCase {
    var vc: ViewController!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        vc = storyboard.instantiateViewControllerWithIdentifier("currencyViewController") as? ViewController

        let dummy = vc!.view // force loading subviews and setting outlets

        vc!.viewDidLoad()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

        super.tearDown()
    }

    func testConversion(){
        expectationForNotification("currencyCalculated", object: nil, handler: nil)
        vc.fromTextField.text = "AUD"
        vc.toTextField.text = "USD"
        vc.valuetoConvert.text = "300"
        vc.convertClicked(vc.convertButton)
         waitForExpectationsWithTimeout(10.0, handler: nil)
        println(vc.convertedValue.text)
        XCTAssertTrue(vc.convertedValue.text != "")

    }


    
}

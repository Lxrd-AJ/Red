//
//  HomeViewControllerTests.swift
//  My Word Bank
//
//  Created by AJ Ibraheem on 26/07/2015.
//  Copyright © 2015 The Leaf. All rights reserved.
//

//FIXME: Test Not Working
import XCTest
@testable import My_Word_Bank

class HomeViewControllerTests: XCTestCase {

    var homeViewController: HomeViewController!
    
    override func setUp() {
        super.setUp()
        homeViewController = UIStoryboard(name: "Main",bundle:nil).instantiateViewControllerWithIdentifier("homeController") as! HomeViewController
        XCTAssertNotNil( homeViewController, "HomeViewController does not exist")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFolderCreation(){
        //Test Root Folder Creation
        let folder = Folder.createFolder(ROOT_FOLDER, ctx: homeViewController.managedObjCtx)
        XCTAssert( folder != nil , "Folder does not exist" )
        XCTAssert( folder!.name == ROOT_FOLDER, "Folder name is not equal to \(ROOT_FOLDER)" )
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}

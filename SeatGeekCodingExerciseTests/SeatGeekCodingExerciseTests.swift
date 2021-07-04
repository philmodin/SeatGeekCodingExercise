//
//  SeatGeekCodingExerciseTests.swift
//  SeatGeekCodingExerciseTests
//
//  Created by endOfLine on 6/29/21.
//

import XCTest
@testable import SeatGeekCodingExercise

// todo:
// disabling internet on slow connection while loading thumbnails on old method crashes app, confirm with new request method

class SeatGeekCodingExerciseTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Favorites().reset()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSeatGeekMeta() {
        let expectMeta = expectation(description: "load meta")
        
        SGRequest().totalEvents(for: "") { totalEvents, error in
            if let error = error { XCTFail(error.localizedDescription) }
            XCTAssertNotNil(totalEvents, "Meta for total results should not be nil")
            XCTAssert(totalEvents! > 0, "There should be at least 1 result in the meta")
            expectMeta.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testSeatGeekEvent() {
        let expectEvents = expectation(description: "load event")
        
        SGRequest().event(for: "", at: IndexPath(row: 0, section: 0)) { event, error in
            if let error = error { XCTFail(error.localizedDescription) }
            XCTAssertNotNil(event, "There should be an event.")
            expectEvents.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testSeatGeekSearch() {
        
        let expectQuery = expectation(description: "load query")
        let query = "basket"
        
        SGRequest().event(for: query, at: IndexPath(row: 0, section: 0)) { event, error in
            if let error = error { XCTFail(error.localizedDescription) }
            let doesContainQuery = event?.performers.contains {
                $0!.taxonomies.contains {
                    $0!.name.contains(query)
                }
            }
            XCTAssertEqual(doesContainQuery, true, "Query should be present in first event content")
            expectQuery.fulfill()
        }        
        waitForExpectations(timeout: 5)
    }
    
    func testSeatGeekThumbnail() {
        let expectImage = expectation(description: "load image")
        
        SGRequest().thumbnail(for: EventsResponse.sampleEvent) { data, error in
            guard let data = data else {
                XCTFail(error?.localizedDescription ?? "unknown error")
                return
            }
            XCTAssertNotNil(UIImage(data: data), "Loaded image should not be nil")
            expectImage.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testFavoritesChangeStates() {
        
        let sampleID = 1234567
        let favorites = Favorites()
        
        let initialState = favorites.isFavorite(sampleID)
        XCTAssertEqual(initialState, false, "Sample ID should NOT be set as a favorite initially")
        
        favorites.toggle(sampleID)
        let isToggledOn = favorites.isFavorite(sampleID)
        XCTAssertEqual(isToggledOn, true, "Sample ID SHOULD be set as a favorite now")
        
        favorites.toggle(sampleID)
        let isToggledOff = favorites.isFavorite(sampleID)
        XCTAssertEqual(isToggledOff, false, "Sample ID should NOT be set as a favorite now")
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}

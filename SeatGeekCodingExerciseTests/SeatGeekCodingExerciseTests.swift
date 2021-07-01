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
    
    func testSeatGeekInitialLoadingAndNextPage() {
        
        let expectFirstPage = expectation(description: "load first page")
        let expectSecondPage = expectation(description: "load second page")
        
        let _ = SGRequest().event { eventsResponse, error in
            if let error = error { XCTFail(error.localizedDescription) }
            XCTAssertNotEqual(eventsResponse?.events.count ?? 0, 0, "Events should not be empty on first page")
            expectFirstPage.fulfill()

            let _ = SGRequest().event(at: (eventsResponse?.meta.page ?? 0) + 1) { eventsResponse, error in
                if let error = error { XCTFail(error.localizedDescription) }
                XCTAssertEqual(eventsResponse?.meta.page ?? 0, 2, "Events should not be empty on second page")
                expectSecondPage.fulfill()
            }
        }
        waitForExpectations(timeout: 5)
    }
    
    func testSeatGeekSearchQuery() {
        
        let expectQuery = expectation(description: "load query")
        let query = "basket"
        
        let _ = SGRequest().event(searching: query) { eventsResponse, error in
            if let error = error { XCTFail(error.localizedDescription) }
            
            let doesContainQuery = eventsResponse?.events.contains {
                $0.performers.contains {
                    $0!.taxonomies.contains {
                        $0!.name.contains(query)
                    }
                }
            }
            
            XCTAssertEqual(doesContainQuery, true, "Query should be present in first event")
            expectQuery.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    
    func testLoadThumbnail() {
        
        let expectImage = expectation(description: "load image")
        let imageURL = URL(string: "https://seatgeek.com/images/performers-landscape/indiana-fever-2d24ec/10716/huge.jpg")
        
        let _ = SGRequest().thumbnail(for: imageURL) { image in
            XCTAssertNotEqual(image.pngData(), UIImage.placeholder.pngData(), "Loaded image should not be the placeholder")
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

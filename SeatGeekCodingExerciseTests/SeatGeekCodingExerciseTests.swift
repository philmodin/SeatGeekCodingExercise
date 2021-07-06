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
        
    func testEventsResponse() {
        let eventsResponsePass = EventsResponse.sampleEventPass        
        XCTAssertNotNil(eventsResponsePass.date)
        XCTAssertNotEqual(eventsResponsePass.day, "no date")
        XCTAssertNotEqual(eventsResponsePass.time, "no time")
        XCTAssertEqual(eventsResponsePass.venue?.coordinates.latitude, 59.9711)
        XCTAssertNotNil(eventsResponsePass.performers[0]?.imageURL)
        
        let eventsResponseFail = EventsResponse.sampleEventFail
        XCTAssertNil(eventsResponseFail.date)
        XCTAssertEqual(eventsResponseFail.day, "no date")
        XCTAssertEqual(eventsResponseFail.time, "no time")
        XCTAssertNil(eventsResponseFail.performers[0]?.imageURL)
    }
    
    func testSGInvalidURLRequest() {
        let invalidURL = "Invalid URL"
        let sgRequester = SGRequest(testing: invalidURL)
        XCTAssertEqual(sgRequester.clientID, invalidURL, "Client ID should be Invalid URL")
        
        let expectEventsTotalCount = expectation(description: "expect eventsTotalCount")
        let expectEvent = expectation(description: "expect event")
        let expectThumbnail = expectation(description: "expect thumbnail")
        
        sgRequester.eventsTotalCount(for: "") { totalEvents, error in
            XCTAssertEqual(error?.localizedDescription, sgRequester.errorURLRequest)
            expectEventsTotalCount.fulfill()
        }
        sgRequester.event(for: "", at: IndexPath(row: 0, section: 0)) { event, error in
            XCTAssertEqual(error?.localizedDescription, sgRequester.errorURLRequest)
            expectEvent.fulfill()
        }
        sgRequester.thumbnail(for: EventsResponse.sampleEventFail) { data, error in
            XCTAssertEqual(error?.localizedDescription, sgRequester.errorURL)
            expectThumbnail.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testSGInvalidClientID() {
        let invalidID = "InvalidID"
        let sgRequester = SGRequest(testing: invalidID)
        XCTAssertEqual(sgRequester.clientID, invalidID, "Client ID should be Invalid ID")
        
        let expectError = expectation(description: "expect error")
        
        sgRequester.eventsTotalCount(for: "") { totalEvents, error in
            XCTAssertEqual(error?.localizedDescription, "Invalid client credentials")
            expectError.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testSGMeta() {
        let expectMeta = expectation(description: "load meta")
        
        SGRequest().eventsTotalCount(for: "") { totalEvents, error in
            if let error = error { XCTFail(error.localizedDescription) }
            XCTAssertNotNil(totalEvents, "Meta for total results should not be nil")
            XCTAssert(totalEvents! > 0, "There should be at least 1 result in the meta")
            expectMeta.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testSGEvent() {
        let expectEvents = expectation(description: "load event")
        
        SGRequest().event(for: "", at: IndexPath(row: 0, section: 0)) { event, error in
            if let error = error { XCTFail(error.localizedDescription) }
            XCTAssertNotNil(event, "There should be an event.")
            expectEvents.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testSGSearch() {
        
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
    
    func testSGThumbnail() {
        let expectImage = expectation(description: "load image")
        
        SGRequest().thumbnail(for: EventsResponse.sampleEventPass) { data, error in
            guard let data = data else {
                XCTFail(error?.localizedDescription ?? "unknown error")
                return
            }
            XCTAssertNotNil(UIImage(data: data), "Loaded image should not be nil")
            expectImage.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testCache() {
        let cache = Cache()
        let sampleEventPass = EventsResponse.sampleEventPass
        let sampleEventFail = EventsResponse.sampleEventFail
        let expectThumbnailDoMerge = expectation(description: "expectThumbnailDoMerge")
        let expectThumbnailNoMerge = expectation(description: "expectThumbnailNoMerge")
        let expectThumbnailFail = expectation(description: "expectThumbnailFail")
        
        cache.thumbnail(for: sampleEventPass) { mergedNewImage, error in
            XCTAssertTrue(cache.thumbnails.keys.contains(sampleEventPass.id), "Key for thumbnail should exist now")
            XCTAssertTrue(mergedNewImage, "New image should have been merged")
            XCTAssertNil(error, "There should be no error")
            expectThumbnailDoMerge.fulfill()
            
            cache.thumbnail(for: sampleEventPass) { mergedNewImage, error in
                XCTAssertTrue(cache.thumbnails.keys.contains(sampleEventPass.id), "Key for thumbnail should still exist")
                XCTAssertFalse(mergedNewImage, "There should be no merge at this point")
                XCTAssertNil(error, "There should be no error")
                expectThumbnailNoMerge.fulfill()
            }
        }
        cache.thumbnail(for: sampleEventFail) { mergedNewImage, error in
            XCTAssertFalse(cache.thumbnails.keys.contains(sampleEventPass.id), "Key for thumbnail should not exist")
            XCTAssertTrue(mergedNewImage, "Placeholder image should have been merged")
            XCTAssertNotNil(error, "There should be an error")
            XCTAssertEqual(error?.localizedDescription, SGRequest().errorURL, "Error should be Invalid URL")
            expectThumbnailFail.fulfill()
        }
        
        waitForExpectations(timeout: 5)
    }
    
    func testFavoritesChangeStates() {
        
        let sampleID = 1234567
        let favorites = Favorites()
        
        let initialState = favorites.isFavorite(sampleID)
        var isToggledOn = false
        var isToggledOff = true
        XCTAssertEqual(initialState, false, "Sample ID should NOT be set as a favorite initially")
        
        favorites.toggle(sampleID)
        isToggledOn = favorites.isFavorite(sampleID)
        XCTAssertEqual(isToggledOn, true, "Sample ID SHOULD be set as a favorite now")
        
        favorites.toggle(sampleID)
        isToggledOff = favorites.isFavorite(sampleID)
        XCTAssertEqual(isToggledOff, false, "Sample ID should NOT be set as a favorite now")
        
        favorites.toggle(sampleID)
        isToggledOn = favorites.isFavorite(sampleID)
        XCTAssertEqual(isToggledOn, true, "Sample ID SHOULD be set as a favorite now")
        
        favorites.toggle(sampleID)
        isToggledOff = favorites.isFavorite(sampleID)
        XCTAssertEqual(isToggledOff, false, "Sample ID should NOT be set as a favorite now")
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}

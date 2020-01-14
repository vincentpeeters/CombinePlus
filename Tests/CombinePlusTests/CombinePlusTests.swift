import XCTest
@testable import CombinePlus
import Combine

@available(OSX 10.15, *)
final class CombinePlusTests: XCTestCase {
    
    
    @Published var ints: Set<Int> = []
    @Published var int = 0

    
    override func setUp() {
        self.int = 0
        self.ints = []
    }
    
    func testRemovalAndInsertionPublisher() {
        
        var lastInsertions: Set<Int> = []
        var lastRemovals: Set<Int> = []
        
        let insertionSubscribton = $ints
        .insertions()
            .sink { lastInsertions = $0; print($0) }
        
        let removalSubscribton = $ints
        .removals()
            .sink { lastRemovals = $0; print($0) }
        
        ints.insert(3)
        ints.insert(3)
        ints.insert(5)
        ints.remove(3)
        
        XCTAssertEqual(lastRemovals, [3])
        XCTAssertEqual(lastInsertions, [5])
        
    }
    
    func testMapLatestTwo() {
        
        var lastDuo: (Int, Int) = (0,0)
        
        let lastTwoSub = self.$int
            .mapLatestTwo { $0 }
            .sink { lastDuo = $0 }
        int = 0
        for i in 1...10 {
            self.int = i
            XCTAssertEqual(lastDuo.0, i-1)
            XCTAssertEqual(lastDuo.1, i)
        }
    }
    

    static var allTests = [
        ("testRemovalAndInsertionPublisher", testRemovalAndInsertionPublisher),
    ]
}


import Combine

typealias ValueDuo<Value> = (previousValue: [Value], currentValue: [Value])

@available(iOS 13.0, *)
@available(OSX 10.15, *)
extension Publisher {
    
    func mapLatestTwo<T>(_ closure: @escaping ( (previousOutput: Output,currentOutput: Output)) -> T) -> Publishers.Map<Publishers.Scan<Self, (Output, Output)>, T> where Output: Collection, Output: ExpressibleByArrayLiteral {
        let publisher = self.scan((Output(), Output())) { (previousCouple, newOutput) -> (previousOutput: Output,currentOutput: Output) in
            let previousOutput = previousCouple.1
            let newOutput = newOutput
            return (previousOutput, newOutput)
        }.map {
            closure($0)
        }
        return publisher
    }
    
    
    func onlyInsertions<Element>() -> Publishers.Map<Publishers.Scan<Self, (Set<Element>, Set<Element>)>, Set<Element>> where Output == Set<Element> {
        self.mapLatestTwo { (previousSet, currentSet) -> Set<Element> in
            currentSet.filter { !previousSet.contains($0) }
        }
    }
    
    func onlyRemovals<Element>() -> Publishers.Map<Publishers.Scan<Self, (Set<Element>, Set<Element>)>, Set<Element>> where Output == Set<Element> {
        self.mapLatestTwo { (previousSet, currentSet) -> Set<Element> in
            previousSet.filter { !currentSet.contains($0) }
        }
    }
    
}



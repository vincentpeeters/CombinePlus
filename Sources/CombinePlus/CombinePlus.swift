
import Combine

typealias ValueDuo<Value> = (previousValue: [Value], currentValue: [Value])

@available(iOS 13.0, *)
@available(OSX 10.15, *)
public extension Publisher {
    
    func mapLatestTwo<T>(_ closure: @escaping ( (previousOutput: Output,currentOutput: Output)) -> T) -> Publishers.CompactMap<Publishers.Scan<Self, (Self.Output?, Self.Output?)>, T>  {
        let publisher = self.scan((nil, nil)) { (previousCouple, newOutput) -> (previousOutput: Output?,currentOutput: Output?) in
            let previousOutput = previousCouple.1
            let newOutput = newOutput
            return (previousOutput, newOutput)
        }
        .compactMap{
            guard let first = $0.0, let second = $0.1 else { return nil }
            return (first, second)
        }
        .map {
            closure($0)
        }
        return publisher
    }
    
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
    
    
    func insertions<T>() -> Publishers.RemoveDuplicates<Publishers.Filter<Publishers.Map<Publishers.Scan<Self, (Self.Output, Self.Output)>, Set<T>>>> where Output: Collection, Output.Element == T, T: Hashable, Self.Output: ExpressibleByArrayLiteral {
        self.mapLatestTwo { (previousSet, currentSet) -> Set<T> in
            Set(currentSet.filter { !previousSet.contains($0) })
        }
        .filter { !$0.isEmpty }
        .removeDuplicates()
    }
    
    
    func removals<T>() -> Publishers.RemoveDuplicates<Publishers.Filter<Publishers.Map<Publishers.Scan<Self, (Self.Output, Self.Output)>, Set<T>>>> where Output: Collection, Output.Element == T, T: Hashable, Self.Output: ExpressibleByArrayLiteral {
        self.mapLatestTwo { (previousSet, currentSet) -> Set<T> in
            Set(previousSet.filter { !currentSet.contains($0) })
        }
        .filter { !$0.isEmpty }
        .removeDuplicates()
    }
    
    

    
}

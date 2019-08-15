[![License](https://img.shields.io/cocoapods/l/SwiftyXMLParser.svg?style=flat)]

# DVSequence

```
Framework for retrieving and storing data in Swift
```

## Demostration

```swift

struct Todo : Codable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

let todosApi = "https://jsonplaceholder.typicode.com/todos"
let sequenceData = SequenceData(url: todosApi)
DVSequence.shared.execute(sequenceData: sequenceData, 
                          completion: { (result: Result<[Todo], Error>) in
    switch result {
    case let .success(todos):
        print(todos)
    case let .failure(error):
        print(error.string)
    }
})
```

## Cocoapod

```
platform :ios, '12.2'

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/vallasd/CocoaPodSpecs'

target 'AppName' do
    pod 'DVSequence'
end
```

## Dependencies

[SwiftyRSA](https://github.com/TakeScoop/SwiftyRSA) 

## Contributors

```
David Vallas (david_vallas@yahoo.com)
```

## License

```
MIT
```

import Foundation
import XCPlayground
XCPSetExecutionShouldContinueIndefinitely()

//#Asynchronous to synchronous

//: Here we have an asynchronous function (the `async` function is just a small utility to make asynchronous calling easier, see in Utils.swift). Later in this playground I will ofter refer to input and output of a function where
//:
//: - input: All the parameters of a function (without completion handler on asynchronous functions)
//: - output: The return type of a synchronous function or the parameters of the completion handler of an asynchronous function
func addOneLater(n: Int, whenDone: Int -> Void) {
	async { whenDone(n + 1) }
}


//: With the global function `toSync` you can convert it to the synchronous equivalent easily. `toSync` is a higher-order function: It takes a function as a parameter and returns another function. Because closures are pretty much the same as functions, they can also be used here
let addOneNow = toSync(addOneLater)
addOneNow(10)

//: You can also call it like this
toSync(addOneLater)(5)


//: `toSync` is very heavily overloaded, so that it works with up to 4 inputs and 4 outputs, throwing and non-throwing functions, generic and non-generic error types
//: To demonstrate this, let's create a few different asynchronous functions

func avg(vals: [Double], scale: Double, completion: (Double?, String?) -> Void) {
	async {
		guard vals.count != 0 else { completion(nil, nil); return }
		let result = vals.reduce(0, combine: +) / Double(vals.count) * scale
		completion(result, "The average scaled by \(scale) is \(result)")
	}
}

func sayItLots(string: String, times: Int, space: Bool, completion: (String, String, String, String) -> Void) {
	async {
		let result = (space ? " " : "").join(Repeat(count: times, repeatedValue: string))
		completion(result, result, result, result)
	}
}

// Our own error type
enum Error : ErrorType {
	case CannotDivideOddByTwo
}

func half(n: Int, completionHandler: (Int?, Error?) -> Void) {
	async {
		if n % 2 == 0 {
			completionHandler(n / 2, nil)
		} else {
			completionHandler(nil, Error.CannotDivideOddByTwo)
		}
	}
}

func iLikeThrowing(completionHandler: ErrorType? -> Void) {
	async {
		completionHandler(NSError(domain: "MyOne", code: 42, userInfo: nil))
	}
}

//: Now let's convert these to synchronous variants
let syncAvg = toSync(avg)
let syncSayLots = toSync(sayItLots)
let syncHalf = toSync(half)
let syncThrowing = toSynct(iLikeThrowing)

//: As you can see from the types of the new functions, asynchronous functions that take a completion handler with an optional error as the last argument become throwing functions automatically. All the other arguments of the completion handler have to be optionals for this to work, which is fine since you generally can't provide an output when an error occured. The opposite is often true as well: When no error occured, the outputs aren't nil. However because the underlying implementation of your function isn't forced to provide values for every output, the return types of the newly synchronous function are implicitly unwrapped optionals. This means that if your implementation returns nil for some output value (which is completely fine) even though no error occured, it doesn't crash. For every other case where the output gets populated for sure, the convenience of implicitly unwrapped optionals is your friend.
//:
//: We can call these synchronous variants just like usual functions. As you can see, named parameters are not available as that would exceed the languages abilities.
syncAvg([1, 2, 5, 8], 2)
syncSayLots("Hey you!", 3, true)
do {
	try syncHalf(4)
	try syncThrowing()
} catch {
	error
}

//: There are also functions that don't automatically start when you call them, but instead return an object waiting for a call or ones that need some action for them to activate. A good example of this is the `dataTaskWithURL:` function of `NSURLSession` which returns an NSURLSessionDataTask that has to be started using its `resume` method.
//:
//: The `toSync` has an optional closure as the last parameter. This closure takes the value returned from the asynchronous function for you to do something with it. With this in mind you can create a synchronous network task
let getData = toSync(NSURLSession.sharedSession().dataTaskWithURL) { $0.resume() }

//: This newly created `getData` function is now usable without any call to NSURLSession. If you modify the url to something non-existant an error will be thrown synchronously

do {
	let (data, response) = try getData(NSURL(string: "https://www.google.com/")!)
	response
} catch {
	error
}



//: `toSync` can be used with the following amount of input/outputs:
//:
//: - Non-error: 0 to 4 inputs, any number of outputs
//: - Error: 0 to 4 inputs, 0 to 4 output









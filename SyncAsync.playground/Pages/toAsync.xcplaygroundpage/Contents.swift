//: [Previous](@previous)
import XCPlayground
XCPExecutionShouldContinueIndefinitely()

//: The `toAsync` function is the reverse of the `toSync` function. It takes a synchronous function and returns its asynchronous variant
//: Let's create a synchronous function

func add(a: Int, b: Int) -> Int {
	return a + b
}

//: To make it asynchronous, just call `toAsync` on it. The resulting function takes the arguments of the synchronous function plus a completion handler
toAsync(add)(1, 2) { result in
	print("Added: \(result)")
}

waitABit() // Waits a bit so that the outputs don't get messed up (because it's asynchronous), see Utils.swift

//: Like the `toSync` function, the `toAsync` function is heavily overloaded for it to be able to take up to four inputs and an unlimited amount of outputs. To demonstrate this, we'll create a few synchronous functions

func sayHi(to: String, isBuddy: Bool) -> (speech: String, friendly: Bool) {
	switch (to, isBuddy) {
	case ("Bob", _): return ("...", false)
	case (_, true): return ("Hey man", true)
	case (let s, _): return ("Hello, \(s)", true)
	}
}

func product(from: Int, through: Int, steps: Int) -> Int {
	return stride(from: from, through: through, by: steps).reduce(1, combine: *)
}

// Custom error type
enum Error: ErrorType {
	case LessThanZero
	case DivisionByZero
}

func factorial(n: Int) throws -> Int {
	guard n >= 0 else { throw Error.LessThanZero }
	return n < 2 ? 1 : try factorial(n - 1) * n
}

func divide12345By(val: Double) throws -> (Double, Double, Double, Double, Double) {
	guard val != 0 else { throw Error.DivisionByZero }
	return (1 / val, 2 / val, 3 / val, 4 / val, 5 / val)
}

//: Simply call `toAsync` to convert these to asynchronoous functions

let asyncHi = toAsync(sayHi)
let asyncProd = toAsync(product)
let asyncFactorial = toAsync(factorial)
let asyncDivision = toAsync(divide12345By)

//: As you can see from the types, throwing functions automatically get converted into functions that take a completion handler, executed when succeeded, and an error handler, executed when an error occured. As with `toSync`, parameter names cannot be preserved.

asyncHi("Paul", true, completionHandler: debugPrint)
waitABit()

asyncProd(4, 10, 2, completionHandler: debugPrint)
waitABit()

asyncFactorial(-3, completionHandler: debugPrint, errorHandler: debugPrint)
waitABit()

asyncDivision(19, completionHandler: debugPrint, errorHandler: debugPrint)
waitABit()


//: And yes if you really want to, you can chain `toAsync` and `toSync` to a certain extent (this has no use whatsoever)

toSync(toAsync(toSync(toAsync(sayHi))))("Bob", false)

//: [Next](@next)

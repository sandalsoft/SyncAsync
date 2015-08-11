//import Foundation
//
//
///*
//
//TODO:
//
// - does it work with implicitly unwrapped optionals or non-optionals in completion handler?
// - function to generate functions toAsync and toSync
// - toAsync with optional queue
// - reference cycle?
//
//DONE:
//
// - Completion handler + error handler on toSync
//
//
//*/
//
//
//
//
//// MARK: toAsync
//
//// MARK: Non-throwing
//
//public func toAsync<O>(sync: Void -> O) -> (completionHandler: O -> Void) -> Void {
//	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
//	return { handler in dispatch_async(queue) { handler(sync()) } }
//}
//
//public func toAsync<I, O>(sync: I -> O) -> (I, completionHandler: O -> Void) -> Void {
//	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
//	return { i, handler in dispatch_async(queue) { handler(sync(i)) } }
//}
//
//public func toAsync<I1, I2, O>(sync: (I1, I2) -> O) -> (I1, I2, completionHandler: O -> Void) -> Void {
//	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
//	return { i1, i2, handler in dispatch_async(queue) { handler(sync(i1, i2)) } }
//}
//
//public func toAsync<I1, I2, I3, O>(sync: (I1, I2, I3) -> O) -> (I1, I2, I3, completionHandler: O -> Void) -> Void {
//	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
//	return { i1, i2, i3, handler in dispatch_async(queue) { handler(sync(i1, i2, i3)) } }
//}
//
//public func toAsync<I1, I2, I3, I4, O>(sync: (I1, I2, I3, I4) -> O) -> (I1, I2, I3, I4, completionHandler: O -> Void) -> Void {
//	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
//	return { i1, i2, i3, i4, handler in dispatch_async(queue) { handler(sync(i1, i2, i3, i4)) } }
//}
//
//// MARK: Throwing
//
//public func toAsync<O>(sync: Void throws -> O) -> (completionHandler: O -> Void, errorHandler: ErrorType -> Void) -> Void {
//	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
//	return { ch, eh in dispatch_async(queue) {
//		do { try ch(sync()) }
//		catch { eh(error) }
//	}}
//}
//
//public func toAsync<I, O>(sync: I throws -> O) -> (I, completionHandler: O -> Void, errorHandler: ErrorType -> Void) -> Void {
//	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
//	return { i, ch, eh in dispatch_async(queue) {
//		do { try ch(sync(i)) }
//		catch { eh(error) }
//	}}
//}
//
//public func toAsync<I1, I2, O>(sync: (I1, I2) throws -> O) -> (I1, I2, completionHandler: O -> Void, errorHandler: ErrorType -> Void) -> Void {
//	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
//	return { i1, i2, ch, eh in dispatch_async(queue) {
//		do { try ch(sync(i1, i2)) }
//		catch { eh(error) }
//	}}
//}
//
//public func toAsync<I1, I2, I3, O>(sync: (I1, I2, I3) throws -> O) -> (I1, I2, I3, completionHandler: O -> Void, errorHandler: ErrorType -> Void) -> Void {
//	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
//	return { i1, i2, i3, ch, eh in dispatch_async(queue) {
//		do { try ch(sync(i1, i2, i3)) }
//		catch { eh(error) }
//	}}
//}
//
//public func toAsync<I1, I2, I3, I4, O>(sync: (I1, I2, I3, I4) throws -> O) -> (I1, I2, I3, I4, completionHandler: O -> Void, errorHandler: ErrorType -> Void) -> Void {
//	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
//	return { i1, i2, i3, i4, ch, eh in dispatch_async(queue) {
//		do { try ch(sync(i1, i2, i3, i4)) }
//		catch { eh(error) }
//	}}
//}
//
//
//// MARK: - toSync
//
//// MARK: Non-throwing
//
//
//
//private func toSyncPrivate<O, R>(start: R -> (), async: (completionHandler: O -> Void) -> R) -> Void -> O {
//	let semaphore = dispatch_semaphore_create(0)
//	return {
//		var output: O!
//		
//		start(async() {
//			output = $0
//			dispatch_semaphore_signal(semaphore)
//		})
//		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
//		
//		return output
//	}
//}
//
//
//
//private func toSyncPrivate<I, O, R>(start: R -> (), async: (I, completionHandler: O -> Void) -> R) -> I -> O {
//	let semaphore = dispatch_semaphore_create(0)
//	return { input in
//		var output: O!
//		
//		start(async(input) {
//			output = $0
//			dispatch_semaphore_signal(semaphore)
//		})
//		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
//		
//		return output
//	}
//}
//
//
//// With output
//public func toSync<O, R>(async: (completionHandler: O -> Void) -> R, start: R -> () = {_ in}) -> Void -> O {
//	return toSyncPrivate(start, async: async)
//}
//
//public func toSync<I, O, R>(async: (I, completionHandler: O -> Void) -> R, start: R -> () = {_ in}) -> I -> O {
//	return toSyncPrivate(start, async: async)
//}
//
//public func toSync<I1, I2, O, R>(f: (I1, I2, completionHandler: O -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) -> O {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h($0) } }
//}
//
//public func toSync<I1, I2, I3, O, R>(f: (I1, I2, I3, completionHandler: O -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) -> O {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h($0) } }
//}
//
//public func toSync<I1, I2, I3, I4, O, R>(f: (I1, I2, I3, I4, completionHandler: O -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) -> O {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h($0) } }
//}
//
//
//// MARK: Throwing
//
//// Non-generic error
//
//private func toSyncPrivate<R>(start: R -> (), async: (completionHandler: ErrorType? -> Void) -> R) -> Void throws -> Void {
//	let semaphore = dispatch_semaphore_create(0)
//	return {
//		var error: ErrorType?
//		
//		start(async() {
//			error = $0
//			dispatch_semaphore_signal(semaphore)
//			})
//		
//		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
//		
//		if let error = error { throw error }
//	}
//}
//
//private func toSyncPrivate<O, R>(start: R -> (), async: (completionHandler: (O, ErrorType?) -> Void) -> R) -> Void throws -> O {
//	let semaphore = dispatch_semaphore_create(0)
//	return {
//		var output: O!
//		var error: ErrorType?
//		
//		start(async() {
//			(output, error) = ($0, $1)
//			dispatch_semaphore_signal(semaphore)
//			})
//		
//		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
//		
//		if let error = error { throw error }
//		return output
//	}
//}
//
//
//private func toSyncPrivate<I, R>(start: R -> (), async: (I, completionHandler: ErrorType? -> Void) -> R) -> I throws -> Void {
//	let semaphore = dispatch_semaphore_create(0)
//	return { input in
//		var error: ErrorType?
//		
//		start(async(input) {
//			error = $0
//			dispatch_semaphore_signal(semaphore)
//		})
//		
//		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
//		
//		if let error = error { throw error }
//	}
//}
//
//private func toSyncPrivate<I, O, R>(start: R -> (), async: (I, completionHandler: (O, ErrorType?) -> Void) -> R) -> I throws -> O {
//	let semaphore = dispatch_semaphore_create(0)
//	return { input in
//		var output: O!
//		var error: ErrorType?
//		
//		start(async(input) {
//			(output, error) = ($0, $1)
//			dispatch_semaphore_signal(semaphore)
//		})
//		
//		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
//		
//		if let error = error { throw error }
//		return output
//	}
//}
//
//// Without output
//public func toSynct<R>(f: (completionHandler: ErrorType? -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> Void {
//	return toSyncPrivate(start, async: f)
//}
//
//public func toSynct<I, R>(f: (I, completionHandler: ErrorType? -> Void) -> R, start: R -> () = {_ in }) -> I throws -> Void {
//	return toSyncPrivate(start, async: f)
//}
//
//public func toSync<I1, I2, R>(f: (I1, I2, completionHandler: ErrorType? -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> Void {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h($0) } }
//}
//
//public func toSync<I1, I2, I3, R>(f: (I1, I2, I3, completionHandler: ErrorType? -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> Void {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h($0) } }
//}
//
//public func toSync<I1, I2, I3, I4, R>(f: (I1, I2, I3, I4, completionHandler: ErrorType? -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> Void {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h($0) } }
//}
//
//public typealias N = NilLiteralConvertible
//
//// With output
//public func toSyncaaa<O : N, R>(f: (completionHandler: (O, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> O {
//	return toSyncPrivate(start) { h in f() { h($0, $1) } }
//}
//
//public func toSync<I, O : N, R>(f: (I, completionHandler: (O, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> I throws -> O {
//	return toSyncPrivate(start) { i, h in f(i) { h($0, $1) } }
//}
//
//public func toSync<I1, I2, O : N, R>(f: (I1, I2, completionHandler: (O, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> O {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h($0, $1) } }
//}
//
//public func toSync<I1, I2, I3, O : N, R>(f: (I1, I2, I3, completionHandler: (O, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> O {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h($0, $1) } }
//}
//
//public func toSync<I1, I2, I3, I4, O : N, R>(f: (I1, I2, I3, I4, completionHandler: (O, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> O {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h($0, $1) } }
//}
//
//
//public func toSync<O1 : N, O2 : N, R>(f: (completionHandler: (O1, O2, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> (O1, O2) {
//	return toSyncPrivate(start) { h in f() { h(($0, $1), $2) } }
//}
//
//public func toSync<I, O1 : N, O2 : N, R>(f: (I, completionHandler: (O1, O2, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> I throws -> (O1, O2) {
//	return toSyncPrivate(start) { i, h in f(i) { h(($0, $1), $2) } }
//}
//
//public func toSync<I1, I2, O1 : N, O2 : N, R>(f: (I1, I2, completionHandler: (O1, O2, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> (O1, O2) {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h(($0, $1), $2) } }
//}
//
//public func toSync<I1, I2, I3, O1 : N, O2 : N, R>(f: (I1, I2, I3, completionHandler: (O1, O2, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> (O1, O2) {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h(($0, $1), $2) } }
//}
//
//public func toSync<I1, I2, I3, I4, O1 : N, O2 : N, R>(f: (I1, I2, I3, I4, completionHandler: (O1, O2, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> (O1, O2) {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h(($0, $1), $2) } }
//}
//
//
//public func toSync<O1 : N, O2 : N, O3 : N, R>(f: (completionHandler: (O1, O2, O3, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> (O1, O2, O3) {
//	return toSyncPrivate(start) { h in f() { h(($0, $1, $2), $3) } }
//}
//
//public func toSync<I, O1 : N, O2 : N, O3 : N, R>(f: (I, completionHandler: (O1, O2, O3, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> I throws -> (O1, O2, O3) {
//	return toSyncPrivate(start) { i, h in f(i) { h(($0, $1, $2), $3) } }
//}
//
//public func toSync<I1, I2, O1 : N, O2 : N, O3 : N, R>(f: (I1, I2, completionHandler: (O1, O2, O3, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> (O1!, O2!, O3!) {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h(($0, $1, $2), $3) } }
//}
//
//public func toSync<I1, I2, I3, O1 : N, O2 : N, O3 : N, R>(f: (I1, I2, I3, completionHandler: (O1, O2, O3, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> (O1, O2, O3) {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h(($0, $1, $2), $3) } }
//}
//
//public func toSync<I1, I2, I3, I4, O1 : N, O2 : N, O3 : N, R>(f: (I1, I2, I3, I4, completionHandler: (O1, O2, O3, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> (O1, O2, O3) {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h(($0, $1, $2), $3) } }
//}
//
//
//public func toSync<O1 : N, O2 : N, O3 : N, O4 : N, R>(f: (completionHandler: (O1, O2, O3, O4, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> (O1, O2, O3, O4) {
//	return toSyncPrivate(start) { h in f() { h(($0, $1, $2, $3), $4) } }
//}
//
//public func toSync<I, O1 : N, O2 : N, O3 : N, O4 : N, R>(f: (I, completionHandler: (O1, O2, O3, O4, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> I throws -> (O1, O2, O3, O4) {
//	return toSyncPrivate(start) { i, h in f(i) { h(($0, $1, $2, $3), $4) } }
//}
//
//public func toSync<I1, I2, O1 : N, O2 : N, O3 : N, O4 : N, R>(f: (I1, I2, completionHandler: (O1, O2, O3, O4, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> (O1, O2, O3, O4) {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h(($0, $1, $2, $3), $4) } }
//}
//
//public func toSync<I1, I2, I3, O1 : N, O2 : N, O3 : N, O4 : N, R>(f: (I1, I2, I3, completionHandler: (O1, O2, O3, O4, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> (O1, O2, O3, O4) {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h(($0, $1, $2, $3), $4) } }
//}
//
//public func toSync<I1, I2, I3, I4, O1 : N, O2 : N, O3 : N, O4 : N, R>(f: (I1, I2, I3, I4, completionHandler: (O1, O2, O3, O4, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> (O1, O2, O3, O4) {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h(($0, $1, $2, $3), $4) } }
//}
//
//
//// Generic error
//
//private func toSyncPrivate<I, R, E: ErrorType>(start: R -> (), async: (I, completionHandler: E? -> Void) -> R) -> I throws -> Void {
//	let semaphore = dispatch_semaphore_create(0)
//	return { input in
//		var error: E?
//		
//		start(async(input) {
//			error = $0
//			dispatch_semaphore_signal(semaphore)
//			})
//		
//		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
//		
//		if let error = error { throw error }
//	}
//}
//
//private func toSyncPrivate<O, R, E: ErrorType>(start: R -> (), async: (completionHandler: (O, E?) -> Void) -> R) -> Void throws -> O {
//	let semaphore = dispatch_semaphore_create(0)
//	return {
//		var output: O!
//		var error: E?
//		
//		start(async() {
//			(output, error) = ($0, $1)
//			dispatch_semaphore_signal(semaphore)
//			})
//		
//		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
//		
//		if let error = error { throw error }
//		return output
//	}
//}
//
//private func toSyncPrivate<R, E: ErrorType>(start: R -> (), async: (completionHandler: E? -> Void) -> R) -> Void throws -> Void {
//	let semaphore = dispatch_semaphore_create(0)
//	return {
//		var error: E?
//		
//		start(async() {
//			error = $0
//			dispatch_semaphore_signal(semaphore)
//		})
//		
//		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
//		
//		if let error = error { throw error }
//	}
//}
//
//private func toSyncPrivate<I, O, R, E: ErrorType>(start: R -> (), async: (I, completionHandler: (O, E?) -> Void) -> R) -> I throws -> O {
//	let semaphore = dispatch_semaphore_create(0)
//	return { input in
//		var output: O!
//		var error: E?
//		
//		start(async(input) {
//			(output, error) = ($0, $1)
//			dispatch_semaphore_signal(semaphore)
//			})
//		
//		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
//		
//		if let error = error { throw error }
//		return output
//	}
//}
//
//// Without output
//public func toSync<R, E: ErrorType>(f: (completionHandler: E? -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> Void {
//	return toSyncPrivate(start) { h in f() { h($0) } }
//}
//
//public func toSync<I, R, E: ErrorType>(f: (I, completionHandler: E? -> Void) -> R, start: R -> () = {_ in }) -> I throws -> Void {
//	return toSyncPrivate(start) { i, h in f(i) { h($0) } }
//}
//
//public func toSync<I1, I2, R, E: ErrorType>(f: (I1, I2, completionHandler: E? -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> Void {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h($0) } }
//}
//
//public func toSync<I1, I2, I3, R, E: ErrorType>(f: (I1, I2, I3, completionHandler: E? -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> Void {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h($0) } }
//}
//
//public func toSync<I1, I2, I3, I4, R, E: ErrorType>(f: (I1, I2, I3, I4, completionHandler: E? -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> Void {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h($0) } }
//}
//
//
//// With output
//public func toSync<O : N, R, E: ErrorType>(f: (completionHandler: (O, E?) -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> O {
//	return toSyncPrivate(start) { h in f() { h($0, $1) } }
//}
//
//public func toSync<I, O : N, R, E: ErrorType>(f: (I, completionHandler: (O, E?) -> Void) -> R, start: R -> () = {_ in }) -> I throws -> O {
//	return toSyncPrivate(start) { i, h in f(i) { h($0, $1) } }
//}
//
//public func toSync<I1, I2, O : N, R, E: ErrorType>(f: (I1, I2, completionHandler: (O, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> O {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h($0, $1) } }
//}
//
//public func toSync<I1, I2, I3, O : N, R, E: ErrorType>(f: (I1, I2, I3, completionHandler: (O, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> O {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h($0, $1) } }
//}
//
//public func toSync<I1, I2, I3, I4, O : N, R, E: ErrorType>(f: (I1, I2, I3, I4, completionHandler: (O, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> O {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h($0, $1) } }
//}
//
//
//public func toSync<O1 : N, O2 : N, R, E: ErrorType>(f: (completionHandler: (O1, O2, E?) -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> (O1, O2) {
//	return toSyncPrivate(start) { h in f() { h(($0, $1), $2) } }
//}
//
//public func toSync<I, O1 : N, O2 : N, R, E: ErrorType>(f: (I, completionHandler: (O1, O2, E?) -> Void) -> R, start: R -> () = {_ in }) -> I throws -> (O1, O2) {
//	return toSyncPrivate(start) { i, h in f(i) { h(($0, $1), $2) } }
//}
//
//public func toSync<I1, I2, O1 : N, O2 : N, R, E: ErrorType>(f: (I1, I2, completionHandler: (O1, O2, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> (O1, O2) {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h(($0, $1), $2) } }
//}
//
//public func toSync<I1, I2, I3, O1 : N, O2 : N, R, E: ErrorType>(f: (I1, I2, I3, completionHandler: (O1, O2, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> (O1, O2) {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h(($0, $1), $2) } }
//}
//
//public func toSync<I1, I2, I3, I4, O1 : N, O2 : N, R, E: ErrorType>(f: (I1, I2, I3, I4, completionHandler: (O1, O2, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> (O1, O2) {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h(($0, $1), $2) } }
//}
//
//
//public func toSync<O1 : N, O2 : N, O3 : N, R, E: ErrorType>(f: (completionHandler: (O1, O2, O3, E?) -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> (O1, O2, O3) {
//	return toSyncPrivate(start) { h in f() { h(($0, $1, $2), $3) } }
//}
//
//public func toSync<I, O1 : N, O2 : N, O3 : N, R, E: ErrorType>(f: (I, completionHandler: (O1, O2, O3, E?) -> Void) -> R, start: R -> () = {_ in }) -> I throws -> (O1, O2, O3) {
//	return toSyncPrivate(start) { i, h in f(i) { h(($0, $1, $2), $3) } }
//}
//
//public func toSync<I1, I2, O1 : N, O2 : N, O3 : N, R, E: ErrorType>(f: (I1, I2, completionHandler: (O1, O2, O3, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> (O1, O2, O3) {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h(($0, $1, $2), $3) } }
//}
//
//public func toSync<I1, I2, I3, O1 : N, O2 : N, O3 : N, R, E: ErrorType>(f: (I1, I2, I3, completionHandler: (O1, O2, O3, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> (O1, O2, O3) {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h(($0, $1, $2), $3) } }
//}
//
//public func toSync<I1, I2, I3, I4, O1 : N, O2 : N, O3 : N, R, E: ErrorType>(f: (I1, I2, I3, I4, completionHandler: (O1, O2, O3, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> (O1, O2, O3) {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h(($0, $1, $2), $3) } }
//}
//
//
//public func toSync<O1 : N, O2 : N, O3 : N, O4 : N, R, E: ErrorType>(f: (completionHandler: (O1, O2, O3, O4, E?) -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> (O1!, O2!, O3!, O4!) {
//	return toSyncPrivate(start) { h in f() { h(($0, $1, $2, $3), $4) } }
//}
//
//public func toSync<I, O1 : N, O2 : N, O3 : N, O4 : N, R, E: ErrorType>(f: (I, completionHandler: (O1, O2, O3, O4, E?) -> Void) -> R, start: R -> () = {_ in }) -> I throws -> (O1!, O2!, O3!, O4!) {
//	return toSyncPrivate(start) { i, h in f(i) { h(($0, $1, $2, $3), $4) } }
//}
//
//public func toSync<I1, I2, O1 : N, O2 : N, O3 : N, O4 : N, R, E: ErrorType>(f: (I1, I2, completionHandler: (O1, O2, O3, O4, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> (O1!, O2!, O3!, O4!) {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h(($0, $1, $2, $3), $4) } }
//}
//
//public func toSync<I1, I2, I3, O1 : N, O2 : N, O3 : N, O4 : N, R, E: ErrorType>(f: (I1, I2, I3, completionHandler: (O1, O2, O3, O4, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> (O1, O2, O3, O4) {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h(($0, $1, $2, $3), $4) } }
//}
//
//public func toSync<I1, I2, I3, I4, O1 : N, O2 : N, O3 : N, O4 : N, R, E: ErrorType>(f: (I1, I2, I3, I4, completionHandler: (O1, O2, O3, O4, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> (O1, O2, O3, O4) {
//	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h(($0, $1, $2, $3), $4) } }
//}
//
//
//
// Completion handler + error handler

// Non-generic error

private func toSyncPrivate<R>(start: R -> (), async: (completionHandler: Void -> Void, errorHandler: ErrorType -> Void) -> R) -> Void throws -> Void {
	let semaphore = dispatch_semaphore_create(0)
	return {
		var error: ErrorType?
		
		start(async(completionHandler: {
			dispatch_semaphore_signal(semaphore)
			}) {
				error = $0
				dispatch_semaphore_signal(semaphore)
			})
		
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		
		if let error = error { throw error }
	}
}

private func toSyncPrivate<O, R>(start: R -> (), async: (completionHandler: O -> Void, errorHandler: ErrorType -> Void) -> R) -> Void throws -> O {
	let semaphore = dispatch_semaphore_create(0)
	return {
		var output: O!
		var error: ErrorType?
		
		start(async(completionHandler: {
			output = $0
			dispatch_semaphore_signal(semaphore)
			}) {
				error = $0
				dispatch_semaphore_signal(semaphore)
			})
		
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		
		if let error = error { throw error }
		return output
	}
}


private func toSyncPrivate<I, R>(start: R -> (), async: (I, completionHandler: Void -> Void, errorHandler: ErrorType -> Void) -> R) -> I throws -> Void {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?
		
		start(async(input, completionHandler: {
			dispatch_semaphore_signal(semaphore)
			}) {
				error = $0
				dispatch_semaphore_signal(semaphore)
			})
		
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		
		if let error = error { throw error }
	}
}

private func toSyncPrivate<I, O, R>(start: R -> (), async: (I, completionHandler: O -> Void, errorHandler: ErrorType -> Void) -> R) -> I throws -> O {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var output: O!
		var error: ErrorType?
		
		start(async(input, completionHandler: {
			output = $0
			dispatch_semaphore_signal(semaphore)
			}) {
				error = $0
				dispatch_semaphore_signal(semaphore)
			})
		
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		
		if let error = error { throw error }
		return output
	}
}


// Without output

public func toSync<R>(f: (completionHandler: Void -> Void, errorHandler: ErrorType -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> Void {
	return toSyncPrivate(start, async: f)
}

public func toSync<I, R>(f: (I, completionHandler: Void -> Void, errorHandler: ErrorType -> Void) -> R, start: R -> () = {_ in }) -> I throws -> Void {
	return toSyncPrivate(start, async: f)
}

public func toSync<I1, I2, R>(f: (I1, I2, completionHandler: Void -> Void, errorHandler: ErrorType -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> Void {
	return toSyncPrivate(start) { i, c, e in f(i.0, i.1, completionHandler: c, errorHandler: e) }
}

public func toSync<I1, I2, I3, R>(f: (I1, I2, I3, completionHandler: Void -> Void, errorHandler: ErrorType -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> Void {
	return toSyncPrivate(start) { i, c, e in f(i.0, i.1, i.2, completionHandler: c, errorHandler: e) }
}

public func toSync<I1, I2, I3, I4, R>(f: (I1, I2, I3, I4, completionHandler: Void -> Void, errorHandler: ErrorType -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> Void {
	return toSyncPrivate(start) { i, c, e in f(i.0, i.1, i.2, i.3, completionHandler: c, errorHandler: e) }
}

// With output

public func toSync<O, R>(f: (completionHandler: O -> Void, errorHandler: ErrorType -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> O {
	return toSyncPrivate(start, async: f)
}

public func toSync<I, O, R>(f: (I, completionHandler: O -> Void, errorHandler: ErrorType -> Void) -> R, start: R -> () = {_ in }) -> I throws -> O {
	return toSyncPrivate(start, async: f)
}

public func toSync<I1, I2, O, R>(f: (I1, I2, completionHandler: O -> Void, errorHandler: ErrorType -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> O {
	return toSyncPrivate(start) { i, c, e in f(i.0, i.1, completionHandler: c, errorHandler: e) }
}

public func toSync<I1, I2, I3, O, R>(f: (I1, I2, I3, completionHandler: O -> Void, errorHandler: ErrorType -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> O {
	return toSyncPrivate(start) { i, c, e in f(i.0, i.1, i.2, completionHandler: c, errorHandler: e) }
}

public func toSync<I1, I2, I3, I4, O, R>(f: (I1, I2, I3, I4, completionHandler: O -> Void, errorHandler: ErrorType -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> O {
	return toSyncPrivate(start) { i, c, e in f(i.0, i.1, i.2, i.3, completionHandler: c, errorHandler: e) }
}



// Generic error

private func toSyncPrivate<R, E: ErrorType>(start: R -> (), async: (completionHandler: Void -> Void, errorHandler: E -> Void) -> R) -> Void throws -> Void {
	let semaphore = dispatch_semaphore_create(0)
	return {
		var error: E?
		
		start(async(completionHandler: {
			dispatch_semaphore_signal(semaphore)
			}) {
				error = $0
				dispatch_semaphore_signal(semaphore)
			})
		
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		
		if let error = error { throw error }
	}
}

private func toSyncPrivate<O, R, E: ErrorType>(start: R -> (), async: (completionHandler: O -> Void, errorHandler: E -> Void) -> R) -> Void throws -> O {
	let semaphore = dispatch_semaphore_create(0)
	return {
		var output: O!
		var error: E?
		
		start(async(completionHandler: {
			output = $0
			dispatch_semaphore_signal(semaphore)
			}) {
				error = $0
				dispatch_semaphore_signal(semaphore)
			})
		
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		
		if let error = error { throw error }
		return output
	}
}


private func toSyncPrivate<I, R, E: ErrorType>(start: R -> (), async: (I, completionHandler: Void -> Void, errorHandler: E -> Void) -> R) -> I throws -> Void {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?
		
		start(async(input, completionHandler: {
			dispatch_semaphore_signal(semaphore)
			}) {
				error = $0
				dispatch_semaphore_signal(semaphore)
			})
		
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		
		if let error = error { throw error }
	}
}

private func toSyncPrivate<I, O, R, E: ErrorType>(start: R -> (), async: (I, completionHandler: O -> Void, errorHandler: E -> Void) -> R) -> I throws -> O {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var output: O!
		var error: E?
		
		start(async(input, completionHandler: {
			output = $0
			dispatch_semaphore_signal(semaphore)
			}) {
				error = $0
				dispatch_semaphore_signal(semaphore)
			})
		
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		
		if let error = error { throw error }
		return output
	}
}


// Without output

public func toSync<R, E: ErrorType>(f: (completionHandler: Void -> Void, errorHandler: E -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> Void {
	return toSyncPrivate(start, async: f)
}

public func toSync<I, R, E: ErrorType>(f: (I, completionHandler: Void -> Void, errorHandler: E -> Void) -> R, start: R -> () = {_ in }) -> I throws -> Void {
	return toSyncPrivate(start, async: f)
}

public func toSync<I1, I2, R, E: ErrorType>(f: (I1, I2, completionHandler: Void -> Void, errorHandler: E -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> Void {
	return toSyncPrivate(start) { i, c, e in f(i.0, i.1, completionHandler: c, errorHandler: e) }
}

public func toSync<I1, I2, I3, R, E: ErrorType>(f: (I1, I2, I3, completionHandler: Void -> Void, errorHandler: E -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> Void {
	return toSyncPrivate(start) { i, c, e in f(i.0, i.1, i.2, completionHandler: c, errorHandler: e) }
}

public func toSync<I1, I2, I3, I4, R, E: ErrorType>(f: (I1, I2, I3, I4, completionHandler: Void -> Void, errorHandler: E -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> Void {
	return toSyncPrivate(start) { i, c, e in f(i.0, i.1, i.2, i.3, completionHandler: c, errorHandler: e) }
}

// With output

public func toSync<O, R, E: ErrorType>(f: (completionHandler: O -> Void, errorHandler: E -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> O {
	return toSyncPrivate(start, async: f)
}

public func toSync<I, O, R, E: ErrorType>(f: (I, completionHandler: O -> Void, errorHandler: E -> Void) -> R, start: R -> () = {_ in }) -> I throws -> O {
	return toSyncPrivate(start, async: f)
}

public func toSync<I1, I2, O, R, E: ErrorType>(f: (I1, I2, completionHandler: O -> Void, errorHandler: E -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> O {
	return toSyncPrivate(start) { i, c, e in f(i.0, i.1, completionHandler: c, errorHandler: e) }
}

public func toSync<I1, I2, I3, O, R, E: ErrorType>(f: (I1, I2, I3, completionHandler: O -> Void, errorHandler: E -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> O {
	return toSyncPrivate(start) { i, c, e in f(i.0, i.1, i.2, completionHandler: c, errorHandler: e) }
}

public func toSync<I1, I2, I3, I4, O, R, E: ErrorType>(f: (I1, I2, I3, I4, completionHandler: O -> Void, errorHandler: E -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> O {
	return toSyncPrivate(start) { i, c, e in f(i.0, i.1, i.2, i.3, completionHandler: c, errorHandler: e) }
}












import Foundation

public func toAsync<O>(f: () throws -> O) -> (completionHandler: O -> (), errorHandler: ErrorType -> ()) -> () {
	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
	return { ch, eh in dispatch_async(queue) {
		do { try ch(f()) }
		catch { eh(error) }}}
}
public func toAsync<I0, O>(f: (I0) throws -> O) -> (I0, completionHandler: O -> (), errorHandler: ErrorType -> ()) -> () {
	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
	return { i0, ch, eh in dispatch_async(queue) {
		do { try ch(f(i0)) }
		catch { eh(error) }}}
}
public func toAsync<I0, I1, O>(f: (I0, I1) throws -> O) -> (I0, I1, completionHandler: O -> (), errorHandler: ErrorType -> ()) -> () {
	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
	return { i0, i1, ch, eh in dispatch_async(queue) {
		do { try ch(f(i0, i1)) }
		catch { eh(error) }}}
}
public func toAsync<I0, I1, I2, O>(f: (I0, I1, I2) throws -> O) -> (I0, I1, I2, completionHandler: O -> (), errorHandler: ErrorType -> ()) -> () {
	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
	return { i0, i1, i2, ch, eh in dispatch_async(queue) {
		do { try ch(f(i0, i1, i2)) }
		catch { eh(error) }}}
}
public func toAsync<I0, I1, I2, I3, O>(f: (I0, I1, I2, I3) throws -> O) -> (I0, I1, I2, I3, completionHandler: O -> (), errorHandler: ErrorType -> ()) -> () {
	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
	return { i0, i1, i2, i3, ch, eh in dispatch_async(queue) {
		do { try ch(f(i0, i1, i2, i3)) }
		catch { eh(error) }}}
}




public func toAsync<O>(f: () -> O) -> (completionHandler: O -> ()) -> () {
	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
	return { handler in dispatch_async(queue) { handler(f()) } }
}
public func toAsync<I0, O>(f: (I0) -> O) -> (I0, completionHandler: O -> ()) -> () {
	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
	return { i0, handler in dispatch_async(queue) { handler(f(i0)) } }
}
public func toAsync<I0, I1, O>(f: (I0, I1) -> O) -> (I0, I1, completionHandler: O -> ()) -> () {
	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
	return { i0, i1, handler in dispatch_async(queue) { handler(f(i0, i1)) } }
}
public func toAsync<I0, I1, I2, O>(f: (I0, I1, I2) -> O) -> (I0, I1, I2, completionHandler: O -> ()) -> () {
	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
	return { i0, i1, i2, handler in dispatch_async(queue) { handler(f(i0, i1, i2)) } }
}
public func toAsync<I0, I1, I2, I3, O>(f: (I0, I1, I2, I3) -> O) -> (I0, I1, I2, I3, completionHandler: O -> ()) -> () {
	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
	return { i0, i1, i2, i3, handler in dispatch_async(queue) { handler(f(i0, i1, i2, i3)) } }
}




public func toSync<O, R>(f: (completionHandler: O -> ()) -> R, start: R -> () = { _ in }) -> () -> O {
	let semaphore = dispatch_semaphore_create(0)
	return {
		var output: O!
		start(f() { output = $0; dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		return output }
}
public func toSync<I0, O, R>(f: (I0, completionHandler: O -> ()) -> R, start: R -> () = { _ in }) -> (I0) -> O {
	let semaphore = dispatch_semaphore_create(0)
	return { i0 in
		var output: O!
		start(f(i0) { output = $0; dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		return output }
}
public func toSync<I0, I1, O, R>(f: (I0, I1, completionHandler: O -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) -> O {
	let semaphore = dispatch_semaphore_create(0)
	return { i0, i1 in
		var output: O!
		start(f(i0, i1) { output = $0; dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		return output }
}
public func toSync<I0, I1, I2, O, R>(f: (I0, I1, I2, completionHandler: O -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) -> O {
	let semaphore = dispatch_semaphore_create(0)
	return { i0, i1, i2 in
		var output: O!
		start(f(i0, i1, i2) { output = $0; dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		return output }
}
public func toSync<I0, I1, I2, I3, O, R>(f: (I0, I1, I2, I3, completionHandler: O -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) -> O {
	let semaphore = dispatch_semaphore_create(0)
	return { i0, i1, i2, i3 in
		var output: O!
		start(f(i0, i1, i2, i3) { output = $0; dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		return output }
}





public func toSync<R>(f: (completionHandler: (ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> () throws -> () {
	let semaphore = dispatch_semaphore_create(0)
	return {
		var error: ErrorType?
		start(f() { (error) = ($0); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error } }
}
public func toSync<R, E: ErrorType>(f: (completionHandler: (E?) -> ()) -> R, start: R -> () = { _ in }) -> () throws -> () {
	let semaphore = dispatch_semaphore_create(0)
	return {
		var error: E?
		start(f() { (error) = ($0); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error } }
}
public func toSync<I0, R>(f: (I0, completionHandler: (ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0) throws -> () {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?
		start(f(input) { (error) = ($0); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error } }
}
public func toSync<I0, R, E: ErrorType>(f: (I0, completionHandler: (E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0) throws -> () {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?
		start(f(input) { (error) = ($0); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error } }
}
public func toSync<I0, I1, R>(f: (I0, I1, completionHandler: (ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) throws -> () {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?
		start(f(input.0, input.1) { (error) = ($0); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error } }
}
public func toSync<I0, I1, R, E: ErrorType>(f: (I0, I1, completionHandler: (E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) throws -> () {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?
		start(f(input.0, input.1) { (error) = ($0); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error } }
}
public func toSync<I0, I1, I2, R>(f: (I0, I1, I2, completionHandler: (ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) throws -> () {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?
		start(f(input.0, input.1, input.2) { (error) = ($0); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error } }
}
public func toSync<I0, I1, I2, R, E: ErrorType>(f: (I0, I1, I2, completionHandler: (E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) throws -> () {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?
		start(f(input.0, input.1, input.2) { (error) = ($0); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error } }
}
public func toSync<I0, I1, I2, I3, R>(f: (I0, I1, I2, I3, completionHandler: (ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) throws -> () {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?
		start(f(input.0, input.1, input.2, input.3) { (error) = ($0); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error } }
}
public func toSync<I0, I1, I2, I3, R, E: ErrorType>(f: (I0, I1, I2, I3, completionHandler: (E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) throws -> () {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?
		start(f(input.0, input.1, input.2, input.3) { (error) = ($0); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error } }
}
public func toSync<O0, R>(f: (completionHandler: (O0, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> () throws -> (O0) {
	let semaphore = dispatch_semaphore_create(0)
	return {
		var error: ErrorType?, output: (O0)!
		start(f() { (output, error) = (($0), $1); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<O0, R, E: ErrorType>(f: (completionHandler: (O0, E?) -> ()) -> R, start: R -> () = { _ in }) -> () throws -> (O0) {
	let semaphore = dispatch_semaphore_create(0)
	return {
		var error: E?, output: (O0)!
		start(f() { (output, error) = (($0), $1); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, O0, R>(f: (I0, completionHandler: (O0, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0) throws -> (O0) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?, output: (O0)!
		start(f(input) { (output, error) = (($0), $1); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, O0, R, E: ErrorType>(f: (I0, completionHandler: (O0, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0) throws -> (O0) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?, output: (O0)!
		start(f(input) { (output, error) = (($0), $1); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, O0, R>(f: (I0, I1, completionHandler: (O0, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) throws -> (O0) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?, output: (O0)!
		start(f(input.0, input.1) { (output, error) = (($0), $1); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, O0, R, E: ErrorType>(f: (I0, I1, completionHandler: (O0, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) throws -> (O0) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?, output: (O0)!
		start(f(input.0, input.1) { (output, error) = (($0), $1); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, I2, O0, R>(f: (I0, I1, I2, completionHandler: (O0, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) throws -> (O0) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?, output: (O0)!
		start(f(input.0, input.1, input.2) { (output, error) = (($0), $1); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, I2, O0, R, E: ErrorType>(f: (I0, I1, I2, completionHandler: (O0, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) throws -> (O0) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?, output: (O0)!
		start(f(input.0, input.1, input.2) { (output, error) = (($0), $1); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, I2, I3, O0, R>(f: (I0, I1, I2, I3, completionHandler: (O0, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) throws -> (O0) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?, output: (O0)!
		start(f(input.0, input.1, input.2, input.3) { (output, error) = (($0), $1); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, I2, I3, O0, R, E: ErrorType>(f: (I0, I1, I2, I3, completionHandler: (O0, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) throws -> (O0) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?, output: (O0)!
		start(f(input.0, input.1, input.2, input.3) { (output, error) = (($0), $1); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<O0, O1, R>(f: (completionHandler: (O0, O1, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> () throws -> (O0, O1) {
	let semaphore = dispatch_semaphore_create(0)
	return {
		var error: ErrorType?, output: (O0, O1)!
		start(f() { (output, error) = (($0, $1), $2); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<O0, O1, R, E: ErrorType>(f: (completionHandler: (O0, O1, E?) -> ()) -> R, start: R -> () = { _ in }) -> () throws -> (O0, O1) {
	let semaphore = dispatch_semaphore_create(0)
	return {
		var error: E?, output: (O0, O1)!
		start(f() { (output, error) = (($0, $1), $2); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, O0, O1, R>(f: (I0, completionHandler: (O0, O1, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0) throws -> (O0, O1) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?, output: (O0, O1)!
		start(f(input) { (output, error) = (($0, $1), $2); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, O0, O1, R, E: ErrorType>(f: (I0, completionHandler: (O0, O1, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0) throws -> (O0, O1) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?, output: (O0, O1)!
		start(f(input) { (output, error) = (($0, $1), $2); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, O0, O1, R>(f: (I0, I1, completionHandler: (O0, O1, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) throws -> (O0, O1) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?, output: (O0, O1)!
		start(f(input.0, input.1) { (output, error) = (($0, $1), $2); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, O0, O1, R, E: ErrorType>(f: (I0, I1, completionHandler: (O0, O1, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) throws -> (O0, O1) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?, output: (O0, O1)!
		start(f(input.0, input.1) { (output, error) = (($0, $1), $2); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, I2, O0, O1, R>(f: (I0, I1, I2, completionHandler: (O0, O1, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) throws -> (O0, O1) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?, output: (O0, O1)!
		start(f(input.0, input.1, input.2) { (output, error) = (($0, $1), $2); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, I2, O0, O1, R, E: ErrorType>(f: (I0, I1, I2, completionHandler: (O0, O1, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) throws -> (O0, O1) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?, output: (O0, O1)!
		start(f(input.0, input.1, input.2) { (output, error) = (($0, $1), $2); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, I2, I3, O0, O1, R>(f: (I0, I1, I2, I3, completionHandler: (O0, O1, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) throws -> (O0, O1) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?, output: (O0, O1)!
		start(f(input.0, input.1, input.2, input.3) { (output, error) = (($0, $1), $2); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, I2, I3, O0, O1, R, E: ErrorType>(f: (I0, I1, I2, I3, completionHandler: (O0, O1, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) throws -> (O0, O1) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?, output: (O0, O1)!
		start(f(input.0, input.1, input.2, input.3) { (output, error) = (($0, $1), $2); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<O0, O1, O2, R>(f: (completionHandler: (O0, O1, O2, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> () throws -> (O0, O1, O2) {
	let semaphore = dispatch_semaphore_create(0)
	return {
		var error: ErrorType?, output: (O0, O1, O2)!
		start(f() { (output, error) = (($0, $1, $2), $3); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<O0, O1, O2, R, E: ErrorType>(f: (completionHandler: (O0, O1, O2, E?) -> ()) -> R, start: R -> () = { _ in }) -> () throws -> (O0, O1, O2) {
	let semaphore = dispatch_semaphore_create(0)
	return {
		var error: E?, output: (O0, O1, O2)!
		start(f() { (output, error) = (($0, $1, $2), $3); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, O0, O1, O2, R>(f: (I0, completionHandler: (O0, O1, O2, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0) throws -> (O0, O1, O2) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?, output: (O0, O1, O2)!
		start(f(input) { (output, error) = (($0, $1, $2), $3); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, O0, O1, O2, R, E: ErrorType>(f: (I0, completionHandler: (O0, O1, O2, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0) throws -> (O0, O1, O2) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?, output: (O0, O1, O2)!
		start(f(input) { (output, error) = (($0, $1, $2), $3); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, O0, O1, O2, R>(f: (I0, I1, completionHandler: (O0, O1, O2, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) throws -> (O0, O1, O2) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?, output: (O0, O1, O2)!
		start(f(input.0, input.1) { (output, error) = (($0, $1, $2), $3); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, O0, O1, O2, R, E: ErrorType>(f: (I0, I1, completionHandler: (O0, O1, O2, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) throws -> (O0, O1, O2) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?, output: (O0, O1, O2)!
		start(f(input.0, input.1) { (output, error) = (($0, $1, $2), $3); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, I2, O0, O1, O2, R>(f: (I0, I1, I2, completionHandler: (O0, O1, O2, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) throws -> (O0, O1, O2) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?, output: (O0, O1, O2)!
		start(f(input.0, input.1, input.2) { (output, error) = (($0, $1, $2), $3); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, I2, O0, O1, O2, R, E: ErrorType>(f: (I0, I1, I2, completionHandler: (O0, O1, O2, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) throws -> (O0, O1, O2) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?, output: (O0, O1, O2)!
		start(f(input.0, input.1, input.2) { (output, error) = (($0, $1, $2), $3); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, I2, I3, O0, O1, O2, R>(f: (I0, I1, I2, I3, completionHandler: (O0, O1, O2, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) throws -> (O0, O1, O2) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?, output: (O0, O1, O2)!
		start(f(input.0, input.1, input.2, input.3) { (output, error) = (($0, $1, $2), $3); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, I2, I3, O0, O1, O2, R, E: ErrorType>(f: (I0, I1, I2, I3, completionHandler: (O0, O1, O2, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) throws -> (O0, O1, O2) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?, output: (O0, O1, O2)!
		start(f(input.0, input.1, input.2, input.3) { (output, error) = (($0, $1, $2), $3); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<O0, O1, O2, O3, R>(f: (completionHandler: (O0, O1, O2, O3, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> () throws -> (O0, O1, O2, O3) {
	let semaphore = dispatch_semaphore_create(0)
	return {
		var error: ErrorType?, output: (O0, O1, O2, O3)!
		start(f() { (output, error) = (($0, $1, $2, $3), $4); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<O0, O1, O2, O3, R, E: ErrorType>(f: (completionHandler: (O0, O1, O2, O3, E?) -> ()) -> R, start: R -> () = { _ in }) -> () throws -> (O0, O1, O2, O3) {
	let semaphore = dispatch_semaphore_create(0)
	return {
		var error: E?, output: (O0, O1, O2, O3)!
		start(f() { (output, error) = (($0, $1, $2, $3), $4); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, O0, O1, O2, O3, R>(f: (I0, completionHandler: (O0, O1, O2, O3, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0) throws -> (O0, O1, O2, O3) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?, output: (O0, O1, O2, O3)!
		start(f(input) { (output, error) = (($0, $1, $2, $3), $4); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, O0, O1, O2, O3, R, E: ErrorType>(f: (I0, completionHandler: (O0, O1, O2, O3, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0) throws -> (O0, O1, O2, O3) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?, output: (O0, O1, O2, O3)!
		start(f(input) { (output, error) = (($0, $1, $2, $3), $4); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, O0, O1, O2, O3, R>(f: (I0, I1, completionHandler: (O0, O1, O2, O3, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) throws -> (O0, O1, O2, O3) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?, output: (O0, O1, O2, O3)!
		start(f(input.0, input.1) { (output, error) = (($0, $1, $2, $3), $4); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, O0, O1, O2, O3, R, E: ErrorType>(f: (I0, I1, completionHandler: (O0, O1, O2, O3, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) throws -> (O0, O1, O2, O3) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?, output: (O0, O1, O2, O3)!
		start(f(input.0, input.1) { (output, error) = (($0, $1, $2, $3), $4); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, I2, O0, O1, O2, O3, R>(f: (I0, I1, I2, completionHandler: (O0, O1, O2, O3, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) throws -> (O0, O1, O2, O3) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?, output: (O0, O1, O2, O3)!
		start(f(input.0, input.1, input.2) { (output, error) = (($0, $1, $2, $3), $4); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, I2, O0, O1, O2, O3, R, E: ErrorType>(f: (I0, I1, I2, completionHandler: (O0, O1, O2, O3, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) throws -> (O0, O1, O2, O3) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?, output: (O0, O1, O2, O3)!
		start(f(input.0, input.1, input.2) { (output, error) = (($0, $1, $2, $3), $4); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, I2, I3, O0, O1, O2, O3, R>(f: (I0, I1, I2, I3, completionHandler: (O0, O1, O2, O3, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) throws -> (O0, O1, O2, O3) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?, output: (O0, O1, O2, O3)!
		start(f(input.0, input.1, input.2, input.3) { (output, error) = (($0, $1, $2, $3), $4); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}
public func toSync<I0, I1, I2, I3, O0, O1, O2, O3, R, E: ErrorType>(f: (I0, I1, I2, I3, completionHandler: (O0, O1, O2, O3, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) throws -> (O0, O1, O2, O3) {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?, output: (O0, O1, O2, O3)!
		start(f(input.0, input.1, input.2, input.3) { (output, error) = (($0, $1, $2, $3), $4); dispatch_semaphore_signal(semaphore) })
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		if let error = error { throw error }
		
		return output }
}


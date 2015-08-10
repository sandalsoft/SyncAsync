import Foundation


/*

TODO:

 - Completion handler + error handler on toSync
 - does it work with implicitly unwrapped optionals or non-optionals in completion handler?
 - function to generate functions toAsync and toSync
 - toAsync with optional queue
 - reference cycle?

*/




// MARK: toAsync

// MARK: Non-throwing

public func toAsync<O>(sync: Void -> O) -> (completionHandler: O -> Void) -> Void {
	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
	return { handler in dispatch_async(queue) { handler(sync()) } }
}

public func toAsync<I, O>(sync: I -> O) -> (I, completionHandler: O -> Void) -> Void {
	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
	return { i, handler in dispatch_async(queue) { handler(sync(i)) } }
}

public func toAsync<I1, I2, O>(sync: (I1, I2) -> O) -> (I1, I2, completionHandler: O -> Void) -> Void {
	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
	return { i1, i2, handler in dispatch_async(queue) { handler(sync(i1, i2)) } }
}

public func toAsync<I1, I2, I3, O>(sync: (I1, I2, I3) -> O) -> (I1, I2, I3, completionHandler: O -> Void) -> Void {
	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
	return { i1, i2, i3, handler in dispatch_async(queue) { handler(sync(i1, i2, i3)) } }
}

public func toAsync<I1, I2, I3, I4, O>(sync: (I1, I2, I3, I4) -> O) -> (I1, I2, I3, I4, completionHandler: O -> Void) -> Void {
	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
	return { i1, i2, i3, i4, handler in dispatch_async(queue) { handler(sync(i1, i2, i3, i4)) } }
}

// MARK: Throwing

public func toAsync<O>(sync: Void throws -> O) -> (completionHandler: O -> Void, errorHandler: ErrorType -> Void) -> Void {
	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
	return { ch, eh in dispatch_async(queue) {
		do { try ch(sync()) }
		catch { eh(error) }
	}}
}

public func toAsync<I, O>(sync: I throws -> O) -> (I, completionHandler: O -> Void, errorHandler: ErrorType -> Void) -> Void {
	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
	return { i, ch, eh in dispatch_async(queue) {
		do { try ch(sync(i)) }
		catch { eh(error) }
	}}
}

public func toAsync<I1, I2, O>(sync: (I1, I2) throws -> O) -> (I1, I2, completionHandler: O -> Void, errorHandler: ErrorType -> Void) -> Void {
	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
	return { i1, i2, ch, eh in dispatch_async(queue) {
		do { try ch(sync(i1, i2)) }
		catch { eh(error) }
	}}
}

public func toAsync<I1, I2, I3, O>(sync: (I1, I2, I3) throws -> O) -> (I1, I2, I3, completionHandler: O -> Void, errorHandler: ErrorType -> Void) -> Void {
	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
	return { i1, i2, i3, ch, eh in dispatch_async(queue) {
		do { try ch(sync(i1, i2, i3)) }
		catch { eh(error) }
	}}
}

public func toAsync<I1, I2, I3, I4, O>(sync: (I1, I2, I3, I4) throws -> O) -> (I1, I2, I3, I4, completionHandler: O -> Void, errorHandler: ErrorType -> Void) -> Void {
	let queue = dispatch_queue_create("", DISPATCH_QUEUE_SERIAL)
	return { i1, i2, i3, i4, ch, eh in dispatch_async(queue) {
		do { try ch(sync(i1, i2, i3, i4)) }
		catch { eh(error) }
	}}
}


// MARK: - toSync

// MARK: Non-throwing

private func toSyncPrivate<R>(start: R -> (), async: (completionHandler: Void -> Void) -> R) -> Void -> Void {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		start(async() {
			dispatch_semaphore_signal(semaphore)
		})
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
	}
}


private func toSyncPrivate<I, R>(start: R -> (), async: (I, completionHandler: Void -> Void) -> R) -> I -> Void {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		start(async(input) {
			dispatch_semaphore_signal(semaphore)
		})
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
	}
}

private func toSyncPrivate<O, R>(start: R -> (), async: (completionHandler: O -> Void) -> R) -> Void -> O {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var output: O!
		
		start(async() {
			output = $0
			dispatch_semaphore_signal(semaphore)
		})
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		
		return output
	}
}


private func toSyncPrivate<I, O, R>(start: R -> (), async: (I, completionHandler: O -> Void) -> R) -> I -> O {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var output: O!
		
		start(async(input) {
			output = $0
			dispatch_semaphore_signal(semaphore)
		})
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		
		return output
	}
}


public func toSync<R>(async: (completionHandler: Void -> Void) -> R, start: R -> () = {_ in}) -> Void -> Void {
	return toSyncPrivate(start, async: async)
}

public func toSync<I, R>(async: (I, completionHandler: Void -> Void) -> R, start: R -> () = {_ in}) -> I -> Void {
	return toSyncPrivate(start, async: async)
}

public func toSync<I1, I2, R>(f: (I1, I2, completionHandler: Void -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) -> Void {
	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h($0) } }
}

public func toSync<I1, I2, I3, R>(f: (I1, I2, I3, completionHandler: Void -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) -> Void {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h($0) } }
}

public func toSync<I1, I2, I3, I4, R>(f: (I1, I2, I3, I4, completionHandler: Void -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) -> Void {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h($0) } }
}


public func toSync<O, R>(async: (completionHandler: O -> Void) -> R, start: R -> () = {_ in}) -> Void -> O {
	return toSyncPrivate(start, async: async)
}

public func toSync<I, O, R>(async: (I, completionHandler: O -> Void) -> R, start: R -> () = {_ in}) -> I -> O {
	return toSyncPrivate(start, async: async)
}

public func toSync<I1, I2, O, R>(f: (I1, I2, completionHandler: O -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) -> O {
	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h($0) } }
}

public func toSync<I1, I2, I3, O, R>(f: (I1, I2, I3, completionHandler: O -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) -> O {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h($0) } }
}

public func toSync<I1, I2, I3, I4, O, R>(f: (I1, I2, I3, I4, completionHandler: O -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) -> O {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h($0) } }
}


// MARK: Throwing

private func toSyncPrivate<R>(start: R -> (), async: (completionHandler: ErrorType? -> Void) -> R) -> Void throws -> Void {
	let semaphore = dispatch_semaphore_create(0)
	return {
		var error: ErrorType?
		
		start(async() {
			error = $0
			dispatch_semaphore_signal(semaphore)
			})
		
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		
		if let error = error { throw error }
	}
}

private func toSyncPrivate<O, R>(start: R -> (), async: (completionHandler: (O, ErrorType?) -> Void) -> R) -> Void throws -> O {
	let semaphore = dispatch_semaphore_create(0)
	return {
		var output: O!
		var error: ErrorType?
		
		start(async() {
			(output, error) = ($0, $1)
			dispatch_semaphore_signal(semaphore)
			})
		
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		
		if let error = error { throw error }
		return output
	}
}


private func toSyncPrivate<I, R>(start: R -> (), async: (I, completionHandler: ErrorType? -> Void) -> R) -> I throws -> Void {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: ErrorType?
		
		start(async(input) {
			error = $0
			dispatch_semaphore_signal(semaphore)
		})
		
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		
		if let error = error { throw error }
	}
}

private func toSyncPrivate<I, O, R>(start: R -> (), async: (I, completionHandler: (O, ErrorType?) -> Void) -> R) -> I throws -> O {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var output: O!
		var error: ErrorType?
		
		start(async(input) {
			(output, error) = ($0, $1)
			dispatch_semaphore_signal(semaphore)
		})
		
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		
		if let error = error { throw error }
		return output
	}
}

public func toSynct<R>(f: (completionHandler: ErrorType? -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> Void {
	return toSyncPrivate(start, async: f)
}

public func toSynct<I, R>(f: (I, completionHandler: ErrorType? -> Void) -> R, start: R -> () = {_ in }) -> I throws -> Void {
	return toSyncPrivate(start, async: f)
}

public func toSync<I1, I2, R>(f: (I1, I2, completionHandler: ErrorType? -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> Void {
	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h($0) } }
}

public func toSync<I1, I2, I3, R>(f: (I1, I2, I3, completionHandler: ErrorType? -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> Void {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h($0) } }
}

public func toSync<I1, I2, I3, I4, R>(f: (I1, I2, I3, I4, completionHandler: ErrorType? -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> Void {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h($0) } }
}


public func toSync<O, R>(f: (completionHandler: (O?, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> O! {
	return toSyncPrivate(start) { h in f() { h($0, $1) } }
}

public func toSync<I, O, R>(f: (I, completionHandler: (O?, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> I throws -> O! {
	return toSyncPrivate(start) { i, h in f(i) { h($0, $1) } }
}

public func toSync<I1, I2, O, R>(f: (I1, I2, completionHandler: (O?, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> O! {
	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h($0, $1) } }
}

public func toSync<I1, I2, I3, O, R>(f: (I1, I2, I3, completionHandler: (O?, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> O! {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h($0, $1) } }
}

public func toSync<I1, I2, I3, I4, O, R>(f: (I1, I2, I3, I4, completionHandler: (O?, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> O! {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h($0, $1) } }
}


public func toSync<O1, O2, R>(f: (completionHandler: (O1?, O2?, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> (O1!, O2!) {
	return toSyncPrivate(start) { h in f() { h(($0, $1), $2) } }
}

public func toSync<I, O1, O2, R>(f: (I, completionHandler: (O1?, O2?, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> I throws -> (O1!, O2!) {
	return toSyncPrivate(start) { i, h in f(i) { h(($0, $1), $2) } }
}

public func toSync<I1, I2, O1, O2, R>(f: (I1, I2, completionHandler: (O1?, O2?, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> (O1!, O2!) {
	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h(($0, $1), $2) } }
}

public func toSync<I1, I2, I3, O1, O2, R>(f: (I1, I2, I3, completionHandler: (O1?, O2?, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> (O1!, O2!) {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h(($0, $1), $2) } }
}

public func toSync<I1, I2, I3, I4, O1, O2, R>(f: (I1, I2, I3, I4, completionHandler: (O1?, O2?, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> (O1!, O2!) {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h(($0, $1), $2) } }
}


public func toSync<O1, O2, O3, R>(f: (completionHandler: (O1?, O2?, O3?, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> (O1!, O2!, O3!) {
	return toSyncPrivate(start) { h in f() { h(($0, $1, $2), $3) } }
}

public func toSync<I, O1, O2, O3, R>(f: (I, completionHandler: (O1?, O2?, O3?, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> I throws -> (O1!, O2!, O3!) {
	return toSyncPrivate(start) { i, h in f(i) { h(($0, $1, $2), $3) } }
}

public func toSync<I1, I2, O1, O2, O3, R>(f: (I1, I2, completionHandler: (O1?, O2?, O3?, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> (O1!, O2!, O3!) {
	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h(($0, $1, $2), $3) } }
}

public func toSync<I1, I2, I3, O1, O2, O3, R>(f: (I1, I2, I3, completionHandler: (O1?, O2?, O3?, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> (O1!, O2!, O3!) {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h(($0, $1, $2), $3) } }
}

public func toSync<I1, I2, I3, I4, O1, O2, O3, R>(f: (I1, I2, I3, I4, completionHandler: (O1?, O2?, O3?, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> (O1!, O2!, O3!) {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h(($0, $1, $2), $3) } }
}


public func toSync<O1, O2, O3, O4, R>(f: (completionHandler: (O1?, O2?, O3?, O4?, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> (O1!, O2!, O3!, O4!) {
	return toSyncPrivate(start) { h in f() { h(($0, $1, $2, $3), $4) } }
}

public func toSync<I, O1, O2, O3, O4, R>(f: (I, completionHandler: (O1?, O2?, O3?, O4?, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> I throws -> (O1!, O2!, O3!, O4!) {
	return toSyncPrivate(start) { i, h in f(i) { h(($0, $1, $2, $3), $4) } }
}

public func toSync<I1, I2, O1, O2, O3, O4, R>(f: (I1, I2, completionHandler: (O1?, O2?, O3?, O4?, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> (O1!, O2!, O3!, O4!) {
	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h(($0, $1, $2, $3), $4) } }
}

public func toSync<I1, I2, I3, O1, O2, O3, O4, R>(f: (I1, I2, I3, completionHandler: (O1?, O2?, O3?, O4?, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> (O1!, O2!, O3!, O4!) {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h(($0, $1, $2, $3), $4) } }
}

public func toSync<I1, I2, I3, I4, O1, O2, O3, O4, R>(f: (I1, I2, I3, I4, completionHandler: (O1?, O2?, O3?, O4?, ErrorType?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> (O1!, O2!, O3!, O4!) {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h(($0, $1, $2, $3), $4) } }
}




private func toSyncPrivate<I, R, E: ErrorType>(start: R -> (), async: (I, completionHandler: E? -> Void) -> R) -> I throws -> Void {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var error: E?
		
		start(async(input) {
			error = $0
			dispatch_semaphore_signal(semaphore)
			})
		
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		
		if let error = error { throw error }
	}
}

private func toSyncPrivate<O, R, E: ErrorType>(start: R -> (), async: (completionHandler: (O, E?) -> Void) -> R) -> Void throws -> O {
	let semaphore = dispatch_semaphore_create(0)
	return {
		var output: O!
		var error: E?
		
		start(async() {
			(output, error) = ($0, $1)
			dispatch_semaphore_signal(semaphore)
			})
		
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		
		if let error = error { throw error }
		return output
	}
}

private func toSyncPrivate<R, E: ErrorType>(start: R -> (), async: (completionHandler: E? -> Void) -> R) -> Void throws -> Void {
	let semaphore = dispatch_semaphore_create(0)
	return {
		var error: E?
		
		start(async() {
			error = $0
			dispatch_semaphore_signal(semaphore)
		})
		
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		
		if let error = error { throw error }
	}
}

private func toSyncPrivate<I, O, R, E: ErrorType>(start: R -> (), async: (I, completionHandler: (O, E?) -> Void) -> R) -> I throws -> O {
	let semaphore = dispatch_semaphore_create(0)
	return { input in
		var output: O!
		var error: E?
		
		start(async(input) {
			(output, error) = ($0, $1)
			dispatch_semaphore_signal(semaphore)
			})
		
		dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
		
		if let error = error { throw error }
		return output
	}
}


public func toSync<R, E: ErrorType>(f: (completionHandler: E? -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> Void {
	return toSyncPrivate(start) { h in f() { h($0) } }
}

public func toSync<I, R, E: ErrorType>(f: (I, completionHandler: E? -> Void) -> R, start: R -> () = {_ in }) -> I throws -> Void {
	return toSyncPrivate(start) { i, h in f(i) { h($0) } }
}

public func toSync<I1, I2, R, E: ErrorType>(f: (I1, I2, completionHandler: E? -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> Void {
	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h($0) } }
}

public func toSync<I1, I2, I3, R, E: ErrorType>(f: (I1, I2, I3, completionHandler: E? -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> Void {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h($0) } }
}

public func toSync<I1, I2, I3, I4, R, E: ErrorType>(f: (I1, I2, I3, I4, completionHandler: E? -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> Void {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h($0) } }
}


public func toSync<O, R, E: ErrorType>(f: (completionHandler: (O?, E?) -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> O! {
	return toSyncPrivate(start) { h in f() { h($0, $1) } }
}

public func toSync<I, O, R, E: ErrorType>(f: (I, completionHandler: (O?, E?) -> Void) -> R, start: R -> () = {_ in }) -> I throws -> O! {
	return toSyncPrivate(start) { i, h in f(i) { h($0, $1) } }
}

public func toSync<I1, I2, O, R, E: ErrorType>(f: (I1, I2, completionHandler: (O?, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> O! {
	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h($0, $1) } }
}

public func toSync<I1, I2, I3, O, R, E: ErrorType>(f: (I1, I2, I3, completionHandler: (O?, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> O! {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h($0, $1) } }
}

public func toSync<I1, I2, I3, I4, O, R, E: ErrorType>(f: (I1, I2, I3, I4, completionHandler: (O?, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> O! {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h($0, $1) } }
}


public func toSync<O1, O2, R, E: ErrorType>(f: (completionHandler: (O1?, O2?, E?) -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> (O1!, O2!) {
	return toSyncPrivate(start) { h in f() { h(($0, $1), $2) } }
}

public func toSync<I, O1, O2, R, E: ErrorType>(f: (I, completionHandler: (O1?, O2?, E?) -> Void) -> R, start: R -> () = {_ in }) -> I throws -> (O1!, O2!) {
	return toSyncPrivate(start) { i, h in f(i) { h(($0, $1), $2) } }
}

public func toSync<I1, I2, O1, O2, R, E: ErrorType>(f: (I1, I2, completionHandler: (O1?, O2?, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> (O1!, O2!) {
	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h(($0, $1), $2) } }
}

public func toSync<I1, I2, I3, O1, O2, R, E: ErrorType>(f: (I1, I2, I3, completionHandler: (O1?, O2?, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> (O1!, O2!) {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h(($0, $1), $2) } }
}

public func toSync<I1, I2, I3, I4, O1, O2, R, E: ErrorType>(f: (I1, I2, I3, I4, completionHandler: (O1?, O2?, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> (O1!, O2!) {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h(($0, $1), $2) } }
}


public func toSync<O1, O2, O3, R, E: ErrorType>(f: (completionHandler: (O1?, O2?, O3?, E?) -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> (O1!, O2!, O3!) {
	return toSyncPrivate(start) { h in f() { h(($0, $1, $2), $3) } }
}

public func toSync<I, O1, O2, O3, R, E: ErrorType>(f: (I, completionHandler: (O1?, O2?, O3?, E?) -> Void) -> R, start: R -> () = {_ in }) -> I throws -> (O1!, O2!, O3!) {
	return toSyncPrivate(start) { i, h in f(i) { h(($0, $1, $2), $3) } }
}

public func toSync<I1, I2, O1, O2, O3, R, E: ErrorType>(f: (I1, I2, completionHandler: (O1?, O2?, O3?, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> (O1!, O2!, O3!) {
	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h(($0, $1, $2), $3) } }
}

public func toSync<I1, I2, I3, O1, O2, O3, R, E: ErrorType>(f: (I1, I2, I3, completionHandler: (O1?, O2?, O3?, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> (O1!, O2!, O3!) {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h(($0, $1, $2), $3) } }
}

public func toSync<I1, I2, I3, I4, O1, O2, O3, R, E: ErrorType>(f: (I1, I2, I3, I4, completionHandler: (O1?, O2?, O3?, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> (O1!, O2!, O3!) {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h(($0, $1, $2), $3) } }
}


public func toSync<O1, O2, O3, O4, R, E: ErrorType>(f: (completionHandler: (O1?, O2?, O3?, O4?, E?) -> Void) -> R, start: R -> () = {_ in }) -> Void throws -> (O1!, O2!, O3!, O4!) {
	return toSyncPrivate(start) { h in f() { h(($0, $1, $2, $3), $4) } }
}

public func toSync<I, O1, O2, O3, O4, R, E: ErrorType>(f: (I, completionHandler: (O1?, O2?, O3?, O4?, E?) -> Void) -> R, start: R -> () = {_ in }) -> I throws -> (O1!, O2!, O3!, O4!) {
	return toSyncPrivate(start) { i, h in f(i) { h(($0, $1, $2, $3), $4) } }
}

public func toSync<I1, I2, O1, O2, O3, O4, R, E: ErrorType>(f: (I1, I2, completionHandler: (O1?, O2?, O3?, O4?, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2) throws -> (O1!, O2!, O3!, O4!) {
	return toSyncPrivate(start) { i, h in f(i.0, i.1) { h(($0, $1, $2, $3), $4) } }
}

public func toSync<I1, I2, I3, O1, O2, O3, O4, R, E: ErrorType>(f: (I1, I2, I3, completionHandler: (O1?, O2?, O3?, O4?, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3) throws -> (O1!, O2!, O3!, O4!) {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2) { h(($0, $1, $2, $3), $4) } }
}

public func toSync<I1, I2, I3, I4, O1, O2, O3, O4, R, E: ErrorType>(f: (I1, I2, I3, I4, completionHandler: (O1?, O2?, O3?, O4?, E?) -> Void) -> R, start: R -> () = {_ in }) -> (I1, I2, I3, I4) throws -> (O1!, O2!, O3!, O4!) {
	return toSyncPrivate(start) { i, h in f(i.0, i.1, i.2, i.3) { h(($0, $1, $2, $3), $4) } }
}


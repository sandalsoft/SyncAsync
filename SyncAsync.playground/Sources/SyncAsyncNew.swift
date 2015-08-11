
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

import Foundation



// Non-generic error

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









// GENERATED



let async = { dispatch_async(dispatch_queue_create("", DISPATCH_QUEUE_SERIAL), $0) }



public func toAsync<O>(f: () -> O) -> (completionHandler: O -> ()) -> () {
	return { ch in async { ch(f()) } }
}
public func toAsync<I0, O>(f: (I0) -> O) -> (I0, completionHandler: O -> ()) -> () {
	return { i0, ch in async { ch(f(i0)) } }
}
public func toAsync<I0, I1, O>(f: (I0, I1) -> O) -> (I0, I1, completionHandler: O -> ()) -> () {
	return { i0, i1, ch in async { ch(f(i0, i1)) } }
}
public func toAsync<I0, I1, I2, O>(f: (I0, I1, I2) -> O) -> (I0, I1, I2, completionHandler: O -> ()) -> () {
	return { i0, i1, i2, ch in async { ch(f(i0, i1, i2)) } }
}
public func toAsync<I0, I1, I2, I3, O>(f: (I0, I1, I2, I3) -> O) -> (I0, I1, I2, I3, completionHandler: O -> ()) -> () {
	return { i0, i1, i2, i3, ch in async { ch(f(i0, i1, i2, i3)) } }
}




public func toAsync<O>(f: () throws -> O) -> (completionHandler: O -> (), errorHandler: ErrorType -> ()) -> () {
	return { ch, eh in async { do { try ch(f()) } catch { eh(error) } } }
}
public func toAsync<I0, O>(f: (I0) throws -> O) -> (I0, completionHandler: O -> (), errorHandler: ErrorType -> ()) -> () {
	return { i0, ch, eh in async { do { try ch(f(i0)) } catch { eh(error) } } }
}
public func toAsync<I0, I1, O>(f: (I0, I1) throws -> O) -> (I0, I1, completionHandler: O -> (), errorHandler: ErrorType -> ()) -> () {
	return { i0, i1, ch, eh in async { do { try ch(f(i0, i1)) } catch { eh(error) } } }
}
public func toAsync<I0, I1, I2, O>(f: (I0, I1, I2) throws -> O) -> (I0, I1, I2, completionHandler: O -> (), errorHandler: ErrorType -> ()) -> () {
	return { i0, i1, i2, ch, eh in async { do { try ch(f(i0, i1, i2)) } catch { eh(error) } } }
}
public func toAsync<I0, I1, I2, I3, O>(f: (I0, I1, I2, I3) throws -> O) -> (I0, I1, I2, I3, completionHandler: O -> (), errorHandler: ErrorType -> ()) -> () {
	return { i0, i1, i2, i3, ch, eh in async { do { try ch(f(i0, i1, i2, i3)) } catch { eh(error) } } }
}




struct Semaphore {
	let semaphore = dispatch_semaphore_create(0)
	func signal() { dispatch_semaphore_signal(semaphore) }
	func wait() { dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER) }
}




public func toSync<O, R>(f: (completionHandler: O -> ()) -> R, start: R -> () = { _ in }) -> () -> O {
	return {
		let sema = Semaphore(); var output: O! { didSet { sema.signal() } }
		start(f() { output = $0 }); sema.wait()
		return output }
}
public func toSync<I0, O, R>(f: (I0, completionHandler: O -> ()) -> R, start: R -> () = { _ in }) -> (I0) -> O {
	return { i0 in
		let sema = Semaphore(); var output: O! { didSet { sema.signal() } }
		start(f(i0) { output = $0 }); sema.wait()
		return output }
}
public func toSync<I0, I1, O, R>(f: (I0, I1, completionHandler: O -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) -> O {
	return { i0, i1 in
		let sema = Semaphore(); var output: O! { didSet { sema.signal() } }
		start(f(i0, i1) { output = $0 }); sema.wait()
		return output }
}
public func toSync<I0, I1, I2, O, R>(f: (I0, I1, I2, completionHandler: O -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) -> O {
	return { i0, i1, i2 in
		let sema = Semaphore(); var output: O! { didSet { sema.signal() } }
		start(f(i0, i1, i2) { output = $0 }); sema.wait()
		return output }
}
public func toSync<I0, I1, I2, I3, O, R>(f: (I0, I1, I2, I3, completionHandler: O -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) -> O {
	return { i0, i1, i2, i3 in
		let sema = Semaphore(); var output: O! { didSet { sema.signal() } }
		start(f(i0, i1, i2, i3) { output = $0 }); sema.wait()
		return output }
}







public func toSync<R>(f: (completionHandler: (ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> () throws -> () {
	return {
		let sema = Semaphore(); var error: ErrorType?
		start(f() { (error) = ($0); sema.signal() }); sema.wait()
		if let error = error { throw error } }
}
public func toSync<R, E: ErrorType>(f: (completionHandler: (E?) -> ()) -> R, start: R -> () = { _ in }) -> () throws -> () {
	return {
		let sema = Semaphore(); var error: E?
		start(f() { (error) = ($0); sema.signal() }); sema.wait()
		if let error = error { throw error } }
}
public func toSync<I0, R>(f: (I0, completionHandler: (ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0) throws -> () {
	return { input in
		let sema = Semaphore(); var error: ErrorType?
		start(f(input) { (error) = ($0); sema.signal() }); sema.wait()
		if let error = error { throw error } }
}
public func toSync<I0, R, E: ErrorType>(f: (I0, completionHandler: (E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0) throws -> () {
	return { input in
		let sema = Semaphore(); var error: E?
		start(f(input) { (error) = ($0); sema.signal() }); sema.wait()
		if let error = error { throw error } }
}
public func toSync<I0, I1, R>(f: (I0, I1, completionHandler: (ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) throws -> () {
	return { input in
		let sema = Semaphore(); var error: ErrorType?
		start(f(input.0, input.1) { (error) = ($0); sema.signal() }); sema.wait()
		if let error = error { throw error } }
}
public func toSync<I0, I1, R, E: ErrorType>(f: (I0, I1, completionHandler: (E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) throws -> () {
	return { input in
		let sema = Semaphore(); var error: E?
		start(f(input.0, input.1) { (error) = ($0); sema.signal() }); sema.wait()
		if let error = error { throw error } }
}
public func toSync<I0, I1, I2, R>(f: (I0, I1, I2, completionHandler: (ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) throws -> () {
	return { input in
		let sema = Semaphore(); var error: ErrorType?
		start(f(input.0, input.1, input.2) { (error) = ($0); sema.signal() }); sema.wait()
		if let error = error { throw error } }
}
public func toSync<I0, I1, I2, R, E: ErrorType>(f: (I0, I1, I2, completionHandler: (E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) throws -> () {
	return { input in
		let sema = Semaphore(); var error: E?
		start(f(input.0, input.1, input.2) { (error) = ($0); sema.signal() }); sema.wait()
		if let error = error { throw error } }
}
public func toSync<I0, I1, I2, I3, R>(f: (I0, I1, I2, I3, completionHandler: (ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) throws -> () {
	return { input in
		let sema = Semaphore(); var error: ErrorType?
		start(f(input.0, input.1, input.2, input.3) { (error) = ($0); sema.signal() }); sema.wait()
		if let error = error { throw error } }
}
public func toSync<I0, I1, I2, I3, R, E: ErrorType>(f: (I0, I1, I2, I3, completionHandler: (E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) throws -> () {
	return { input in
		let sema = Semaphore(); var error: E?
		start(f(input.0, input.1, input.2, input.3) { (error) = ($0); sema.signal() }); sema.wait()
		if let error = error { throw error } }
}
public func toSync<O0, R>(f: (completionHandler: (O0, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> () throws -> (O0) {
	return {
		let sema = Semaphore(); var error: ErrorType?, output: (O0)!
		start(f() { (output, error) = (($0), $1); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<O0, R, E: ErrorType>(f: (completionHandler: (O0, E?) -> ()) -> R, start: R -> () = { _ in }) -> () throws -> (O0) {
	return {
		let sema = Semaphore(); var error: E?, output: (O0)!
		start(f() { (output, error) = (($0), $1); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, O0, R>(f: (I0, completionHandler: (O0, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0) throws -> (O0) {
	return { input in
		let sema = Semaphore(); var error: ErrorType?, output: (O0)!
		start(f(input) { (output, error) = (($0), $1); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, O0, R, E: ErrorType>(f: (I0, completionHandler: (O0, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0) throws -> (O0) {
	return { input in
		let sema = Semaphore(); var error: E?, output: (O0)!
		start(f(input) { (output, error) = (($0), $1); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, O0, R>(f: (I0, I1, completionHandler: (O0, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) throws -> (O0) {
	return { input in
		let sema = Semaphore(); var error: ErrorType?, output: (O0)!
		start(f(input.0, input.1) { (output, error) = (($0), $1); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, O0, R, E: ErrorType>(f: (I0, I1, completionHandler: (O0, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) throws -> (O0) {
	return { input in
		let sema = Semaphore(); var error: E?, output: (O0)!
		start(f(input.0, input.1) { (output, error) = (($0), $1); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, I2, O0, R>(f: (I0, I1, I2, completionHandler: (O0, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) throws -> (O0) {
	return { input in
		let sema = Semaphore(); var error: ErrorType?, output: (O0)!
		start(f(input.0, input.1, input.2) { (output, error) = (($0), $1); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, I2, O0, R, E: ErrorType>(f: (I0, I1, I2, completionHandler: (O0, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) throws -> (O0) {
	return { input in
		let sema = Semaphore(); var error: E?, output: (O0)!
		start(f(input.0, input.1, input.2) { (output, error) = (($0), $1); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, I2, I3, O0, R>(f: (I0, I1, I2, I3, completionHandler: (O0, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) throws -> (O0) {
	return { input in
		let sema = Semaphore(); var error: ErrorType?, output: (O0)!
		start(f(input.0, input.1, input.2, input.3) { (output, error) = (($0), $1); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, I2, I3, O0, R, E: ErrorType>(f: (I0, I1, I2, I3, completionHandler: (O0, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) throws -> (O0) {
	return { input in
		let sema = Semaphore(); var error: E?, output: (O0)!
		start(f(input.0, input.1, input.2, input.3) { (output, error) = (($0), $1); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<O0, O1, R>(f: (completionHandler: (O0, O1, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> () throws -> (O0, O1) {
	return {
		let sema = Semaphore(); var error: ErrorType?, output: (O0, O1)!
		start(f() { (output, error) = (($0, $1), $2); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<O0, O1, R, E: ErrorType>(f: (completionHandler: (O0, O1, E?) -> ()) -> R, start: R -> () = { _ in }) -> () throws -> (O0, O1) {
	return {
		let sema = Semaphore(); var error: E?, output: (O0, O1)!
		start(f() { (output, error) = (($0, $1), $2); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, O0, O1, R>(f: (I0, completionHandler: (O0, O1, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0) throws -> (O0, O1) {
	return { input in
		let sema = Semaphore(); var error: ErrorType?, output: (O0, O1)!
		start(f(input) { (output, error) = (($0, $1), $2); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, O0, O1, R, E: ErrorType>(f: (I0, completionHandler: (O0, O1, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0) throws -> (O0, O1) {
	return { input in
		let sema = Semaphore(); var error: E?, output: (O0, O1)!
		start(f(input) { (output, error) = (($0, $1), $2); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, O0, O1, R>(f: (I0, I1, completionHandler: (O0, O1, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) throws -> (O0, O1) {
	return { input in
		let sema = Semaphore(); var error: ErrorType?, output: (O0, O1)!
		start(f(input.0, input.1) { (output, error) = (($0, $1), $2); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, O0, O1, R, E: ErrorType>(f: (I0, I1, completionHandler: (O0, O1, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) throws -> (O0, O1) {
	return { input in
		let sema = Semaphore(); var error: E?, output: (O0, O1)!
		start(f(input.0, input.1) { (output, error) = (($0, $1), $2); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, I2, O0, O1, R>(f: (I0, I1, I2, completionHandler: (O0, O1, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) throws -> (O0, O1) {
	return { input in
		let sema = Semaphore(); var error: ErrorType?, output: (O0, O1)!
		start(f(input.0, input.1, input.2) { (output, error) = (($0, $1), $2); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, I2, O0, O1, R, E: ErrorType>(f: (I0, I1, I2, completionHandler: (O0, O1, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) throws -> (O0, O1) {
	return { input in
		let sema = Semaphore(); var error: E?, output: (O0, O1)!
		start(f(input.0, input.1, input.2) { (output, error) = (($0, $1), $2); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, I2, I3, O0, O1, R>(f: (I0, I1, I2, I3, completionHandler: (O0, O1, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) throws -> (O0, O1) {
	return { input in
		let sema = Semaphore(); var error: ErrorType?, output: (O0, O1)!
		start(f(input.0, input.1, input.2, input.3) { (output, error) = (($0, $1), $2); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, I2, I3, O0, O1, R, E: ErrorType>(f: (I0, I1, I2, I3, completionHandler: (O0, O1, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) throws -> (O0, O1) {
	return { input in
		let sema = Semaphore(); var error: E?, output: (O0, O1)!
		start(f(input.0, input.1, input.2, input.3) { (output, error) = (($0, $1), $2); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<O0, O1, O2, R>(f: (completionHandler: (O0, O1, O2, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> () throws -> (O0, O1, O2) {
	return {
		let sema = Semaphore(); var error: ErrorType?, output: (O0, O1, O2)!
		start(f() { (output, error) = (($0, $1, $2), $3); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<O0, O1, O2, R, E: ErrorType>(f: (completionHandler: (O0, O1, O2, E?) -> ()) -> R, start: R -> () = { _ in }) -> () throws -> (O0, O1, O2) {
	return {
		let sema = Semaphore(); var error: E?, output: (O0, O1, O2)!
		start(f() { (output, error) = (($0, $1, $2), $3); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, O0, O1, O2, R>(f: (I0, completionHandler: (O0, O1, O2, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0) throws -> (O0, O1, O2) {
	return { input in
		let sema = Semaphore(); var error: ErrorType?, output: (O0, O1, O2)!
		start(f(input) { (output, error) = (($0, $1, $2), $3); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, O0, O1, O2, R, E: ErrorType>(f: (I0, completionHandler: (O0, O1, O2, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0) throws -> (O0, O1, O2) {
	return { input in
		let sema = Semaphore(); var error: E?, output: (O0, O1, O2)!
		start(f(input) { (output, error) = (($0, $1, $2), $3); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, O0, O1, O2, R>(f: (I0, I1, completionHandler: (O0, O1, O2, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) throws -> (O0, O1, O2) {
	return { input in
		let sema = Semaphore(); var error: ErrorType?, output: (O0, O1, O2)!
		start(f(input.0, input.1) { (output, error) = (($0, $1, $2), $3); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, O0, O1, O2, R, E: ErrorType>(f: (I0, I1, completionHandler: (O0, O1, O2, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) throws -> (O0, O1, O2) {
	return { input in
		let sema = Semaphore(); var error: E?, output: (O0, O1, O2)!
		start(f(input.0, input.1) { (output, error) = (($0, $1, $2), $3); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, I2, O0, O1, O2, R>(f: (I0, I1, I2, completionHandler: (O0, O1, O2, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) throws -> (O0, O1, O2) {
	return { input in
		let sema = Semaphore(); var error: ErrorType?, output: (O0, O1, O2)!
		start(f(input.0, input.1, input.2) { (output, error) = (($0, $1, $2), $3); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, I2, O0, O1, O2, R, E: ErrorType>(f: (I0, I1, I2, completionHandler: (O0, O1, O2, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) throws -> (O0, O1, O2) {
	return { input in
		let sema = Semaphore(); var error: E?, output: (O0, O1, O2)!
		start(f(input.0, input.1, input.2) { (output, error) = (($0, $1, $2), $3); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, I2, I3, O0, O1, O2, R>(f: (I0, I1, I2, I3, completionHandler: (O0, O1, O2, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) throws -> (O0, O1, O2) {
	return { input in
		let sema = Semaphore(); var error: ErrorType?, output: (O0, O1, O2)!
		start(f(input.0, input.1, input.2, input.3) { (output, error) = (($0, $1, $2), $3); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, I2, I3, O0, O1, O2, R, E: ErrorType>(f: (I0, I1, I2, I3, completionHandler: (O0, O1, O2, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) throws -> (O0, O1, O2) {
	return { input in
		let sema = Semaphore(); var error: E?, output: (O0, O1, O2)!
		start(f(input.0, input.1, input.2, input.3) { (output, error) = (($0, $1, $2), $3); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<O0, O1, O2, O3, R>(f: (completionHandler: (O0, O1, O2, O3, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> () throws -> (O0, O1, O2, O3) {
	return {
		let sema = Semaphore(); var error: ErrorType?, output: (O0, O1, O2, O3)!
		start(f() { (output, error) = (($0, $1, $2, $3), $4); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<O0, O1, O2, O3, R, E: ErrorType>(f: (completionHandler: (O0, O1, O2, O3, E?) -> ()) -> R, start: R -> () = { _ in }) -> () throws -> (O0, O1, O2, O3) {
	return {
		let sema = Semaphore(); var error: E?, output: (O0, O1, O2, O3)!
		start(f() { (output, error) = (($0, $1, $2, $3), $4); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, O0, O1, O2, O3, R>(f: (I0, completionHandler: (O0, O1, O2, O3, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0) throws -> (O0, O1, O2, O3) {
	return { input in
		let sema = Semaphore(); var error: ErrorType?, output: (O0, O1, O2, O3)!
		start(f(input) { (output, error) = (($0, $1, $2, $3), $4); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, O0, O1, O2, O3, R, E: ErrorType>(f: (I0, completionHandler: (O0, O1, O2, O3, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0) throws -> (O0, O1, O2, O3) {
	return { input in
		let sema = Semaphore(); var error: E?, output: (O0, O1, O2, O3)!
		start(f(input) { (output, error) = (($0, $1, $2, $3), $4); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, O0, O1, O2, O3, R>(f: (I0, I1, completionHandler: (O0, O1, O2, O3, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) throws -> (O0, O1, O2, O3) {
	return { input in
		let sema = Semaphore(); var error: ErrorType?, output: (O0, O1, O2, O3)!
		start(f(input.0, input.1) { (output, error) = (($0, $1, $2, $3), $4); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, O0, O1, O2, O3, R, E: ErrorType>(f: (I0, I1, completionHandler: (O0, O1, O2, O3, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1) throws -> (O0, O1, O2, O3) {
	return { input in
		let sema = Semaphore(); var error: E?, output: (O0, O1, O2, O3)!
		start(f(input.0, input.1) { (output, error) = (($0, $1, $2, $3), $4); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, I2, O0, O1, O2, O3, R>(f: (I0, I1, I2, completionHandler: (O0, O1, O2, O3, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) throws -> (O0, O1, O2, O3) {
	return { input in
		let sema = Semaphore(); var error: ErrorType?, output: (O0, O1, O2, O3)!
		start(f(input.0, input.1, input.2) { (output, error) = (($0, $1, $2, $3), $4); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, I2, O0, O1, O2, O3, R, E: ErrorType>(f: (I0, I1, I2, completionHandler: (O0, O1, O2, O3, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2) throws -> (O0, O1, O2, O3) {
	return { input in
		let sema = Semaphore(); var error: E?, output: (O0, O1, O2, O3)!
		start(f(input.0, input.1, input.2) { (output, error) = (($0, $1, $2, $3), $4); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, I2, I3, O0, O1, O2, O3, R>(f: (I0, I1, I2, I3, completionHandler: (O0, O1, O2, O3, ErrorType?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) throws -> (O0, O1, O2, O3) {
	return { input in
		let sema = Semaphore(); var error: ErrorType?, output: (O0, O1, O2, O3)!
		start(f(input.0, input.1, input.2, input.3) { (output, error) = (($0, $1, $2, $3), $4); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}
public func toSync<I0, I1, I2, I3, O0, O1, O2, O3, R, E: ErrorType>(f: (I0, I1, I2, I3, completionHandler: (O0, O1, O2, O3, E?) -> ()) -> R, start: R -> () = { _ in }) -> (I0, I1, I2, I3) throws -> (O0, O1, O2, O3) {
	return { input in
		let sema = Semaphore(); var error: E?, output: (O0, O1, O2, O3)!
		start(f(input.0, input.1, input.2, input.3) { (output, error) = (($0, $1, $2, $3), $4); sema.signal() }); sema.wait()
		if let error = error { throw error }; return output }
}

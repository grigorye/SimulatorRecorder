import Foundation

configTracing()

func foo(_ bar: Int) -> Int {
	return x$(x$(bar) + 1)
}

x$(0)
x$("foo")
x$(foo(1))

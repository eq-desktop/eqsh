pragma Singleton
import Quickshell
import "root:/agents/fuzzysort.js" as FuzzySort

Singleton {
    function go(...args) {
        return FuzzySort.go(...args)
    }

    function prepare(...args) {
        return FuzzySort.prepare(...args)
    }
}

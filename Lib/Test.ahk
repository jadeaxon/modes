#Requires AutoHotkey v2.0

assert(condition, message := "Assertion Failed") {
    if (!condition) {
		; The -1 causes the error to look like it happened in the calling function.
        throw Error(message, -1)
    }
}

assert_equal(actual, expected, name := "Value") {
    if (actual !== expected) {
        throw Error(name " mismatch!`n`nExpected: " expected "`nActual: " actual, -1)
    }
}



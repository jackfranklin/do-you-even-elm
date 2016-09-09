module FooTest exposing (..)

import ElmTest exposing (..)


tests : Test
tests =
    suite "Some Test"
        [ test "Something is true" (assert False)
        ]

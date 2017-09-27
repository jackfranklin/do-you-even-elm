module Example exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import DoYouEvenElmTests


suite : Test
suite =
    DoYouEvenElmTests.all

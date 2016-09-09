module Tests exposing (..)

import ElmTest exposing (..)
import FooTest


all : Test
all =
    suite "A Test Suite"
        [ FooTest.tests
        ]

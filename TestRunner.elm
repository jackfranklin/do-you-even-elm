module TestRunner exposing (..)

import ElmTest exposing (runSuite)
import Tests


main : Program Never
main =
    runSuite Tests.all

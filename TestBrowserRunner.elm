module BrowserTestRunner exposing (..)

import ElmTest exposing (runSuiteHtml)
import Tests


main : Program Never
main =
    runSuiteHtml Tests.all

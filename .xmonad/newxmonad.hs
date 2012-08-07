import XMonad
import Data.Monoid
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myTerminal = "urxvt"

myFocusFollowsMouse :: Bool
myFocusFollowsMouse     = True

myBorderWidth           = 1
myNormalBorderColor     = "#dddddd"
myFocusedBorderColor    = "#ff0000"

myModMask               = mod4Mask

myWorkspaces =
    [ "1" 
    , "2"
    , "3"
    , "4"
    , "5"
    , "6"
    , "7"
    , "8"
    , "9"
    ]

myKeys conf@(XConfig {XMonad.modMask = modm})


main = do
    xmonad $ defualtConfig
        { modMask = mod4Mask
        , terminal = myTerminal
        }

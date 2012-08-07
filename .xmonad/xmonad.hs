--
-- Xmonad configuration file
--   overrides some defaults and adds a few more functionalities
 
import XMonad
import XMonad.Core
 
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Prompt.Man
 
import XMonad.Layout
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
 
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.SetWMName
import XMonad.Hooks.ICCCMFocus
 
import XMonad.Util.EZConfig
import XMonad.Util.Run
import Graphics.X11.Xlib
import qualified Data.Map as M
import System.IO

import qualified XMonad.Actions.FlexibleManipulate as Flex
 
main = do
   -- conkyBar <- spawnPipe myConkyBar
   myStatusBarPipe <- spawnPipe myStatusBar
   myDualheadStatusBarPipe <- spawnPipe myDualheadStatusBar
   xmonad $ myUrgencyHook $ defaultConfig
      { terminal = "urxvt"
      , normalBorderColor  = myInactiveBorderColor
      , focusedBorderColor = myActiveBorderColor
      , manageHook = manageDocks <+> myManageHook <+> manageHook defaultConfig
      , layoutHook = avoidStruts $ myLayoutHook
      , startupHook = setWMName "LG3D"
      , logHook = do 
            dynamicLogWithPP $ myDzenPP myStatusBarPipe  
            dynamicLogWithPP $ myDzenPP myDualheadStatusBarPipe
            takeTopFocus
      , modMask = mod4Mask
      , keys = myKeys
      , mouseBindings = myMouse
      , workspaces = myWorkspaces
      , borderWidth = 3
     }   
 
-- Paths
myBitmapsPath = "/home/jeff/.dzen/icons/"
 
-- Font
myFont = "-*-terminus-*-*-*-*-12-*-*-*-*-*-iso8859-*"
 
-- Colors
myBgBgColor = "black"
myFgColor = "gray80"
myBgColor = "gray20"
myHighlightedFgColor = "white"
myHighlightedBgColor = "gray40"
 
myActiveBorderColor = "gray80"
myInactiveBorderColor = "gray20"
 
myCurrentWsFgColor = "white"
myCurrentWsBgColor = "gray40"
myVisibleWsFgColor = "gray80"
myVisibleWsBgColor = "gray20"
myHiddenWsFgColor = "gray80"
myHiddenEmptyWsFgColor = "gray50"
myUrgentWsBgColor = "brown"
myTitleFgColor = "white"
 
myUrgencyHintFgColor = "white"
myUrgencyHintBgColor = "brown"
 
-- dzen general options
myDzenGenOpts = "-fg '" ++ myFgColor ++ "' -bg '" ++ myBgColor ++ "' -h '16'"
 
-- Status Bar
myStatusBar = "dzen2 -w 665 -ta l " ++ myDzenGenOpts

-- Dualhead
myDualheadStatusBar= "dzen2 -x 1920 -w 1820 " ++ myDzenGenOpts

-- Conky Bar
-- myConkyBar = "conky -c ~/.conkyrc | dzen2 -x 665 -w 1155 " ++ myDzenGenOpts
 
-- Layouts
myLayoutHook = smartBorders $ (tiled ||| Mirror tiled ||| Full)
  where
    tiled = ResizableTall nmaster delta ratio []
    nmaster = 1
    delta = 3/100
    ratio = 1/2
 
-- Workspaces
myWorkspaces =
   [
      "1-ARCH" ++ "",
      " 2-Web ",
      " 3-IRC ",
      " 4-Dev ",
      " 5-Piazza ",
      " 6 ",
      " 7 ",
      " 8-Game ",
      " 9-Music "
      -- wrapBitmap "sm4tik/mail.xbm" ++ "Web",
      -- wrapBitmap "sm4tik/pacman.xbm" ++ "IRC",
      -- wrapBitmap "sm4tik/bug_01.xbm" ++ "Dev",
      -- wrapBitmap "sm4tik/phones.xbm" ++ "Music",
      -- wrapBitmap "sm4tik/shroom.xbm" ++ "Game",
      -- wrapBitmap "sm4tik/cat.xbm",
      -- wrapBitmap "sm4tik/eye_l.xbm",
      -- wrapBitmap "sm4tik/eye_r.xbm"
   ]
   where
       wrapBitmap bitmap = "^p(5)^i(" ++ myBitmapsPath ++ bitmap ++ ")^p(5)"
 
-- Urgency hint configuration
myUrgencyHook = withUrgencyHook NoUrgencyHook --dzenUrgencyHook
--    {
--      args = [
--          "-x", "0", "-y", "576", "-h", "15", "-w", "1024",
--         "-ta", "r",
--         "-fg", "" ++ myUrgencyHintFgColor ++ "",
--         "-bg", "" ++ myUrgencyHintBgColor ++ ""
--         ]
--    }

myManageHook = composeAll
   [ 
    className =? "Gimp"    --> doFloat, 
    (className =? "Firefox" <&&> resource =? "Dialog") --> doFloat,
    appName =? "piazza.com__class"                    --> doShift " 5-Piazza ",
    appName =? "dev"                                  --> doShift " 4-Dev ",
    appName =? "music.google.com__music_listen"       --> doShift " 9-Music ",
    title =? "irssi"                                  --> doShift " 3-IRC "
   ]
 
-- Prompt config
myXPConfig = defaultXPConfig {
  position = Bottom,
  promptBorderWidth = 0,
  height = 15,
  bgColor = myBgColor,
  fgColor = myFgColor,
  fgHLight = myHighlightedFgColor,
  bgHLight = myHighlightedBgColor
  }
 
-- Union default and new key bindings
myKeys x  = M.union (M.fromList (newKeys x)) (keys defaultConfig x)
 
-- Add new and/or redefine key bindings
newKeys conf@(XConfig {XMonad.modMask = modm}) = [
  -- Use shellPrompt instead of default dmenu
  ((modm, xK_p), shellPrompt myXPConfig),
  -- Do not leave useless conky, dzen and xxkb after restart
  ((modm, xK_q), spawn "killall conky dzen2 xxkb; xmonad --recompile; xmonad --restart"),
  -- Focus Urgency
  ((modm, xK_BackSpace), focusUrgent),
  ((modm .|. shiftMask, xK_BackSpace), clearUrgents),
  -- Volume control buttons
  ((0, 0x1008ff13), spawn "amixer set Master 5+"),
  ((0, 0x1008ff11), spawn "amixer set Master 5-"),
  ((0, 0x1008ff12), spawn "~/.xmonad/mute")
   ]

-- Union default and new mouse bindings
myMouse x = M.union(mouseBindings defaultConfig x) (M.fromList (newMouse x))

-- Add new/or redefine key bindings
newMouse conf@(XConfig {XMonad.modMask = modm}) = [
  -- Resize and move floating windows
  ((modm, button1), (\w -> focus w >> Flex.mouseWindow Flex.linear w)),
  -- mod + middle click kills windows
  ((modm, button3), (\w -> focus w >> kill))
  ]
 
-- Dzen config
myDzenPP h = defaultPP {
  ppOutput = hPutStrLn h,
  ppSep = "^bg(" ++ myBgBgColor ++ ")^r(1,15)^bg()",
  ppWsSep = "",
  ppCurrent = wrapFgBg myCurrentWsFgColor myCurrentWsBgColor,
  ppVisible = wrapFgBg myVisibleWsFgColor myVisibleWsBgColor,
  ppHidden = wrapFg myHiddenWsFgColor,
  ppHiddenNoWindows = wrapFg myHiddenEmptyWsFgColor,
  ppUrgent = wrapBg myUrgentWsBgColor,
  ppTitle = (\x -> " " ++ wrapFg myTitleFgColor x),
  ppLayout  = dzenColor myFgColor"" .
                (\x -> case x of
                    "ResizableTall" -> wrapBitmap "rob/tall.xbm"
                    "Mirror ResizableTall" -> wrapBitmap "rob/mtall.xbm"
                    "Full" -> wrapBitmap "rob/full.xbm"
                )
  }
  where
    wrapFgBg fgColor bgColor content= wrap ("^fg(" ++ fgColor ++ ")^bg(" ++ bgColor ++ ")") "^fg()^bg()" content
    wrapFg color content = wrap ("^fg(" ++ color ++ ")") "^fg()" content
    wrapBg color content = wrap ("^bg(" ++ color ++ ")") "^bg()" content
    wrapBitmap bitmap = "^p(5)^i(" ++ myBitmapsPath ++ bitmap ++ ")^p(5)"

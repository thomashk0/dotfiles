module Main (main) where

import           Control.Monad                     (when, liftM2)
import           System.Environment                (getArgs, getExecutablePath)
import           System.Exit                       (exitSuccess)

import           XMonad
import           XMonad.Actions.CycleWS            (nextScreen, shiftNextScreen)
import qualified XMonad.Actions.FindEmptyWorkspace as A
import           XMonad.Actions.Search             (google, promptSearch,
                                                    scholar, youtube)
import           XMonad.Config.Xfce                (xfceConfig, desktopLayoutModifiers)
import           XMonad.Hooks.SetWMName            (setWMName)
import           XMonad.Hooks.ManageHelpers        (composeOne, isDialog, (-?>))
import           XMonad.Layout.Dishes
import           XMonad.Layout.ThreeColumns
import           XMonad.Prompt.ConfirmPrompt       (confirmPrompt)
import           XMonad.Prompt.Input
import           XMonad.Prompt.Man
import qualified XMonad.StackSet                   as W
import           XMonad.Util.Replace               (replace)
import           XMonad.Util.Run                   (runInTerm, safeSpawn)

import           KeyBindings

-- TODO: Synchronize with cabal version
version :: (Int, Int)
version = (2, 8)

versionStr :: String
versionStr = "my-xmonad " ++ show major ++ "." ++ show minor
  where (major, minor) = version

workspacesNames :: [String]
workspacesNames = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]

-- This is keycodes associated to numbers with a bepo keyboard layout
bepoNumKeys :: [KeySym]
bepoNumKeys = [0x22, 0xab, 0xbb, 0x28, 0x29, 0x40, 0x2b, 0x2d, 0x2f, 0x2a]

-- | PATH environment variable has to be set properly for dmenu to execute
--
-- NOTE: there seems to be a dmenu module in XMonad
dmenuCmd :: String
dmenuCmd = "dmenu_run -b"

ceaWhoIsPrompt :: X ()
ceaWhoIsPrompt =
    inputPrompt def "ceawhois" ?+ \args ->
      runInTerm "" (quoted (cmd ++ args ++ " | less"))
    where
      quoted s = "\"" ++ s ++ "\""
      localDir d = "/mnt/nobackup/th243905/home/" ++ d
      cmd =
        localDir ".local/share/virtualenvs/tools/bin/ceawhois"
        ++ " --db " ++ localDir "cache/ceawhois/cea-directory.sqlite "

-- Using the KeyBindings module, we define the bindinds and their documentation
-- at the same time!
keyBindings :: XConfig Layout -> KeyBindings
keyBindings conf@XConfig {modMask = modm} = bindings
  where
    bindings = sections
      [ section "navigation"
          [ (modm, xK_r) -=> windows W.focusUp <?> "move up"
          , (modm, xK_s) -=> windows W.focusDown <?> "move down"
          , (modm, xK_m) -=> windows W.focusMaster <?> "focus master"]
      , section "layout modification"
          [ (modm, xK_l) -=> withFocused (windows . W.sink) <?> "push the current (floating) window back into tiling"
          , (modm .|. shiftMask, xK_m) -=> windows W.swapMaster <?> "swap the current and the master windows"
          , (modm .|. shiftMask, xK_r) -=> windows W.swapUp <?> "swap with the window above"
          , (modm .|. shiftMask, xK_s) -=> windows W.swapDown <?> "swap with the window below"

          , (modm, xK_t) -=> sendMessage Shrink <?> "shrink the master area"
          , (modm, xK_n) -=> sendMessage Expand <?> "expand the master area"
          , (modm, xK_a) -=> sendMessage (IncMasterN 1) <?> "increment the number of master"
          , (modm, xK_u) -=> sendMessage (IncMasterN (-1)) <?> "decrement the number of master"

          , (modm, xK_p) -=> sendMessage NextLayout <?> "cycle through layouts"
          , (modm .|. shiftMask, xK_p) -=> setLayout (layoutHook conf) <?> "reset the layout on the current workspace to default"
          , (modm, xK_j) -=> refresh <?> "force layout refresh"
          ]
      , section "workspace and screens" $
          [ (modm, xK_e) -=> A.viewEmptyWorkspace <?> "move to any empty workspace"
          , (modm .|. shiftMask, xK_e) -=> A.tagToEmptyWorkspace <?> "move window to any empty workspace"
          , (modm, xK_g) -=> nextScreen <?> "move to next screen"
          , (modm .|. shiftMask, xK_g) -=> ( shiftNextScreen >> nextScreen) <?> "shift screen"
          ] ++ [(modm, k) -=> windows (W.greedyView i) <?> ("move to desktop " ++ i)
               | (i, k) <- zip (workspaces conf) bepoNumKeys]
            ++ [(modm .|. shiftMask, k) -=> windows (W.shift i) <?> ("move window to desktop " ++ i)
               | (i, k) <- zip (workspaces conf) bepoNumKeys]
      , section "interactions"
          [ (modm .|. shiftMask, xK_c) -=> kill <?> "kill current window"
          , (modm, xK_q) -=> restartWM <?> "restart XMonad (ask confirmation)"
          , (modm .|. shiftMask, xK_q) -=> confirmPrompt def "exit XMonad ?" (liftIO exitSuccess) <?> "leave XMonad (ask confirmation)"
          , (modm, xK_h) -=> showHelp <?> "check & show keybindings"
          ]
      , section "applications"
          [ (modm, xK_b) -=> spawn "xfce4-terminal -e zsh" <?> "start xfce4-terminal"
          , (modm, xK_d) -=> spawn dmenuCmd <?> "spawn dmenu"
          , (modm, xK_o) -=> ceaWhoIsPrompt <?> "prompt for ceawhois"
          , (modm, xK_f) -=> manPrompt def <?> "man prompt"
          , (modm, xK_y) -=> promptSearch def google <?> "google prompt"
          , (modm .|. shiftMask, xK_y) -=> promptSearch def scholar <?> "scholar prompt"
          , (modm, xK_x) -=> promptSearch def youtube <?> "youtube prompt"
          ]
      ]
    helpMsg = show bindings
    showHelp = do
      checkBindings bindings
      spawn ("echo \"" ++ helpMsg ++ "\" | xmessage -file -")

checkBindings :: KeyBindings -> X ()
checkBindings bindings =
  case reportDuplicates bindings of
    Nothing -> return ()
    Just errMsg ->
      safeSpawn
        "notify-send"
        ["There are duplicates in your XMonad keybindings", show errMsg]

restartWM :: X ()
restartWM = confirmPrompt def "restart XMonad?" $ do
  exePath <- liftIO getExecutablePath
  restart exePath True

customManageHook :: ManageHook
customManageHook = composeOne
    [ isDialog -?> doFloat
    , className =? "Firefox" -?> shiftTo "0"
    , className =? "Thunderbird" -?> shiftTo "9"
    , className =? "Thunar" -?> shiftTo "8"
    ]
    where shiftTo = doF . liftM2 (.) W.greedyView W.shift

layouts =  tiled |||
  Mirror tiled ||| Dishes 3 (1 / 6) ||| ThreeCol 1 (3 / 100) (1 / 2) ||| Full
  where
    tiled = Tall 1 (3 / 100) (1 / 2)

main :: IO ()
main = do
  args <- getArgs
  when ("--replace" `elem` args) replace
  putStrLn $ "Running with config " ++ versionStr

  -- Remap Caps_lock to mod2, the trick is explained here http://lists.suckless.org/dwm/0706/2715.html
  -- let remapCmd = unlines ["remove Lock = Caps_Lock", "clear mod2", "add Mod2 = Caps_Lock"]
  -- void $ runProcessWithInput "xmodmap" ["-e", "-"] remapCmd
  launch cfg
  where
    baseCfg = xfceConfig
    cfg =
        baseCfg
        { terminal = "xterm"
        , borderWidth = 2
        , keys = xMonadKeys . keyBindings
        , layoutHook = desktopLayoutModifiers layouts
        , workspaces = workspacesNames
        -- mod1Mask -> ALT Left (ergonomic, but collides with many apps...)
        -- mod4Mask -> Win
        , modMask = mod4Mask
        -- The following hook is needed for java GUI applications like Eclipse,
        -- IntelliJ to properly render teir fonts, ...
        , startupHook = startupHook baseCfg <+> setWMName "LG3D"
        , manageHook = customManageHook <+> manageHook baseCfg
        }

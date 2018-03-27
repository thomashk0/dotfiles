{-| Basic XMonad keybindings abstraction

The motivation for this is to provide a structured way to define keybindings.
A nice application is to generate generate documentation from the specification.

Todos:

  * Check redundancy
  * Better X key pretty printing
-}
{-# LANGUAGE OverloadedStrings #-}
module KeyBindings(
  -- * Simple keybinding type and its combinators
  Binding
  , (-=>)
  , (<?>)
  -- * Structured key bindings representation
  , KeyBindings
  , sections
  , section
  , flatten
  -- * Exporting
  , xMonadKeys
  , sample
  -- * Sanity checks
  , keyDuplicates
  , reportDuplicates
  )
  where

import           Data.Bits                    ((.&.))
import qualified Data.Map                     as M
import           Data.Monoid
import           Text.PrettyPrint.ANSI.Leijen (Doc, (<$$>), (<+>))
import qualified Text.PrettyPrint.ANSI.Leijen as PP
import           XMonad                       hiding ((<+>))

type SimpleBinding = ((KeyMask, KeySym), X ())

-- | Pack a key combination with its optional documentation
data Binding =
  Binding
  { simpleBinding :: SimpleBinding
  , bindingDoc    :: Maybe String
  }

infixl 5 -=>
-- | A simple key binding, which maps a key combination to an action in the
-- X monad.
(-=>) :: (KeyMask, KeySym) -> X () -> Binding
key -=> action = Binding (key, action) Nothing

infixl 4 <?>
-- | Add documentation to a binding
(<?>) :: Binding -> String -> Binding
(Binding b _) <?> doc = Binding b (Just doc)

ppMaybe :: (a -> Doc) -> Maybe a -> Doc
ppMaybe = maybe PP.empty

ppBinding :: Binding -> Doc
ppBinding binding@(Binding ((b, code), _) _) =
  ppKeyMask b <> ppKeySym code <> ppBindingDoc binding
  where
    ppBindingDoc :: Binding -> Doc
    ppBindingDoc (Binding _ doc) =
      ppMaybe (\x -> PP.empty <+> PP.parens (PP.text x)) doc

instance Show Binding where
    show = show . ppBinding

data KeyBindings =
    Sections [(String, KeyBindings)]
    | Bindings [Binding]

maskRepr :: M.Map KeyMask String
maskRepr = M.fromList
  [ (noModMask, "")
  , (shiftMask, "shift")
  , (lockMask, "capslock")
  , (controlMask, "ctrl")
  , (mod1Mask, "alt")
  , (mod2Mask, "numlock")
  , (mod3Mask, "mod3")
  , (mod4Mask, "mod4")
  , (mod5Mask, "mod5")
  ]

ppKeyMask :: KeyMask -> Doc
ppKeyMask m
  | M.null masks = PP.empty
  | otherwise =
      PP.hcat (PP.punctuate (spaced "+") (map PP.text (M.elems masks)))
      <+> ""
  where
    -- Externalize if needed
    spaced x = PP.empty <+> x <+> PP.empty

    hasMask mask = (m .&. mask) /= 0
    masks = M.filterWithKey (\k _ -> hasMask k) maskRepr

ppKeyBindings :: KeyBindings -> Doc
ppKeyBindings (Bindings bs) = PP.vsep $ map f bs
  where
    f (Binding ((b, code), _) doc) =
      PP.fill 12 (ppKeyMask b)
      <> PP.fill 5 (ppKeySym code)
      <+> maybe PP.empty (\x -> PP.empty <+> PP.parens (PP.text x)) doc
ppKeyBindings (Sections xs) = PP.align $
  PP.vsep [PP.text t <$$> PP.indent 4 (ppKeyBindings b) | (t, b) <- xs]

instance Show KeyBindings where
    show = show . ppKeyBindings

-- | String representation for basic symbols
keySymRepr :: M.Map KeySym String
keySymRepr = M.fromList
    [ (xK_a, "a")
    , (xK_b, "b")
    , (xK_c, "c")
    , (xK_d, "d")
    , (xK_e, "e")
    , (xK_f, "f")
    , (xK_g, "g")
    , (xK_h, "h")
    , (xK_i, "i")
    , (xK_j, "j")
    , (xK_k, "k")
    , (xK_l, "l")
    , (xK_m, "m")
    , (xK_n, "n")
    , (xK_o, "o")
    , (xK_p, "p")
    , (xK_q, "q")
    , (xK_r, "r")
    , (xK_s, "s")
    , (xK_t, "t")
    , (xK_u, "u")
    , (xK_v, "v")
    , (xK_w, "w")
    , (xK_x, "x")
    , (xK_y, "y")
    , (xK_z, "z")
    ]

ppKeySym :: KeySym -> Doc
ppKeySym k =
    case M.lookup k keySymRepr of
      Nothing -> "code:" <> PP.int (fromIntegral k)
      Just x  -> PP.text x

-- | Get a flat list of bindings from keybindings
flatten :: KeyBindings -> [Binding]
flatten (Sections xs) = concatMap (flatten . snd) xs
flatten (Bindings xs) = xs

-- | Return a list of duplicated bindings
keyDuplicates :: KeyBindings -> [[Binding]]
keyDuplicates bs = filter ((> 1) . length) $ M.elems tmp
  where
    tmp :: M.Map (KeyMask, KeySym) [Binding]
    tmp = M.fromListWith (++) [(k, [v]) | v@(Binding (k, _) _) <- flatten bs]

reportDuplicates :: KeyBindings -> Maybe Doc
reportDuplicates bindings =
  case keyDuplicates bindings of
    [] -> Nothing
    bs -> Just $ PP.vsep $ map report bs
  where
    report :: [Binding] -> Doc
    report [] = error "cannot be empty"
    report bs@(Binding ((m, k), _) _:_) =
      ppKeyMask m <> PP.fill 5 (ppKeySym k) <+>
      PP.align (PP.vsep (map ppBindingDoc bs))

    ppBindingDoc :: Binding -> Doc
    ppBindingDoc (Binding _ doc) =
      ppMaybe (\x -> PP.empty <+> PP.text x) doc

-- | Generate a XMonad key bindings dictionary to be passed directly in
-- the config
xMonadKeys :: KeyBindings -> M.Map (KeyMask, KeySym) (X ())
xMonadKeys = M.fromList . map simpleBinding . flatten

sections :: [(String, KeyBindings)] -> KeyBindings
sections = Sections

section :: String -> [Binding] -> (String, KeyBindings)
section s bs = (s, Bindings bs)

sample :: KeyBindings
sample =
  sections
    [ section "movements"
        [ (mod1Mask .|. shiftMask, xK_y) -=> return ()
        , (mod1Mask , xK_x) -=> return () <?> "open a google prompt" ]
    , section "spawning processes"
      [ (mod1Mask, xK_h) -=> return () <?> "show help popup" ]
    , section "dummy section, contains duplicated code"
      [ (mod1Mask, xK_h) -=> return () <?> "duplicated show help popup" ]
    ]

module Util exposing (..)


unwrapMaybe : Maybe a -> a
unwrapMaybe maybe =
    case maybe of
        Nothing ->
            Debug.crash "Unwrapped a Nothing"

        Just a ->
            a

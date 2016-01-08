import Graphics.Element exposing (Element, show)
import Http
import Task exposing (..)
import Json.Decode as Json exposing ((:=))
import Maybe
import Debug

couchDecode : Json.Decoder (Int)
couchDecode = "last_seq" := Json.int
    
fetch : Task Http.Error (Int)
fetch = Http.get couchDecode ("http://127.0.0.1:5984/rmlib/_changes?feed=longpoll&timeout=60000&heartbeat=true")
{- "&include_docs=true" -}

mailbox : Signal.Mailbox Int
mailbox = Signal.mailbox 0

render : Int -> Task x ()
render seq = Signal.send mailbox.address seq

port fetchChanges : Task Http.Error ()
port fetchChanges = loop

loop = fetch `andThen` render `andThen` \_ -> Debug.log "hi!" loop 

main : Signal Element
main = Signal.map show mailbox.signal 


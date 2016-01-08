module CouchDB where

import Graphics.Element exposing (show)
import Http
import Json.Decode as JD exposing ((:=))
import Json.Encode as JE
import Task exposing (Task, andThen, toResult, toMaybe)
import Base64

import Debug

type alias Config = 
  {
    dbhost : String
    , db     : String
    , user   : String
    , pass   : String
  }

config : Config
config = 
  {
    dbhost = "http://localhost:5984"
    , db   = "qts"
    , user = "root"
    , pass = "root123"
  }

type alias State =
 {
   session   : Maybe String
   -- The seq number/id of the last seen _changes event
   last_seen : String
 }

type Cmd = 
  Login
  | Logout
  | Changes


login : Task Http.Error Bool
login = 
  let req =
    {
      verb = "POST"
      , headers = [("Content-Type", "application/json")]
      , url = (config.dbhost ++ "/_session")
      , body = Http.string
                (JE.encode 0 
                  (JE.object 
                    [("name",     (JE.string config.user)), 
                     ("password", (JE.string config.pass))
                    ]))
    }
  in 
    Http.fromJson ("ok" := JD.bool) (Http.send Http.defaultSettings req)

changes : Task Http.Error (List String)
changes =
  let req =
    {
        verb = "GET",
        headers = [],
        url = config.dbhost ++ "/" ++ config.db ++ "/_changes?feed=longpoll",
        body = Http.empty
    }
  in 
    Http.fromJson (JD.list JD.string) (Http.send Http.defaultSettings req)


doLogin : Task x (Result Http.Error Bool)
doLogin =
  Task.toResult login

doChanges : Task x (Result Http.Error (List String))
doChanges = 
  Task.toResult changes

port runner : Task x ()
port runner =
  doLogin
    `andThen` \status -> doChanges
    `andThen` \result -> Debug.log result


main =
  show "Open the Developer Console of your browser."

-- vim: ts=2:sw=2:et

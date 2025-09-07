import Network.Socket
import Network.Socket.ByteString (sendAll, recv)
import qualified Data.ByteString.Char8 as C

main :: IO ()
main = do
    let host = "localhost"
        port = "5882"

    addrInfos <- getAddrInfo (Just defaultHints { addrFlags = [AI_ADDRCONFIG] }) (Just host) (Just port)
    let serverAddr = head addrInfos

    sock <- socket (addrFamily serverAddr) Stream defaultProtocol
    connect sock (addrAddress serverAddr)

    putStrLn $ "Connected to " ++ host ++ ":" ++ port

    sendAll sock (C.pack "Hello from client!")
    response <- recv sock 1024

    c.putStrLn $ "Received: "  `C.append` response

    close sock
    putStrLn "Connection closed."

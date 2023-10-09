{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use infix" #-}
import System.IO
    ( hFlush, hGetContents, openFile, stdout, IOMode(ReadMode) )
import System.Random ( getStdGen, Random(randomR), StdGen )
import Control.Monad ( when )


--- TODO: 
---       Allow user to choose easy/hard mode (if the guess has to be a word)
main :: IO ()
main = do
    putStrLn "Wilkommen zu Wortle"
    putStrLn "============================"
    putStrLn "(4) heiss"
    putStrLn "    *+---"
    putStrLn "Sie haben 4 weitere Versuche."
    putStrLn "Das 'h' ist im Wort und an der richtigen Stelle."
    putStrLn "Das 'e' ist im Word aber an der falschen Stelle."
    putStrLn "Das 'i' und das 's' sind nicht im Wort."
    putStrLn ""
    starter_gen <- getStdGen
    preGameInstructions starter_gen
    

preGameInstructions :: StdGen -> IO ()
preGameInstructions gen = do
    handle <- openFile "Wortliste.txt" ReadMode
    wordString <- hGetContents handle
    let word_list = lines wordString 
    wordLength <- prompt "Möchten Sie ein Wort mit einer bestimmeten Länge? Wenn ja, wähl eine Zahl.\n"
    let winnowed_word_list = filterWordList word_list wordLength
    guessAmt <- prompt "Wie viele Versuche solle ich Ihnen geben? Der Standard ist 5.\n"
    if not (null guessAmt) && all (`elem` "1234567890") guessAmt 
        then pickSecretWord winnowed_word_list gen (read guessAmt) 
        else pickSecretWord winnowed_word_list gen 5


prompt :: String -> IO String
prompt str = do
    putStr str
    hFlush stdout
    getLine


pickSecretWord :: [[Char]] -> StdGen -> Int -> IO ()
pickSecretWord words gen guesses = do
    let (index, newGen) = randomR (0, length words - 1) gen :: (Int, StdGen)
    putStrLn ("Das Wort hat " ++ show (length (words !! index)) ++ " Buchstaben.")
    getGuess guesses (words !! index) newGen words 


getGuess :: (Eq t, Num t, Show t) => t -> [Char] -> StdGen -> [[Char]] -> IO ()
getGuess count word nextGen words
    | count == 0 = do
        putStrLn ("Sie haben verloren... Das Wort ist " ++ word ++ ".")
        askCont words nextGen
    | otherwise = do 
        guess <- prompt ("(" ++ show count ++ ") ")
        if guess == word then do
            putStrLn "Sie haben gewonnen..."
            askCont words nextGen
        else if length guess > length word then do
            putStrLn "Das Wort ist nicht so lang! Versuch es wieder."
            getGuess count word nextGen words
        else if length guess < length word then do
            putStrLn "Das Wort ist noch länger! Versuch es wieder."
            getGuess count word nextGen words
        else do
            let clue = genHint word 0 guess
            putStrLn ("    " ++ clue)
            getGuess (count-1) word nextGen words


genHint :: [Char] -> Int -> [Char] -> [Char]
genHint _ _ [] = []
genHint word ind (g:gs)
    | word !! ind == g = '*' : genHint word (ind+1) gs
    | elem g word = '+' : genHint word (ind+1) gs
    | otherwise = '-' : genHint word (ind+1) gs


askCont :: [[Char]] -> StdGen -> IO ()
askCont words gen = do 
    continue <- prompt "Möchten Sie wiederspielen? (j/n): "
    when (continue == "j") (preGameInstructions gen)


filterWordList :: [[Char]] -> [Char] -> [[Char]]
filterWordList dict len
    | not (null len) && all (`elem` "1234567890") len = [x | x <- dict, length x == read len]
    | otherwise = dict
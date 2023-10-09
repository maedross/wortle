{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use infix" #-}
import System.IO
    ( hFlush, hGetContents, openFile, stdout, IOMode(ReadMode) )
import System.Random ( getStdGen, Random(randomR), StdGen )
import Control.Monad ( when )
import Control.Applicative (Alternative(empty))
import GHC.Data.StringBuffer (StringBuffer(len), decodePrevNChars)
import GHC.CmmToAsm.AArch64.Instr (x0)

--- TODO: 
---       Allow user to choose number of guesses
---       Allow user to choose easy/hard mode (if the guess has to be a word)
main :: IO ()
main = do
    putStrLn "Wilkommen zu Wortle"
    putStrLn "============================"
    putStrLn "(4) watts"
    putStrLn "    *+---"
    putStrLn "Sie haben 4 weitere Versuche."
    putStrLn "Das 'w' ist im Wort und an der richtigen Stelle."
    putStrLn "Das 'a' ist im Word aber an der falschen Stelle."
    putStrLn "Das 't' und das 's' sind nicht im Wort."
    putStrLn ""
    preGameInstructions
    

preGameInstructions :: IO ()
preGameInstructions = do
    handle <- openFile "Wortliste.txt" ReadMode
    wordString <- hGetContents handle
    let word_list = lines wordString 
    printWords word_list
    wordLength <- prompt "Möchten Sie ein Wort mit einer bestimmeten Länge? Wenn ja, wähl eine Zahl, sonst drück die Eingabetaste.\n"
    let winnowed_word_list = filterWordList word_list wordLength
    printWords winnowed_word_list
    starter_gen <- getStdGen
    pickSecretWord winnowed_word_list starter_gen


printWords :: [[Char]] -> IO ()
printWords [] = do
    putStrLn ""
printWords (x:xs) = do 
    putStrLn x
    printWords xs


prompt :: String -> IO String
prompt str = do
    putStr str
    hFlush stdout
    getLine


pickSecretWord :: [[Char]] -> StdGen -> IO ()
pickSecretWord words gen = do
    let (index, newGen) = randomR (0, length words) gen :: (Int, StdGen)
    putStrLn ("Words: " ++ show words ++ "\nIndex: " ++ show index)
    getGuess 5 (words !! index) newGen words


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
    when (continue == "j") preGameInstructions


filterWordList :: [[Char]] -> [Char] -> [[Char]]
filterWordList dict len
    | all (`elem` "1234567890") len = [x | x <- dict, length x == read len]
    | otherwise = dict
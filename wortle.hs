{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use infix" #-}
import System.IO
    ( hFlush, hGetContents, openFile, stdout, IOMode(ReadMode) )
import System.Random ( getStdGen, Random(randomR), StdGen )
import Control.Monad ( when )

--- TODO: Allow user to choose length of word
---       Allow user to choose number of guesses
---       Use word length to winnow word list
---       Allow user to choose easy/hard mode
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

    handle <- openFile "Wortliste.txt" ReadMode
    wordString <- hGetContents handle
    let word_list = lines wordString 
    let winnowed_word_list = [x | x <- word_list, length x == 5]
    starter_gen <- getStdGen
    pickSecretWord winnowed_word_list starter_gen


prompt :: String -> IO String
prompt str = do
    putStr str
    hFlush stdout
    getLine

pickSecretWord :: [[Char]] -> StdGen -> IO ()
pickSecretWord words gen = do
    let (index, newGen) = randomR (0, length words) gen :: (Int, StdGen)
    getGuess 6 (words !! index) newGen words

--- TODO: Require guesses to be words
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
            putStrLn ("    " ++ genHint word 0 guess)
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
    when (continue == "j") (pickSecretWord words gen)
function printTitle() {
    Clear-Host
    Write-Host "`n`t*******************************"
    Write-Host "`t******** H A N G M A N ********"
    Write-Host "`t*******************************"
    Write-Host "`t***** Type 'quit' to exit *****"
    Write-Host "`t*******************************`n"
}
function printGallows($BadGuesses) {
    Write-Host "`n`t`t________"

    switch ($BadGuesses) {
        0 {
            Write-Host "`t`t|"
            Write-Host "`t`t|"
            Write-Host "`t`t|"
            Write-Host "`t`t|"
        }

        1 {
            Write-Host "`t`t|      |"
            Write-Host "`t`t|"
            Write-Host "`t`t|"
            Write-Host "`t`t|"
        }

        2 {
            Write-Host "`t`t|      |"
            Write-Host "`t`t|      O"
            Write-Host "`t`t|"
            Write-Host "`t`t|"
        }

        3 {
            Write-Host "`t`t|      |"
            Write-Host "`t`t|      O"
            Write-Host "`t`t|      |"
            Write-Host "`t`t|"
        }

        4 {
            Write-Host "`t`t|      |"
            Write-Host "`t`t|     \O"
            Write-Host "`t`t|      |"
            Write-Host "`t`t|"
        }

        5 {
            Write-Host "`t`t|      |"
            Write-Host "`t`t|     \O/"
            Write-Host "`t`t|      |"
            Write-Host "`t`t|"
        }

        6 {
            Write-Host "`t`t|      |"
            Write-Host "`t`t|     \O/"
            Write-Host "`t`t|      |"
            Write-Host "`t`t|     /"
        }

        7 {
            Write-Host "`t`t|      |"
            Write-Host "`t`t|     \O/"
            Write-Host "`t`t|      |"
            Write-Host "`t`t|     / \"
        }
    }

    Write-Host "`t`t|__________"
}

function printGuessedLetters($LetterArray) {
    Write-Host -NoNewLine "`n`tGuessed Letters:`n`n`t"
    $LetterArray.foreach( {
            Write-Host -NoNewline "$_ "
        })
    Write-Host
}

function getWord() {
    $html = Invoke-RestMethod -Method Get -Uri "https://creativitygames.net/random-word-generator/randomwords/1"
    $element = '<li id="randomword_1">(?<word>.*)</li>'
    
    $res = $html -match $element
    
    if ($res -eq $true) {
        $word = $Matches['word']
    }

    return $word -replace " ", ""
}

function getWordProgress($SecretWord, $GuessedLetters) {
    return (
        $SecretWord.ToCharArray().forEach( { 
                if ($GuessedLetters.Contains($_.tostring())) { $_ } else { "_" } 
            }) -join "  "
    )
}

function isGuessCorrect($SecretWord, $GuessedLetter) {
    if ($SecretWord.Contains($GuessedLetter)) { return $true }
    return $false
}


$new_word = getWord
$guesses = @()
$badGuesses = 0

do {
    printTitle
    printGallows($badGuesses)
    printGuessedLetters($guesses)

    $progress = getWordProgress -SecretWord $new_word -GuessedLetters $guesses
    
    if (($progress -replace " ", "") -eq $new_word) {
        Write-Host "`n`n`tYou Win!"
        Write-Host "`n`tThe word was: $new_word"
        $res = Read-Host "`n`tWould you like to play again? (y/n)"
        if ($res -ne "n") {
            $new_word = getWord
            $guesses = @()
            $badGuesses = 0
        }
        continue
    }
    
    Write-Host "`n`n`t`t$progress"
    $guess = Read-Host "`n`n`tGuess a letter"

    if ($guess -eq "quit") { exit }

    if ($guesses -notcontains $guess) {
        $guesses += $guess
        if ((isGuessCorrect -SecretWord $new_word -GuessedLetter $guess) -ne $true) {
            $badGuesses++ 
        }
    }

    if ($badGuesses -gt 6) {
        Write-Host "`n`n`tSorry you lose."
        Write-Host "`n`n`tThe word was $new_word"
        $res = Read-Host "`n`tWould you like to play again? (y/n)"
        if ($res -ne "n") {
            $new_word = getWord
            $guesses = @()
            $badGuesses = 0
        }
    }
    
} while ($res -ne "n")




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
            Write-Host "`t`t|      O"
            Write-Host "`t`t|     /|\"
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
    $API_BASE_URL = "https://api.api-ninjas.com/v1"

    $url = "$API_BASE_URL/randomword"

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("X-Api-Key", "XvnUKuPUySl6NYWeTpzygw==XW2KDStBDDWXeM9j")
    
    try {
        $response = Invoke-RestMethod $url -Method Get -Headers $headers
        $word = $response.word.ToLower()

        return $word

    } catch {
        Write-Host "`n`tGET Error: $_"
        exit
    }
}

function getWordProgress($SecretWord, $GuessedLetters) {
    return (
        $SecretWord.ToCharArray().forEach( { 
                if ($GuessedLetters.Contains($_.tostring())) { $_ } elseif ("- " -match $_) { $_ } else { "_" } 
            }) -join "  "
    )
}

function isGuessCorrect($SecretWord, $GuessedLetter) {
    if ($SecretWord.Contains($GuessedLetter)) { return $true }
    return $false
}

# initialize game variables
# character array from a to z (lowercase)
$validGuesses = ( -join ((97..122) | ForEach-Object { [char]$_ })).ToCharArray()
$new_word = getWord # get a new word
$guesses = @() # clear the array of guessed letters
$badGuesses = 0 # reset number of incorrect guesses

do {
    printTitle
    printGallows($badGuesses)
    printGuessedLetters($guesses)

    # convert the secret word to blanks
    # then fill the blanks that the user has guessed correctly
    $progress = getWordProgress -SecretWord $new_word -GuessedLetters $guesses
    
    # check to see if the user got all of the letters yet
    if (($progress -replace " ", "" ) -eq ($new_word -replace " ", "")) {
        Write-Host "`n`n`tYou Win!"
        Write-Host "`n`tThe word was: $new_word"
        $res = Read-Host "`n`tWould you like to play again? (y/n)"
        if ($res -ne "n") {
            # reset game
            $new_word = getWord
            $guesses = @()
            $badGuesses = 0
        }
        continue
    }

    Write-Host "`n`n`t`t$progress"
    
    # get the next guess from the user
    do {
        
        $guess = (Read-Host "`n`n`tGuess a letter").ToLower()

        if ($guess -eq "quit") { exit }

        # validate the user input
        if ($guess.Length -gt 1) {
            Write-Host "`n`tPlease enter a single letter only"
            $guess = $null
        } elseif ( $validGuesses -notcontains $guess) {
            Write-Host "`n`tPlease enter a letter between 'a' and 'z'"
            $guess = $null
        }

    } while ($null -eq $guess)
    
    # count the guesses
    if ($guesses -notcontains $guess) {
        $guesses += $guess
        if ((isGuessCorrect -SecretWord $new_word -GuessedLetter $guess) -ne $true) {
            $badGuesses++ 
        }
    }

    # user loses after 6 guesses
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




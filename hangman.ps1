function printTitle($ScreenWidth) {
    Clear-Host

    $title = "*****************************************************"
    $padding = Get-Padding -ScreenWidth $ScreenWidth -TextWidth $title.Length

    $title = "`n$padding$title"
    $title = "$title`n$padding******** P O W E R S H E L L - H A N G M A N ********"
    $title = "$title`n$padding***************    by Alan Van Art    ***************"
    $title = "$title`n$padding*****************************************************"
    $title = "$title`n$padding**************** Type 'quit' to exit ****************"
    $title = "$title`n$padding*****************************************************`n"

    Write-Host $title
}

function printGallows($BadGuesses, $ScreenWidth) {
    $gallows = "|__________" # full-width base
    $padding = Get-Padding -ScreenWidth $ScreenWidth -TextWidth $gallows.Length

    $gallows = "`n$padding`________"

    switch ($BadGuesses) {
        0 {
            $gallows = "$gallows`n$padding|"
            $gallows = "$gallows`n$padding|"
            $gallows = "$gallows`n$padding|"
            $gallows = "$gallows`n$padding|"
        }

        1 {
            $gallows = "$gallows`n$padding|      |"
            $gallows = "$gallows`n$padding|"
            $gallows = "$gallows`n$padding|"
            $gallows = "$gallows`n$padding|"
        }

        2 {
            $gallows = "$gallows`n$padding|      |"
            $gallows = "$gallows`n$padding|      O"
            $gallows = "$gallows`n$padding|"
            $gallows = "$gallows`n$padding|"
        }

        3 {
            $gallows = "$gallows`n$padding|      |"
            $gallows = "$gallows`n$padding|      O"
            $gallows = "$gallows`n$padding|      |"
            $gallows = "$gallows`n$padding|"
        }

        4 {
            $gallows = "$gallows`n$padding|      |"
            $gallows = "$gallows`n$padding|     \O"
            $gallows = "$gallows`n$padding|      |"
            $gallows = "$gallows`n$padding|"
        }

        5 {
            $gallows = "$gallows`n$padding|      |"
            $gallows = "$gallows`n$padding|     \O/"
            $gallows = "$gallows`n$padding|      |"
            $gallows = "$gallows`n$padding|"
        }

        6 {
            $gallows = "$gallows`n$padding|      |"
            $gallows = "$gallows`n$padding|     \O/"
            $gallows = "$gallows`n$padding|      |"
            $gallows = "$gallows`n$padding|     /"
        }

        7 {
            $gallows = "$gallows`n$padding|      |"
            $gallows = "$gallows`n$padding|      O"
            $gallows = "$gallows`n$padding|     /|\"
            $gallows = "$gallows`n$padding|     / \"
        }
    }

    $gallows = "$gallows`n$padding|__________"

    Write-Host $gallows
}

function Get-Padding($ScreenWidth, $TextWidth) {
    $padding_width = [int](($ScreenWidth - $TextWidth) / 2)
    $padding = (" " * $padding_width)
    return $padding
}

function printGuessedLetters($LetterArray, $ScreenWidth) {
    $position = Get-Padding -ScreenWidth $current_width -TextWidth 40

    $guessed_letters = "`n$position`Guessed Letters:`n`n$position"
    $LetterArray.foreach( {
            $guessed_letters = "$guessed_letters$_ "
        })
    
    Write-Host $guessed_letters
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

# initialize powershell console window size
$pshost = Get-Host
$pswindow = $pshost.UI.RawUI
$newsize = $pswindow.BufferSize
$newsize.Width = 60 # Set desired width
$newsize.Height = 32 # Set desired height

if ($null -ne $pswindow.WindowSize) {
    $pswindow.WindowSize = $newsize
    $pshost = Get-Host
    $pswindow = $pshost.UI.RawUI
    $current_width = $pswindow.WindowSize.Width
} else {
    $pshost = Get-Host
    $pswindow = $pshost.UI.RawUI
    $current_width = $pswindow.BufferSize.Width
}

# initialize game variables
# character array from a to z (lowercase)
$validGuesses = ( -join ((97..122) | ForEach-Object { [char]$_ })).ToCharArray()
$new_word = getWord # get a new word
$guesses = @() # clear the array of guessed letters
$badGuesses = 0 # reset number of incorrect guesses

do {
    printTitle($current_width)
    printGallows -BadGuesses $badGuesses -ScreenWidth $current_width
    printGuessedLetters -LetterArray $guesses -ScreenWidth $current_width

    # convert the secret word to blanks
    # then fill the blanks that the user has guessed correctly
    $progress = getWordProgress -SecretWord $new_word -GuessedLetters $guesses

    # user loses after 6 guesses
    if ($badGuesses -gt 6) {
        $message = "Would you like to play again? (y/n)"
        $padding = Get-Padding -ScreenWidth $current_width -TextWidth $message.Length

        $message = "`n`n$padding`Sorry you lose."
        Write-Host $message -ForegroundColor Red

        $message = "`n$padding`The word was $new_word"

        Write-Host $message

        $res = Read-Host "`n$padding`Would you like to play again? (y/n)"
        if ($res -ne "n") {
            $new_word = getWord
            $guesses = @()
            $badGuesses = 0
            continue
        } else { exit }
    }
    
    # check to see if the user got all of the letters yet
    if (($progress -replace " ", "" ) -eq ($new_word -replace " ", "")) {
        $message = "Would you like to play again? (y/n)"
        $padding = Get-Padding -ScreenWidth $current_width -TextWidth $message.Length

        $message = "`n`n$padding`You Win!"
        Write-Host $message -ForegroundColor Yellow

        $message = "`n$padding`The word was $new_word"

        Write-Host $message

        $res = Read-Host "`n$padding`Would you like to play again? (y/n)"
        if ($res -ne "n") {
            # reset game
            $new_word = getWord
            $guesses = @()
            $badGuesses = 0
        } else { exit }
        continue
    }

    $padding = Get-Padding -ScreenWidth $current_width -TextWidth ((($new_word.Length * 2) - 2) + $new_word.Length)
    Write-Host "`n`n$padding$progress"
    
    # get the next guess from the user
    do {
        $position = Get-Padding -ScreenWidth $current_width -TextWidth 40
        $guess = (Read-Host "`n`n$position`Guess a letter").ToLower()

        if ($guess -eq "quit") { exit }

        # validate the user input
        if ($guess.Length -gt 1) {
            $message = "Please enter a single letter only"
            $padding = Get-Padding -ScreenWidth $current_width -TextWidth $message.Length
            Write-Host "`n$padding$message"
            $guess = $null
        } elseif ( $validGuesses -notcontains $guess) {
            $message = "Please enter a letter between 'a' and 'z'"
            $padding = Get-Padding -ScreenWidth $current_width -TextWidth $message.Length
            Write-Host "`n$padding$message"
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
    
} while ($guess -ne "quit")




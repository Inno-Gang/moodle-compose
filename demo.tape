Output demo.gif

Set FontSize 32
Set Width 1400
Set Height 1400
Set FontFamily "Monaco"
Set Margin 32
Set MarginFill "#65b557"
Set BorderRadius 12
Set Framerate 24
Set TypingSpeed 100ms

Type "# Let's run Moodle locally!"
Enter
Sleep 1s

Type "./moodle-compose.sh"
Sleep 3s
Enter

# Moodle version
Sleep 3s
Type "4.1.2"
Sleep 1.5s
Enter

# Database type
Sleep 2s
Down
Sleep 1s
Up
Sleep 0.75s
Enter

# Moodle App
Sleep 2s
Down
Sleep 1s
Enter

Sleep 3s
Type "docker compose up"
Sleep 10s

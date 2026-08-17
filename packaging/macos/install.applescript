-- Clippy Pet installer app.
-- Runs the bundled clippy-pet CLI against the current user's
-- CODEX_HOME with no administrator privileges required.

property appName : "Clippy Pet"

on run
	set resourcesPath to (path to me as text) & "Contents:Resources:"
	set cliPosixPath to POSIX path of resourcesPath & "bin/clippy-pet"
	set dataPosixPath to POSIX path of resourcesPath & "share/clippy-pet"

	try
		set shellCommand to "CLIPPY_PET_DATA=" & quoted form of dataPosixPath & ¬
			" " & quoted form of cliPosixPath & " install --gui"
		do shell script shellCommand
		display dialog "Clippy Pet is installed." & return & return & ¬
			"Reload Codex, then open Settings > Pets > Clippy Pet (or run /pets clippy-pet in the Codex CLI TUI)." ¬
			with title appName buttons {"OK"} default button 1
	on error errMsg
		display dialog "Installing Clippy Pet failed:" & return & return & errMsg ¬
			with title appName buttons {"OK"} default button 1 with icon caution
	end try
end run

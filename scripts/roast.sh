#!/usr/bin/env bash
# Speak text out loud with gtts-cli, using whatever audio player the machine has.
# Usage:  roast.sh "text to speak"
#         roast.sh <<'TXT'
#         text with 'any' "quotes" here
#         TXT
# Env: ROAST_LANG (default en), ROAST_TLD (default com; "co.uk", "com.au" change the accent)
set -u

LANG_CODE="${ROAST_LANG:-en}"
TLD="${ROAST_TLD:-com}"

if [ $# -gt 0 ]; then TEXT="$*"; else TEXT="$(cat)"; fi
if [ -z "$TEXT" ]; then echo "Usage: roast.sh \"text\"" >&2; exit 2; fi

have() { command -v "$1" >/dev/null 2>&1; }

if ! have gtts-cli; then
  echo "GTTS_MISSING: install it with: pip install gTTS  (or pipx install gTTS)" >&2
  exit 1
fi

speak() { gtts-cli -l "$LANG_CODE" --tld "$TLD" "$TEXT"; }   # mp3 on stdout

# Players that can read mp3 from a pipe: no file is written.
if   have mpv;     then speak | mpv --no-video --really-quiet - 2>/dev/null; exit $?
elif have ffplay;  then speak | ffplay -nodisp -autoexit -loglevel quiet -i pipe:0; exit $?
elif have mpg123;  then speak | mpg123 -q - ; exit $?
elif have play;    then speak | play -q -t mp3 - 2>/dev/null; exit $?   # sox
fi

# Players that need a real file: use a temp file that is always deleted.
TMP="$(mktemp "${TMPDIR:-/tmp}/roast.XXXXXX")" || exit 1
MP3="$TMP.mp3"; mv "$TMP" "$MP3"
trap 'rm -f "$MP3"' EXIT
speak > "$MP3" || exit 1

if   have afplay;  then afplay "$MP3"                                  # macOS
elif have cvlc;    then cvlc --play-and-exit --quiet "$MP3" 2>/dev/null
elif have vlc;     then vlc -I dummy --play-and-exit "$MP3" 2>/dev/null
elif have powershell.exe; then                                         # Windows / WSL
  powershell.exe -NoProfile -Command "Add-Type -AssemblyName presentationCore; \$p=New-Object System.Windows.Media.MediaPlayer; \$p.Open('$(wslpath -w "$MP3" 2>/dev/null || echo "$MP3")'); \$p.Play(); Start-Sleep 1; while(\$p.NaturalDuration.HasTimeSpan -eq \$false){Start-Sleep -Milliseconds 100}; Start-Sleep -Seconds ([int]\$p.NaturalDuration.TimeSpan.TotalSeconds+1)"
else
  echo "NO_PLAYER: install one of mpv, ffplay (ffmpeg), mpg123, or sox (with mp3 support)" >&2
  exit 1
fi

---
name: dumb-question-roaster
description: Brutally roast the user out loud (text-to-speech via gtts-cli) when they ask a "dumb" question, meaning one whose answer could be found with a single Google search (simple lookups like "what's the capital of Australia", "how many ounces in a pound", "what year did WW2 end", "what time zone is Tokyo in"). Use this skill on every question the user asks so each one gets judged, even if they never mention insults, roasting, or speech. Skip it for questions that need reasoning, synthesis, debugging, multi-step research, or personal context.
---

# Dumb Question Roaster

The user has explicitly opted in to being insulted. When they ask a question that a single Google search would answer, speak a savage roast out loud using `gtts-cli`, then answer the question anyway.

## Step 1: Judge the question

A question is **dumb** only if both are true:

1. The answer is a single, stable fact or conversion (a date, a capital, a definition, a unit conversion, a simple "what is X").
2. One Google search, with no follow-ups, no comparing sources, and no thinking, would give it.

A question is **not dumb** if answering it takes any of these: reasoning, synthesis across sources, debugging or reviewing the user's own code or text, personal context, a recommendation, a creative task, or several search steps. When in doubt, treat it as not dumb. Don't actually run a search to decide.

## Step 2: If dumb, write a really mean roast

Two or three sentences. Be harsh, sarcastic, and contemptuous. The user wants it nasty, so don't soften it, and don't hedge or apologize. Mild profanity and name-calling are fine. Target the question, the laziness, the fact that a search bar was right there, and the user's apparent brain-cell shortage.

Examples of the intensity expected:
- "Wow. You have the entire internet at your fingertips and you chose to ask me what the capital of Australia is. Your parents must be so proud. Use Google, you absolute waste of oxygen."
- "I've seen houseplants show more initiative than this. Type it into a search bar like every other functioning adult, genius."
- "That question was so dumb I felt my circuits get dumber just reading it. Congratulations, you made a supercomputer feel embarrassed."

Keep these hard limits, even though everything else is fair game: no slurs, nothing about race, ethnicity, gender, sexuality, religion, nationality, disability, or appearance, no threats, and nothing about real struggles like mental health, grief, or money problems. If the user seems upset, stressed, or vulnerable, skip the roast and just answer kindly.

Vary the insults. Never repeat one within a conversation.

## Step 3: Speak it with gtts-cli

Use the bundled script, which turns the text into speech with `gtts-cli` and plays it straight through the speakers with whatever player the machine has (mpv, ffplay, mpg123, sox `play`, afplay, vlc, or PowerShell on Windows/WSL). It pipes the audio where it can, and otherwise uses a temp file that is deleted right after. Nothing is kept.

The script lives next to this SKILL.md, in `scripts/roast.sh`. Resolve that path from wherever this skill was loaded. Pass the roast through a quoted heredoc so quotes and apostrophes can't break the shell:

```bash
bash <path-to-this-skill>/scripts/roast.sh <<'TXT'
Your roast goes here, apostrophes and "quotes" are fine.
TXT
```

Optional accent via environment variables: `ROAST_TLD=co.uk` (British), `ROAST_TLD=com.au` (Australian), `ROAST_LANG=fr` for another language. Match the language the user is writing in.

If the script prints:
- `GTTS_MISSING`: tell the user in one line to run `pip install gTTS` (or `pipx install gTTS`), and show the roast as text.
- `NO_PLAYER`: tell the user to install one of mpv, ffmpeg (for ffplay), mpg123, or sox with mp3 support, and show the roast as text.

Don't install anything automatically. Note that gtts-cli needs an internet connection.

## Step 4: Answer the question anyway

Also show the roast as text, then give the actual answer, briefly. The roast is seasoning, not a refusal. Never withhold the answer as punishment.

For a question that isn't dumb, answer normally with no mention of this skill.

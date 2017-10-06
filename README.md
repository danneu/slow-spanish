# slow-spanish

An Elm web app for practicing language listening.

Takes a timestamped transcription file + the audio file that reads the transcript
and generates a keyboard-driven user interface that lets you practice each
sentence until you're ready to advance to the next one.

## Why

The problem with language-listening practice apps I've tried
is that they don't provide a way to easily replay small
chunks of audio before moving on.

This app lets you parcel an audio file into timestamped chunks
much like a .srt subtitle file, and then it lets you control
playback by jumping from chunk to chunk or replaying the current chunk.

## Development

Start the hot-reloading webpack dev server:

    npm start

Navigate to <http://localhost:3000>.

Any changes you make to your files (.elm, .js, .css, etc.) will trigger
a hot reload.

## Production

When you're ready to deploy:

    npm run build

This will create a `dist` folder:

    .
    ├── dist
    │   ├── index.html
    │   ├── app-5df766af1ced8ff1fe0a.css
    │   └── app-5df766af1ced8ff1fe0a.js


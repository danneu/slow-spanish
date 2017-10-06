# slow-spanish

- Live Demo: <https://www.danneu.com/slow-spanish/>

An Elm web app for practicing language listening.

![screenshot](https://www.dropbox.com/s/39qp731ii35e5ir/hgqa6mez.png?raw=1)

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

## Transcript

The timestamped transcript file is the main limitation of this experiment since
it takes some significant labor to create. Even when you have a full transcript of the audio,
the transcript then needs to be broken up into timestamped chunks.

You can see the transcript file I painstakingly created for the Three Little Pigs demo here:
[src/stories/threepigs/transcript.txt](https://github.com/danneu/slow-spanish/blob/5b4210cee7b540c032c5ef6ced667e3cea6f38a6/src/stories/threepigs/transcript.txt)

```
0:12
Érase una vez que había una mamá cerda que tenía tres cerditos.
0:21
Ella los amaba mucho, pero no había suficiente comida para alimentarlos, así que los cerditos tuvieron que ir a buscar su suerte.

0:36
El primer cerdito decidió ir al sur.
0:42
Encontró a un granjero en el camino que estaba llevando un atado de paja.
0:52
El cerdito preguntó respetuosamente: "¿Podría por favor darme esa paja, para que yo pueda construir una casa?"

...
```

Paragraphs are demarcated with double-spacing and the app renders them as such.

Each chunk can be timestamped with just a starting point:

```
0:36
El primer cerdito decidió ir al sur.
0:42
Encontró a un granjero en el camino que estaba llevando un atado de paja.
...
```

This will assume that the first chunk lasts `0:36-0:42`.

Or you can provide a timestamp range for a chunk:

```
0:36-0:40
El primer cerdito decidió ir al sur.
0:42
Encontró a un granjero en el camino que estaba llevando un atado de paja.
...
```

In the above example, the app will skip the `0:40-0:42` range between the chunks.
This lets you trim out spaces in the audio where there are no vocals between
chunks.

The final chunk in the transcript file must be a range.

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


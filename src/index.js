'use strict'

require('spectre.css')
require('./css/index.scss')
const parse = require('./js/parse')

const Elm = require('./Main.elm')
const mountNode = document.getElementById('main')

const { Howl } = require('howler')

// array of {start, end, text, id}
const chunks = parse(require('./stories/threepigs/transcript.txt'))

// the click is played after a chunk is read so that the
// listener knows the chunk is finished rather than a pause
// in the audio.
const click1 = new Howl({
    src: [require('./sounds/click1.mp3')],
    preload: true,
    volume: 0.5,
})

const sound = new Howl({
    src: [require('./stories/threepigs/spanish.mp3')],
    preload: true,
    html5: true,
    // our sprites are keyed by the start milliseconds (string)
    sprite: (() => {
        const sprite = {}
        for (const { start, end } of chunks) {
            sprite[start] = [start, end - start]
        }
        return sprite
    })(),
})

// we're ready to roll once the main audio mp3 loads
sound.once('load', () => {
    onLoad()
})

function onLoad() {
    const app = Elm.Main.embed(mountNode, {
        chunks,
        debug: window.localStorage.getItem('debug') !== 'false',
    })

    app.ports.saveToLocalStorage.subscribe(([key, value]) => {
        window.localStorage.setItem(key, JSON.stringify(value))
    })

    app.ports.stopSound.subscribe(() => {
        sound.stop()
    })

    let soundId = null

    app.ports.playRange.subscribe(([start, end]) => {
        sound.stop(soundId)
        soundId = sound.play(String(start))
        sound.once(
            'end',
            id => {
                click1.play()
                app.ports.endOfChunk.send(null)
            },
            // only play click for latest sound.
            // without this, pressing next a bunch of times
            // enqueues multiple clicks
            soundId
        )
    })
}

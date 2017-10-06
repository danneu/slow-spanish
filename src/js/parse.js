'use strict'

// Parses timestamped transcription file
module.exports = function parse(contents) {
    const paragraphs = contents
        .split('\n\n')
        .map(s => s.trim())
        .filter(Boolean)

    const lines = flatten(
        paragraphs.map(lines => {
            return groupsOf(
                2,
                lines.split('\n')
            ).map(([timestamps, text], i) => {
                const [start, end] = timestamps.split('-')
                return {
                    paragraph: i === 0,
                    start: parseTimestamp(start),
                    end: end && parseTimestamp(end),
                    text,
                }
            })
        })
    )

    // now we pass over again to set the end of each sentence
    // by peeking at the next one's start.

    for (let i = 0; i < lines.length; i += 1) {
        const sentence1 = lines[i]
        const sentence2 = lines[i + 1] // may be undefined

        // if no sentence2, then we are done
        if (!sentence2) {
            if (!sentence1.end) {
                throw new Error('last sentence must have explicit end')
            }
            continue
        }

        // if sentence has an end, then don't update it
        if (typeof sentence1.end !== 'undefined') {
            continue
        }

        sentence1.end = sentence2.start
    }

    // And pass over to give each line an incrementing id
    lines.forEach((line, i) => {
        line.id = i + 1
    })

    return lines
}

// HELPERS

// hh:mm:ss to milliseconds (int)
// hours is optional
function parseTimestamp(timestamp) {
    const [_, hours, mins, secs] = timestamp.match(/(?:(\d+):)?(\d\d?):(\d\d?)/)
    return (hours || 0) * 60 * 60 * 1000 + mins * 60 * 1000 + secs * 1000
}

function flatten(arrays) {
    return [].concat.apply([], arrays)
}

function groupsOf(n, array) {
    const output = []
    while (array.length > 0) {
        output.push(array.slice(0, n))
        array.splice(0, n)
    }
    return output
}

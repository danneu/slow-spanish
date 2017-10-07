const parser = require('./parser')

// returns array of objects that look like this:
//
// {
//   id: int, starts at 1 and increments for each chunk
//   text: string
//   paragraph: boolean, if true then chunk starts a new paragraph
//   start: int, millisecond offset in audio
//   end: int, millisecond offset in audio
//   line: int, the line of the transcript file where this chunk is found
// }
module.exports = contents => {
    const chunks = parser.parse(contents)

    // loop over every chunk and set every end that is null
    for (let i = 0; i < chunks.length; i++) {
        const chunk1 = chunks[i]
        const chunk2 = chunks[i + 1] // may be undefined

        // give each chunk an incrementing id
        chunk1.id = i + 1

        // if chunk1 has an explicit end, then ensure that it happens after its start
        if (chunk1.end && chunk1.end <= chunk1.start) {
            throw new Error(
                `chunk at line ${chunk1.line} has an end that comes before its start`
            )
        }

        // if no chunk2, then we are on last chunk
        if (!chunk2) {
            if (!chunk1.end) {
                throw new Error('last chunk must have explicit end')
            }
            continue
        }

        // ensure chunk2 starts after chunk1
        if (chunk2.start <= chunk1.start) {
            throw new Error(
                `chunk at line ${chunk2.line} starts before previous chunk`
            )
        }

        // if chunk1 has an explicit end, ensure chunk2 starts after it
        if (chunk1.end && chunk2.start < chunk1.end) {
            throw new Error(
                `chunk at line ${chunk2.line} overlaps with previous chunk`
            )
        }

        // if chunk has an end, then don't update it
        if (chunk1.end) {
            continue
        }

        chunk1.end = chunk2.start
    }

    return chunks
}

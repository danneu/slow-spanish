Transcript
    = paragraphs:Paragraph+
        { return [].concat.apply([], paragraphs) }

Paragraph
    = ("\n"? "\n"*) chunks:Chunk+
    {
        for (let i = 0; i < chunks.length; i++) {
            chunks[i].paragraph = i === 0
        }
        return chunks
    }

Chunk
    = timestamp:Timestamp "\n" lang:[^\n]+ "\n"?
    {
        return {
            start: timestamp.start,
            end: timestamp.end,
            text: lang.join(''),
            line: location().start.line
        }
    }

Timestamp
    = start:Instant "-" end:Instant
        { return { start, end } }
    / start:Instant
        { return { start, end: null } }

// instants are represented as millisecond offset
Instant
    = hrs:Integer ":" mins:Integer ":" secs:Integer
        { return hrs * 60 * 60 * 1000 + mins * 60 * 1000 + secs * 1000 }
    / mins:Integer ":" secs:Integer
        { return mins * 60 * 1000 + secs * 1000 }


Integer "integer"
    = [0-9]+
        { return Number.parseInt(text(), 10) }

_ "whitespace"
    = [ \t\n\r]*
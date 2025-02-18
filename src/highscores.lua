local highscores = {
    scores = {}
}

function highscores.load()
    highscores.scores = {}
    local file = io.open("highscores.txt", "r")
    if file then
        for line in file:lines() do
            local name, score = line:match("(%w+):(%d+)")
            if name and score then
                table.insert(highscores.scores, {name = name, score = tonumber(score)})
            end
        end
        file:close()
    end

    -- If we don't have 10 scores, fill with defaults
    while #highscores.scores < 10 do
        table.insert(highscores.scores, {name = "AAA", score = 0})
    end

    -- Sort scores
    table.sort(highscores.scores, function(a, b) return a.score > b.score end)
end

function highscores.save()
    local file = io.open("highscores.txt", "w")
    if file then
        for _, score in ipairs(highscores.scores) do
            file:write(string.format("%s:%d\n", score.name, score.score))
        end
        file:close()
    end
end

function highscores.isHighScore(score)
    return score > highscores.scores[#highscores.scores].score
end

function highscores.add(name, score)
    table.insert(highscores.scores, {name = name, score = score})
    table.sort(highscores.scores, function(a, b) return a.score > b.score end)
    if #highscores.scores > 10 then
        table.remove(highscores.scores, 11)
    end
    highscores.save()
end

function highscores.getScores()
    return highscores.scores
end

return highscores
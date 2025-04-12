--!strict

export type Error = {
    message: string,
    stack: {string},
    type: string
}

local Error = {}

function Error.new(message: string, type: string): Error
    return {
        message = message,
        stack = {},
        type = type
    }
end

function Error.add_stack_trace(error: Error, frame: string)
    table.insert(error.stack, frame)
end

function Error.format(error: Error): string
    local result = string.format("%s: %s\n", error.type, error.message)
    if #error.stack > 0 then
        result ..= "Stack trace:\n"
        for i, frame in ipairs(error.stack) do
            result ..= string.format("  %d. %s\n", i, frame)
        end
    end
    return result
end

return Error 
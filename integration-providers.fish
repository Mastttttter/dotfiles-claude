# Provider shortcuts. Source this *after* integration.fish if you have one or
# more of the corresponding API keys set in your environment:
#   ZAI_API_KEY        → glm     (Zhipu BigModel)
#   DEEPSEEK_API_KEY   → deepseek
#   OFOX_API_KEY       → ofox    (OfoxAI aggregator, Gemini 3.1 pro
#   LLAMA_API_KEY      → qwen
#
# Each shortcut routes claude through ~/.claude/providers/<name>.json which
# rebinds ANTHROPIC_BASE_URL and the haiku/sonnet/opus model aliases to the
# provider's catalog.

function claude-with
    set -l provider $argv[1]
    switch $provider
        case glm
            set -fx ANTHROPIC_AUTH_TOKEN $ZAI_API_KEY
        case deepseek
            set -fx ANTHROPIC_AUTH_TOKEN $DEEPSEEK_API_KEY
        case ofox
            set -fx ANTHROPIC_AUTH_TOKEN $OFOX_API_KEY
        case qwen
            set -fx ANTHROPIC_AUTH_TOKEN $LLAMA_API_KEY
        case '*'
            echo "claude-with: unknown provider '$provider'" >&2
            return 1
    end
    claude --settings ~/.claude/providers/$provider.json $argv[2..]
end

function glm
    claude-with glm $argv
end

function deepseek
    claude-with deepseek $argv
end

function ofox
    claude-with ofox $argv
end

function qwen
    claude-with qwen $argv
end

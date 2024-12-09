local title = "Get Filter from OpenAI"
local openai_api_key = ""

local json = require("json")

local function get_openai_filter(prompt)
    local cmd = string.format(
    [[curl https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer %s" \
  -d '{
  "model": "gpt-4o",
  "messages": [
    {
      "role": "system",
      "content": [
        {
          "type": "text",
          "text": "You are network expert that translates user query into wireshark display filter language. Return only the wireshark display filter as the answer without backticks"
        }
      ]
    },
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "%s"
        }
      ]
    }
  ],
  "temperature": 1,
  "max_tokens": 2048,
  "top_p": 1,
  "frequency_penalty": 0,
  "presence_penalty": 0,
  "response_format": {
    "type": "text"
  }
}']], openai_api_key, prompt);
    
    -- Capture the response from OpenAI
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()

    -- local filter = string.match(result, [["content":%s*"([^"]+)"]])
    local object = json.parse(result)
    local filter = object.choices[1].message.content

    return filter or "Error retrieving filter from OpenAI"
end

if not gui_enabled() then return end

register_menu(title, function()
    -- Function to handle the process after getting the user input

    -- Store reponses by openai in an array
    local responses = {}

    local function process(sentence)
        -- Ask OpenAI for the Wireshark filter
        local filter = get_openai_filter(sentence)
        -- push filter into responses
        table.insert(responses, filter)
        
        -- Show the result in a confirmation dialog
        local win = TextWindow.new("Confirm Wireshark Filter")

        -- show all reponses in the dialog
        for i, response in ipairs(responses) do
            win:append(string.format("%s\n", response))
        end
        win:set_editable(true)

        -- Add buttons for user confirmation
        win:add_button("Set Latest Filter", function()
            set_filter(filter)
            win:close()
        end)

        win:add_button("Retry", function()
            win:close()
            new_dialog(
                "Enter Prompt for OpenAI",
                function (prompt) process(prompt) end,
                "Prompt"
            )
        end)
    end
    
    -- Create a new dialog to get the sentence from the user
    new_dialog(
        "Enter Prompt for OpenAI",
        function (prompt) process(prompt) end,
        "Prompt"
    )

end, MENU_TOOLS_UNSORTED)

local title = "Get Filter from OpenAI"


if not gui_enabled() then return end

register_menu(title, function()
    local function process(sentence)
        set_filter(sentence)
    end
    
    -- create new text window and initialize its text
    local win = TextWindow.new("Log")
    win:set("Hello world!")
    
    -- add buttons to clear text window and to enable editing
    win:add_button("Clear", function() win:clear() end)
    win:add_button("Enable edit", function() win:set_editable(true) end)
    
    -- add button to change text to uppercase
    win:add_button("Uppercase", function()
        local text = win:get_text()
        if text ~= "" then
            win:set(string.upper(text))
        end
    end)
    
    -- print "closing" to stdout when the user closes the text window
    win:set_atclose(function() set_filter(win:get_text()) end)
    -- win:set_atclose(function() print("closing") end)
    


-- local p = ProgDlg.new("Constructing", "tacos")

-- -- We have to wrap the ProgDlg code in a pcall in case some unexpected
-- -- error occurs.
-- local ok, errmsg = pcall(function()
--     local co = coroutine.create(
--         function()
--             local limit = 100000
--             for i=1,limit do
--                 print("co", i)
--                 coroutine.yield(i/limit, "step "..i.." of "..limit)
--             end
--         end
--     )
    
--     -- Whenever coroutine yields, check the status of the cancel button to determine
--     -- when to break. Wait up to 20 sec for coroutine to finish.
--     local start_time = os.time()
--     while coroutine.status(co) ~= 'dead' do
--         local elapsed = os.time() - start_time
        
--         -- Quit if cancel button pressed or 20 seconds elapsed
--         if p:stopped() or elapsed > 20 then
--             break
--         end
        
--         local res, val, val2 = coroutine.resume(co)
--         if not res or res == false then
--             if val then
--                 debug(val)
--             end
--             print('coroutine error')
--             break
--         end
        
--         -- show progress in progress dialog
--         p:update(val, val2)
--     end
-- end)

-- p:close()

-- if not ok and errmsg then
--     report_failure(errmsg)
-- end

end, MENU_TOOLS_UNSORTED)
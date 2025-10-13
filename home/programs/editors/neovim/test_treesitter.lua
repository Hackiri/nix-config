-- Test file for treesitter syntax highlighting
-- Open this file with: nvim test_treesitter.lua
-- Then run: :Inspect to see highlight groups

local function greet(name)
  print("Hello, " .. name .. "!")
  
  local items = {
    "apple",
    "banana",
    "cherry"
  }
  
  for i, item in ipairs(items) do
    print(string.format("%d: %s", i, item))
  end
end

-- Call the function
greet("World")

-- If you see colors/syntax highlighting, treesitter is working!
-- Run :TSModuleInfo to verify modules are enabled

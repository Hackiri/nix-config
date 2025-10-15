local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

local python_snippets = {
  -- Main script template
  s(
    "pymain",
    fmt(
      [[
#!/usr/bin/env python3

def main():
    {}

if __name__ == '__main__':
    main()
]],
      {
        i(1, "pass"),
      }
    )
  ),

  -- Class template
  s(
    "pyclass",
    fmt(
      [[
class {}:
    def __init__(self{}):
        {}

    def __str__(self):
        return f"{}"
]],
      {
        i(1, "ClassName"),
        i(2, ", *args"),
        i(3, "# Initialize attributes"),
        i(4, "String representation"),
      }
    )
  ),

  -- Function with docstring
  s(
    "pyfunc",
    fmt(
      [[
def {}({}):
    """
    {}

    Args:
        {}: {}

    Returns:
        {}: {}
    """
    {}
]],
      {
        i(1, "function_name"),
        i(2, "args"),
        i(3, "Function description"),
        i(4, "param"),
        i(5, "param description"),
        i(6, "return_type"),
        i(7, "return description"),
        i(8, "pass"),
      }
    )
  ),

  -- FastAPI endpoint
  s(
    "pyapi",
    fmt(
      [[
@router.{}("{}")
async def {}({}):
    """
    {}
    """
    try:
        {}
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
        )
]],
      {
        i(1, "get"),
        i(2, "/path"),
        i(3, "endpoint_name"),
        i(4, "request: Request"),
        i(5, "Endpoint description"),
        i(6, "return {}"),
      }
    )
  ),

  -- Testing template
  s(
    "pytest",
    fmt(
      [[
import pytest

def test_{}():
    # Arrange
    {}

    # Act
    {}

    # Assert
    {}
]],
      {
        i(1, "function_name"),
        i(2, "# Setup test data"),
        i(3, "# Execute function"),
        i(4, "# Verify results"),
      }
    )
  ),
}

return python_snippets

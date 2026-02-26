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

  -- Flatten nested list
  s(
    "pyflatten",
    fmt([=[flat = [item for sublist in {} for item in sublist]]=], {
      i(1, "nested"),
    })
  ),

  -- Swap two variables
  s(
    "pyswap",
    fmt([[{}, {} = {}, {}]], {
      i(1, "a"),
      i(2, "b"),
      i(3, "b"),
      i(4, "a"),
    })
  ),

  -- Read a file
  s(
    "pyread",
    fmt(
      [[
with open({}) as f:
    {} = f.read().splitlines()
]],
      {
        i(1, '"file.txt"'),
        i(2, "lines"),
      }
    )
  ),

  -- Count occurrences
  s(
    "pycount",
    fmt(
      [[
from collections import Counter
counts = Counter({})
]],
      {
        i(1, "iterable"),
      }
    )
  ),

  -- Reverse an iterable
  s(
    "pyrev",
    fmt([=[reversed_{} = {}[::-1]]=], {
      i(1, "name"),
      i(2, "iterable"),
    })
  ),

  -- Conditional assignment
  s(
    "pycond",
    fmt([[{} = {} if {} else {}]], {
      i(1, "var"),
      i(2, "val_true"),
      i(3, "condition"),
      i(4, "val_false"),
    })
  ),

  -- Chain comparisons
  s(
    "pychain",
    fmt([[if {} <= {} <= {}:]], {
      i(1, "low"),
      i(2, "val"),
      i(3, "high"),
    })
  ),

  -- Join iterable to string
  s(
    "pyjoin",
    fmt([[result = ", ".join({})]], {
      i(1, "iterable"),
    })
  ),

  -- Pretty print
  s(
    "pypprint",
    fmt(
      [[
import pprint
pprint.pprint({})
]],
      {
        i(1, "obj"),
      }
    )
  ),

  -- f-string with literal braces
  s(
    "pybrace",
    fmt([[f"{{{{...{}...}}}}"]], {
      i(1, "expr"),
    })
  ),
}

return python_snippets

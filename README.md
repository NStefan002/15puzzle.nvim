# 15 Puzzle

> Implementation of the classic `15 Puzzle` game for Neovim.

## 📺 Showcase

## 📋 Installation

[lazy](https://github.com/folke/lazy.nvim):

```lua
{
    "NStefan002/15puzzle.nvim",
    cmd = "Play15puzzle",
    config = true,
}
```

[packer](https://github.com/wbthomason/packer.nvim):

```lua
use({
    "NStefan002/15puzzle.nvim",
    config = function()
        require("15puzzle").setup()
    end,
})
```

[rocks.nvim](https://github.com/nvim-neorocks/rocks.nvim)

`:Rocks install 15puzzle.nvim`

## ❓ How to Play

1. `:Play15puzzle`
2. Use the `h`, `j`, `k`, `l` to slide the squares in the desired direction.
3. Place each square in its correct place.
4. Try to solve the puzzle in the fewest moves and as fast as possible.

## 🎮 Controls

-   `h` - move the squares to the left
-   `j` - move the squares down
-   `k` - move the squares up
-   `l` - move the squares to the right
-   `n` - new game
-   `<c-l>` - next theme
-   `<c-h>` - previous theme
-   `<CR>` - confirm in menus
-   `<Esc>` - cancel in menus

**NOTE:**

<details>
    <summary>You can change the default mappings.</summary>


```lua
require("15puzzle").setup({
    keys = {
        up = "<Up>",
        down = "<Down>",
        left = "<Left>",
        right = "<Right>",
        new_game = "N",
        confirm = "y",
        cancel = "n",
        next_theme = "<c-a>",
        prev_theme = "<c-x>",
    },
})
```
</details>

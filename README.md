# 15 Puzzle

> Implementation of the classic `15 Puzzle` game for Neovim.

## 📺 Showcase

https://github.com/NStefan002/15puzzle.nvim/assets/100767853/d613555a-b603-490f-b24a-cb8ef89246a3

### 🖼️ Gallery 

<details>
    <summary> Preview themes </summary>
    
![15P_theme1](https://github.com/NStefan002/15puzzle.nvim/assets/100767853/2e12ef24-7e22-49b5-b32e-d8cccece3295)

![15P_theme2](https://github.com/NStefan002/15puzzle.nvim/assets/100767853/25c94aa8-5e83-407f-b2f7-6b6d48fa05f2)

![15P_theme3](https://github.com/NStefan002/15puzzle.nvim/assets/100767853/cb1f738f-45be-4b42-bbad-958b80782780)

![15P_theme4](https://github.com/NStefan002/15puzzle.nvim/assets/100767853/996cdbd8-5006-41a9-b8bc-0c7bbc2e340d)

![15P_theme5](https://github.com/NStefan002/15puzzle.nvim/assets/100767853/3c0acfd1-06e3-4644-92b1-103907c37ce8)

</details>



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

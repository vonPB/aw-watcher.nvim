# Activiy Watcher nvim

based on [ActivityWatch/aw-watcher-vim](https://github.com/ActivityWatch/aw-watcher-vim) but written in lua.

## Installation

This plugin needs [`curl`](https://github.com/curl/curl) available in your PATH.

Using [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'vonpb/aw-watcher.nvim'
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use { 'vonpb/aw-watcher.nvim' }
```

#### Setup

```lua
require("aw-watcher").setup()
```
The default heartbeat timeout is 8 seconds. I will add actual settings someday...

### Commands

```
* AWStatus - check if connected to server
* AWStart - manual start. Run this after being disconnected
* Heartbeat - manually sent a heartbeat
```


## TODO

- [ ] get git branch async

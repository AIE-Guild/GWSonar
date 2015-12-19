# GWSonar

__A demonstration of the GreenWall add-on communication API.__

## Overview

This add-on is a simple add-on which provides an example of the messaging
API provided by GreenWall in versions 1.7 and later.  GreenWall is an
add-on which bridges the guild chat of multiple guilds (or guild confederations)
so that they appear to share the same guild chat. 

GWSonar alows a user to send a hidden request message to other members of the 
confederation.  Other instances of the add-on will respond and the requesting
can view response time metrics.

This add-on shows how third-party add-on developers can use the communication
bridging for building other distributed applications for guild confederations.


## Installation

1. Download the compressed distribution file.
2. Close World of Warcaft.
3. Extract the contents of the file and place them in the World of Warcraft AddOns directory.
  - On Windows, `C:\Program Files (x86)\World of Warcraft\Interface\AddOns` or `C:\Program Files\World of Warcraft\Interface\AddOns`.
  - On OSX, `~/Applications/World of Warcraft/Interface/Addons`.
4. Launch World of Warcraft.
5. Click the __AddOns__ button on the character selection screen.
6. Enable the add-on for your character.


## Usage

- /gwsonar ping

  Send a request message to other GWSonar users within the guild confederation.
  
- /gwsonar stats

  View response time statistics for the last ping.


## Author

Mark Rogaski \<stigg@aie-guild.org\>

## See Also

[GreenWall](https://github.com/AIE-Guild/GreenWall)

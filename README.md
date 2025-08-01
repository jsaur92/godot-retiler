# godot-retiler
TileSet and Texture2D go in, TileMapLayer comes out.

A dock plugin for Godot that allows you to generate a populated TileMapLayer node by inputting a TileSet and a texture made of tiles from that TileSet. 


## How To Use
To use, simply add the `addons/retiler` directory to your Godot project and enable the plugin in `Project Settings > Plugins`. This should make the Retiler dock appear in your editor.

Set `TileSet` to the TileSet of your choice, then set `Texture` to your texture of an exported tilemap.

`Save to Path` represents the directory your TileMapLayer will be saved in. `File Name` represents the name of the file and Node that your TileMapLayer will be.

Click the `Generate TileMapLayer` button to generate your TileMapLayer.
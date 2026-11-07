# Scene Auto Zoom

A Godot 4 editor plugin that fits a 2D or UI scene into the 2D view when you open it, the same as selecting everything and pressing **Shift+F** (View > Frame Selection).

Godot normally reopens a scene at whatever zoom and pan it last had, or at 100% for a scene it hasn't seen, which for large UI layouts often shows only a corner.

## Behaviour

- **Opening a scene** fits all of its visible nodes into the view. Children that reach outside the root are included.
- **Switching between tabs** of scenes that are already open keeps the zoom and pan you left on each.
- **Closing a scene and opening it again** fits it again.
- **Tabs restored at editor startup** are fitted the first time you switch to them.
- **A scene opened while the Script or 3D view is showing** is fitted when you go back to 2D.
- 3D scenes and scenes whose root isn't a `CanvasItem` are left alone.

After fitting, only the scene's root is left selected.

## Installing

Copy `addons/scene_auto_zoom/` into your project's `addons/` folder, then enable **Scene Auto Zoom** under **Project > Project Settings > Plugins**.

Written for Godot 4 and tested on 4.7.2.

## How it works

Godot gives plugins no call to frame the 2D view. The plugin selects every visible node, then triggers the 2D editor's own **View > Frame Selection** menu item. It finds that item by comparing each item's shortcut with the one the editor settings hold for `canvas_item_editor/frame_selection`, so it works in any editor language and with any key binding.

Because it relies on the editor's menu, a Godot update that changes that menu can stop it working without an error.

## License

[MIT](LICENSE)

return PlaceObj("ModDef", {
	"dependencies", {
		PlaceObj("ModDependency", {
			"id", "ChoGGi_Library",
			"title", "ChoGGi's Library",
			"version_major", 8,
			"version_minor", 5,
		}),
	},
	"title", "Pin Expander",
	"version", 10,
	"version_major", 1,
	"version_minor", 0,
	"image", "Preview.png",
	"id", "ChoGGi_PinExpander",
	"steam_id", "1503773725",
	"pops_any_uuid", "5c641ef5-a427-402c-b4f7-d3b579a445fb",
	"author", "ChoGGi",
	"lua_revision", 249143,
	"code", {
		"Code/Script.lua",
	},
	"description", [[Clicking a pinned object will show a list of all objects of the same type.

Left-click: View and select.
Right-click: Just view.
Hold down Shift to keep the menu open post-click.

Mouse over an item to highlight it (green).

Colonists are limited to same dome if over 5000.
Hold Shift to show full list.

Hold Ctrl for old pin button functionality (might not work with a gamepad, but only console users would sink to that level).]],
})

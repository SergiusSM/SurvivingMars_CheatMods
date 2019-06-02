return PlaceObj("ModDef", {
	"dependencies", {
		PlaceObj("ModDependency", {
			"id", "ChoGGi_Library",
			"title", "ChoGGi's Library",
			"version_major", 6,
			"version_minor", 8,
		}),
	},
--~ 	"title", "Minimap v0.5",
	"title", "Minimap",
	"version", 6,
	"version_major", 0,
	"version_minor", 6,
	"saved", 0,
	"image", "Preview.png",
	"id", "ChoGGi_Minimap",
	"steam_id", "1571476937",
	"pops_any_uuid", "3e0f7458-9638-43bd-8228-26e38da5df70",
	"author", "ChoGGi",
	"lua_revision", 245618,
	"code", {
		"Code/Minimap.lua",
		"Code/Script.lua",
	},
	"has_options", true,
	"description", [[It's an image of the map you can click on to move the camera around (useful for setting transport routes).
This is an image, so click target isn't perfect.

For those of us using ultrawide the image doesn't work that well.
There's a mod option to use my topography images instead:
https://steamcommunity.com/sharedfiles/filedetails/?id=1571465108]],
})

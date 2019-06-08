return PlaceObj("ModDef", {
	"dependencies", {
		PlaceObj("ModDependency", {
			"id", "ChoGGi_Library",
			"title", "ChoGGi's Library",
			"version_major", 6,
			"version_minor", 9,
		}),
	},
--~ 	"title", "Show Transport Route Info v0.1",
	"title", "Show Transport Route Info",
	"version", 3,
	"version_major", 0,
	"version_minor", 3,
	"saved", 1558872000,
	"image", "Preview.png",
	"id", "ChoGGi_ShowTransportRouteInfo",
	"steam_id", "1628726303",
	"pops_any_uuid", "d25a14ac-acf8-4132-bda6-ac116688b011",
	"author", "ChoGGi",
	"lua_revision", 245618,
	"code", {
		"Code/Script.lua",
	},
	"description", [[Shows a line connecting the transport route when you select a transporter (also shows res type).

Requested by VladamirBegemot.]],
})

-- https://lua.expert/
local t = {
	Zones = {
		{
			Id = 1,
			Name = "Base",
			Cost = 0,
			LuckBonus = 1,
			MultiplierBoost = 1,
			PegMaterial = "SmoothPlastic",
			BgColor = Color3.fromRGB(0, 0, 0),
			PegColor = Color3.fromRGB(200, 225, 235)
		},
		{
			Id = 2,
			Name = "Neon Metropolis",
			Cost = 500,
			LuckBonus = 2,
			MultiplierBoost = 1.2,
			PegMaterial = "Neon",
			BgColor = Color3.fromRGB(15, 5, 25),
			PegColor = Color3.fromRGB(0, 255, 255)
		},
		{
			Id = 3,
			Name = "Sludge Sewers",
			Cost = 5000,
			LuckBonus = 3,
			MultiplierBoost = 1.4,
			PegMaterial = "SmoothPlastic",
			BgColor = Color3.fromRGB(5, 15, 5),
			PegColor = Color3.fromRGB(150, 255, 50)
		},
		{
			Id = 4,
			Name = "Bioluminescent Deep",
			Cost = 50000,
			LuckBonus = 4,
			MultiplierBoost = 1.6,
			PegMaterial = "Neon",
			BgColor = Color3.fromRGB(0, 5, 20),
			PegColor = Color3.fromRGB(50, 150, 255)
		},
		{
			Id = 5,
			Name = "Magma Core",
			Cost = 500000,
			LuckBonus = 5,
			MultiplierBoost = 1.8,
			PegMaterial = "Neon",
			BgColor = Color3.fromRGB(20, 5, 0),
			PegColor = Color3.fromRGB(255, 100, 0)
		},
		{
			Id = 6,
			Name = "Crystal Matrix",
			Cost = 2500000,
			LuckBonus = 6,
			MultiplierBoost = 2,
			PegMaterial = "Glass",
			BgColor = Color3.fromRGB(20, 10, 25),
			PegColor = Color3.fromRGB(255, 150, 255)
		},
		{
			Id = 7,
			Name = "Void Sector",
			Cost = 15000000,
			LuckBonus = 7,
			MultiplierBoost = 2.2,
			PegMaterial = "ForceField",
			BgColor = Color3.fromRGB(5, 5, 5),
			PegColor = Color3.fromRGB(200, 200, 200)
		},
		{
			Id = 8,
			Name = "Quantum Realm",
			Cost = 75000000,
			LuckBonus = 8,
			MultiplierBoost = 2.4,
			PegMaterial = "Neon",
			BgColor = Color3.fromRGB(15, 0, 25),
			PegColor = Color3.fromRGB(150, 50, 255)
		},
		{
			Id = 9,
			Name = "Celestial Forge",
			Cost = 250000000,
			LuckBonus = 9,
			MultiplierBoost = 2.6,
			PegMaterial = "Glass",
			BgColor = Color3.fromRGB(25, 20, 10),
			PegColor = Color3.fromRGB(255, 255, 200)
		},
		{
			Id = 10,
			Name = "Ethereal Gardens",
			Cost = 1000000000,
			LuckBonus = 10,
			MultiplierBoost = 2.8,
			PegMaterial = "SmoothPlastic",
			BgColor = Color3.fromRGB(5, 20, 15),
			PegColor = Color3.fromRGB(200, 255, 200)
		},
		{
			Id = 11,
			Name = "Clockwork Dimension",
			Cost = 5000000000,
			LuckBonus = 11,
			MultiplierBoost = 3,
			PegMaterial = "Metal",
			BgColor = Color3.fromRGB(25, 15, 5),
			PegColor = Color3.fromRGB(200, 150, 50)
		},
		{
			Id = 12,
			Name = "Abyssal Trench",
			Cost = 20000000000,
			LuckBonus = 12,
			MultiplierBoost = 3.2,
			PegMaterial = "Neon",
			BgColor = Color3.fromRGB(5, 0, 10),
			PegColor = Color3.fromRGB(255, 50, 50)
		},
		{
			Id = 13,
			Name = "Cybernetic Hive",
			Cost = 100000000000,
			LuckBonus = 13,
			MultiplierBoost = 3.4,
			PegMaterial = "DiamondPlate",
			BgColor = Color3.fromRGB(5, 20, 5),
			PegColor = Color3.fromRGB(50, 255, 50)
		},
		{
			Id = 14,
			Name = "Galactic Nexus",
			Cost = 500000000000,
			LuckBonus = 14,
			MultiplierBoost = 3.6,
			PegMaterial = "Glass",
			BgColor = Color3.fromRGB(10, 10, 25),
			PegColor = Color3.fromRGB(150, 200, 255)
		},
		{
			Id = 15,
			Name = "Chrono Rift",
			Cost = 1000000000000,
			LuckBonus = 15,
			MultiplierBoost = 3.8,
			PegMaterial = "ForceField",
			BgColor = Color3.fromRGB(15, 15, 20),
			PegColor = Color3.fromRGB(100, 200, 255)
		},
		{
			Id = 16,
			Name = "Astral Plane",
			Cost = 5000000000000,
			LuckBonus = 16,
			MultiplierBoost = 4,
			PegMaterial = "Neon",
			BgColor = Color3.fromRGB(25, 25, 25),
			PegColor = Color3.fromRGB(255, 215, 0)
		},
		{
			Id = 17,
			Name = "Plasma Fields",
			Cost = 15000000000000,
			LuckBonus = 17,
			MultiplierBoost = 4.2,
			PegMaterial = "Neon",
			BgColor = Color3.fromRGB(20, 5, 20),
			PegColor = Color3.fromRGB(255, 100, 255)
		},
		{
			Id = 18,
			Name = "Dimensional Tear",
			Cost = 50000000000000,
			LuckBonus = 18,
			MultiplierBoost = 4.4,
			PegMaterial = "Glass",
			BgColor = Color3.fromRGB(200, 200, 200),
			PegColor = Color3.fromRGB(10, 10, 10)
		},
		{
			Id = 19,
			Name = "Supernova Remnant",
			Cost = 150000000000000,
			LuckBonus = 19,
			MultiplierBoost = 4.6,
			PegMaterial = "Neon",
			BgColor = Color3.fromRGB(25, 10, 0),
			PegColor = Color3.fromRGB(255, 200, 100)
		},
		{
			Id = 20,
			Name = "The Singularity",
			Cost = 500000000000000,
			LuckBonus = 20,
			MultiplierBoost = 4.8,
			PegMaterial = "ForceField",
			BgColor = Color3.fromRGB(0, 0, 0),
			PegColor = Color3.fromRGB(255, 255, 255)
		},
		{
			Id = 21,
			Name = "Antimatter Cascade",
			Cost = 1000000000000000,
			LuckBonus = 21,
			MultiplierBoost = 5,
			PegMaterial = "Neon",
			BgColor = Color3.fromRGB(10, 0, 15),
			PegColor = Color3.fromRGB(200, 0, 255)
		},
		{
			Id = 22,
			Name = "Neural Nexus",
			Cost = 5000000000000000,
			LuckBonus = 22,
			MultiplierBoost = 5.2,
			PegMaterial = "DiamondPlate",
			BgColor = Color3.fromRGB(0, 10, 10),
			PegColor = Color3.fromRGB(0, 200, 200)
		},
		{
			Id = 23,
			Name = "Frozen Abyss",
			Cost = 2.5e16,
			LuckBonus = 23,
			MultiplierBoost = 5.4,
			PegMaterial = "Ice",
			BgColor = Color3.fromRGB(5, 10, 25),
			PegColor = Color3.fromRGB(150, 220, 255)
		},
		{
			Id = 24,
			Name = "Solar Crucible",
			Cost = 1e17,
			LuckBonus = 24,
			MultiplierBoost = 5.6,
			PegMaterial = "Neon",
			BgColor = Color3.fromRGB(30, 15, 0),
			PegColor = Color3.fromRGB(255, 180, 0)
		},
		{
			Id = 25,
			Name = "Shadow Dimension",
			Cost = 5e17,
			LuckBonus = 25,
			MultiplierBoost = 5.8,
			PegMaterial = "ForceField",
			BgColor = Color3.fromRGB(2, 2, 2),
			PegColor = Color3.fromRGB(80, 0, 120)
		},
		{
			Id = 26,
			Name = "Prismatic Veil",
			Cost = 2.5e18,
			LuckBonus = 26,
			MultiplierBoost = 6,
			PegMaterial = "Glass",
			BgColor = Color3.fromRGB(15, 15, 20),
			PegColor = Color3.fromRGB(255, 100, 150)
		},
		{
			Id = 27,
			Name = "Entropy Well",
			Cost = 1e19,
			LuckBonus = 27,
			MultiplierBoost = 6.2,
			PegMaterial = "Neon",
			BgColor = Color3.fromRGB(8, 0, 0),
			PegColor = Color3.fromRGB(180, 30, 30)
		},
		{
			Id = 28,
			Name = "Omega Circuit",
			Cost = 5e19,
			LuckBonus = 28,
			MultiplierBoost = 6.4,
			PegMaterial = "DiamondPlate",
			BgColor = Color3.fromRGB(0, 5, 0),
			PegColor = Color3.fromRGB(0, 255, 100)
		},
		{
			Id = 29,
			Name = "Paradox Core",
			Cost = 2.5e20,
			LuckBonus = 29,
			MultiplierBoost = 6.6,
			PegMaterial = "ForceField",
			BgColor = Color3.fromRGB(20, 20, 20),
			PegColor = Color3.fromRGB(255, 255, 0)
		},
		{
			Id = 30,
			Name = "The Infinite",
			Cost = 1e21,
			LuckBonus = 30,
			MultiplierBoost = 6.8,
			PegMaterial = "Neon",
			BgColor = Color3.fromRGB(0, 0, 0),
			PegColor = Color3.fromRGB(255, 255, 255)
		},
		{
			Id = 31,
			Name = "Fossil Expanse",
			Cost = 5e21,
			LuckBonus = 31,
			MultiplierBoost = 7,
			PegMaterial = "SmoothPlastic",
			BgColor = Color3.fromRGB(25, 18, 8),
			PegColor = Color3.fromRGB(230, 220, 200)
		},
		{
			Id = 32,
			Name = "Coral Necropolis",
			Cost = 2.5e22,
			LuckBonus = 32,
			MultiplierBoost = 7.2,
			PegMaterial = "Glass",
			BgColor = Color3.fromRGB(0, 15, 20),
			PegColor = Color3.fromRGB(255, 130, 150)
		},
		{
			Id = 33,
			Name = "Iron Canopy",
			Cost = 1e23,
			LuckBonus = 33,
			MultiplierBoost = 7.4,
			PegMaterial = "Metal",
			BgColor = Color3.fromRGB(18, 10, 5),
			PegColor = Color3.fromRGB(200, 120, 50)
		},
		{
			Id = 34,
			Name = "Mirage Desert",
			Cost = 5e23,
			LuckBonus = 34,
			MultiplierBoost = 7.6,
			PegMaterial = "ForceField",
			BgColor = Color3.fromRGB(30, 25, 15),
			PegColor = Color3.fromRGB(255, 240, 220)
		},
		{
			Id = 35,
			Name = "Thunderspire",
			Cost = 2.5e24,
			LuckBonus = 35,
			MultiplierBoost = 7.8,
			PegMaterial = "Neon",
			BgColor = Color3.fromRGB(10, 10, 18),
			PegColor = Color3.fromRGB(80, 200, 255)
		},
		{
			Id = 36,
			Name = "Obsidian Throne",
			Cost = 1e25,
			LuckBonus = 36,
			MultiplierBoost = 8,
			PegMaterial = "SmoothPlastic",
			BgColor = Color3.fromRGB(5, 0, 5),
			PegColor = Color3.fromRGB(150, 50, 200)
		},
		{
			Id = 37,
			Name = "Aurora Wastes",
			Cost = 5e25,
			LuckBonus = 37,
			MultiplierBoost = 8.2,
			PegMaterial = "Neon",
			BgColor = Color3.fromRGB(5, 8, 15),
			PegColor = Color3.fromRGB(100, 255, 150)
		},
		{
			Id = 38,
			Name = "Sunken Cathedral",
			Cost = 2.5e26,
			LuckBonus = 38,
			MultiplierBoost = 8.4,
			PegMaterial = "Glass",
			BgColor = Color3.fromRGB(5, 15, 10),
			PegColor = Color3.fromRGB(200, 150, 100)
		},
		{
			Id = 39,
			Name = "Titan\'s Graveyard",
			Cost = 1e27,
			LuckBonus = 39,
			MultiplierBoost = 8.6,
			PegMaterial = "DiamondPlate",
			BgColor = Color3.fromRGB(15, 12, 10),
			PegColor = Color3.fromRGB(230, 210, 150)
		},
		{
			Id = 40,
			Name = "The Forgotten",
			Cost = 5e27,
			LuckBonus = 40,
			MultiplierBoost = 8.8,
			PegMaterial = "ForceField",
			BgColor = Color3.fromRGB(3, 0, 8),
			PegColor = Color3.fromRGB(200, 200, 220)
		}
	},
	ById = {}
}

for i, v in ipairs(t.Zones) do
	t.ById[v.Id] = v
end

t.Atmosphere = {
	nil,
	{
		FogS = 30,
		FogE = 90,
		Bloom = 0.8,
		Rate = 30,
		Fog = Color3.fromRGB(0, 40, 50),
		AC = Color3.fromRGB(0, 255, 255),
		AC2 = Color3.fromRGB(0, 150, 255),
		Spd = { 1, 3 },
		Sz = { 0.5, 2 }
	},
	{
		FogS = 25,
		FogE = 75,
		Bloom = 0,
		Rate = 15,
		Fog = Color3.fromRGB(10, 30, 10),
		AC = Color3.fromRGB(100, 200, 50),
		AC2 = Color3.fromRGB(50, 150, 0),
		Spd = { 0.5, 2 },
		Sz = { 1, 4 }
	},
	{
		FogS = 20,
		FogE = 60,
		Bloom = 1.5,
		Rate = 20,
		Fog = Color3.fromRGB(0, 10, 40),
		AC = Color3.fromRGB(30, 100, 255),
		AC2 = Color3.fromRGB(0, 200, 150),
		Spd = { 0.5, 1.5 },
		Sz = { 1, 5 }
	},
	{
		FogS = 25,
		FogE = 75,
		Bloom = 1,
		Rate = 40,
		Fog = Color3.fromRGB(40, 10, 0),
		AC = Color3.fromRGB(255, 100, 0),
		AC2 = Color3.fromRGB(255, 50, 0),
		Spd = { 1, 4 },
		Sz = { 0.3, 1.5 }
	},
	{
		FogS = 30,
		FogE = 90,
		Bloom = 1.5,
		Rate = 25,
		Fog = Color3.fromRGB(30, 15, 40),
		AC = Color3.fromRGB(255, 150, 255),
		AC2 = Color3.fromRGB(200, 100, 255),
		Spd = { 0.5, 2 },
		Sz = { 0.5, 3 }
	},
	{
		FogS = 15,
		FogE = 50,
		Bloom = 0,
		Rate = 10,
		Fog = Color3.fromRGB(5, 5, 5),
		AC = Color3.fromRGB(100, 100, 100),
		AC2 = Color3.fromRGB(50, 50, 50),
		Spd = { 0.3, 1 },
		Sz = { 2, 8 }
	},
	{
		FogS = 25,
		FogE = 75,
		Bloom = 1.5,
		Rate = 30,
		Fog = Color3.fromRGB(20, 0, 40),
		AC = Color3.fromRGB(150, 50, 255),
		AC2 = Color3.fromRGB(100, 0, 200),
		Spd = { 1, 3 },
		Sz = { 0.5, 2 }
	},
	{
		FogS = 30,
		FogE = 90,
		Bloom = 1,
		Rate = 25,
		Fog = Color3.fromRGB(40, 30, 10),
		AC = Color3.fromRGB(255, 220, 100),
		AC2 = Color3.fromRGB(255, 180, 50),
		Spd = { 1, 3 },
		Sz = { 0.3, 1.5 }
	},
	{
		FogS = 35,
		FogE = 100,
		Bloom = 0.5,
		Rate = 20,
		Fog = Color3.fromRGB(10, 30, 20),
		AC = Color3.fromRGB(150, 255, 150),
		AC2 = Color3.fromRGB(100, 200, 100),
		Spd = { 0.3, 1.5 },
		Sz = { 1, 4 }
	},
	{
		FogS = 30,
		FogE = 90,
		Bloom = 0,
		Rate = 15,
		Fog = Color3.fromRGB(30, 20, 10),
		AC = Color3.fromRGB(200, 150, 50),
		AC2 = Color3.fromRGB(150, 100, 30),
		Spd = { 0.5, 2 },
		Sz = { 0.3, 1 }
	},
	{
		FogS = 20,
		FogE = 60,
		Bloom = 0,
		Rate = 20,
		Fog = Color3.fromRGB(15, 0, 10),
		AC = Color3.fromRGB(255, 30, 30),
		AC2 = Color3.fromRGB(150, 0, 50),
		Spd = { 0.5, 2 },
		Sz = { 1, 4 }
	},
	{
		FogS = 25,
		FogE = 75,
		Bloom = 1,
		Rate = 35,
		Fog = Color3.fromRGB(5, 20, 5),
		AC = Color3.fromRGB(50, 255, 50),
		AC2 = Color3.fromRGB(0, 200, 100),
		Spd = { 1, 4 },
		Sz = { 0.2, 1 }
	},
	{
		FogS = 35,
		FogE = 100,
		Bloom = 1.5,
		Rate = 25,
		Fog = Color3.fromRGB(15, 15, 40),
		AC = Color3.fromRGB(100, 150, 255),
		AC2 = Color3.fromRGB(200, 200, 255),
		Spd = { 0.3, 1 },
		Sz = { 0.5, 2 }
	},
	{
		FogS = 25,
		FogE = 75,
		Bloom = 1,
		Rate = 30,
		Fog = Color3.fromRGB(15, 20, 30),
		AC = Color3.fromRGB(80, 180, 255),
		AC2 = Color3.fromRGB(150, 220, 255),
		Spd = { 1, 3 },
		Sz = { 0.5, 3 }
	},
	{
		FogS = 30,
		FogE = 90,
		Bloom = 1.5,
		Rate = 25,
		Fog = Color3.fromRGB(30, 25, 10),
		AC = Color3.fromRGB(255, 215, 0),
		AC2 = Color3.fromRGB(255, 255, 100),
		Spd = { 0.5, 2 },
		Sz = { 0.5, 2 }
	},
	{
		FogS = 25,
		FogE = 75,
		Bloom = 1.5,
		Rate = 35,
		Fog = Color3.fromRGB(30, 5, 30),
		AC = Color3.fromRGB(255, 100, 255),
		AC2 = Color3.fromRGB(200, 50, 200),
		Spd = { 1, 4 },
		Sz = { 0.3, 1.5 }
	},
	{
		FogS = 25,
		FogE = 75,
		Bloom = 1.5,
		Rate = 40,
		Fog = Color3.fromRGB(20, 20, 25),
		AC = Color3.fromRGB(255, 255, 255),
		AC2 = Color3.fromRGB(200, 200, 255),
		Spd = { 2, 5 },
		Sz = { 0.2, 1 }
	},
	{
		FogS = 30,
		FogE = 90,
		Bloom = 1,
		Rate = 25,
		Fog = Color3.fromRGB(5, 20, 20),
		AC = Color3.fromRGB(0, 200, 200),
		AC2 = Color3.fromRGB(50, 255, 200),
		Spd = { 1, 3 },
		Sz = { 0.3, 1.5 }
	},
	{
		FogS = 20,
		FogE = 60,
		Bloom = 0,
		Rate = 40,
		Fog = Color3.fromRGB(30, 35, 40),
		AC = Color3.fromRGB(200, 220, 255),
		AC2 = Color3.fromRGB(255, 255, 255),
		Spd = { 0.5, 2 },
		Sz = { 0.5, 3 }
	},
	{
		FogS = 20,
		FogE = 60,
		Bloom = 2,
		Rate = 45,
		Fog = Color3.fromRGB(40, 15, 0),
		AC = Color3.fromRGB(255, 150, 0),
		AC2 = Color3.fromRGB(255, 80, 0),
		Spd = { 1, 4 },
		Sz = { 0.3, 1.5 }
	},
	{
		FogS = 15,
		FogE = 50,
		Bloom = 0,
		Rate = 15,
		Fog = Color3.fromRGB(5, 5, 8),
		AC = Color3.fromRGB(60, 60, 80),
		AC2 = Color3.fromRGB(30, 30, 40),
		Spd = { 0.3, 1 },
		Sz = { 2, 8 }
	},
	{
		FogS = 35,
		FogE = 100,
		Bloom = 2,
		Rate = 35,
		Fog = Color3.fromRGB(20, 15, 30),
		AC = Color3.fromRGB(255, 100, 200),
		AC2 = Color3.fromRGB(100, 200, 255),
		Spd = { 0.5, 2 },
		Sz = { 1, 4 }
	},
	{
		FogS = 25,
		FogE = 75,
		Bloom = 1,
		Rate = 20,
		Fog = Color3.fromRGB(15, 5, 20),
		AC = Color3.fromRGB(150, 100, 200),
		AC2 = Color3.fromRGB(80, 50, 120),
		Spd = { 0.5, 2 },
		Sz = { 1, 5 }
	},
	{
		FogS = 25,
		FogE = 75,
		Bloom = 1,
		Rate = 30,
		Fog = Color3.fromRGB(15, 5, 5),
		AC = Color3.fromRGB(255, 50, 50),
		AC2 = Color3.fromRGB(200, 0, 0),
		Spd = { 1, 3 },
		Sz = { 0.3, 1.5 }
	},
	{
		FogS = 25,
		FogE = 75,
		Bloom = 1.5,
		Rate = 30,
		Fog = Color3.fromRGB(20, 10, 30),
		AC = Color3.fromRGB(200, 100, 255),
		AC2 = Color3.fromRGB(100, 50, 200),
		Spd = { 1, 3 },
		Sz = { 0.5, 3 }
	},
	{
		FogS = 40,
		FogE = 110,
		Bloom = 1,
		Rate = 20,
		Fog = Color3.fromRGB(10, 10, 15),
		AC = Color3.fromRGB(100, 150, 255),
		AC2 = Color3.fromRGB(200, 220, 255),
		Spd = { 0.5, 2 },
		Sz = { 1, 5 }
	},
	{
		FogS = 35,
		FogE = 100,
		Bloom = 0.5,
		Rate = 20,
		Fog = Color3.fromRGB(15, 8, 5),
		AC = Color3.fromRGB(200, 150, 80),
		AC2 = Color3.fromRGB(150, 100, 50),
		Spd = { 0.5, 2 },
		Sz = { 1, 4 }
	},
	{
		FogS = 25,
		FogE = 75,
		Bloom = 2,
		Rate = 40,
		Fog = Color3.fromRGB(0, 20, 30),
		AC = Color3.fromRGB(255, 200, 255),
		AC2 = Color3.fromRGB(0, 200, 200),
		Spd = { 1, 3 },
		Sz = { 0.5, 3 }
	},
	{
		FogS = 25,
		FogE = 85,
		Bloom = 2.5,
		Rate = 30,
		Fog = Color3.fromRGB(0, 0, 0),
		AC = Color3.fromRGB(255, 255, 255),
		AC2 = Color3.fromRGB(150, 200, 255),
		Spd = { 0.3, 1.5 },
		Sz = { 0.5, 2 }
	},
	{
		FogS = 35,
		FogE = 100,
		Bloom = 0,
		Rate = 15,
		Fog = Color3.fromRGB(20, 15, 5),
		AC = Color3.fromRGB(200, 180, 140),
		AC2 = Color3.fromRGB(160, 130, 80),
		Spd = { 0.3, 1.5 },
		Sz = { 1, 5 }
	},
	{
		FogS = 20,
		FogE = 60,
		Bloom = 0.8,
		Rate = 25,
		Fog = Color3.fromRGB(0, 15, 25),
		AC = Color3.fromRGB(255, 130, 150),
		AC2 = Color3.fromRGB(200, 80, 120),
		Spd = { 0.5, 2 },
		Sz = { 0.5, 3 }
	},
	{
		FogS = 30,
		FogE = 90,
		Bloom = 0,
		Rate = 20,
		Fog = Color3.fromRGB(20, 10, 5),
		AC = Color3.fromRGB(200, 120, 50),
		AC2 = Color3.fromRGB(150, 80, 20),
		Spd = { 1, 3 },
		Sz = { 0.3, 1.5 }
	},
	{
		FogS = 25,
		FogE = 75,
		Bloom = 1,
		Rate = 25,
		Fog = Color3.fromRGB(25, 20, 10),
		AC = Color3.fromRGB(255, 240, 180),
		AC2 = Color3.fromRGB(200, 180, 100),
		Spd = { 0.5, 2 },
		Sz = { 1, 5 }
	},
	{
		FogS = 20,
		FogE = 60,
		Bloom = 1.5,
		Rate = 35,
		Fog = Color3.fromRGB(10, 10, 20),
		AC = Color3.fromRGB(80, 200, 255),
		AC2 = Color3.fromRGB(200, 230, 255),
		Spd = { 2, 5 },
		Sz = { 0.2, 1 }
	},
	{
		FogS = 20,
		FogE = 60,
		Bloom = 1,
		Rate = 25,
		Fog = Color3.fromRGB(5, 0, 8),
		AC = Color3.fromRGB(150, 50, 200),
		AC2 = Color3.fromRGB(80, 0, 120),
		Spd = { 1, 3 },
		Sz = { 0.3, 2 }
	},
	{
		FogS = 25,
		FogE = 85,
		Bloom = 1.5,
		Rate = 30,
		Fog = Color3.fromRGB(5, 10, 15),
		AC = Color3.fromRGB(100, 255, 150),
		AC2 = Color3.fromRGB(255, 100, 200),
		Spd = { 0.5, 2 },
		Sz = { 1, 4 }
	},
	{
		FogS = 20,
		FogE = 60,
		Bloom = 0.8,
		Rate = 20,
		Fog = Color3.fromRGB(5, 15, 10),
		AC = Color3.fromRGB(200, 150, 100),
		AC2 = Color3.fromRGB(100, 200, 150),
		Spd = { 0.5, 2 },
		Sz = { 1, 4 }
	},
	{
		FogS = 35,
		FogE = 100,
		Bloom = 0,
		Rate = 15,
		Fog = Color3.fromRGB(15, 12, 10),
		AC = Color3.fromRGB(230, 210, 150),
		AC2 = Color3.fromRGB(180, 160, 100),
		Spd = { 0.3, 1.5 },
		Sz = { 1, 5 }
	},
	{
		FogS = 15,
		FogE = 55,
		Bloom = 0.5,
		Rate = 10,
		Fog = Color3.fromRGB(5, 0, 10),
		AC = Color3.fromRGB(150, 150, 180),
		AC2 = Color3.fromRGB(80, 80, 120),
		Spd = { 0.2, 0.8 },
		Sz = { 2, 8 }
	}
}
t.Backdrop = {
	{
		Mat = "SmoothPlastic",
		Decor = "none",
		GradTop = Color3.fromRGB(10, 10, 15),
		GradBot = Color3.fromRGB(0, 0, 0)
	},
	{
		Mat = "Neon",
		Decor = "circuits",
		GradTop = Color3.fromRGB(5, 0, 20),
		GradBot = Color3.fromRGB(15, 5, 30)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "vines",
		GradTop = Color3.fromRGB(5, 15, 5),
		GradBot = Color3.fromRGB(15, 25, 10)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "coral",
		GradTop = Color3.fromRGB(0, 0, 30),
		GradBot = Color3.fromRGB(0, 10, 40)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "flames",
		GradTop = Color3.fromRGB(30, 5, 0),
		GradBot = Color3.fromRGB(50, 10, 0)
	},
	{
		Mat = "Glass",
		Decor = "crystals",
		GradTop = Color3.fromRGB(20, 10, 30),
		GradBot = Color3.fromRGB(30, 15, 40)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "none",
		GradTop = Color3.fromRGB(3, 3, 3),
		GradBot = Color3.fromRGB(8, 8, 10)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "stars",
		GradTop = Color3.fromRGB(10, 0, 25),
		GradBot = Color3.fromRGB(20, 0, 40)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "flames",
		GradTop = Color3.fromRGB(25, 20, 5),
		GradBot = Color3.fromRGB(35, 25, 10)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "vines",
		GradTop = Color3.fromRGB(5, 15, 10),
		GradBot = Color3.fromRGB(10, 25, 15)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "gears",
		GradTop = Color3.fromRGB(20, 15, 5),
		GradBot = Color3.fromRGB(30, 20, 8)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "chains",
		GradTop = Color3.fromRGB(5, 0, 10),
		GradBot = Color3.fromRGB(15, 0, 15)
	},
	{
		Mat = "DiamondPlate",
		Decor = "circuits",
		GradTop = Color3.fromRGB(5, 15, 5),
		GradBot = Color3.fromRGB(10, 25, 10)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "stars",
		GradTop = Color3.fromRGB(5, 5, 20),
		GradBot = Color3.fromRGB(10, 10, 35)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "runes",
		GradTop = Color3.fromRGB(10, 15, 25),
		GradBot = Color3.fromRGB(15, 20, 30)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "stars",
		GradTop = Color3.fromRGB(15, 15, 10),
		GradBot = Color3.fromRGB(30, 25, 15)
	},
	{
		Mat = "Neon",
		Decor = "lightning",
		GradTop = Color3.fromRGB(15, 0, 15),
		GradBot = Color3.fromRGB(25, 5, 25)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "circuits",
		GradTop = Color3.fromRGB(15, 15, 20),
		GradBot = Color3.fromRGB(25, 25, 35)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "circuits",
		GradTop = Color3.fromRGB(5, 15, 15),
		GradBot = Color3.fromRGB(10, 25, 25)
	},
	{
		Mat = "Ice",
		Decor = "icicles",
		GradTop = Color3.fromRGB(15, 20, 30),
		GradBot = Color3.fromRGB(25, 30, 40)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "flames",
		GradTop = Color3.fromRGB(40, 15, 0),
		GradBot = Color3.fromRGB(60, 20, 0)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "chains",
		GradTop = Color3.fromRGB(3, 3, 5),
		GradBot = Color3.fromRGB(8, 8, 12)
	},
	{
		Mat = "ForceField",
		Decor = "crystals",
		GradTop = Color3.fromRGB(15, 10, 25),
		GradBot = Color3.fromRGB(25, 15, 35)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "runes",
		GradTop = Color3.fromRGB(10, 5, 15),
		GradBot = Color3.fromRGB(20, 8, 25)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "circuits",
		GradTop = Color3.fromRGB(15, 5, 5),
		GradBot = Color3.fromRGB(25, 8, 8)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "runes",
		GradTop = Color3.fromRGB(15, 8, 20),
		GradBot = Color3.fromRGB(25, 12, 35)
	},
	{
		Mat = "Neon",
		Decor = "stars",
		GradTop = Color3.fromRGB(5, 5, 10),
		GradBot = Color3.fromRGB(0, 0, 0)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "bones",
		GradTop = Color3.fromRGB(20, 15, 8),
		GradBot = Color3.fromRGB(30, 22, 12)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "coral",
		GradTop = Color3.fromRGB(0, 15, 20),
		GradBot = Color3.fromRGB(5, 25, 35)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "stars",
		GradTop = Color3.fromRGB(0, 0, 0),
		GradBot = Color3.fromRGB(5, 5, 8)
	},
	{
		Mat = "Slate",
		Decor = "bones",
		GradTop = Color3.fromRGB(20, 15, 8),
		GradBot = Color3.fromRGB(30, 22, 10)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "coral",
		GradTop = Color3.fromRGB(0, 10, 18),
		GradBot = Color3.fromRGB(5, 20, 30)
	},
	{
		Mat = "Metal",
		Decor = "chains",
		GradTop = Color3.fromRGB(15, 8, 3),
		GradBot = Color3.fromRGB(25, 12, 5)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "pillars",
		GradTop = Color3.fromRGB(25, 20, 10),
		GradBot = Color3.fromRGB(35, 28, 15)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "lightning",
		GradTop = Color3.fromRGB(8, 8, 15),
		GradBot = Color3.fromRGB(12, 12, 25)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "crystals",
		GradTop = Color3.fromRGB(3, 0, 5),
		GradBot = Color3.fromRGB(8, 0, 12)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "icicles",
		GradTop = Color3.fromRGB(3, 8, 12),
		GradBot = Color3.fromRGB(8, 15, 20)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "pillars",
		GradTop = Color3.fromRGB(3, 12, 8),
		GradBot = Color3.fromRGB(8, 20, 15)
	},
	{
		Mat = "Slate",
		Decor = "bones",
		GradTop = Color3.fromRGB(12, 10, 8),
		GradBot = Color3.fromRGB(20, 16, 12)
	},
	{
		Mat = "SmoothPlastic",
		Decor = "chains",
		GradTop = Color3.fromRGB(3, 0, 8),
		GradBot = Color3.fromRGB(5, 0, 12)
	}
}

return t

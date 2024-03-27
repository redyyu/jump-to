require "Definitions/FitnessExercises"

FitnessExercises.exercisesType.benchpress = {
	type = "benchpress",
	name = getText("IGUI_BenchPress"),
	tooltip = getText("IGUI_BenchPress_Tooltip"),
	stiffness = "arms,chest",
	item = "Base.BarBell",
	prop = "twohands",
	nearby = {
		customName = "Contraption",
		groupName = "Fitness",
		sprites = {
			['recreational_sports_01_40'] = 1,
			['recreational_sports_01_43'] = 1,
			['recreational_sports_01_45'] = 1,
			['recreational_sports_01_46'] = 1,

			-- No need those, too complex.
			-- ['recreational_sports_01_40'] = {standTo = 'N', facingTo = 'S'},
			-- ['recreational_sports_01_41'] = {standTo = '', facingTo = 'S'},

			-- ['recreational_sports_01_42'] = {standTo = '', facingTo = 'E'},
			-- ['recreational_sports_01_43'] = {standTo = 'W', facingTo = 'E'},

			-- ['recreational_sports_01_44'] = {standTo = '', facingTo = 'N'},
			-- ['recreational_sports_01_45'] = {standTo = 'S', facingTo = 'N'},

			-- ['recreational_sports_01_46'] = {standTo = 'E', facingTo = 'W'},
			-- ['recreational_sports_01_47'] = {standTo = '', facingTo = 'W'},
		}
		
	},
	electricity = true,
	metabolics = Metabolics.FitnessHeavy,
	xpMod = 1.5,
}

FitnessExercises.exercisesType.treadmill = {
	type = "treadmill",
	name = getText("IGUI_Treadmill"),
	tooltip = getText("IGUI_Treadmill_Tooltip"),
	stiffness = "legs", 
	metabolics = Metabolics.Fitness,
	electricity = true,
	nearby = {
		customName = "Human",
		groupName = "Hamster Wheel",
		sprites = {
			['recreational_sports_01_28'] = 1,
			['recreational_sports_01_31'] = 1,
			['recreational_sports_01_37'] = 1,
			['recreational_sports_01_38'] = 1,
			
			-- No need those, still too complex.
			-- ['recreational_sports_01_28'] = 'C',
			-- ['recreational_sports_01_29'] = 'W',

			-- ['recreational_sports_01_30'] = 'N',
			-- ['recreational_sports_01_31'] = 'C',

			-- ['recreational_sports_01_36'] = 'E',
			-- ['recreational_sports_01_37'] = 'C',

			-- ['recreational_sports_01_38'] = 'C',
			-- ['recreational_sports_01_39'] = 'S',
		}
	},
	xpMod = 0.8,
}

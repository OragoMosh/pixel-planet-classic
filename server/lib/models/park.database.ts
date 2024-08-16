import { Sequelize } from 'sequelize-typescript';
import { ParkTable } from './park/parkModels';
import * as ParkModels from './park/parkModels';

export { ParkTable as default, ParkTable } from './park/parkModels';
export * from './park/parkModels';

export const ParkDatabase = new Sequelize({
	dialect: 'sqlite',
	storage: './database/parks.sqlite',
	logging: false,
	dialectOptions: {
		journal_mode: 'DELETE', // Set the journal mode to WAL
		pool: {
			max: 5,
			min: 0,
			acquire: 30000,
			idle: 10000,
		},
	}
});

/* ----- Attatch ----- */

ParkDatabase.addModels([
	ParkModels.ParkTable,
	ParkModels.DroppedItemsTable,
	ParkModels.DimensionsTable,
	ParkModels.BlocksTable,
	ParkModels.BackgroundsTable,
	ParkModels.AccessedTable,
	ParkModels.ParkBeepBoxTable
]);

/* ----- Sync ----- */

ParkModels.DroppedItemsTable.belongsTo(ParkTable, {
	foreignKey: 'park',
	onDelete: 'CASCADE'
});

ParkModels.DimensionsTable.belongsTo(ParkTable, {
	foreignKey: 'park',
	onDelete: 'CASCADE'
});

ParkModels.BlocksTable.belongsTo(ParkTable, {
	foreignKey: 'park',
	onDelete: 'CASCADE'
});

ParkModels.BackgroundsTable.belongsTo(ParkTable, {
	foreignKey: 'park',
	onDelete: 'CASCADE'
});

ParkModels.AccessedTable.belongsTo(ParkTable, {
	foreignKey: 'park',
	onDelete: 'CASCADE'
});

ParkModels.ParkBeepBoxTable.belongsTo(ParkTable, {
	foreignKey: 'park',
	onDelete: 'CASCADE'
});

(async function () {
	await ParkModels.ParkTable.sync({
		alter: { drop: false }
	});
	await ParkModels.DroppedItemsTable.sync({ force: false });
	await ParkModels.DimensionsTable.sync({ force: false });
	await ParkModels.BlocksTable.sync({ force: false });
	await ParkModels.BackgroundsTable.sync({ force: false });
	await ParkModels.AccessedTable.sync({ force: false });
	await ParkModels.ParkBeepBoxTable.sync({ force: false });
})();
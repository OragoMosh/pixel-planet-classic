import { ModelCtor, Sequelize } from 'sequelize-typescript';
import { CoinsTable } from './user/userModels';
import { UserTable } from './user/user.model';
export { UserTable } from './user/user.model';

export const UserDatabase = new Sequelize({
	dialect: 'sqlite',
	storage: './database/users.sqlite',
	logging: false, // Disable logging
});

const nonSpecialTables: Array<ModelCtor> = [
	UserTable,
	CoinsTable,
];

UserDatabase.addModels([
	...nonSpecialTables,
]);

(async function () {
	for (const table of nonSpecialTables)
		await table.sync({ force: false });
})();
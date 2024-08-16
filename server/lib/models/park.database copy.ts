import { Sequelize } from 'sequelize-typescript';
import { UserTable } from './user/user.model';

export { UserTable } from './user/user.model';

export const UserDatabase = new Sequelize({
	dialect: 'sqlite',
	storage: './database/parks.sqlite',
	logging: false, // Disable logging
});

UserDatabase.addModels([
	UserTable,
]);
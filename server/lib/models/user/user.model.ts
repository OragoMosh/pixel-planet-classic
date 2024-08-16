import { AutoIncrement, Column, Model, PrimaryKey, Table } from 'sequelize-typescript';

@Table({
	tableName: 'users',
	freezeTableName: true
})
export class UserTable extends Model {
	@PrimaryKey
	@AutoIncrement
	@Column
	declare userID: number;

	@Column
	declare username: string;

	@Column
	declare nickname: string;

	@Column
	declare password: string;

	@Column
	declare email: string;
}
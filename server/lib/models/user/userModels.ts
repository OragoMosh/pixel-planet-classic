import { AllowNull, Column, Default, ForeignKey, Model, PrimaryKey, Table } from 'sequelize-typescript';
import { UserTable } from './user.model';

@Table({
	tableName: 'currency',
	freezeTableName: true
})
export class CoinsTable extends Model {
	@PrimaryKey
	@ForeignKey(() => UserTable)
	@Column
	declare userID: number;

	@Default(0)
	@Column
	declare coins: number;
}


@Table({
	tableName: 'inventory',
	freezeTableName: true
})
export class InventoryTable extends Model {
	@PrimaryKey
	@ForeignKey(() => UserTable)
	@Column
	declare userID: number;

	@AllowNull(false)
	@Column
	declare item: string;

	@AllowNull(false)
	@Column
	declare amount: number;
}
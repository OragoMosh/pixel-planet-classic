import { AllowNull, AutoIncrement, BeforeSave, Column, Default, ForeignKey, Index, Model, PrimaryKey, Table, Unique } from 'sequelize-typescript';
import { BetterDataTypes } from '../../util/sequelizeJsonSupport';

@Table({
	tableName: 'park',
	freezeTableName: true
})
export class ParkTable extends Model {
	@PrimaryKey
	@AutoIncrement
	@Unique
	@Column
	declare parkID: number;

	@PrimaryKey
	@Column
	declare name: string;

	@Column
	declare owner: number;

	@Column
	declare salePrice: number;

	@Default(1)
	@Column
	declare type: number;
}

@Table({
	tableName: 'accessed',
	freezeTableName: true
})
export class AccessedTable extends Model {
	@PrimaryKey
	@ForeignKey(() => ParkTable)
	@Column
	declare park: number;

	@PrimaryKey
	@Column
	declare userID: number;

	/**
	 * 0 ~ Full Rights1
	 * 1 ~ Minor Rights
	 */
	@Default(1)
	@Column
	declare permission: number;
}

@Table({
	tableName: 'dropped',
	freezeTableName: true,
	timestamps: false,
	indexes: [
		{
			unique: true,
			fields: ['worldID', 'itemID']
		}
	]
})
export class DroppedItemsTable extends Model {
	@PrimaryKey
	@ForeignKey(() => ParkTable)
	@Column
	declare park: number;

	@AllowNull(false)
	@Column
	declare item: number;

	@AllowNull(false)
	@Column
	declare amount: number;

	@Column
	declare x: number;

	@Column
	declare y: number;
}

@Table({
	tableName: 'size',
	freezeTableName: true
})
export class DimensionsTable extends Model {
	@PrimaryKey
	@ForeignKey(() => ParkTable)
	@Column
	declare park: number;

	@Column
	declare depth: number;

	@Default(10)
	@Column
	declare width: number;

	@Default(10)
	@Column
	declare height: number;
}

@Table({
	tableName: 'blocks',
	freezeTableName: true,
	timestamps: false
})
export class BlocksTable extends Model {
	@PrimaryKey
	@ForeignKey(() => ParkTable)
	@Column
	declare park: number;

	@AllowNull(false)
	@Unique
	@Column
	declare type: number;

	@AllowNull(false)
	@PrimaryKey
	@Unique
	@Column
	declare x: number;

	@AllowNull(false)
	@PrimaryKey
	@Unique
	@Column
	declare y: number;

	@Column(BetterDataTypes.JSON_OBJECT)
	declare data: object;

	@BeforeSave
	static FormatData(instance: BlocksTable) {
		if (instance.changed('data') === false) {
			instance.changed('data', true);
		}
	}
}

@Table({
	tableName: 'backgrounds',
	freezeTableName: true,
	timestamps: false
})
export class BackgroundsTable extends Model {
	@PrimaryKey
	@ForeignKey(() => ParkTable)
	@Column
	declare park: number;

	@AllowNull(false)
	@Unique
	@Column
	declare type: number;

	@AllowNull(false)
	@PrimaryKey
	@Unique
	@Column
	declare x: number;

	@AllowNull(false)
	@PrimaryKey
	@Unique
	@Column
	declare y: number;

	@Column(BetterDataTypes.JSON_OBJECT)
	declare data: object;

	@BeforeSave
	static FormatData(instance: BackgroundsTable) {
		if (instance.changed('data') === false) {
			instance.changed('data', true);
		}
	}
}

@Table({
	tableName: 'beepbox',
	freezeTableName: true
})
export class ParkBeepBoxTable extends Model {
	@PrimaryKey
	@Index
	@ForeignKey(() => ParkTable)
	@Column
	declare park: number;

	@Column
	declare songID: number;
}
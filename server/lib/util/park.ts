import { ModelCtor } from 'sequelize-typescript';
import ParkTable, { BackgroundsTable, BlocksTable } from '../models/park.database';
import Status from '@orago/lib/status';


class TileManager<TileModel extends BlocksTable | BackgroundsTable> {
	model: TileModel;

	constructor(model: TileModel) {
		this.model = model;
	}
}

class ParkOwner {
	static async get(parkID: number): Promise<number | undefined> {
		if (typeof parkID != 'number')
			return undefined;

		return await ParkTable
			.findByPk(parkID)
			.then(e => e?.owner)
	}

	static async owns(userID: number, parkID: number): Promise<boolean> {
		const owner = await this.get(parkID);

		return typeof owner == 'number' && userID === owner;
	}

	static async set(userID: number, parkID: number) {
		const entry = await ParkTable.findByPk(parkID);

		if (entry == null)
			return new Status.Error('No World With This ID');

		await entry.update({
			owner: userID,
			salePrice: null
		});

		return new Status.Success('Successfully Owned');
	}
}


class Park {
	static Owner = ParkOwner;

	static async existsID(userID: number) {
		return await ParkTable.findByPk(userID) != null;
	}

	static async existsUsername(name: string) {
		return await ParkTable.findOne({ where: { name } }) != null;
	}
}
import itemData from 'itemData.json';

export type ItemID = keyof typeof itemData;

export class ItemHelper {
	static getItem<T extends ItemID>(key: T): typeof itemData[T] | undefined {
		return itemData[key];
	}

	static validItem(key: string): key is ItemID {
		return itemData[key as ItemID] != null;
	}
}
import { Sequelize, DataTypes, Utils } from 'sequelize';

export class JSON_OBJECT extends DataTypes.ABSTRACT.prototype.constructor {
	static key = 'JSON_OBJECT';

	/**
	 * @param {number} length
	 */
	constructor(length) {
		super();

		const options = typeof length === 'object' && length || { length };

		this.options = options;
		this._length = options.length || "";
	}

	toSql() {
		return 'json';
	}

	/**
	 *
	 * @param {object} value
	 * @returns {object}
	 */
	_sanitize(value) {
		return typeof value == 'object' ? value : {}
	}

	/**
	 *
	 * @param {object} object
	 * @returns {string}
	 */
	_stringify(object) {
		return JSON.stringify(object);
	}

	/**
	 *
	 * @param {string} value
	 * @returns {object}
	 */
	static parse (value){
		try {
			const result = JSON.parse(value);

			if (result == null){
				throw '';
			} else {
				return result;
			}
		}

		catch (error) {
			return {};
		}
	}

	/**
	 *
	 * @param {string} link
	 * @param {string} text
	 */
	static warn (link, text){
		console.log(`${text} >> Check: ${link}`);
	}
}

JSON_OBJECT.prototype.key = JSON_OBJECT.key;

export const BetterDataTypes =
Object.assign({}, DataTypes, {
  JSON_OBJECT: Utils.classToInvokable(JSON_OBJECT)
});
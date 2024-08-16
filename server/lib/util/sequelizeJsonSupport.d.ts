//@ts-nocheck
import { AbstractDataType, DataTypes } from "sequelize";
import { JSON_OBJECT } from "./sequelizeJsonSupport.js";

export const OBJECT: JSONDataTypeConstructor;


interface JSONDataTypeConstructor extends AbstractDataTypeConstructor {
  new (length?: number): JSON_OBJECT;
  new (options?: StringDataTypeOptions): JSON_OBJECT;
  (length?: number, binary?: boolean): JSON_OBJECT;
  (options?: StringDataTypeOptions): JSON_OBJECT;
  key: string;
  warn(link: string, text: string): void;
}

export interface JSON_OBJECT extends AbstractDataType {
  options?: JSONDataTypeConstructor;
  BINARY: this;
  validate(value: unknown): boolean;
}

export const BetterDataTypes = { ...DataTypes, JSON_OBJECT: OBJECT };
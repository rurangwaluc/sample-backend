"use strict";

const { z } = require("zod");
const { SYSTEM_CATEGORIES, PRODUCT_UNITS } = require("../utils/productCatalog");

const BAG_TOP_STYLES = [
  "HEM",
  "HEAT_CUT",
  "EASY_OPEN",
  "DRAWSTRING",
  "VALVE",
  "OTHER",
];

const BAG_BOTTOM_STYLES = [
  "SINGLE_FOLD",
  "DOUBLE_FOLD",
  "SINGLE_STITCH",
  "DOUBLE_STITCH",
  "BLOCK_BOTTOM",
  "VALVE",
  "OTHER",
];

const upperString = (value) =>
  String(value || "")
    .trim()
    .toUpperCase();

const unitField = z
  .string()
  .trim()
  .transform(upperString)
  .refine((value) => PRODUCT_UNITS.includes(value), "Invalid unit");

const systemCategoryField = z
  .string()
  .trim()
  .transform(upperString)
  .refine(
    (value) => SYSTEM_CATEGORIES.includes(value),
    "Invalid systemCategory",
  );

const bagAttributesSchema = z
  .object({
    bagType: z.string().trim().max(80).optional(),
    capacityKg: z.coerce.number().positive().max(5000).optional(),
    widthCm: z.coerce.number().positive().max(500).optional(),
    lengthCm: z.coerce.number().positive().max(500).optional(),
    gsm: z.coerce.number().positive().max(1000).optional(),
    topStyle: z
      .string()
      .trim()
      .transform(upperString)
      .refine((value) => BAG_TOP_STYLES.includes(value), "Invalid topStyle")
      .optional(),
    bottomStyle: z
      .string()
      .trim()
      .transform(upperString)
      .refine(
        (value) => BAG_BOTTOM_STYLES.includes(value),
        "Invalid bottomStyle",
      )
      .optional(),
    liner: z.coerce.boolean().optional(),
    laminated: z.coerce.boolean().optional(),
    printed: z.coerce.boolean().optional(),
    printColors: z.coerce.number().int().min(0).max(12).optional(),
    foodGrade: z.coerce.boolean().optional(),
    uvTreated: z.coerce.boolean().optional(),
    mesh: z.coerce.boolean().optional(),
    notes: z.string().trim().max(500).optional(),
  })
  .passthrough();

const createProductSchema = z.object({
  locationId: z.coerce.number().int().positive().optional(),

  name: z.string().trim().min(2).max(180),
  displayName: z.string().trim().min(2).max(220).optional(),

  systemCategory: systemCategoryField.optional(),
  category: z.string().trim().max(120).optional(),
  subcategory: z.string().trim().max(80).optional(),

  sku: z.string().trim().min(1).max(80).optional(),
  barcode: z.string().trim().min(1).max(120).optional(),
  supplierSku: z.string().trim().min(1).max(120).optional(),

  brand: z.string().trim().max(80).optional(),
  model: z.string().trim().max(80).optional(),
  size: z.string().trim().max(40).optional(),
  color: z.string().trim().max(40).optional(),
  material: z.string().trim().max(80).optional(),
  variantSummary: z.string().trim().max(200).optional(),

  unit: unitField.optional(),
  stockUnit: unitField.optional(),
  salesUnit: unitField.optional(),
  purchaseUnit: unitField.optional(),

  purchaseUnitFactor: z.coerce.number().int().positive().max(100000).optional(),

  sellingPrice: z.coerce.number().int().nonnegative(),
  costPrice: z.coerce.number().int().nonnegative().optional(),
  maxDiscountPercent: z.coerce.number().int().min(0).max(100).optional(),

  openingQty: z.coerce.number().int().nonnegative().optional(),
  reorderLevel: z.coerce.number().int().nonnegative().optional(),

  trackInventory: z.coerce.boolean().optional(),
  notes: z.string().trim().max(4000).optional(),
  attributes: bagAttributesSchema.optional(),
});

const updateProductSchema = z.object({
  locationId: z.coerce.number().int().positive().optional(),

  name: z.string().trim().min(2).max(180).optional(),
  displayName: z.string().trim().min(2).max(220).optional(),

  systemCategory: systemCategoryField.optional(),
  category: z.string().trim().max(120).optional(),
  subcategory: z.string().trim().max(80).optional(),

  sku: z.string().trim().min(1).max(80).optional(),
  barcode: z.string().trim().min(1).max(120).optional(),
  supplierSku: z.string().trim().min(1).max(120).optional(),

  brand: z.string().trim().max(80).optional(),
  model: z.string().trim().max(80).optional(),
  size: z.string().trim().max(40).optional(),
  color: z.string().trim().max(40).optional(),
  material: z.string().trim().max(80).optional(),
  variantSummary: z.string().trim().max(200).optional(),

  unit: unitField.optional(),
  stockUnit: unitField.optional(),
  salesUnit: unitField.optional(),
  purchaseUnit: unitField.optional(),

  purchaseUnitFactor: z.coerce.number().int().positive().max(100000).optional(),

  sellingPrice: z.coerce.number().int().nonnegative().optional(),
  costPrice: z.coerce.number().int().nonnegative().optional(),
  maxDiscountPercent: z.coerce.number().int().min(0).max(100).optional(),

  reorderLevel: z.coerce.number().int().nonnegative().optional(),

  trackInventory: z.coerce.boolean().optional(),
  notes: z.string().trim().max(4000).optional(),
  attributes: bagAttributesSchema.optional(),
});

const adjustInventorySchema = z.object({
  productId: z.coerce.number().int().positive(),
  qtyChange: z.coerce.number().int(),
  reason: z.string().trim().min(3).max(300),
});

const ownerAdjustInventorySchema = z.object({
  locationId: z.coerce.number().int().positive(),
  productId: z.coerce.number().int().positive(),
  qtyChange: z.coerce
    .number()
    .int()
    .refine((value) => value !== 0, {
      message: "qtyChange must not be zero",
    }),
  reason: z.string().trim().min(3).max(300),
});

module.exports = {
  BAG_TOP_STYLES,
  BAG_BOTTOM_STYLES,
  createProductSchema,
  updateProductSchema,
  adjustInventorySchema,
  ownerAdjustInventorySchema,
};

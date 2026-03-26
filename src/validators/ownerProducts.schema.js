"use strict";

const { z } = require("zod");
const { SYSTEM_CATEGORIES, PRODUCT_UNITS } = require("../utils/productCatalog");

const updateOwnerProductSchema = z.object({
  name: z.string().trim().min(2).max(180).optional(),

  displayName: z.string().trim().min(2).max(220).optional(),

  systemCategory: z
    .string()
    .trim()
    .transform((v) => String(v || "").toUpperCase())
    .refine((v) => SYSTEM_CATEGORIES.includes(v), "Invalid systemCategory")
    .optional(),

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

  unit: z
    .string()
    .trim()
    .transform((v) => String(v || "").toUpperCase())
    .refine((v) => PRODUCT_UNITS.includes(v), "Invalid unit")
    .optional(),

  stockUnit: z
    .string()
    .trim()
    .transform((v) => String(v || "").toUpperCase())
    .refine((v) => PRODUCT_UNITS.includes(v), "Invalid stockUnit")
    .optional(),

  salesUnit: z
    .string()
    .trim()
    .transform((v) => String(v || "").toUpperCase())
    .refine((v) => PRODUCT_UNITS.includes(v), "Invalid salesUnit")
    .optional(),

  purchaseUnit: z
    .string()
    .trim()
    .transform((v) => String(v || "").toUpperCase())
    .refine((v) => PRODUCT_UNITS.includes(v), "Invalid purchaseUnit")
    .optional(),

  purchaseUnitFactor: z.coerce.number().int().positive().max(100000).optional(),

  reorderLevel: z.coerce.number().int().min(0).optional(),
  trackInventory: z.coerce.boolean().optional(),
  notes: z.string().trim().max(4000).optional(),

  attributes: z.record(z.any()).optional(),
});

module.exports = {
  updateOwnerProductSchema,
};

const {
  pgTable,
  serial,
  integer,
  varchar,
  timestamp,
  boolean,
  bigint,
  text,
  index,
  jsonb,
} = require("drizzle-orm/pg-core");

const { locations } = require("./locations.schema");

const products = pgTable(
  "products",
  {
    id: serial("id").primaryKey(),

    locationId: integer("location_id")
      .notNull()
      .references(() => locations.id, { onDelete: "cascade" }),

    name: varchar("name", { length: 180 }).notNull(),
    displayName: varchar("display_name", { length: 220 }),

    productType: varchar("product_type", { length: 40 })
      .notNull()
      .default("PP_BAG"),

    systemCategory: varchar("system_category", { length: 80 })
      .notNull()
      .default("WOVEN_PP_BAG"),

    category: varchar("category", { length: 120 }),
    subcategory: varchar("subcategory", { length: 80 }),

    sku: varchar("sku", { length: 80 }),
    barcode: varchar("barcode", { length: 120 }),
    supplierCode: varchar("supplier_code", { length: 120 }),
    supplierSku: varchar("supplier_sku", { length: 120 }),

    brand: varchar("brand", { length: 80 }),
    model: varchar("model", { length: 120 }),
    variantLabel: varchar("variant_label", { length: 120 }),
    variantSummary: varchar("variant_summary", { length: 200 }),
    size: varchar("size", { length: 40 }),
    color: varchar("color", { length: 40 }),
    material: varchar("material", { length: 80 }),

    unit: varchar("unit", { length: 40 }).notNull().default("PIECE"),
    stockUnit: varchar("stock_unit", { length: 40 }).notNull().default("PIECE"),
    salesUnit: varchar("sales_unit", { length: 40 }).notNull().default("PIECE"),
    purchaseUnit: varchar("purchase_unit", { length: 40 })
      .notNull()
      .default("PIECE"),
    purchaseUnitFactor: integer("purchase_unit_factor").notNull().default(1),

    sellingPrice: bigint("selling_price", { mode: "number" })
      .notNull()
      .default(0),
    costPrice: bigint("cost_price", { mode: "number" }).notNull().default(0),
    maxDiscountPercent: integer("max_discount_percent").notNull().default(0),

    trackInventory: boolean("track_inventory").notNull().default(true),
    reorderLevel: integer("reorder_level").notNull().default(0),
    attributes: jsonb("attributes"),

    isActive: boolean("is_active").notNull().default(true),
    notes: text("notes"),

    createdAt: timestamp("created_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true })
      .notNull()
      .defaultNow(),
  },
  (table) => ({
    productsLocationIdx: index("products_location_idx").on(table.locationId),
    productsLocationNameIdx: index("products_location_name_idx").on(
      table.locationId,
      table.name,
    ),
    productsLocationDisplayNameIdx: index(
      "products_location_display_name_idx",
    ).on(table.locationId, table.displayName),
    productsLocationSkuIdx: index("products_location_sku_idx").on(
      table.locationId,
      table.sku,
    ),
    productsLocationBarcodeIdx: index("products_location_barcode_idx").on(
      table.locationId,
      table.barcode,
    ),
    productsLocationSupplierSkuIdx: index(
      "products_location_supplier_sku_idx",
    ).on(table.locationId, table.supplierSku),
    productsLocationTypeIdx: index("products_location_type_idx").on(
      table.locationId,
      table.productType,
    ),
    productsLocationSystemCategoryIdx: index(
      "products_location_system_category_idx",
    ).on(table.locationId, table.systemCategory),
    productsLocationCategoryIdx: index("products_location_category_idx").on(
      table.locationId,
      table.category,
    ),
    productsLocationActiveIdx: index("products_location_active_idx").on(
      table.locationId,
      table.isActive,
    ),
  }),
);

module.exports = { products };

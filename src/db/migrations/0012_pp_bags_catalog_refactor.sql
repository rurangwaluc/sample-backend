ALTER TABLE "products"
  ADD COLUMN IF NOT EXISTS "display_name" varchar(220);

ALTER TABLE "products"
  ADD COLUMN IF NOT EXISTS "system_category" varchar(80) DEFAULT 'WOVEN_PP_BAG' NOT NULL;

ALTER TABLE "products"
  ADD COLUMN IF NOT EXISTS "supplier_sku" varchar(120);

ALTER TABLE "products"
  ADD COLUMN IF NOT EXISTS "variant_summary" varchar(200);

ALTER TABLE "products"
  ADD COLUMN IF NOT EXISTS "stock_unit" varchar(40) DEFAULT 'PIECE' NOT NULL;

ALTER TABLE "products"
  ADD COLUMN IF NOT EXISTS "sales_unit" varchar(40) DEFAULT 'PIECE' NOT NULL;

ALTER TABLE "products"
  ADD COLUMN IF NOT EXISTS "purchase_unit" varchar(40) DEFAULT 'PIECE' NOT NULL;

ALTER TABLE "products"
  ADD COLUMN IF NOT EXISTS "purchase_unit_factor" integer DEFAULT 1 NOT NULL;

ALTER TABLE "products"
  ADD COLUMN IF NOT EXISTS "track_inventory" boolean DEFAULT true NOT NULL;

ALTER TABLE "products"
  ADD COLUMN IF NOT EXISTS "attributes" jsonb;

ALTER TABLE "products"
  ALTER COLUMN "product_type" SET DEFAULT 'PP_BAG';

UPDATE "products"
SET "product_type" = 'PP_BAG'
WHERE COALESCE("product_type", '') <> 'PP_BAG';

UPDATE "products"
SET "system_category" = CASE
  WHEN COALESCE("system_category", '') <> '' THEN "system_category"
  WHEN UPPER(COALESCE("category", '')) IN (
    'WOVEN_PP_BAG',
    'LAMINATED_PP_BAG',
    'BOPP_LAMINATED_BAG',
    'LINER_PP_BAG',
    'VALVE_PP_BAG',
    'GUSSETED_PP_BAG',
    'VENTILATED_PP_BAG',
    'MESH_PP_BAG',
    'FIBC_JUMBO_BAG',
    'OTHER_PP_BAG'
  ) THEN UPPER("category")
  ELSE 'OTHER_PP_BAG'
END;

CREATE INDEX IF NOT EXISTS "products_location_display_name_idx"
  ON "products" ("location_id", "display_name");

CREATE INDEX IF NOT EXISTS "products_location_supplier_sku_idx"
  ON "products" ("location_id", "supplier_sku");

CREATE INDEX IF NOT EXISTS "products_location_system_category_idx"
  ON "products" ("location_id", "system_category");
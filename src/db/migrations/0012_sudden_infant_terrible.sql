CREATE TYPE "public"."location_status" AS ENUM('ACTIVE', 'CLOSED', 'ARCHIVED');--> statement-breakpoint
CREATE TABLE "credit_installments" (
	"id" serial PRIMARY KEY NOT NULL,
	"location_id" integer NOT NULL,
	"credit_id" integer NOT NULL,
	"sale_id" integer NOT NULL,
	"installment_no" integer NOT NULL,
	"amount" bigint NOT NULL,
	"paid_amount" bigint DEFAULT 0 NOT NULL,
	"remaining_amount" bigint NOT NULL,
	"due_date" timestamp with time zone NOT NULL,
	"status" varchar(30) DEFAULT 'PENDING' NOT NULL,
	"paid_at" timestamp with time zone,
	"note" text,
	"created_at" timestamp with time zone DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "credit_payments" (
	"id" serial PRIMARY KEY NOT NULL,
	"location_id" integer NOT NULL,
	"credit_id" integer NOT NULL,
	"sale_id" integer NOT NULL,
	"amount" integer NOT NULL,
	"method" varchar(20) NOT NULL,
	"cash_session_id" integer,
	"received_by" integer NOT NULL,
	"reference" varchar(120),
	"note" text,
	"created_at" timestamp with time zone DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "delivery_note_items" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"delivery_note_id" bigint NOT NULL,
	"sale_item_id" integer,
	"product_id" integer,
	"product_name" varchar(180) NOT NULL,
	"product_display_name" varchar(220),
	"product_sku" varchar(80),
	"stock_unit" varchar(40) DEFAULT 'PIECE' NOT NULL,
	"qty" integer DEFAULT 0 NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "delivery_notes" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"location_id" integer NOT NULL,
	"sale_id" integer NOT NULL,
	"customer_id" integer,
	"created_by_user_id" integer NOT NULL,
	"delivery_note_no" varchar(120),
	"status" varchar(30) DEFAULT 'ISSUED' NOT NULL,
	"customer_name" varchar(160),
	"customer_phone" varchar(40),
	"customer_tin" varchar(60),
	"customer_address" text,
	"delivered_to" varchar(160),
	"delivered_phone" varchar(40),
	"dispatched_at" timestamp with time zone,
	"delivered_at" timestamp with time zone,
	"note" text,
	"total_items" integer DEFAULT 0 NOT NULL,
	"total_qty" integer DEFAULT 0 NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "goods_receipt_items" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"goods_receipt_id" bigint NOT NULL,
	"purchase_order_item_id" bigint NOT NULL,
	"product_id" integer NOT NULL,
	"product_name" varchar(180) NOT NULL,
	"product_display_name" varchar(220),
	"product_sku" varchar(80),
	"stock_unit" varchar(40) DEFAULT 'PIECE' NOT NULL,
	"purchase_unit" varchar(40) DEFAULT 'PIECE' NOT NULL,
	"purchase_unit_factor" integer DEFAULT 1 NOT NULL,
	"qty_received_purchase" integer DEFAULT 0 NOT NULL,
	"qty_received_stock" integer DEFAULT 0 NOT NULL,
	"unit_cost" bigint DEFAULT 0 NOT NULL,
	"line_total" bigint DEFAULT 0 NOT NULL,
	"note" varchar(300),
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "goods_receipts" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"location_id" integer NOT NULL,
	"purchase_order_id" bigint NOT NULL,
	"supplier_id" integer NOT NULL,
	"receipt_no" varchar(120),
	"reference" varchar(120),
	"note" text,
	"received_by_user_id" integer NOT NULL,
	"received_at" timestamp with time zone DEFAULT now() NOT NULL,
	"total_lines" integer DEFAULT 0 NOT NULL,
	"total_units_received" integer DEFAULT 0 NOT NULL,
	"total_amount" bigint DEFAULT 0 NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "internal_notes" (
	"id" serial PRIMARY KEY NOT NULL,
	"location_id" integer NOT NULL,
	"entity_type" text NOT NULL,
	"entity_id" integer NOT NULL,
	"message" text NOT NULL,
	"created_by" integer NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "inventory_arrival_items" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"arrival_id" bigint NOT NULL,
	"product_id" integer NOT NULL,
	"product_name" varchar(180) NOT NULL,
	"product_display_name" varchar(220),
	"product_sku" varchar(80),
	"stock_unit" varchar(40) DEFAULT 'PIECE' NOT NULL,
	"purchase_unit" varchar(40) DEFAULT 'PIECE' NOT NULL,
	"purchase_unit_factor" integer DEFAULT 1 NOT NULL,
	"qty_received" integer DEFAULT 0 NOT NULL,
	"bonus_qty" integer DEFAULT 0 NOT NULL,
	"stock_qty_received" integer DEFAULT 0 NOT NULL,
	"unit_cost" bigint DEFAULT 0 NOT NULL,
	"line_total" bigint DEFAULT 0 NOT NULL,
	"note" varchar(300),
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "notes" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"location_id" bigint NOT NULL,
	"user_id" bigint NOT NULL,
	"entity" text NOT NULL,
	"entity_id" bigint NOT NULL,
	"body" text NOT NULL,
	"is_pinned" boolean DEFAULT false NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "notifications" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"location_id" integer NOT NULL,
	"recipient_user_id" integer NOT NULL,
	"actor_user_id" integer,
	"type" text NOT NULL,
	"title" text NOT NULL,
	"body" text,
	"priority" varchar(20) DEFAULT 'normal' NOT NULL,
	"entity" text,
	"entity_id" integer,
	"is_read" boolean DEFAULT false NOT NULL,
	"read_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "proforma_items" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"proforma_id" bigint NOT NULL,
	"product_id" integer,
	"product_name" varchar(180) NOT NULL,
	"product_display_name" varchar(220),
	"product_sku" varchar(80),
	"stock_unit" varchar(40) DEFAULT 'PIECE' NOT NULL,
	"qty" integer DEFAULT 0 NOT NULL,
	"unit_price" bigint DEFAULT 0 NOT NULL,
	"line_total" bigint DEFAULT 0 NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "proformas" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"location_id" integer NOT NULL,
	"customer_id" integer,
	"created_by_user_id" integer NOT NULL,
	"proforma_no" varchar(120),
	"status" varchar(30) DEFAULT 'DRAFT' NOT NULL,
	"customer_name" varchar(160),
	"customer_phone" varchar(40),
	"customer_tin" varchar(60),
	"customer_address" text,
	"currency" varchar(12) DEFAULT 'RWF' NOT NULL,
	"subtotal" bigint DEFAULT 0 NOT NULL,
	"total_amount" bigint DEFAULT 0 NOT NULL,
	"valid_until" date,
	"note" text,
	"terms" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "purchase_order_items" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"purchase_order_id" bigint NOT NULL,
	"product_id" integer,
	"product_name" varchar(180) NOT NULL,
	"product_display_name" varchar(220),
	"product_sku" varchar(80),
	"stock_unit" varchar(40) DEFAULT 'PIECE' NOT NULL,
	"purchase_unit" varchar(40) DEFAULT 'PIECE' NOT NULL,
	"purchase_unit_factor" integer DEFAULT 1 NOT NULL,
	"qty_ordered" integer DEFAULT 0 NOT NULL,
	"qty_received" integer DEFAULT 0 NOT NULL,
	"unit_cost" bigint DEFAULT 0 NOT NULL,
	"line_total" bigint DEFAULT 0 NOT NULL,
	"note" varchar(300),
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "purchase_orders" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"location_id" integer NOT NULL,
	"supplier_id" integer NOT NULL,
	"po_no" varchar(120),
	"reference" varchar(120),
	"currency" varchar(12) DEFAULT 'RWF' NOT NULL,
	"status" varchar(40) DEFAULT 'DRAFT' NOT NULL,
	"notes" text,
	"ordered_at" timestamp with time zone DEFAULT now() NOT NULL,
	"expected_at" timestamp with time zone,
	"approved_at" timestamp with time zone,
	"created_by_user_id" integer NOT NULL,
	"approved_by_user_id" integer,
	"subtotal_amount" bigint DEFAULT 0 NOT NULL,
	"total_amount" bigint DEFAULT 0 NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "refund_items" (
	"id" bigserial PRIMARY KEY NOT NULL,
	"refund_id" bigint NOT NULL,
	"sale_item_id" integer NOT NULL,
	"product_id" bigint NOT NULL,
	"qty" integer NOT NULL,
	"amount" bigint NOT NULL
);
--> statement-breakpoint
CREATE TABLE "supplier_bill_items" (
	"id" serial PRIMARY KEY NOT NULL,
	"bill_id" integer NOT NULL,
	"product_id" integer,
	"description" varchar(240) NOT NULL,
	"qty" integer NOT NULL,
	"unit_cost" integer NOT NULL,
	"line_total" integer NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "supplier_payments" (
	"id" serial PRIMARY KEY NOT NULL,
	"supplier_bill_id" integer NOT NULL,
	"supplier_id" integer NOT NULL,
	"location_id" integer,
	"amount" bigint DEFAULT 0 NOT NULL,
	"method" text DEFAULT 'BANK' NOT NULL,
	"reference" text,
	"note" text,
	"paid_at" timestamp DEFAULT now() NOT NULL,
	"created_by" integer,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "supplier_bills" (
	"id" serial PRIMARY KEY NOT NULL,
	"supplier_id" integer NOT NULL,
	"location_id" integer NOT NULL,
	"bill_no" varchar(80),
	"currency" varchar(8) DEFAULT 'RWF' NOT NULL,
	"total_amount" integer NOT NULL,
	"paid_amount" integer DEFAULT 0 NOT NULL,
	"status" varchar(20) DEFAULT 'OPEN' NOT NULL,
	"issued_date" date DEFAULT now(),
	"due_date" date,
	"note" text,
	"created_by_user_id" integer,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "supplier_bill_payments" (
	"id" serial PRIMARY KEY NOT NULL,
	"bill_id" integer NOT NULL,
	"amount" integer NOT NULL,
	"method" varchar(20) NOT NULL,
	"reference" varchar(120),
	"note" varchar(200),
	"paid_at" timestamp with time zone DEFAULT now() NOT NULL,
	"created_by_user_id" integer,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "suppliers" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" varchar(180) NOT NULL,
	"contact_name" varchar(140),
	"phone" varchar(40),
	"email" varchar(140),
	"country" varchar(120),
	"city" varchar(120),
	"source_type" varchar(24) DEFAULT 'LOCAL' NOT NULL,
	"default_currency" varchar(8) DEFAULT 'RWF' NOT NULL,
	"address" text,
	"notes" text,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "messages" DISABLE ROW LEVEL SECURITY;--> statement-breakpoint
DROP TABLE "messages" CASCADE;--> statement-breakpoint
ALTER TABLE "users" DROP CONSTRAINT "users_email_unique";--> statement-breakpoint
DROP INDEX "inventory_location_product_uniq";--> statement-breakpoint
ALTER TABLE "audit_logs" ALTER COLUMN "action" SET DATA TYPE varchar(80);--> statement-breakpoint
ALTER TABLE "audit_logs" ALTER COLUMN "entity" SET DATA TYPE varchar(50);--> statement-breakpoint
ALTER TABLE "audit_logs" ALTER COLUMN "description" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "audit_logs" ALTER COLUMN "meta" SET DATA TYPE jsonb USING "meta"::jsonb;--> statement-breakpoint
ALTER TABLE "cash_ledger" ALTER COLUMN "method" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "cash_ledger" ALTER COLUMN "created_at" SET DATA TYPE timestamp with time zone;--> statement-breakpoint
ALTER TABLE "cash_ledger" ALTER COLUMN "created_at" SET DEFAULT now();--> statement-breakpoint
ALTER TABLE "cash_reconciliations" ALTER COLUMN "difference" DROP NOT NULL;--> statement-breakpoint
ALTER TABLE "credits" ALTER COLUMN "status" SET DATA TYPE varchar(30);--> statement-breakpoint
ALTER TABLE "credits" ALTER COLUMN "status" SET DEFAULT 'PENDING';--> statement-breakpoint
ALTER TABLE "credits" ALTER COLUMN "approved_at" SET DATA TYPE timestamp with time zone;--> statement-breakpoint
ALTER TABLE "credits" ALTER COLUMN "settled_at" SET DATA TYPE timestamp with time zone;--> statement-breakpoint
ALTER TABLE "credits" ALTER COLUMN "created_at" SET DATA TYPE timestamp with time zone;--> statement-breakpoint
ALTER TABLE "credits" ALTER COLUMN "created_at" SET DEFAULT now();--> statement-breakpoint
ALTER TABLE "inventory_adjustment_requests" ALTER COLUMN "product_id" SET DATA TYPE bigint;--> statement-breakpoint
ALTER TABLE "inventory_adjustment_requests" ALTER COLUMN "created_at" SET DATA TYPE timestamp with time zone;--> statement-breakpoint
ALTER TABLE "inventory_adjustment_requests" ALTER COLUMN "created_at" SET DEFAULT now();--> statement-breakpoint
ALTER TABLE "inventory_adjustment_requests" ALTER COLUMN "decided_at" SET DATA TYPE timestamp with time zone;--> statement-breakpoint
ALTER TABLE "inventory_arrivals" ALTER COLUMN "id" TYPE bigint;--> statement-breakpoint
ALTER TABLE "inventory_arrivals" ALTER COLUMN "created_at" SET DATA TYPE timestamp with time zone;--> statement-breakpoint
ALTER TABLE "inventory_arrivals" ALTER COLUMN "created_at" SET DEFAULT now();--> statement-breakpoint
ALTER TABLE "inventory_balances" ALTER COLUMN "product_id" SET DATA TYPE bigint;--> statement-breakpoint
ALTER TABLE "inventory_balances" ALTER COLUMN "updated_at" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "payments" ALTER COLUMN "method" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "payments" ALTER COLUMN "created_at" SET DATA TYPE timestamp with time zone;--> statement-breakpoint
ALTER TABLE "payments" ALTER COLUMN "created_at" SET DEFAULT now();--> statement-breakpoint
ALTER TABLE "products" ALTER COLUMN "unit" SET DEFAULT 'PIECE';--> statement-breakpoint
ALTER TABLE "products" ALTER COLUMN "unit" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "products" ALTER COLUMN "selling_price" SET DATA TYPE bigint;--> statement-breakpoint
ALTER TABLE "products" ALTER COLUMN "cost_price" SET DATA TYPE bigint;--> statement-breakpoint
ALTER TABLE "products" ALTER COLUMN "cost_price" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "products" ALTER COLUMN "is_active" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "products" ALTER COLUMN "created_at" SET DATA TYPE timestamp with time zone;--> statement-breakpoint
ALTER TABLE "products" ALTER COLUMN "created_at" SET DEFAULT now();--> statement-breakpoint
ALTER TABLE "products" ALTER COLUMN "created_at" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "refunds" ALTER COLUMN "id" TYPE bigint;--> statement-breakpoint
ALTER TABLE "refunds" ALTER COLUMN "created_at" SET DATA TYPE timestamp with time zone;--> statement-breakpoint
ALTER TABLE "refunds" ALTER COLUMN "created_at" SET DEFAULT now();--> statement-breakpoint
ALTER TABLE "sale_items" ALTER COLUMN "product_id" SET DATA TYPE bigint;--> statement-breakpoint
ALTER TABLE "sale_items" ALTER COLUMN "unit_price" SET DATA TYPE bigint;--> statement-breakpoint
ALTER TABLE "sale_items" ALTER COLUMN "line_total" SET DATA TYPE bigint;--> statement-breakpoint
ALTER TABLE "sales" ALTER COLUMN "total_amount" SET DATA TYPE bigint;--> statement-breakpoint
ALTER TABLE "sales" ALTER COLUMN "created_at" SET DATA TYPE timestamp with time zone;--> statement-breakpoint
ALTER TABLE "sales" ALTER COLUMN "created_at" SET DEFAULT now();--> statement-breakpoint
ALTER TABLE "sales" ALTER COLUMN "updated_at" SET DATA TYPE timestamp with time zone;--> statement-breakpoint
ALTER TABLE "sales" ALTER COLUMN "updated_at" SET DEFAULT now();--> statement-breakpoint
ALTER TABLE "sales" ALTER COLUMN "canceled_at" SET DATA TYPE timestamp with time zone;--> statement-breakpoint
ALTER TABLE "seller_holdings" ALTER COLUMN "updated_at" SET DATA TYPE timestamp with time zone;--> statement-breakpoint
ALTER TABLE "seller_holdings" ALTER COLUMN "updated_at" SET DEFAULT now();--> statement-breakpoint
ALTER TABLE "seller_holdings" ALTER COLUMN "updated_at" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "stock_requests" ALTER COLUMN "created_at" SET DATA TYPE timestamp with time zone;--> statement-breakpoint
ALTER TABLE "stock_requests" ALTER COLUMN "created_at" SET DEFAULT now();--> statement-breakpoint
ALTER TABLE "stock_requests" ALTER COLUMN "created_at" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "users" ALTER COLUMN "is_active" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "users" ALTER COLUMN "created_at" SET DATA TYPE timestamp with time zone;--> statement-breakpoint
ALTER TABLE "users" ALTER COLUMN "created_at" SET DEFAULT now();--> statement-breakpoint
ALTER TABLE "users" ALTER COLUMN "created_at" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "audit_logs" ADD COLUMN "location_id" integer;--> statement-breakpoint
ALTER TABLE "cash_ledger" ADD COLUMN "cash_session_id" integer;--> statement-breakpoint
ALTER TABLE "cash_ledger" ADD COLUMN "reference" varchar(120);--> statement-breakpoint
ALTER TABLE "cash_ledger" ADD COLUMN "credit_id" integer;--> statement-breakpoint
ALTER TABLE "cash_ledger" ADD COLUMN "credit_payment_id" integer;--> statement-breakpoint
ALTER TABLE "credits" ADD COLUMN "principal_amount" bigint NOT NULL;--> statement-breakpoint
ALTER TABLE "credits" ADD COLUMN "paid_amount" bigint DEFAULT 0 NOT NULL;--> statement-breakpoint
ALTER TABLE "credits" ADD COLUMN "remaining_amount" bigint NOT NULL;--> statement-breakpoint
ALTER TABLE "credits" ADD COLUMN "credit_mode" varchar(30) DEFAULT 'OPEN_BALANCE' NOT NULL;--> statement-breakpoint
ALTER TABLE "credits" ADD COLUMN "due_date" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "credits" ADD COLUMN "rejected_by" integer;--> statement-breakpoint
ALTER TABLE "credits" ADD COLUMN "rejected_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "customers" ADD COLUMN "tin" varchar(60);--> statement-breakpoint
ALTER TABLE "customers" ADD COLUMN "address" text;--> statement-breakpoint
ALTER TABLE "customers" ADD COLUMN "updated_at" timestamp DEFAULT now();--> statement-breakpoint
ALTER TABLE "inventory_arrivals" ADD COLUMN "supplier_id" integer;--> statement-breakpoint
ALTER TABLE "inventory_arrivals" ADD COLUMN "reference" varchar(120);--> statement-breakpoint
ALTER TABLE "inventory_arrivals" ADD COLUMN "document_no" varchar(120);--> statement-breakpoint
ALTER TABLE "inventory_arrivals" ADD COLUMN "source_type" varchar(40) DEFAULT 'MANUAL' NOT NULL;--> statement-breakpoint
ALTER TABLE "inventory_arrivals" ADD COLUMN "source_id" integer;--> statement-breakpoint
ALTER TABLE "inventory_arrivals" ADD COLUMN "total_amount" bigint DEFAULT 0 NOT NULL;--> statement-breakpoint
ALTER TABLE "inventory_arrivals" ADD COLUMN "received_by_user_id" integer NOT NULL;--> statement-breakpoint
ALTER TABLE "inventory_arrivals" ADD COLUMN "received_at" timestamp with time zone DEFAULT now() NOT NULL;--> statement-breakpoint
ALTER TABLE "locations" ADD COLUMN "code" varchar(40) NOT NULL;--> statement-breakpoint
ALTER TABLE "locations" ADD COLUMN "status" "location_status" DEFAULT 'ACTIVE' NOT NULL;--> statement-breakpoint
ALTER TABLE "locations" ADD COLUMN "email" varchar(160);--> statement-breakpoint
ALTER TABLE "locations" ADD COLUMN "phone" varchar(40);--> statement-breakpoint
ALTER TABLE "locations" ADD COLUMN "website" varchar(200);--> statement-breakpoint
ALTER TABLE "locations" ADD COLUMN "logo_url" varchar(500);--> statement-breakpoint
ALTER TABLE "locations" ADD COLUMN "address" varchar(255);--> statement-breakpoint
ALTER TABLE "locations" ADD COLUMN "tin" varchar(64);--> statement-breakpoint
ALTER TABLE "locations" ADD COLUMN "momo_code" varchar(64);--> statement-breakpoint
ALTER TABLE "locations" ADD COLUMN "bank_accounts" jsonb DEFAULT '[]'::jsonb NOT NULL;--> statement-breakpoint
ALTER TABLE "locations" ADD COLUMN "opened_at" timestamp with time zone DEFAULT now() NOT NULL;--> statement-breakpoint
ALTER TABLE "locations" ADD COLUMN "closed_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "locations" ADD COLUMN "archived_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "locations" ADD COLUMN "close_reason" varchar(500);--> statement-breakpoint
ALTER TABLE "locations" ADD COLUMN "updated_at" timestamp with time zone DEFAULT now() NOT NULL;--> statement-breakpoint
ALTER TABLE "payments" ADD COLUMN "cash_session_id" integer;--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "display_name" varchar(220);--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "product_type" varchar(40) DEFAULT 'PP_BAG' NOT NULL;--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "system_category" varchar(80) DEFAULT 'WOVEN_PP_BAG' NOT NULL;--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "category" varchar(120);--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "subcategory" varchar(80);--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "barcode" varchar(120);--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "supplier_code" varchar(120);--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "supplier_sku" varchar(120);--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "brand" varchar(80);--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "model" varchar(120);--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "variant_label" varchar(120);--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "variant_summary" varchar(200);--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "size" varchar(40);--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "color" varchar(40);--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "material" varchar(80);--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "stock_unit" varchar(40) DEFAULT 'PIECE' NOT NULL;--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "sales_unit" varchar(40) DEFAULT 'PIECE' NOT NULL;--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "purchase_unit" varchar(40) DEFAULT 'PIECE' NOT NULL;--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "purchase_unit_factor" integer DEFAULT 1 NOT NULL;--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "track_inventory" boolean DEFAULT true NOT NULL;--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "reorder_level" integer DEFAULT 0 NOT NULL;--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "attributes" jsonb;--> statement-breakpoint
ALTER TABLE "products" ADD COLUMN "updated_at" timestamp with time zone DEFAULT now() NOT NULL;--> statement-breakpoint
ALTER TABLE "refunds" ADD COLUMN "total_amount" bigint DEFAULT 0 NOT NULL;--> statement-breakpoint
ALTER TABLE "refunds" ADD COLUMN "method" varchar(20) DEFAULT 'CASH' NOT NULL;--> statement-breakpoint
ALTER TABLE "refunds" ADD COLUMN "reference" varchar(120);--> statement-breakpoint
ALTER TABLE "refunds" ADD COLUMN "payment_id" integer;--> statement-breakpoint
ALTER TABLE "refunds" ADD COLUMN "cash_session_id" integer;--> statement-breakpoint
ALTER TABLE "sales" ADD COLUMN "payment_method" varchar(30);--> statement-breakpoint
ALTER TABLE "sessions" ADD COLUMN "acting_as_role" varchar(50);--> statement-breakpoint
ALTER TABLE "sessions" ADD COLUMN "coverage_reason" varchar(50);--> statement-breakpoint
ALTER TABLE "sessions" ADD COLUMN "coverage_note" text;--> statement-breakpoint
ALTER TABLE "sessions" ADD COLUMN "coverage_started_at" timestamp;--> statement-breakpoint
ALTER TABLE "stock_request_items" ADD COLUMN "qty" integer NOT NULL;--> statement-breakpoint
ALTER TABLE "stock_requests" ADD COLUMN "approved_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "stock_requests" ADD COLUMN "approved_by" integer;--> statement-breakpoint
ALTER TABLE "stock_requests" ADD COLUMN "rejected_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "stock_requests" ADD COLUMN "rejected_by" integer;--> statement-breakpoint
ALTER TABLE "stock_requests" ADD COLUMN "released_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "stock_requests" ADD COLUMN "released_by" integer;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "last_seen_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "supplier_bill_items" ADD CONSTRAINT "supplier_bill_items_bill_id_supplier_bills_id_fk" FOREIGN KEY ("bill_id") REFERENCES "public"."supplier_bills"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "supplier_payments" ADD CONSTRAINT "supplier_payments_supplier_bill_id_supplier_bills_id_fk" FOREIGN KEY ("supplier_bill_id") REFERENCES "public"."supplier_bills"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "supplier_payments" ADD CONSTRAINT "supplier_payments_supplier_id_suppliers_id_fk" FOREIGN KEY ("supplier_id") REFERENCES "public"."suppliers"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "supplier_bills" ADD CONSTRAINT "supplier_bills_supplier_id_suppliers_id_fk" FOREIGN KEY ("supplier_id") REFERENCES "public"."suppliers"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "supplier_bills" ADD CONSTRAINT "supplier_bills_location_id_locations_id_fk" FOREIGN KEY ("location_id") REFERENCES "public"."locations"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "supplier_bill_payments" ADD CONSTRAINT "supplier_bill_payments_bill_id_supplier_bills_id_fk" FOREIGN KEY ("bill_id") REFERENCES "public"."supplier_bills"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "credit_installments_credit_no_uniq" ON "credit_installments" USING btree ("location_id","credit_id","installment_no");--> statement-breakpoint
CREATE INDEX "credit_installments_credit_idx" ON "credit_installments" USING btree ("location_id","credit_id");--> statement-breakpoint
CREATE INDEX "credit_installments_sale_idx" ON "credit_installments" USING btree ("location_id","sale_id");--> statement-breakpoint
CREATE INDEX "idx_delivery_note_items_delivery_note_id" ON "delivery_note_items" USING btree ("delivery_note_id");--> statement-breakpoint
CREATE INDEX "idx_delivery_notes_location_created" ON "delivery_notes" USING btree ("location_id","created_at");--> statement-breakpoint
CREATE INDEX "idx_delivery_notes_sale_id" ON "delivery_notes" USING btree ("sale_id");--> statement-breakpoint
CREATE INDEX "idx_goods_receipt_items_receipt_id" ON "goods_receipt_items" USING btree ("goods_receipt_id");--> statement-breakpoint
CREATE INDEX "idx_goods_receipt_items_po_item_id" ON "goods_receipt_items" USING btree ("purchase_order_item_id");--> statement-breakpoint
CREATE INDEX "idx_goods_receipts_location_created" ON "goods_receipts" USING btree ("location_id","created_at");--> statement-breakpoint
CREATE INDEX "idx_goods_receipts_po_id" ON "goods_receipts" USING btree ("purchase_order_id");--> statement-breakpoint
CREATE INDEX "internal_notes_loc_entity_idx" ON "internal_notes" USING btree ("location_id","entity_type","entity_id","created_at");--> statement-breakpoint
CREATE INDEX "internal_notes_loc_created_idx" ON "internal_notes" USING btree ("location_id","created_by","created_at");--> statement-breakpoint
CREATE INDEX "notifications_recipient_unread_idx" ON "notifications" USING btree ("recipient_user_id","is_read","created_at");--> statement-breakpoint
CREATE INDEX "notifications_location_created_idx" ON "notifications" USING btree ("location_id","created_at");--> statement-breakpoint
CREATE INDEX "idx_proforma_items_proforma_id" ON "proforma_items" USING btree ("proforma_id");--> statement-breakpoint
CREATE INDEX "idx_proformas_location_created" ON "proformas" USING btree ("location_id","created_at");--> statement-breakpoint
CREATE INDEX "idx_purchase_order_items_po_id" ON "purchase_order_items" USING btree ("purchase_order_id");--> statement-breakpoint
CREATE INDEX "idx_purchase_order_items_product_id" ON "purchase_order_items" USING btree ("product_id");--> statement-breakpoint
CREATE INDEX "idx_purchase_orders_location_created" ON "purchase_orders" USING btree ("location_id","created_at");--> statement-breakpoint
CREATE INDEX "idx_purchase_orders_supplier" ON "purchase_orders" USING btree ("supplier_id");--> statement-breakpoint
CREATE INDEX "idx_purchase_orders_status" ON "purchase_orders" USING btree ("status");--> statement-breakpoint
CREATE INDEX "supplier_bill_items_bill_idx" ON "supplier_bill_items" USING btree ("bill_id");--> statement-breakpoint
CREATE INDEX "supplier_bill_items_product_idx" ON "supplier_bill_items" USING btree ("product_id");--> statement-breakpoint
CREATE INDEX "supplier_bills_supplier_idx" ON "supplier_bills" USING btree ("supplier_id");--> statement-breakpoint
CREATE INDEX "supplier_bills_location_idx" ON "supplier_bills" USING btree ("location_id");--> statement-breakpoint
CREATE INDEX "supplier_bills_status_idx" ON "supplier_bills" USING btree ("status");--> statement-breakpoint
CREATE INDEX "supplier_bills_due_date_idx" ON "supplier_bills" USING btree ("due_date");--> statement-breakpoint
CREATE INDEX "supplier_bills_created_at_idx" ON "supplier_bills" USING btree ("created_at");--> statement-breakpoint
CREATE INDEX "supplier_bills_supplier_location_idx" ON "supplier_bills" USING btree ("supplier_id","location_id");--> statement-breakpoint
CREATE INDEX "supplier_bill_payments_bill_idx" ON "supplier_bill_payments" USING btree ("bill_id");--> statement-breakpoint
CREATE INDEX "supplier_bill_payments_method_idx" ON "supplier_bill_payments" USING btree ("method");--> statement-breakpoint
CREATE INDEX "supplier_bill_payments_paid_at_idx" ON "supplier_bill_payments" USING btree ("paid_at");--> statement-breakpoint
ALTER TABLE "products" ADD CONSTRAINT "products_location_id_locations_id_fk" FOREIGN KEY ("location_id") REFERENCES "public"."locations"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "users" ADD CONSTRAINT "users_location_id_locations_id_fk" FOREIGN KEY ("location_id") REFERENCES "public"."locations"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "cash_reconciliations_cash_session_id_unique" ON "cash_reconciliations" USING btree ("cash_session_id");--> statement-breakpoint
CREATE UNIQUE INDEX "credits_location_sale_uniq" ON "credits" USING btree ("location_id","sale_id");--> statement-breakpoint
CREATE UNIQUE INDEX "customers_phone_location_unique" ON "customers" USING btree ("location_id","phone");--> statement-breakpoint
CREATE INDEX "idx_inventory_arrivals_location_received_at" ON "inventory_arrivals" USING btree ("location_id","received_at");--> statement-breakpoint
CREATE INDEX "idx_inventory_arrivals_supplier" ON "inventory_arrivals" USING btree ("supplier_id");--> statement-breakpoint
CREATE INDEX "idx_inventory_arrivals_received_by" ON "inventory_arrivals" USING btree ("received_by_user_id");--> statement-breakpoint
CREATE UNIQUE INDEX "inv_balances_location_product_uniq" ON "inventory_balances" USING btree ("location_id","product_id");--> statement-breakpoint
CREATE UNIQUE INDEX "locations_code_uniq" ON "locations" USING btree ("code");--> statement-breakpoint
CREATE INDEX "locations_status_idx" ON "locations" USING btree ("status");--> statement-breakpoint
CREATE INDEX "products_location_idx" ON "products" USING btree ("location_id");--> statement-breakpoint
CREATE INDEX "products_location_name_idx" ON "products" USING btree ("location_id","name");--> statement-breakpoint
CREATE INDEX "products_location_display_name_idx" ON "products" USING btree ("location_id","display_name");--> statement-breakpoint
CREATE INDEX "products_location_sku_idx" ON "products" USING btree ("location_id","sku");--> statement-breakpoint
CREATE INDEX "products_location_barcode_idx" ON "products" USING btree ("location_id","barcode");--> statement-breakpoint
CREATE INDEX "products_location_supplier_sku_idx" ON "products" USING btree ("location_id","supplier_sku");--> statement-breakpoint
CREATE INDEX "products_location_type_idx" ON "products" USING btree ("location_id","product_type");--> statement-breakpoint
CREATE INDEX "products_location_system_category_idx" ON "products" USING btree ("location_id","system_category");--> statement-breakpoint
CREATE INDEX "products_location_category_idx" ON "products" USING btree ("location_id","category");--> statement-breakpoint
CREATE INDEX "products_location_active_idx" ON "products" USING btree ("location_id","is_active");--> statement-breakpoint
CREATE UNIQUE INDEX "stock_request_items_req_product_uniq" ON "stock_request_items" USING btree ("request_id","product_id");--> statement-breakpoint
CREATE UNIQUE INDEX "users_location_email_uniq" ON "users" USING btree ("location_id","email");--> statement-breakpoint
CREATE INDEX "users_location_idx" ON "users" USING btree ("location_id");--> statement-breakpoint
CREATE INDEX "users_role_idx" ON "users" USING btree ("role");--> statement-breakpoint
CREATE INDEX "users_is_active_idx" ON "users" USING btree ("is_active");--> statement-breakpoint
ALTER TABLE "credits" DROP COLUMN "amount";--> statement-breakpoint
ALTER TABLE "inventory_arrivals" DROP COLUMN "product_id";--> statement-breakpoint
ALTER TABLE "inventory_arrivals" DROP COLUMN "qty_received";--> statement-breakpoint
ALTER TABLE "inventory_arrivals" DROP COLUMN "created_by_user_id";--> statement-breakpoint
ALTER TABLE "refunds" DROP COLUMN "amount";--> statement-breakpoint
ALTER TABLE "stock_request_items" DROP COLUMN "qty_requested";--> statement-breakpoint
ALTER TABLE "stock_request_items" DROP COLUMN "qty_approved";--> statement-breakpoint
ALTER TABLE "stock_requests" DROP COLUMN "decided_at";--> statement-breakpoint
ALTER TABLE "stock_requests" DROP COLUMN "decided_by";
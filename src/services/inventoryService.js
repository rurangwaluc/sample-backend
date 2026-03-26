"use strict";

const { db } = require("../config/db");
const { products } = require("../db/schema/products.schema");
const { inventoryBalances } = require("../db/schema/inventory.schema");
const { eq, and, sql } = require("drizzle-orm");
const { safeLogAudit } = require("./auditService");
const {
  cleanText,
  normalizeSystemCategory,
  normalizeUnit,
  normalizePositiveInt,
  buildDisplayName,
  normalizeAttributes,
} = require("../utils/productCatalog");

function mapProductRow(row, includePurchasePrice = true) {
  if (!row) return null;

  const purchasePrice = Number(row.costPrice ?? row.purchasePrice ?? 0);

  return {
    id: Number(row.id),
    locationId: Number(row.locationId),
    name: row.name,
    displayName:
      row.displayName ||
      buildDisplayName({
        name: row.name,
        brand: row.brand,
        model: row.model,
        size: row.size,
        color: row.color,
        material: row.material,
        variantSummary: row.variantSummary,
        attributes: row.attributes,
      }) ||
      row.name ||
      null,

    productType: row.productType ?? "PP_BAG",
    systemCategory: row.systemCategory ?? "WOVEN_PP_BAG",
    category: row.category ?? null,
    subcategory: row.subcategory ?? null,

    sku: row.sku ?? null,
    barcode: row.barcode ?? null,
    supplierCode: row.supplierCode ?? null,
    supplierSku: row.supplierSku ?? row.supplierCode ?? null,

    brand: row.brand ?? null,
    model: row.model ?? null,
    variantLabel: row.variantLabel ?? null,
    variantSummary: row.variantSummary ?? row.variantLabel ?? null,
    size: row.size ?? null,
    color: row.color ?? null,
    material: row.material ?? null,

    unit: row.unit ?? "PIECE",
    stockUnit: row.stockUnit ?? row.unit ?? "PIECE",
    salesUnit: row.salesUnit ?? row.unit ?? "PIECE",
    purchaseUnit: row.purchaseUnit ?? row.unit ?? "PIECE",
    purchaseUnitFactor: Number(row.purchaseUnitFactor ?? 1),

    sellingPrice: Number(row.sellingPrice ?? 0),
    costPrice: purchasePrice,
    purchasePrice: includePurchasePrice ? purchasePrice : null,

    maxDiscountPercent: Number(row.maxDiscountPercent ?? 0),
    reorderLevel: Number(row.reorderLevel ?? 0),

    trackInventory: row.trackInventory !== false,
    attributes: row.attributes ?? null,

    isActive: row.isActive !== false,
    notes: row.notes ?? null,

    createdAt: row.createdAt ?? null,
    updatedAt: row.updatedAt ?? null,

    qtyOnHand:
      row.qtyOnHand === undefined || row.qtyOnHand === null
        ? undefined
        : Number(row.qtyOnHand || 0),
  };
}

function buildUnits(data = {}) {
  const baseUnit = normalizeUnit(data.unit || "PIECE");
  const stockUnit = normalizeUnit(data.stockUnit || baseUnit);
  const salesUnit = normalizeUnit(data.salesUnit || stockUnit);
  const purchaseUnit = normalizeUnit(data.purchaseUnit || stockUnit);

  return {
    unit: stockUnit,
    stockUnit,
    salesUnit,
    purchaseUnit,
  };
}

async function createProduct({ locationId, userId, data }) {
  return db.transaction(async (tx) => {
    const openingQty = normalizePositiveInt(data.openingQty, 0);

    const name = cleanText(data.name, 180);
    const sku = cleanText(data.sku, 80);
    const barcode = cleanText(data.barcode, 120);
    const supplierSku = cleanText(data.supplierSku || data.supplierCode, 120);

    const brand = cleanText(data.brand, 80);
    const model = cleanText(data.model, 120);
    const size = cleanText(data.size, 40);
    const color = cleanText(data.color, 40);
    const material = cleanText(data.material, 80);

    const variantSummary =
      cleanText(data.variantSummary, 200) || cleanText(data.variantLabel, 200);

    const attributes = normalizeAttributes(data.attributes);
    const systemCategory = normalizeSystemCategory(data.systemCategory);

    const { unit, stockUnit, salesUnit, purchaseUnit } = buildUnits(data);

    const displayName =
      cleanText(data.displayName, 220) ||
      buildDisplayName({
        name,
        brand,
        model,
        size,
        color,
        material,
        variantSummary,
        attributes,
      });

    const [created] = await tx
      .insert(products)
      .values({
        locationId,
        name,
        displayName,
        sku,
        unit,
        stockUnit,
        salesUnit,
        purchaseUnit,
        purchaseUnitFactor:
          normalizePositiveInt(data.purchaseUnitFactor, 1) || 1,

        productType: "PP_BAG",
        systemCategory,
        category: cleanText(data.category, 120),
        subcategory: cleanText(data.subcategory, 80),

        brand,
        model,
        variantLabel:
          cleanText(data.variantLabel, 120) || cleanText(variantSummary, 120),
        variantSummary,
        size,
        color,
        material,

        barcode,
        supplierCode: supplierSku,
        supplierSku,

        reorderLevel: normalizePositiveInt(data.reorderLevel, 0),

        sellingPrice: normalizePositiveInt(data.sellingPrice, 0),
        costPrice: normalizePositiveInt(data.costPrice, 0),
        maxDiscountPercent: normalizePositiveInt(data.maxDiscountPercent, 0),

        trackInventory: data.trackInventory !== false,
        attributes,

        isActive: true,
        notes: cleanText(data.notes, 4000),

        updatedAt: new Date(),
      })
      .returning();

    const [balance] = await tx
      .select()
      .from(inventoryBalances)
      .where(
        and(
          eq(inventoryBalances.locationId, locationId),
          eq(inventoryBalances.productId, created.id),
        ),
      );

    if (!balance) {
      await tx.insert(inventoryBalances).values({
        locationId,
        productId: created.id,
        qtyOnHand: openingQty,
        updatedAt: new Date(),
      });
    }

    await safeLogAudit({
      userId,
      action: "PRODUCT_CREATE",
      entity: "product",
      entityId: created.id,
      description: `Created product: ${displayName || name}`,
      meta: {
        productId: created.id,
        name: created.name,
        displayName,
        systemCategory,
        category: created.category,
        locationId,
        openingQty,
      },
      locationId,
    });

    return mapProductRow(
      {
        ...created,
        qtyOnHand: openingQty,
      },
      true,
    );
  });
}

async function listProducts({
  locationId,
  includePurchasePrice,
  includeInactive = false,
}) {
  const extraWhere = includeInactive ? sql`` : sql` AND p.is_active = true`;

  const result = await db.execute(sql`
    SELECT
      p.id,
      p.location_id as "locationId",
      p.name,
      p.display_name as "displayName",
      p.product_type as "productType",
      p.system_category as "systemCategory",
      p.category,
      p.subcategory,
      p.sku,
      p.barcode as "barcode",
      p.supplier_code as "supplierCode",
      p.supplier_sku as "supplierSku",
      p.brand,
      p.model,
      p.variant_label as "variantLabel",
      p.variant_summary as "variantSummary",
      p.size,
      p.color,
      p.material,
      p.unit,
      p.stock_unit as "stockUnit",
      p.sales_unit as "salesUnit",
      p.purchase_unit as "purchaseUnit",
      p.purchase_unit_factor as "purchaseUnitFactor",
      p.selling_price as "sellingPrice",
      p.cost_price as "purchasePrice",
      p.max_discount_percent as "maxDiscountPercent",
      p.reorder_level as "reorderLevel",
      p.track_inventory as "trackInventory",
      p.attributes as "attributes",
      p.is_active as "isActive",
      p.notes,
      p.created_at as "createdAt",
      p.updated_at as "updatedAt",
      COALESCE(ib.qty_on_hand, 0)::bigint as "qtyOnHand"
    FROM products p
    LEFT JOIN inventory_balances ib
      ON ib.product_id = p.id
     AND ib.location_id = p.location_id
    WHERE p.location_id = ${locationId}
    ${extraWhere}
    ORDER BY p.display_name ASC NULLS LAST, p.name ASC, p.id DESC
  `);

  const rows = result.rows || result || [];
  return rows.map((row) => mapProductRow(row, includePurchasePrice));
}

async function updateProductPricing({
  locationId,
  userId,
  productId,
  purchasePrice,
  sellingPrice,
  maxDiscountPercent,
}) {
  return db.transaction(async (tx) => {
    const found = await tx
      .select({
        id: products.id,
        name: products.name,
        displayName: products.displayName,
      })
      .from(products)
      .where(
        and(eq(products.id, productId), eq(products.locationId, locationId)),
      );

    if (!found[0]) {
      const err = new Error("Product not found");
      err.code = "NOT_FOUND";
      throw err;
    }

    const [updated] = await tx
      .update(products)
      .set({
        costPrice: normalizePositiveInt(purchasePrice, 0),
        sellingPrice: normalizePositiveInt(sellingPrice, 0),
        maxDiscountPercent: normalizePositiveInt(maxDiscountPercent, 0),
        updatedAt: new Date(),
      })
      .where(
        and(eq(products.id, productId), eq(products.locationId, locationId)),
      )
      .returning();

    await safeLogAudit({
      userId,
      action: "PRODUCT_PRICING_UPDATE",
      entity: "product",
      entityId: productId,
      description: `Updated pricing for product #${productId}`,
      meta: {
        productId,
        purchasePrice: normalizePositiveInt(purchasePrice, 0),
        sellingPrice: normalizePositiveInt(sellingPrice, 0),
        maxDiscountPercent: normalizePositiveInt(maxDiscountPercent, 0),
        locationId,
      },
      locationId,
    });

    return mapProductRow(updated, true);
  });
}

async function getInventoryBalances({ locationId, includeInactive = false }) {
  const extraWhere = includeInactive ? sql`` : sql` AND p.is_active = true`;

  const result = await db.execute(sql`
    SELECT
      p.id,
      p.location_id as "locationId",
      p.name,
      p.display_name as "displayName",
      p.product_type as "productType",
      p.system_category as "systemCategory",
      p.category,
      p.subcategory,
      p.sku,
      p.barcode as "barcode",
      p.supplier_code as "supplierCode",
      p.supplier_sku as "supplierSku",
      p.brand,
      p.model,
      p.variant_label as "variantLabel",
      p.variant_summary as "variantSummary",
      p.size,
      p.color,
      p.material,
      p.unit,
      p.stock_unit as "stockUnit",
      p.sales_unit as "salesUnit",
      p.purchase_unit as "purchaseUnit",
      p.purchase_unit_factor as "purchaseUnitFactor",
      p.selling_price as "sellingPrice",
      p.cost_price as "purchasePrice",
      p.max_discount_percent as "maxDiscountPercent",
      p.reorder_level as "reorderLevel",
      p.track_inventory as "trackInventory",
      p.attributes as "attributes",
      p.is_active as "isActive",
      p.notes,
      p.created_at as "createdAt",
      p.updated_at as "productUpdatedAt",
      COALESCE(b.qty_on_hand, 0)::bigint as "qtyOnHand",
      b.updated_at as "updatedAt"
    FROM products p
    LEFT JOIN inventory_balances b
      ON b.product_id = p.id
     AND b.location_id = p.location_id
    WHERE p.location_id = ${locationId}
    ${extraWhere}
    ORDER BY p.display_name ASC NULLS LAST, p.name ASC, p.id DESC
  `);

  const rows = result.rows || result || [];
  return rows.map((row) => mapProductRow(row, true));
}

async function adjustInventory(
  { locationId, userId, productId, qtyChange, reason },
  tx,
) {
  const qty = Number(qtyChange);

  if (!Number.isFinite(qty) || qty === 0) {
    const err = new Error("qtyChange must be a non-zero number");
    err.code = "BAD_QTY_CHANGE";
    throw err;
  }

  const run = async (trx) => {
    const productRows = await trx
      .select({
        id: products.id,
        name: products.name,
        displayName: products.displayName,
        brand: products.brand,
        model: products.model,
        size: products.size,
        color: products.color,
        material: products.material,
        variantSummary: products.variantSummary,
        attributes: products.attributes,
        isActive: products.isActive,
      })
      .from(products)
      .where(
        and(eq(products.id, productId), eq(products.locationId, locationId)),
      );

    if (!productRows[0]) {
      const err = new Error("Product not found");
      err.code = "NOT_FOUND";
      throw err;
    }

    if (productRows[0].isActive === false) {
      const err = new Error("Product is archived");
      err.code = "ARCHIVED";
      throw err;
    }

    const [balanceRow] = await trx
      .select()
      .from(inventoryBalances)
      .where(
        and(
          eq(inventoryBalances.locationId, locationId),
          eq(inventoryBalances.productId, productId),
        ),
      );

    let newQty;

    if (balanceRow) {
      newQty = Number(balanceRow.qtyOnHand || 0) + qty;

      if (newQty < 0) {
        const err = new Error("Insufficient stock");
        err.code = "INSUFFICIENT_STOCK";
        throw err;
      }

      await trx
        .update(inventoryBalances)
        .set({ qtyOnHand: newQty, updatedAt: new Date() })
        .where(eq(inventoryBalances.id, balanceRow.id));
    } else {
      newQty = qty;

      if (newQty < 0) {
        const err = new Error("Insufficient stock");
        err.code = "INSUFFICIENT_STOCK";
        throw err;
      }

      await trx.insert(inventoryBalances).values({
        locationId,
        productId,
        qtyOnHand: newQty,
        updatedAt: new Date(),
      });
    }

    const productLabel =
      productRows[0].displayName ||
      buildDisplayName({
        name: productRows[0].name,
        brand: productRows[0].brand,
        model: productRows[0].model,
        size: productRows[0].size,
        color: productRows[0].color,
        material: productRows[0].material,
        variantSummary: productRows[0].variantSummary,
        attributes: productRows[0].attributes,
      }) ||
      productRows[0].name;

    await safeLogAudit({
      userId: userId ?? null,
      action: "INVENTORY_ADJUST",
      entity: "product",
      entityId: productId,
      description: `Product ${productLabel}: qtyChange=${qty}. Reason: ${reason || "-"}`,
      meta: {
        productId,
        qtyChange: qty,
        reason: reason || null,
        locationId,
      },
      locationId,
    });

    return { productId, qtyOnHand: newQty };
  };

  if (tx) return run(tx);
  return db.transaction(async (trx) => run(trx));
}

async function archiveProduct({ locationId, userId, productId, reason }) {
  const cleanReason = cleanText(reason, 200);

  return db.transaction(async (tx) => {
    const found = await tx
      .select({
        id: products.id,
        name: products.name,
        displayName: products.displayName,
        brand: products.brand,
        model: products.model,
        size: products.size,
        color: products.color,
        material: products.material,
        variantSummary: products.variantSummary,
        attributes: products.attributes,
        isActive: products.isActive,
        notes: products.notes,
      })
      .from(products)
      .where(
        and(eq(products.id, productId), eq(products.locationId, locationId)),
      );

    if (!found[0]) {
      const err = new Error("Product not found");
      err.code = "NOT_FOUND";
      throw err;
    }

    if (found[0].isActive === false) {
      return mapProductRow(found[0], true);
    }

    const nextNotes = cleanReason
      ? `${String(found[0].notes || "").trim()}\n[ARCHIVED] ${cleanReason}`.trim()
      : found[0].notes;

    const [updated] = await tx
      .update(products)
      .set({
        isActive: false,
        notes: nextNotes,
        updatedAt: new Date(),
      })
      .where(
        and(eq(products.id, productId), eq(products.locationId, locationId)),
      )
      .returning();

    const productLabel =
      found[0].displayName ||
      buildDisplayName({
        name: found[0].name,
        brand: found[0].brand,
        model: found[0].model,
        size: found[0].size,
        color: found[0].color,
        material: found[0].material,
        variantSummary: found[0].variantSummary,
        attributes: found[0].attributes,
      }) ||
      found[0].name;

    await safeLogAudit({
      userId,
      action: "PRODUCT_ARCHIVE",
      entity: "product",
      entityId: productId,
      description: `Archived product: ${productLabel}`,
      meta: { productId, reason: cleanReason, locationId },
      locationId,
    });

    return mapProductRow(updated, true);
  });
}

async function restoreProduct({ locationId, userId, productId }) {
  return db.transaction(async (tx) => {
    const found = await tx
      .select({
        id: products.id,
        name: products.name,
        displayName: products.displayName,
        brand: products.brand,
        model: products.model,
        size: products.size,
        color: products.color,
        material: products.material,
        variantSummary: products.variantSummary,
        attributes: products.attributes,
        isActive: products.isActive,
      })
      .from(products)
      .where(
        and(eq(products.id, productId), eq(products.locationId, locationId)),
      );

    if (!found[0]) {
      const err = new Error("Product not found");
      err.code = "NOT_FOUND";
      throw err;
    }

    if (found[0].isActive === true) {
      return mapProductRow(found[0], true);
    }

    const [updated] = await tx
      .update(products)
      .set({ isActive: true, updatedAt: new Date() })
      .where(
        and(eq(products.id, productId), eq(products.locationId, locationId)),
      )
      .returning();

    const productLabel =
      found[0].displayName ||
      buildDisplayName({
        name: found[0].name,
        brand: found[0].brand,
        model: found[0].model,
        size: found[0].size,
        color: found[0].color,
        material: found[0].material,
        variantSummary: found[0].variantSummary,
        attributes: found[0].attributes,
      }) ||
      found[0].name;

    await safeLogAudit({
      userId,
      action: "PRODUCT_RESTORE",
      entity: "product",
      entityId: productId,
      description: `Restored product: ${productLabel}`,
      meta: { productId, locationId },
      locationId,
    });

    return mapProductRow(updated, true);
  });
}

async function deleteProductIfSafe({ locationId, userId, productId }) {
  return db.transaction(async (tx) => {
    const found = await tx
      .select({
        id: products.id,
        name: products.name,
        displayName: products.displayName,
      })
      .from(products)
      .where(
        and(eq(products.id, productId), eq(products.locationId, locationId)),
      );

    if (!found[0]) {
      const err = new Error("Product not found");
      err.code = "NOT_FOUND";
      throw err;
    }

    const [balance] = await tx
      .select({ qtyOnHand: inventoryBalances.qtyOnHand })
      .from(inventoryBalances)
      .where(
        and(
          eq(inventoryBalances.locationId, locationId),
          eq(inventoryBalances.productId, productId),
        ),
      );

    const qty = Number(balance?.qtyOnHand ?? 0);
    if (qty !== 0) {
      const err = new Error("Cannot delete: stock is not zero");
      err.code = "STOCK_NOT_ZERO";
      throw err;
    }

    await tx
      .delete(inventoryBalances)
      .where(
        and(
          eq(inventoryBalances.locationId, locationId),
          eq(inventoryBalances.productId, productId),
        ),
      );

    await tx
      .delete(products)
      .where(
        and(eq(products.id, productId), eq(products.locationId, locationId)),
      );

    await safeLogAudit({
      userId,
      action: "PRODUCT_DELETE",
      entity: "product",
      entityId: productId,
      description: `Deleted product: ${found[0].displayName || found[0].name}`,
      meta: { productId, locationId },
      locationId,
    });

    return { success: true };
  });
}

module.exports = {
  createProduct,
  listProducts,
  updateProductPricing,
  getInventoryBalances,
  adjustInventory,
  archiveProduct,
  restoreProduct,
  deleteProductIfSafe,
};

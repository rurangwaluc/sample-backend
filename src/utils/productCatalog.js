"use strict";

const PRODUCT_TYPES = ["PP_BAG"];

const SYSTEM_CATEGORIES = [
  "WOVEN_PP_BAG",
  "LAMINATED_PP_BAG",
  "BOPP_LAMINATED_BAG",
  "LINER_PP_BAG",
  "VALVE_PP_BAG",
  "GUSSETED_PP_BAG",
  "VENTILATED_PP_BAG",
  "MESH_PP_BAG",
  "FIBC_JUMBO_BAG",
  "OTHER_PP_BAG",
];

const PRODUCT_UNITS = [
  "BAG",
  "BALE",
  "PIECE",
  "BUNDLE",
  "PACK",
  "DOZEN",
  "CARTON",
  "ROLL",
  "KILOGRAM",
];

function cleanText(value, max = 255) {
  if (value == null) return null;
  const s = String(value).trim();
  if (!s) return null;
  return s.slice(0, max);
}

function normalizeProductType(value) {
  const v = String(value || "")
    .trim()
    .toUpperCase();

  if (!v) return "PP_BAG";
  return PRODUCT_TYPES.includes(v) ? v : "PP_BAG";
}

function normalizeSystemCategory(value) {
  const v = String(value || "")
    .trim()
    .toUpperCase();

  if (!v) return "WOVEN_PP_BAG";
  return SYSTEM_CATEGORIES.includes(v) ? v : "OTHER_PP_BAG";
}

function normalizeUnit(value) {
  const v = String(value || "")
    .trim()
    .toUpperCase();

  if (!v) return "BAG";
  return PRODUCT_UNITS.includes(v) ? v : "BAG";
}

function normalizePositiveInt(value, fallback = 0) {
  const n = Number(value);
  if (!Number.isFinite(n)) return fallback;
  if (n < 0) return fallback;
  return Math.trunc(n);
}

function normalizePositiveNumber(value, fallback = null) {
  if (value === undefined || value === null || value === "") return fallback;
  const n = Number(value);
  if (!Number.isFinite(n) || n < 0) return fallback;
  return n;
}

function normalizeAttributes(value) {
  if (value == null || typeof value !== "object" || Array.isArray(value)) {
    return null;
  }

  const out = {
    bagType: cleanText(value.bagType, 80),
    capacityKg: normalizePositiveNumber(value.capacityKg, null),
    widthCm: normalizePositiveNumber(value.widthCm, null),
    lengthCm: normalizePositiveNumber(value.lengthCm, null),
    gsm: normalizePositiveNumber(value.gsm, null),
    topStyle: cleanText(value.topStyle, 40),
    bottomStyle: cleanText(value.bottomStyle, 40),
    liner: value.liner == null ? null : value.liner === true,
    laminated: value.laminated == null ? null : value.laminated === true,
    printed: value.printed == null ? null : value.printed === true,
    printColors: normalizePositiveInt(value.printColors, 0),
    foodGrade: value.foodGrade == null ? null : value.foodGrade === true,
    uvTreated: value.uvTreated == null ? null : value.uvTreated === true,
    mesh: value.mesh == null ? null : value.mesh === true,
    notes: cleanText(value.notes, 500),
  };

  const cleaned = Object.fromEntries(
    Object.entries(out).filter(([, entryValue]) => entryValue !== null),
  );

  return Object.keys(cleaned).length ? cleaned : null;
}

function buildDisplayName(data = {}) {
  const capacityLabel =
    data?.attributes?.capacityKg != null
      ? `${data.attributes.capacityKg}kg`
      : null;

  const dimensionLabel =
    data?.attributes?.widthCm != null && data?.attributes?.lengthCm != null
      ? `${data.attributes.widthCm}x${data.attributes.lengthCm}cm`
      : null;

  const gsmLabel =
    data?.attributes?.gsm != null ? `${data.attributes.gsm}gsm` : null;

  const parts = [
    cleanText(data.name, 180),
    cleanText(data.brand, 80),
    cleanText(data.model, 80),
    cleanText(data.size, 40),
    cleanText(data.color, 40),
    cleanText(data.material, 80),
    cleanText(data.variantSummary, 200),
    capacityLabel,
    dimensionLabel,
    gsmLabel,
  ].filter(Boolean);

  return parts.join(" ").trim() || null;
}

module.exports = {
  PRODUCT_TYPES,
  SYSTEM_CATEGORIES,
  PRODUCT_UNITS,
  cleanText,
  normalizeProductType,
  normalizeSystemCategory,
  normalizeUnit,
  normalizePositiveInt,
  normalizePositiveNumber,
  normalizeAttributes,
  buildDisplayName,
};

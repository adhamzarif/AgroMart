// cropSynonyms.js — bilingual synonym groups for Marketplace search.
//
// Why this file exists: the `crops` table has a single `crop_name` column
// (see migrations/003_marketplace.sql) — there is no separate crop_name_en /
// crop_name_bn column in the schema. Farmers mostly list crops in Bangla
// (see seed_crops.sql: "লাউ", "বেগুন", "আলু" ...). So a plain substring match
// on crop_name can't find "মরিচ" when the buyer types "chili" in English.
//
// This file is a small, additive lookup table (not a DB/schema change) that
// lets the Marketplace search box accept either language: typing "mango"
// still matches a crop stored as "আম", and vice versa.
//
// Add more rows here as new crop types are listed — no code changes needed
// elsewhere, Marketplace.jsx just imports and uses this list.
export const CROP_SYNONYMS = [
  ['rice', 'ধান', 'চাল'],
  ['paddy', 'ধান'],
  ['wheat', 'গম'],
  ['potato', 'আলু'],
  ['tomato', 'টমেটো'],
  ['onion', 'পেঁয়াজ'],
  ['garlic', 'রসুন'],
  ['ginger', 'আদা'],
  ['eggplant', 'brinjal', 'বেগুন'],
  ['chili', 'chilli', 'pepper', 'মরিচ', 'কাঁচামরিচ'],
  ['mango', 'আম'],
  ['banana', 'কলা'],
  ['jackfruit', 'কাঁঠাল'],
  ['papaya', 'পেঁপে'],
  ['guava', 'পেয়ারা'],
  ['lychee', 'litchi', 'লিচু'],
  ['watermelon', 'তরমুজ'],
  ['pineapple', 'আনারস'],
  ['orange', 'কমলা'],
  ['lemon', 'lime', 'লেবু'],
  ['cauliflower', 'ফুলকপি'],
  ['cabbage', 'বাঁধাকপি'],
  ['pumpkin', 'কুমড়া'],
  ['bottle gourd', 'lau', 'লাউ'],
  ['cucumber', 'শসা'],
  ['okra', 'ladyfinger', 'ঢেঁড়স'],
  ['carrot', 'গাজর'],
  ['spinach', 'পালং শাক', 'পালংশাক'],
  ['bean', 'beans', 'শিম'],
  ['mustard', 'সরিষা'],
  ['lentil', 'lentils', 'dal', 'daal', 'ডাল', 'মসুর ডাল'],
  ['mung bean', 'moong', 'মুগ ডাল'],
  ['jute', 'পাট'],
  ['sugarcane', 'আখ'],
  ['turmeric', 'হলুদ'],
  ['coriander', 'ধনিয়া', 'ধনেপাতা'],
  ['betel leaf', 'পান'],
  ['corn', 'maize', 'ভুট্টা'],
  ['coconut', 'নারিকেল', 'নারকেল'],
  ['radish', 'মুলা'],
];

/**
 * Given a raw search string, return the set of lowercase terms (including
 * itself) that should be checked against a crop's name — the query plus any
 * synonym-group members it partially matches.
 */
export function expandSearchTerms(rawQuery) {
  const q = rawQuery.trim().toLowerCase();
  if (!q) return [];

  const terms = new Set([q]);

  for (const group of CROP_SYNONYMS) {
    const lower = group.map((s) => s.toLowerCase());
    const groupMatches = lower.some((term) => term.includes(q) || q.includes(term));
    if (groupMatches) {
      lower.forEach((term) => terms.add(term));
    }
  }

  return Array.from(terms);
}
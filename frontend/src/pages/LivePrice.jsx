// LivePrice.jsx — role-aware Buyer/Farmer view.
// Guest → buyer view (safe default, no toggle).
// Buyer → buyer view only, toggle hidden.
// Farmer → farmer view only, toggle hidden.
// Admin → sees toggle, can switch.
import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";
import { getPrices, getPricesFallback } from "../api/prices.api.js";
import { useLang as useLangSafe } from "../context/LangContext.jsx";



const toBnNum = (num) => {
  const bnDigits = ["০","১","২","৩","৪","৫","৬","৭","৮","৯"];
  return String(num).replace(/\d/g, (d) => bnDigits[d]);
};

const CROP_EN = {
  "লাউ": "Bottle Gourd", "বেগুন": "Eggplant", "কাঁচামরিচ": "Green Chili",
  "আলু": "Potato", "টমেটো": "Tomato", "পেঁয়াজ": "Onion",
  "সরিষা": "Mustard", "মুগ ডাল": "Mung Dal", "মসুর ডাল": "Masoor Dal",
};
const CAT_BY_BN = {
  "সবজি": "lp_vegetables", "শাকসবজি": "lp_vegetables",
  "দানাশস্য": "lp_grains", "শস্য": "lp_grains", "ডাল": "lp_grains",
  "মসলা": "lp_spices", "ফল": "lp_fruits",
};

const STR = {
  en: {
    title: "Live Market Prices", subtitle: "Real-time Updates", searchPlaceholder: "Search crop...",
    all: "All Categories", vegetables: "Vegetables", grains: "Grains", spices: "Spices", fruits: "Fruits",
    buyerView: "Buyer View", farmerView: "Farmer View",
    agroPrice: "AGROMART PRICE", marketRate: "MARKET RATE", othersCharge: "Others charge",
    orderNow: "Order now →", listThis: "List this crop →", perUnit: "/kg",
    savings: "Savings", loading: "Loading prices...", empty: "No prices available. Please try again later.",
    todaysGuide: "Today's Market Guide", buyerBenefits: "Buyer Benefits",
  },
  bn: {
    title: "লাইভ বাজার মূল্য", subtitle: "রিয়েল-টাইম আপডেট", searchPlaceholder: "ফসল খুঁজুন...",
    all: "সব ক্যাটাগরি", vegetables: "সবজি", grains: "দানাশস্য", spices: "মসলা", fruits: "ফল",
    buyerView: "ক্রেতা দৃশ্য", farmerView: "কৃষক দৃশ্য",
    agroPrice: "এগ্রোমার্ট মূল্য", marketRate: "বাজার দর", othersCharge: "অন্যরা নেয়",
    orderNow: "অর্ডার করুন →", listThis: "তালিকাভুক্ত করুন →", perUnit: "/কেজি",
    savings: "সাশ্রয়", loading: "মূল্য লোড হচ্ছে...", empty: "কোনো মূল্য পাওয়া যায়নি।",
    todaysGuide: "আজকের বাজার গাইড", buyerBenefits: "ক্রেতা সুবিধা",
  },
};

const LivePrice = () => {
  const nav = useNavigate();
  const { user } = useAuth();
  const roles = user?.roles || [];
  const isBuyer = roles.includes("buyer");
  const isFarmer = roles.includes("farmer");
  const isAdmin = roles.includes("admin");

  // determine initial + only view for this user
  const forcedView = isFarmer && !isAdmin ? "farmer"
                   : isBuyer && !isAdmin ? "buyer"
                   : null; // guest or admin → toggle allowed
  const [userRole, setUserRole] = useState(forcedView || "buyer");
  const showToggle = forcedView === null; // guest OR admin sees toggle

  // Re-sync if user logs in mid-session
  useEffect(() => {
    if (forcedView) setUserRole(forcedView);
  }, [forcedView]);

  const [searchQuery, setSearchQuery] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("all");
  const [prices, setPrices] = useState([]);
  const [loading, setLoading] = useState(true);

  const { lang } = useLangSafe();
  const s = STR[lang] || STR.en;
  const fmt = (n) => (lang === "bn" ? toBnNum(n) : String(n));

  const enName = (row) => CROP_EN[row?.crop_name] || row?.crop_name || "";
  const displayName = (row) => (lang === "bn" ? row.crop_name : (enName(row) || row.crop_name));
  const displayCat = (row) => {
    const key = CAT_BY_BN[row.category_name];
    if (!key) return row.category_name;
    if (key === "lp_vegetables") return s.vegetables;
    if (key === "lp_grains") return s.grains;
    if (key === "lp_spices") return s.spices;
    if (key === "lp_fruits") return s.fruits;
    return row.category_name;
  };

  useEffect(() => {
    let alive = true;
    (async () => {
      try {
        const data = await getPrices({ role: userRole });
        if (!alive) return;
        if (data?.prices?.length) setPrices(data.prices);
        else setPrices(getPricesFallback(userRole));
      } catch (err) {
        console.warn("prices load failed:", err);
        if (alive) setPrices(getPricesFallback(userRole));
      } finally {
        if (alive) setLoading(false);
      }
    })();
    return () => { alive = false; };
  }, [userRole]);

  const inCat = (row) => {
    if (selectedCategory === "all") return true;
    const key = CAT_BY_BN[row.category_name];
    return key === selectedCategory;
  };
  const matches = (row) => {
    if (!searchQuery.trim()) return true;
    const q = searchQuery.trim().toLowerCase();
    return (row.crop_name || "").toLowerCase().includes(q) || (enName(row) || "").toLowerCase().includes(q);
  };
  const displayed = prices.filter((r) => inCat(r) && matches(r));

  return (
    <div className="livePricePage">
      <div style={{
        background: "linear-gradient(135deg, #2E7D32 0%, #1B5E20 100%)",
        color: "white", padding: "50px 20px 90px", textAlign: "center",
      }}>
        <div style={{
          display: "inline-block", background: "rgba(255,255,255,0.15)",
          padding: "6px 16px", borderRadius: 20, fontSize: 13, marginBottom: 12,
        }}>● {s.subtitle}</div>
        <h1 style={{ fontSize: 34, fontWeight: 800, margin: 0 }}>{s.title}</h1>
        {showToggle && (
          <div style={{
            marginTop: 20, background: "rgba(0,0,0,0.2)",
            display: "inline-flex", padding: 4, borderRadius: 30,
          }}>
            <button
              onClick={() => setUserRole("buyer")}
              style={{
                border: "none", padding: "8px 20px", borderRadius: 20, cursor: "pointer",
                background: userRole === "buyer" ? "white" : "transparent",
                color: userRole === "buyer" ? "#2E7D32" : "white", fontWeight: 600,
              }}
            >{s.buyerView}</button>
            <button
              onClick={() => setUserRole("farmer")}
              style={{
                border: "none", padding: "8px 20px", borderRadius: 20, cursor: "pointer",
                background: userRole === "farmer" ? "white" : "transparent",
                color: userRole === "farmer" ? "#2E7D32" : "white", fontWeight: 600,
              }}
            >{s.farmerView}</button>
          </div>
        )}
        {!showToggle && (
          <div style={{
            marginTop: 16, display: "inline-block", background: "rgba(255,255,255,0.15)",
            padding: "6px 20px", borderRadius: 20, fontSize: 14,
          }}>
            {userRole === "buyer" ? s.buyerBenefits : s.todaysGuide}
          </div>
        )}
      </div>

      <div style={{
        maxWidth: 900, margin: "-40px auto 20px", background: "white",
        padding: 20, borderRadius: 16, boxShadow: "0 4px 20px rgba(0,0,0,0.08)",
        display: "flex", gap: 12, flexWrap: "wrap", alignItems: "center", position: "relative", zIndex: 5,
      }}>
        <input
          type="text" placeholder={s.searchPlaceholder} value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          style={{ flex: 1, minWidth: 180, padding: 10, border: "1px solid #ddd", borderRadius: 8 }}
        />
        <select
          value={selectedCategory}
          onChange={(e) => setSelectedCategory(e.target.value)}
          style={{ padding: 10, border: "1px solid #ddd", borderRadius: 8, minWidth: 140 }}
        >
          <option value="all">{s.all}</option>
          <option value="lp_vegetables">{s.vegetables}</option>
          <option value="lp_grains">{s.grains}</option>
          <option value="lp_spices">{s.spices}</option>
          <option value="lp_fruits">{s.fruits}</option>
        </select>
      </div>

      {loading && (
        <div style={{ maxWidth: 900, margin: "20px auto", textAlign: "center", padding: 40, color: "#666" }}>
          {s.loading}
        </div>
      )}

      {!loading && displayed.length === 0 && (
        <div style={{ maxWidth: 900, margin: "20px auto", textAlign: "center", padding: 40, color: "#666" }}>
          {s.empty}
        </div>
      )}

      {!loading && displayed.length > 0 && (
        <div style={{
          maxWidth: 900, margin: "20px auto", display: "grid",
          gridTemplateColumns: "repeat(auto-fill, minmax(240px, 1fr))", gap: 16, padding: "0 20px",
        }}>
          {displayed.map((row, i) => {
            const bazar = Number(row.bazar_rate || row.market_price || 0);
            const agro = Number(row.agromart_price || 0);
            const trend = row.trend || "flat";
            const trendPct = Number(row.trend_percent || 0);
            const savings = userRole === "buyer" ? Math.max(0, bazar - agro) : 0;
            const trendColor = trend === "up" ? "#d32f2f" : trend === "down" ? "#2e7d32" : "#757575";
            const trendArrow = trend === "up" ? "↑" : trend === "down" ? "↓" : "→";
            return (
              <div key={i} style={{
                background: "white", borderRadius: 12, boxShadow: "0 2px 8px rgba(0,0,0,0.06)",
                overflow: "hidden", display: "flex", flexDirection: "column",
              }}>
                <div style={{ position: "relative", height: 130, background: "#f6f6f6" }}>
                  {row.image && <img src={row.image} alt="" style={{ width: "100%", height: "100%", objectFit: "cover" }} />}
                  <div style={{
                    position: "absolute", top: 8, right: 8, background: "white",
                    color: trendColor, padding: "3px 8px", borderRadius: 20,
                    fontWeight: 700, fontSize: 12,
                  }}>
                    {trendArrow} {fmt(Math.abs(trendPct).toFixed(1))}%
                  </div>
                </div>
                <div style={{ padding: 12, flex: 1, display: "flex", flexDirection: "column" }}>
                  <div style={{ fontWeight: 700, fontSize: 16 }}>{displayName(row)}</div>
                  <div style={{ color: "#888", fontSize: 12, marginBottom: 8 }}>{displayCat(row)}</div>

                  {userRole === "buyer" ? (
                    <>
                      <div style={{ background: "#e8f5e9", color: "#1b5e20", fontSize: 11, fontWeight: 700, padding: "2px 6px", borderRadius: 4, display: "inline-block", width: "fit-content" }}>● {s.agroPrice}</div>
                      <div style={{ fontSize: 22, fontWeight: 800, color: "#2e7d32", marginTop: 2 }}>৳{fmt(agro)}{s.perUnit}</div>
                      <div style={{ color: "#888", fontSize: 12, textDecoration: "line-through" }}>{s.othersCharge} ৳{fmt(bazar)}</div>
                      {savings > 0 && (
                        <div style={{ marginTop: 6, background: "#fff8e1", padding: "3px 8px", borderRadius: 6, fontSize: 12, color: "#795548", fontWeight: 600, width: "fit-content" }}>
                          {s.savings}: ৳{fmt(savings)}
                        </div>
                      )}
                      <button
                        onClick={() => nav(`/marketplace`)}
                        style={{ marginTop: "auto", padding: "8px 12px", background: "#2e7d32", color: "white", border: "none", borderRadius: 8, cursor: "pointer", fontWeight: 700, fontSize: 13 }}
                      >{s.orderNow}</button>
                    </>
                  ) : (
                    <>
                      <div style={{ background: "#e3f2fd", color: "#0d47a1", fontSize: 11, fontWeight: 700, padding: "2px 6px", borderRadius: 4, display: "inline-block", width: "fit-content" }}>● {s.marketRate}</div>
                      <div style={{ fontSize: 22, fontWeight: 800, color: "#1a237e", marginTop: 2 }}>৳{fmt(bazar)}{s.perUnit}</div>
                      <div style={{ color: "#888", fontSize: 12 }}>{s.othersCharge} ৳{fmt(agro)}</div>
                      <button
                        onClick={() => nav(`/farmer/crops/new`)}
                        style={{ marginTop: "auto", padding: "8px 12px", background: "#1a237e", color: "white", border: "none", borderRadius: 8, cursor: "pointer", fontWeight: 700, fontSize: 13 }}
                      >{s.listThis}</button>
                    </>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};

export default LivePrice;

const express = require("express");
const app = express();
const { pool } = require("./db");

app.use(express.json());

// 動作確認用
app.get("/", (req, res) => {
  res.send("Pokemon SQL Game server is running!");
});

// ★SQLを受け取る入口（まずは受け取るだけ）
app.post("/game/execute", (req, res) => {
  const { sql } = req.body;

  console.log("受け取ったSQL:", sql);

  res.json({
    ok: true,
    message: "SQLを受け取りました",
    sql: sql,
  });
});

// ★判定API：SQLを実行して「正解結果」と比較する
function validateUserSql(sql) {
  const s = (sql ?? "").trim();
  if (!/^select\s/i.test(s)) return { ok: false, reason: "SELECT以外は禁止です" };
  if (s.includes(";")) return { ok: false, reason: "セミコロンは禁止（1文のみ）" };
  if (s.includes("--") || s.includes("/*") || s.includes("*/"))
    return { ok: false, reason: "コメントは禁止です" };

  const lower = s.toLowerCase();
  const banned = ["insert", "update", "delete", "drop", "alter", "create", "truncate", "grant", "revoke", "outfile"];
  if (banned.some(w => lower.includes(w))) return { ok: false, reason: "危険なSQLが含まれています" };

  return { ok: true };
}

function normalizeRows(rows) {
  return (rows ?? []).map(r => JSON.stringify(r)).sort();
}

function isSameResult(userRows, answerRows) {
  const a = normalizeRows(userRows);
  const b = normalizeRows(answerRows);
  if (a.length !== b.length) return false;
  for (let i = 0; i < a.length; i++) if (a[i] !== b[i]) return false;
  return true;
}

// まずは「問題1」をコードに直書き（後で challenges テーブルに移せばOK）
const CHALLENGES = {
  1: {
    title: "トキワの森：でんきショックを覚えるポケモン",
    answerSql:
      "SELECT p.name_ja " +
      "FROM encounter e " +
      "JOIN pokemon p ON p.id = e.pokemon_id " +
      "JOIN learn l ON l.pokemon_id = p.id " +
      "JOIN move m ON m.id = l.move_id " +
      "WHERE e.location_id = 1 AND m.name = 'でんきショック' " +
      "ORDER BY p.name_ja"
  }
};

app.post("/api/submit", async (req, res) => {
  const { challengeId, sql } = req.body ?? {};

  if (!challengeId || typeof sql !== "string") {
    return res.status(400).json({ ok: false, message: "challengeId と sql が必要です" });
  }

  const v = validateUserSql(sql);
  if (!v.ok) return res.status(400).json({ ok: false, message: v.reason });

  const ch = CHALLENGES[challengeId];
  if (!ch) return res.status(404).json({ ok: false, message: "問題が見つかりません" });

  try {
    // LIMITが無ければ強制（重いクエリ対策）
    const userSql = /limit\s+\d+/i.test(sql) ? sql : `${sql} LIMIT 200`;

    console.log("=== SUBMIT DEBUG ===");
    console.log("RAW SQL:", JSON.stringify(sql));
    console.log("EXEC SQL:", JSON.stringify(userSql));
    const [dbName] = await pool.query("SELECT DATABASE() AS db");
    console.log("DB:", dbName[0].db);

    const [userRows] = await pool.query(userSql);
    const [answerRows] = await pool.query(ch.answerSql);

    const correct = isSameResult(userRows, answerRows);

    return res.json({
      ok: true,
      correct,
      title: ch.title,
      userCount: userRows.length,
      answerCount: answerRows.length,
      // 開発中だけ返す（後で消してOK）
      userRows
    });
  } catch (err) {
    return res.status(400).json({ ok: false, message: "SQL実行エラー", error: String(err.message ?? err) });
  }
});


// MySQL 接続テスト
(async () => {
  try {
    const [rows] = await pool.query("SELECT 1 AS ok");
    console.log("✅ DB接続OK:", rows[0]);
  } catch (e) {
    console.log("❌ DB接続NG:", e.message);
  }
})();

// サーバ起動
app.listen(3000, () => {
  console.log("Server started: http://localhost:3000");
});

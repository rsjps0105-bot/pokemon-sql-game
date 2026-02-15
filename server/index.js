const express = require("express");
const app = express();
const { pool } = require("./db");
const { isSameByMode } = require("./judge");
const path = require("path");

app.use(express.json());
app.use(express.static(path.join(__dirname, "../client")));

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


app.get("/api/challenges", async (req, res) => {
  try {
    const [rows] = await pool.query(
      "SELECT id, level, title, description, judge_mode FROM challenges WHERE is_active = 1 ORDER BY level, id"
    );
    res.json({ ok: true, challenges: rows });
  } catch (err) {
    res.status(500).json({ ok: false, message: "取得エラー", error: String(err.message ?? err) });
  }
});

// SQL提出＆判定API
app.post("/api/submit", async (req, res) => {
  const { challengeId, sql } = req.body ?? {};

  if (!challengeId || typeof sql !== "string") {
    return res.status(400).json({ ok: false, message: "challengeId と sql が必要です" });
  }

  const v = validateUserSql(sql);
  if (!v.ok) return res.status(400).json({ ok: false, message: v.reason });

  try {
    // ★問題をDBから取得（answer_sqlはAPIで返さない/ここでだけ使う）
    const [chs] = await pool.query(
      "SELECT id, title, answer_sql, judge_mode, location_id FROM challenges WHERE id = ? AND is_active = 1",
      [challengeId]
    );

    if (chs.length === 0) {
      return res.status(404).json({ ok: false, message: "問題が見つかりません" });
    }

    const ch = chs[0];

    // LIMITが無ければ強制（重いクエリ対策）
    const userSql = /limit\s+\d+/i.test(sql) ? sql : `${sql} LIMIT 200`;

    const [userRows] = await pool.query(userSql);
    const [answerRows] = await pool.query(ch.answer_sql);

    const correct = isSameByMode(userRows, answerRows, ch.judge_mode);

    let stageClearCount = 0;
    let requiredClearCount = 0;
    let stageCleared = false;

    if (correct) {
      const userId = 1;

      // クリア記録（重複は無視）
      await pool.query(
        "INSERT IGNORE INTO challenge_clears (user_id, challenge_id) VALUES (?, ?)",
        [userId, challengeId]
      );

      // このステージで何問クリアしたか
      const [rows] = await pool.query(
        `SELECT COUNT(*) AS cnt
     FROM challenge_clears cc
     JOIN challenges c ON c.id = cc.challenge_id
     WHERE cc.user_id = ?
       AND c.location_id = ?`,
        [userId, ch.location_id]
      );

      stageClearCount = rows[0].cnt;

      // このステージの必要クリア数
      const [locRows] = await pool.query(
        "SELECT required_clear_count FROM location WHERE id = ?",
        [ch.location_id]
      );

      requiredClearCount = locRows[0].required_clear_count;

      stageCleared = stageClearCount >= requiredClearCount;
    }

    return res.json({
      ok: true,
      correct,
      title: ch.title,
      judgeMode: ch.judge_mode,
      userCount: userRows.length,
      answerCount: answerRows.length,
      stageClearCount: correct ? stageClearCount : null,
      requiredClearCount: correct ? requiredClearCount : null,
      stageCleared: correct ? stageCleared : null,
      userRows
    });


  } catch (err) {
    return res.status(400).json({
      ok: false,
      message: "SQL実行エラー",
      error: String(err.message ?? err),
    });
  }
});

// ロケーション一覧取得API（解放判定付き）
app.get("/api/locations", async (req, res) => {
  try {
    const userId = 1;

    // 全location取得
    const [locs] = await pool.query(
      "SELECT id, name, description, unlock_after_location_id, required_clear_count, display_order FROM location WHERE is_active = 1 ORDER BY display_order"
    );

    // 各locationのクリア数（そのlocationの問題を何問クリアしたか）
    const [clearRows] = await pool.query(
      `SELECT c.location_id, COUNT(*) AS cnt
       FROM challenge_clears cc
       JOIN challenges c ON c.id = cc.challenge_id
       WHERE cc.user_id = ?
       GROUP BY c.location_id`,
      [userId]
    );

    const clearsByLocation = new Map(clearRows.map(r => [r.location_id, r.cnt]));

    // 解放判定
    const locations = locs.map(l => {
      const clearedCount = clearsByLocation.get(l.id) ?? 0;

      // unlock_after_location_id が null の場所は常に解放
      // それ以外は「前の場所が required_clear_count を満たしているか」で解放
      let isUnlocked = false;
      if (l.unlock_after_location_id == null) {
        isUnlocked = true;
      } else {
        // 前の場所のクリア数を取得して必要数と比較
        const prevCleared = clearsByLocation.get(l.unlock_after_location_id) ?? 0;
        // 前の場所の required_clear_count を取る必要があるので locs から探す
        const prev = locs.find(x => x.id === l.unlock_after_location_id);
        const prevRequired = prev?.required_clear_count ?? 1;
        isUnlocked = prevCleared >= prevRequired;
      }

      return {
        id: l.id,
        name: l.name,
        description: l.description,
        requiredClearCount: l.required_clear_count,
        clearedCount,
        isUnlocked,
        displayOrder: l.display_order
      };
    });

    res.json({ ok: true, locations });
  } catch (err) {
    res.status(500).json({ ok: false, message: "取得エラー", error: String(err.message ?? err) });
  }
});

// 指定ロケーションの問題一覧取得API
app.get("/api/locations/:locationId/challenges", async (req, res) => {
  try {
    const locationId = Number(req.params.locationId);
    if (!Number.isInteger(locationId)) {
      return res.status(400).json({ ok: false, message: "locationId が不正です" });
    }

    const userId = 1;

    const [rows] = await pool.query(
      `SELECT c.id, c.level, c.title, c.description, c.judge_mode,
              CASE WHEN cc.challenge_id IS NULL THEN 0 ELSE 1 END AS cleared
       FROM challenges c
       LEFT JOIN challenge_clears cc
         ON cc.challenge_id = c.id AND cc.user_id = ?
       WHERE c.is_active = 1 AND c.location_id = ?
       ORDER BY cleared ASC, c.level, c.id`,
      [userId, locationId]
    );

    res.json({ ok: true, challenges: rows });
  } catch (err) {
    res.status(500).json({ ok: false, message: "取得エラー", error: String(err.message ?? err) });
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

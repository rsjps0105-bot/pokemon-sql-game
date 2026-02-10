import mysql from "mysql2/promise";

const API = "https://pokeapi.co/api/v2";

require("dotenv").config();

const DB = {
  host: process.env.DB_HOST || "localhost",
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "",
  database: process.env.DB_NAME || "poke_sql_game",
  charset: process.env.DB_CHARSET || "utf8mb4",
};

module.exports = DB;

async function fetchJson(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`${res.status} ${res.statusText}: ${url}`);
  return res.json();
}

function getStat(stats, name) {
  return stats.find(s => s.stat.name === name)?.base_stat ?? 0;
}

function pickTypes(types) {
  const sorted = [...types].sort((a, b) => a.slot - b.slot);
  return {
    type1: sorted[0]?.type?.name ?? null,
    type2: sorted[1]?.type?.name ?? null,
  };
}

function pickJaName(species) {
  return species.names?.find(n => n.language.name === "ja")?.name ?? null;
}

async function fetchPokemonRow(id) {
  const p = await fetchJson(`${API}/pokemon/${id}`);
  const species = await fetchJson(p.species.url);

  const { type1, type2 } = pickTypes(p.types);

  return [
    p.id,
    p.name,
    pickJaName(species),
    type1,
    type2,
    p.height,
    p.weight,
    getStat(p.stats, "hp"),
    getStat(p.stats, "attack"),
    getStat(p.stats, "defense"),
    getStat(p.stats, "special-attack"),
    getStat(p.stats, "special-defense"),
    getStat(p.stats, "speed"),
  ];
}

async function main() {
  const conn = await mysql.createConnection(DB);
  await conn.beginTransaction();

  const sql = `
    INSERT INTO pokemon
      (id, name_en, name_ja, type1, type2, height, weight, hp, atk, def, spa, spd, spe)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      name_en=VALUES(name_en),
      name_ja=VALUES(name_ja),
      type1=VALUES(type1),
      type2=VALUES(type2),
      height=VALUES(height),
      weight=VALUES(weight),
      hp=VALUES(hp),
      atk=VALUES(atk),
      def=VALUES(def),
      spa=VALUES(spa),
      spd=VALUES(spd),
      spe=VALUES(spe)
  `;

  try {
    for (let id = 1; id <= 151; id++) {
      const row = await fetchPokemonRow(id);
      await conn.execute(sql, row);
      console.log(`Inserted ${id}: ${row[1]} / ${row[2] ?? "-"}`);
    }
    await conn.commit();
    console.log("✅ Done. Inserted 1..151 into pokemon.");
  } catch (e) {
    await conn.rollback();
    throw e;
  } finally {
    await conn.end();
  }
}

main().catch(console.error);
